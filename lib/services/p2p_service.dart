import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:hive/hive.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/network_security_service.dart';

class P2PService extends ChangeNotifier {
  static P2PService? _instance;
  static P2PService get instance => _instance ??= P2PService._();

  P2PService._();

  // Network components
  ServerSocket? _serverSocket;
  MDnsClient? _mdnsClient;

  // State management
  bool _isEnabled = false;
  bool _isDiscovering = false;
  ConnectionStatus _connectionStatus = ConnectionStatus.disconnected;
  NetworkInfo? _currentNetworkInfo;

  // User management
  P2PUser? _currentUser;
  final Map<String, P2PUser> _discoveredUsers = {};
  final Map<String, Socket> _connectedSockets = {};

  // File storage settings
  P2PFileStorageSettings? _fileStorageSettings;

  // Pairing management
  final List<PairingRequest> _pendingRequests = [];

  // Callback for new pairing requests (for auto-showing dialogs)
  Function(PairingRequest)? _onNewPairingRequest;

  // Data transfer management
  final Map<String, DataTransferTask> _activeTransfers = {};
  final Map<String, Isolate> _transferIsolates = {};
  final Map<String, ReceivePort> _transferPorts = {};

  // File receiving management
  final Map<String, List<Uint8List>> _incomingFileChunks = {};
  final Map<String, Map<String, dynamic>> _incomingFileMetadata = {};

  // Encryption
  late Encrypter _encrypter;
  late Key _encryptionKey;

  // Constants
  static const int _basePort = 8080;
  static const int _maxPort = 8090;
  static const String _serviceType = '_setpocket_p2p._tcp';
  static const int _chunkSize = 64 * 1024; // 64KB chunks
  static const Duration _discoveryInterval = Duration(seconds: 30);
  static const Duration _heartbeatInterval = Duration(seconds: 10);
  static const Duration _cleanupInterval =
      Duration(seconds: 10); // More frequent cleanup
  static const Duration _announcementInterval =
      Duration(seconds: 15); // Faster announcements
  static const Duration _offlineTimeout =
      Duration(seconds: 90); // Mark offline after 90s

  // Timers - Keep only essential ones
  Timer? _heartbeatTimer; // Keep for paired devices
  Timer? _cleanupTimer; // Keep for cleanup

  // Stream subscriptions
  StreamSubscription? _mdnsSubscription;

  // Broadcast socket for UDP announcements
  RawDatagramSocket? _broadcastSocket;

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isDiscovering => _isDiscovering;
  bool get isMdnsEnabled => _mdnsClient != null;
  String get discoveryMode => _mdnsClient == null
      ? 'Simplified (mDNS disabled)'
      : 'Full (mDNS enabled)';
  ConnectionStatus get connectionStatus => _connectionStatus;
  NetworkInfo? get currentNetworkInfo => _currentNetworkInfo;
  P2PUser? get currentUser => _currentUser;
  List<P2PUser> get discoveredUsers => _discoveredUsers.values.toList();
  List<P2PUser> get pairedUsers =>
      _discoveredUsers.values.where((u) => u.isPaired).toList();
  List<P2PUser> get connectedUsers =>
      _discoveredUsers.values.where((u) => u.isStored).toList();
  List<P2PUser> get unconnectedUsers =>
      _discoveredUsers.values.where((u) => !u.isStored).toList();
  P2PFileStorageSettings? get fileStorageSettings => _fileStorageSettings;
  List<PairingRequest> get pendingRequests =>
      List.unmodifiable(_pendingRequests);
  List<DataTransferTask> get activeTransfers =>
      _activeTransfers.values.toList();

  /// Last discovery time for UI to show refresh status
  DateTime? lastDiscoveryTime;

  /// Set callback for new pairing requests
  void setNewPairingRequestCallback(Function(PairingRequest)? callback) {
    _onNewPairingRequest = callback;
  }

  /// Initialize P2P service
  Future<void> initialize() async {
    try {
      // Initialize encryption
      _initializeEncryption();

      // Load saved data - simple approach like the old version
      await _loadSavedData();

      logInfo('P2P Service initialized');
    } catch (e) {
      logError('Failed to initialize P2P service: $e');
      rethrow;
    }
  }

  /// Start P2P networking
  Future<bool> startNetworking() async {
    try {
      if (_isEnabled) return true;

      // Check network security
      _currentNetworkInfo = await NetworkSecurityService.checkNetworkSecurity();

      // Log network info for debugging
      logInfo('Network Info: WiFi=${_currentNetworkInfo!.isWiFi}, '
          'Mobile=${_currentNetworkInfo!.isMobile}, '
          'SecurityType=${_currentNetworkInfo!.securityType}, '
          'IsSecure=${_currentNetworkInfo!.isSecure}');

      // Accept WiFi, Mobile, or Ethernet connections
      final hasValidConnection = _currentNetworkInfo!.isWiFi ||
          _currentNetworkInfo!.isMobile ||
          (_currentNetworkInfo!.securityType == 'ETHERNET');

      if (!hasValidConnection) {
        throw Exception('No suitable network connection available. '
            'WiFi: ${_currentNetworkInfo!.isWiFi}, '
            'Mobile: ${_currentNetworkInfo!.isMobile}, '
            'SecurityType: ${_currentNetworkInfo!.securityType}');
      }

      // Check permissions
      final hasPermissions = await NetworkSecurityService.checkPermissions();
      if (!hasPermissions) {
        throw Exception('Required permissions not granted');
      }

      // Create current user profile
      await _createCurrentUser(_currentNetworkInfo!);

      // Start server
      await _startServer();

      // Start mDNS discovery
      await _startDiscovery();

      // Start timers
      _startTimers();

      _isEnabled = true;
      _connectionStatus = ConnectionStatus.discovering;

      notifyListeners();
      logInfo('P2P networking started');
      return true;
    } catch (e) {
      logError('Failed to start P2P networking: $e');
      await stopNetworking();
      return false;
    }
  }

  /// Stop P2P networking
  Future<void> stopNetworking() async {
    try {
      _isEnabled = false;
      _isDiscovering = false;
      _connectionStatus = ConnectionStatus.disconnected;

      // Stop timers
      _stopTimers();

      // Cancel active transfers
      await _cancelAllTransfers();

      // Close connections
      await _closeAllConnections();

      // Stop server
      await _stopServer();

      // Stop discovery
      await _stopDiscovery();

      // Clear discovered users to ensure a clean state, as in the old logic
      _discoveredUsers.clear();

      // Clean up receiving data
      _incomingFileChunks.clear();
      _incomingFileMetadata.clear();

      notifyListeners();
      logInfo('P2P networking stopped');
    } catch (e) {
      logError('Error stopping P2P networking: $e');
    }
  }

  /// Send pairing request to user
  Future<bool> sendPairingRequest(
      P2PUser targetUser, bool saveConnection) async {
    try {
      if (_currentUser == null) return false;

      final request = PairingRequest(
        fromUserId: _currentUser!.id,
        fromUserName: _currentUser!.displayName,
        fromDeviceId: _currentUser!.deviceId,
        fromIpAddress: _currentUser!.ipAddress,
        fromPort: _currentUser!.port,
        wantsSaveConnection: saveConnection,
      );

      final message = P2PMessage(
        type: P2PMessageTypes.pairingRequest,
        fromUserId: _currentUser!.id,
        toUserId: targetUser.id,
        data: request.toJson(),
      );

      return await _sendMessage(targetUser, message);
    } catch (e) {
      logError('Failed to send pairing request: $e');
      return false;
    }
  }

  /// Respond to pairing request
  Future<bool> respondToPairingRequest(String requestId, bool accept,
      bool trustUser, bool saveConnection) async {
    try {
      final request = _pendingRequests.firstWhere((r) => r.id == requestId);

      if (accept) {
        // Create or update user
        final existingUser = _discoveredUsers[request.fromUserId];
        final user = existingUser ??
            P2PUser(
              id: request.fromUserId,
              displayName: request.fromUserName,
              deviceId: request.fromDeviceId,
              ipAddress: request.fromIpAddress,
              port: request.fromPort,
            );

        // Update pairing status
        user.isPaired = true;
        user.isTrusted = trustUser;
        user.autoConnect = saveConnection;
        user.pairedAt = DateTime.now();
        user.isStored = saveConnection; // Mark as stored if connection is saved

        _discoveredUsers[user.id] = user;
        await _saveUser(user);
      }

      // Send response
      final message = P2PMessage(
        type: P2PMessageTypes.pairingResponse,
        fromUserId: _currentUser!.id,
        toUserId: request.fromUserId,
        data: {
          'requestId': requestId,
          'accepted': accept,
          'trusted': trustUser,
          'saveConnection': saveConnection,
        },
      );

      final targetUser = _discoveredUsers[request.fromUserId];
      if (targetUser != null) {
        await _sendMessage(targetUser, message);
      }

      // Remove from pending list
      _pendingRequests.removeWhere((r) => r.id == requestId);

      // Remove from storage completely (don't save processed requests)
      try {
        final requestsBox =
            await Hive.openBox<PairingRequest>('pairing_requests');
        await requestsBox.delete(requestId);
        logInfo(
            'Completely removed processed pairing request from storage: $requestId');
      } catch (e) {
        logError('Failed to remove pairing request from storage: $e');
      }

      notifyListeners();
      logInfo(
          'Pairing request ${accept ? "accepted" : "rejected"}: $requestId');
      return true;
    } catch (e) {
      logError('Failed to respond to pairing request: $e');
      return false;
    }
  }

  /// Send file to paired user
  Future<bool> sendData(String filePath, P2PUser targetUser) async {
    try {
      if (!targetUser.isPaired) {
        throw Exception('User is not paired');
      }

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final fileSize = await file.length();
      final fileName = file.path.split('/').last;

      final task = DataTransferTask(
        fileName: fileName,
        filePath: filePath,
        fileSize: fileSize,
        targetUserId: targetUser.id,
        targetUserName: targetUser.displayName,
        isOutgoing: true,
      );

      _activeTransfers[task.id] = task;

      // Send data transfer request
      if (!targetUser.isTrusted) {
        final message = P2PMessage(
          type: P2PMessageTypes.dataTransferRequest,
          fromUserId: _currentUser!.id,
          toUserId: targetUser.id,
          data: {
            'taskId': task.id,
            'fileName': fileName,
            'fileSize': fileSize,
          },
        );

        task.status = DataTransferStatus.requesting;
        await _sendMessage(targetUser, message);
      } else {
        // Start transfer immediately for trusted users
        await _startDataTransfer(task, targetUser);
      }

      notifyListeners();
      return true;
    } catch (e) {
      logError('Failed to send file: $e');
      return false;
    }
  }

  /// Cancel data transfer
  Future<bool> cancelDataTransfer(String taskId) async {
    try {
      final task = _activeTransfers[taskId];
      if (task == null) return false;

      task.status = DataTransferStatus.cancelled;

      // Stop isolate if running
      final isolate = _transferIsolates[taskId];
      if (isolate != null) {
        isolate.kill();
        _transferIsolates.remove(taskId);
      }

      // Close port
      final port = _transferPorts[taskId];
      if (port != null) {
        port.close();
        _transferPorts.remove(taskId);
      }

      // Notify other user
      final targetUser = _discoveredUsers[task.targetUserId];
      if (targetUser != null) {
        final message = P2PMessage(
          type: P2PMessageTypes.dataTransferCancel,
          fromUserId: _currentUser!.id,
          toUserId: targetUser.id,
          data: {'taskId': taskId},
        );
        await _sendMessage(targetUser, message);
      }

      _activeTransfers.remove(taskId);
      notifyListeners();
      return true;
    } catch (e) {
      logError('Failed to cancel data transfer: $e');
      return false;
    }
  }

  // Private methods

  void _initializeEncryption() {
    // Generate or load encryption key
    final keyBytes = List.generate(32, (i) => Random.secure().nextInt(256));
    _encryptionKey = Key(Uint8List.fromList(keyBytes));
    _encrypter = Encrypter(AES(_encryptionKey));
  }

  Future<void> _loadSavedData() async {
    try {
      // Load saved users - same as old logic, simple and direct
      final usersBox = await Hive.openBox<P2PUser>('p2p_users');
      for (final user in usersBox.values) {
        // Mark as stored since it's from cache, but keep discovery status simple
        user.isStored = true;
        user.isOnline = false; // Will be updated when discovered online
        user.lastSeen = DateTime.now().subtract(const Duration(minutes: 1));

        _discoveredUsers[user.id] = user;
        logInfo(
            'Loaded stored user: ${user.displayName} (${user.id}) - paired: ${user.isPaired}, trusted: ${user.isTrusted}');
      }

      // Load pending requests and clean up any processed ones
      final requestsBox =
          await Hive.openBox<PairingRequest>('pairing_requests');

      // Remove any processed requests from storage (cleanup)
      final processedRequestIds = <String>[];
      for (final request in requestsBox.values) {
        if (request.isProcessed) {
          processedRequestIds.add(request.id);
        } else {
          _pendingRequests.add(request);
        }
      }

      // Clean up processed requests from storage
      if (processedRequestIds.isNotEmpty) {
        for (final id in processedRequestIds) {
          await requestsBox.delete(id);
        }
        logInfo(
            'Cleaned up ${processedRequestIds.length} processed pairing requests from storage on startup');
      }

      // Load file storage settings
      final storageBox =
          await Hive.openBox<P2PFileStorageSettings>('p2p_storage_settings');
      if (storageBox.isNotEmpty) {
        _fileStorageSettings = storageBox.values.first;
      }

      logInfo(
          'Loaded ${_discoveredUsers.length} stored users and ${_pendingRequests.length} pending requests');
    } catch (e) {
      logError('Failed to load saved data: $e');
    }
  }

  Future<void> _createCurrentUser(NetworkInfo networkInfo) async {
    final deviceId = await NetworkSecurityService.getDeviceId();
    final deviceName = await NetworkSecurityService.getDeviceName();

    _currentUser = P2PUser(
      displayName: deviceName,
      deviceId: deviceId,
      ipAddress: networkInfo.ipAddress ?? '127.0.0.1',
      port: _basePort,
      isOnline: true,
    );
  }

  Future<void> _startServer() async {
    for (int port = _basePort; port <= _maxPort; port++) {
      try {
        _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
        _currentUser!.port = port;

        _serverSocket!.listen(_handleClientConnection);
        logInfo('P2P server started on port $port');
        return;
      } catch (e) {
        if (port == _maxPort) {
          throw Exception(
              'Failed to bind to any port in range $_basePort-$_maxPort');
        }
      }
    }
  }

  Future<void> _stopServer() async {
    await _serverSocket?.close();
    _serverSocket = null;
  }

  Future<void> _startDiscovery() async {
    if (_currentUser == null) {
      logError("Cannot start discovery: current user is null.");
      return;
    }

    try {
      // On Windows, we need special handling for mDNS to avoid socket binding issues
      if (Platform.isWindows) {
        await _startWindowsDiscovery();
      } else {
        await _startStandardDiscovery();
      }

      _isDiscovering = true;
      logInfo('mDNS discovery started. Looking for $_serviceType services.');

      // Send initial announcement when discovery starts
      await _sendInitialAnnouncement();
    } catch (e) {
      logError('Failed to start discovery: $e');
      rethrow;
    }
  }

  Future<void> _startWindowsDiscovery() async {
    try {
      // First, try the conservative mDNS approach
      _mdnsClient = MDnsClient(
        rawDatagramSocketFactory: (dynamic host, int port,
            {bool reuseAddress = true, bool reusePort = true, int ttl = 255}) {
          // Always use specific IP address on Windows instead of 'any'
          dynamic effectiveHost = host;

          if (host is InternetAddress) {
            if (host == InternetAddress.anyIPv4 ||
                host == InternetAddress.anyIPv6) {
              // Use the current user's IP address instead of 'any'
              effectiveHost = InternetAddress(_currentUser!.ipAddress);
              logInfo(
                  "Windows: Using specific IP ${_currentUser!.ipAddress} instead of 'any'");
            }
          }

          // Try alternative ports if standard mDNS port (5353) is occupied
          if (port == 5353) {
            return _bindWithPortFallback(effectiveHost, port, ttl);
          }

          // On Windows, disable problematic socket options
          return RawDatagramSocket.bind(
            effectiveHost,
            port,
            reuseAddress: false, // Disable to avoid conflicts
            reusePort: false, // Not supported on Windows
            ttl: ttl,
          );
        },
      );

      await _mdnsClient!.start();

      // Register our service so others can discover us
      await _registerService();

      logInfo('Windows: mDNS client started successfully');
    } catch (e) {
      logError('Windows: Failed to start mDNS client: $e');

      // Check if it's a port conflict issue
      final isPortConflict = e.toString().contains('10048') ||
          e.toString().contains('address already in use') ||
          e.toString().contains('normally permitted');

      if (isPortConflict) {
        logInfo(
            'Windows: mDNS port conflict detected (likely Windows mDNS service is running)');
      }

      // Fallback: Disable mDNS and use simple network discovery
      logInfo('Windows: Switching to simplified discovery mode');
      _mdnsClient = null;

      // Still announce our service via UDP broadcast even without mDNS
      await _announceServiceViaBroadcast();

      // Just log that we're running in simplified mode
      logInfo('Windows: Running in simplified P2P mode (mDNS disabled)');
    }
  }

  Future<RawDatagramSocket> _bindWithPortFallback(
      dynamic host, int originalPort, int ttl) async {
    // Try original port first
    try {
      return await RawDatagramSocket.bind(
        host,
        originalPort,
        reuseAddress: false,
        reusePort: false,
        ttl: ttl,
      );
    } catch (e) {
      logInfo(
          'Windows: Port $originalPort unavailable, trying alternatives...');

      // Try alternative ports for mDNS-like functionality
      final alternativePorts = [5354, 5355, 5356, 0]; // 0 = any available port

      for (final port in alternativePorts) {
        try {
          final socket = await RawDatagramSocket.bind(
            host,
            port,
            reuseAddress: false,
            reusePort: false,
            ttl: ttl,
          );
          logInfo(
              'Windows: Successfully bound to alternative port ${socket.port}');
          return socket;
        } catch (e) {
          if (port == alternativePorts.last) {
            rethrow; // Re-throw if this was the last attempt
          }
        }
      }

      throw Exception('Failed to bind to any alternative port');
    }
  }

  Future<void> _startStandardDiscovery() async {
    try {
      // Standard mDNS client for other platforms
      _mdnsClient = MDnsClient(
        rawDatagramSocketFactory: (dynamic host, int port,
            {bool reuseAddress = true, bool reusePort = true, int ttl = 255}) {
          // Disable reusePort on Android as it's not supported on some versions
          final useReusePort = Platform.isAndroid ? false : reusePort;

          return RawDatagramSocket.bind(host, port,
              reuseAddress: reuseAddress, reusePort: useReusePort, ttl: ttl);
        },
      );

      await _mdnsClient!.start();

      // Register our service so others can discover us
      await _registerService();

      logInfo('${Platform.operatingSystem}: mDNS client started successfully');
    } catch (e) {
      logError('${Platform.operatingSystem}: Failed to start mDNS client: $e');

      // Fallback: Use simplified mode similar to Windows
      logInfo(
          '${Platform.operatingSystem}: Switching to simplified discovery mode');
      _mdnsClient = null;

      // Still announce our service via UDP broadcast even without mDNS
      await _announceServiceViaBroadcast();

      logInfo(
          '${Platform.operatingSystem}: Running in simplified P2P mode (mDNS disabled)');
    }
  }

  Future<void> _registerService() async {
    if (_mdnsClient == null || _currentUser == null) {
      logWarning(
          'Cannot register service: mDNS client or current user is null');
      return;
    }

    try {
      // Create service instance name using device ID
      final instanceName = _currentUser!.id;
      final serviceName = '$instanceName.$_serviceType.local';

      logInfo(
          'Registering mDNS service: $serviceName on ${_currentUser!.ipAddress}:${_currentUser!.port}');

      // Note: The multicast_dns package doesn't directly support service registration
      // We need to manually advertise our service through mDNS responses
      // For now, we'll implement a simple UDP broadcast as alternative
      await _announceServiceViaBroadcast();
    } catch (e) {
      logError('Failed to register mDNS service: $e');
    }
  }

  Future<void> _announceServiceViaBroadcast() async {
    try {
      // Don't create multiple broadcast sockets
      if (_broadcastSocket != null) {
        return;
      }

      // Use UDP broadcast to announce our service as fallback to mDNS registration
      _broadcastSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _broadcastSocket!.broadcastEnabled = true;

      // Also listen for announcements from other devices
      _broadcastSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _broadcastSocket!.receive();
          if (datagram != null) {
            logInfo(
                'Received UDP packet from ${datagram.address}:${datagram.port}');
            try {
              final message = utf8.decode(datagram.data);
              final data = jsonDecode(message) as Map<String, dynamic>;
              logInfo('UDP packet content: ${data['type']}');

              if (data['type'] == 'setpocket_service_announcement' &&
                  data['userId'] != _currentUser!.id) {
                logInfo(
                    'Received UDP announcement from ${data['userId']} at ${data['ipAddress']}:${data['port']}');
                _handleDiscoveredUser(
                  name: data['userId'] as String,
                  ipAddress: data['ipAddress'] as String,
                  port: data['port'] as int,
                );

                // Update display name if available - same logic as old version
                final existingUser = _discoveredUsers[data['userId'] as String];
                final userName = data['userName'] as String?;
                if (existingUser != null &&
                    userName != null &&
                    userName.isNotEmpty &&
                    existingUser.displayName.startsWith('Device-') &&
                    !userName.startsWith('Device-')) {
                  existingUser.displayName = userName;
                  logInfo(
                      'Updated display name via UDP: ${data['userId']} -> $userName');
                }
              } else if (data['type'] == 'setpocket_service_announcement' &&
                  data['userId'] == _currentUser!.id) {
                logInfo('Received our own UDP announcement (loopback)');
              }
            } catch (e) {
              logWarning('Failed to parse UDP packet: $e');
            }
          }
        }
      });

      // Direct IP scanning will be triggered manually via manualDiscovery()

      logInfo('UDP broadcast announcement started on port 8082');
    } catch (e) {
      logError('Failed to start UDP broadcast announcement: $e');
    }
  }

  Future<void> _performDirectIPScan() async {
    if (_currentUser == null) return;

    try {
      // Get current IP to determine subnet
      final currentIP = _currentUser!.ipAddress;
      final ipParts = currentIP.split('.');

      if (ipParts.length != 4) return;

      // Use a Set to avoid duplicate subnets
      final subnets = <String>{
        '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}', // Same subnet as current IP
        '192.168.1', // Common home subnet
        '192.168.0', // Another common subnet
      };

      logInfo('Performing direct IP scan on subnets: ${subnets.join(", ")}');

      for (final subnet in subnets) {
        // Scan a few common IPs in each subnet
        final commonIPs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100, 101, 102, 254];

        for (final lastOctet in commonIPs) {
          final targetIP = '$subnet.$lastOctet';

          // Skip our own IP
          if (targetIP == currentIP) continue;

          // Try to connect to potential P2P service
          await _tryConnectToIP(targetIP);
        }
      }
    } catch (e) {
      logError('Error during direct IP scan: $e');
    }
  }

  Future<void> _tryConnectToIP(String ipAddress) async {
    try {
      // Try to connect to potential P2P service on port 8080
      final socket = await Socket.connect(ipAddress, _basePort,
          timeout: const Duration(seconds: 2));

      // Send a discovery message
      final discoveryMessage = P2PMessage(
        type: P2PMessageTypes.discovery,
        fromUserId: _currentUser!.id,
        toUserId: '', // Unknown target
        data: _currentUser!.toJson(),
      );

      // Frame the message correctly with a length prefix
      final messageBytes = utf8.encode(jsonEncode(discoveryMessage.toJson()));
      final lengthHeader = ByteData(4)
        ..setUint32(0, messageBytes.length, Endian.big);
      socket.add(lengthHeader.buffer.asUint8List());
      socket.add(messageBytes);
      await socket.flush();

      logInfo('Sent discovery message to $ipAddress:$_basePort');

      // Close the connection after sending
      await socket.close();
    } catch (e) {
      // Expected for most IPs - they won't have our service running
      // Only log if it's not a connection timeout/refused
      if (!e.toString().contains('refused') &&
          !e.toString().contains('timeout') &&
          !e.toString().contains('unreachable')) {
        logWarning('Unexpected error connecting to $ipAddress: $e');
      }
    }
  }

  void _handleDiscoveredUser({
    required String name,
    required String ipAddress,
    required int port,
  }) {
    final discoveredId = name.split('.').first;

    if (discoveredId == _currentUser?.id) {
      return; // It's me
    }

    // Find existing user by ID or IP address for robustness
    P2PUser? existingUser = _discoveredUsers[discoveredId];
    if (existingUser == null) {
      // Use a loop to find user by IP, as firstWhere doesn't support nullable returns without a package.
      for (final user in _discoveredUsers.values) {
        if (user.ipAddress == ipAddress) {
          existingUser = user;
          break;
        }
      }
    }

    if (existingUser != null) {
      // User already exists - update network info and mark online
      bool hasChanges = false;
      if (existingUser.ipAddress != ipAddress || existingUser.port != port) {
        existingUser.ipAddress = ipAddress;
        existingUser.port = port;
        hasChanges = true;
      }
      if (!existingUser.isOnline) {
        existingUser.isOnline = true;
        hasChanges = true;
      }
      existingUser.lastSeen = DateTime.now();

      if (hasChanges) {
        notifyListeners();
      }
    } else {
      // New user discovery
      final newUser = P2PUser(
        id: discoveredId,
        displayName: 'Device-$discoveredId'.substring(0, 8), // Placeholder name
        deviceId: discoveredId,
        ipAddress: ipAddress,
        port: port,
        isOnline: true,
        lastSeen: DateTime.now(),
        isStored: false, // New discovery is not stored
      );
      _discoveredUsers[discoveredId] = newUser;
      notifyListeners();
    }
  }

  Future<void> _stopDiscovery() async {
    try {
      await _mdnsSubscription?.cancel();
      _mdnsSubscription = null;

      if (_mdnsClient != null) {
        _mdnsClient!.stop();
        _mdnsClient = null;
        logInfo('mDNS discovery stopped.');
      } else {
        logInfo('Discovery stopped (was running in simplified mode).');
      }

      // Close broadcast socket
      _broadcastSocket?.close();
      _broadcastSocket = null;

      _isDiscovering = false;
    } catch (e) {
      logError('Error stopping discovery: $e');
      _isDiscovering = false;
    }
  }

  void _startTimers() {
    // Only start essential timers
    _heartbeatTimer =
        Timer.periodic(_heartbeatInterval, (_) => _sendHeartbeats());
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) => _performCleanup());
  }

  Future<void> _sendInitialAnnouncement() async {
    if (_currentUser == null) return;

    // Send initial announcement when discovery starts
    await _sendUDPAnnouncement();

    logInfo('Sent initial announcement');
  }

  /// Manual discovery - call this from UI when user refreshes
  Future<void> manualDiscovery() async {
    if (!_isEnabled || _currentUser == null) return;

    lastDiscoveryTime = DateTime.now();
    logInfo('Starting manual discovery...');

    // Send announcement to let others know we're here
    await _sendUDPAnnouncement();

    // Perform mDNS discovery sweep (if available)
    await _performDiscovery();

    // Perform direct IP scan
    await _performDirectIPScan();

    logInfo('Manual discovery completed');
    notifyListeners();
  }

  /// Quick refresh - lighter version for frequent calls
  Future<void> quickRefresh() async {
    if (!_isEnabled || _currentUser == null) return;

    // Just send announcement without heavy scanning
    await _sendUDPAnnouncement();
  }

  Future<void> _sendUDPAnnouncement() async {
    if (_broadcastSocket == null || _currentUser == null) return;

    try {
      final announcement = {
        'type': 'setpocket_service_announcement',
        'service': _serviceType,
        'userId': _currentUser!.id,
        'userName': _currentUser!.displayName,
        'deviceId': _currentUser!.deviceId,
        'ipAddress': _currentUser!.ipAddress,
        'port': _currentUser!.port,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final data = utf8.encode(jsonEncode(announcement));

      // Broadcast to common broadcast addresses
      final broadcastAddresses = [
        '255.255.255.255', // Global broadcast
        '192.168.1.255', // Common subnet broadcast
        '192.168.0.255', // Another common subnet
      ];

      for (final address in broadcastAddresses) {
        try {
          _broadcastSocket!.send(data, InternetAddress(address), 8082);
        } catch (e) {
          // Ignore individual broadcast failures
        }
      }
    } catch (e) {
      logError('Failed to send UDP announcement: $e');
    }
  }

  void _stopTimers() {
    _heartbeatTimer?.cancel();
    _cleanupTimer?.cancel();
  }

  Future<void> _performDiscovery() async {
    if (_mdnsClient == null) {
      // In simplified mode (fallback for platforms with mDNS issues)
      logInfo(
          '${Platform.operatingSystem}: P2P service running in simplified mode (no mDNS discovery)');
      return;
    }

    logInfo('Performing mDNS discovery sweep for $_serviceType.local...');

    try {
      // We lookup for PTR records that point to a service of the type we are interested in
      _mdnsClient!
          .lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer('$_serviceType.local'))
          .listen(
        (PtrResourceRecord ptr) {
          // For each service pointer, we lookup the SRV record to get port/host
          _mdnsClient!
              .lookup<SrvResourceRecord>(
                  ResourceRecordQuery.service(ptr.domainName))
              .listen((SrvResourceRecord srv) {
            // And for each SRV record, we lookup the IP address
            _mdnsClient!
                .lookup<IPAddressResourceRecord>(
                    ResourceRecordQuery.addressIPv4(srv.target))
                .listen((IPAddressResourceRecord ip) {
              _handleDiscoveredUser(
                name: srv.name,
                ipAddress: ip.address.address,
                port: srv.port,
              );
            });
          });
        },
        onError: (dynamic error) {
          logError('mDNS lookup error: $error');
        },
      );
    } catch (e) {
      logError('Error performing mDNS discovery: $e');
    }
  }

  Future<void> _sendHeartbeats() async {
    if (_currentUser == null) return;

    final pairedUsers =
        _discoveredUsers.values.where((u) => u.isPaired && u.isOnline).toList();

    for (final user in pairedUsers) {
      try {
        final message = P2PMessage(
          type: P2PMessageTypes.heartbeat,
          fromUserId: _currentUser!.id,
          toUserId: user.id,
          data: {},
        );

        final success = await _sendMessage(user, message);
        if (!success) {
          // Mark user as potentially offline if heartbeat fails
          logWarning(
              'Heartbeat failed for ${user.displayName}, marking as potentially offline');

          // Check if user has been unreachable for too long
          final timeSinceLastSeen = DateTime.now().difference(user.lastSeen);
          if (timeSinceLastSeen > const Duration(minutes: 3) && user.isStored) {
            // If stored user has been unreachable for 3+ minutes, check if they disconnected
            await _checkForSilentDisconnect(user);
          }
        } else {
          // Update last seen time for successful heartbeats
          user.lastSeen = DateTime.now();
        }
      } catch (e) {
        logError('Failed to send heartbeat to ${user.displayName}: $e');
        // Don't mark as offline immediately - might be temporary network issue
      }
    }
  }

  /// Check if a user has silently disconnected (no disconnect message received)
  Future<void> _checkForSilentDisconnect(P2PUser user) async {
    if (!user.isStored || !user.isPaired) return;

    // Try multiple connection attempts to confirm disconnection
    int failedAttempts = 0;
    const maxAttempts = 3;

    for (int i = 0; i < maxAttempts; i++) {
      try {
        final testMessage = P2PMessage(
          type: P2PMessageTypes.heartbeat,
          fromUserId: _currentUser!.id,
          toUserId: user.id,
          data: {'test': true},
        );

        final success = await _sendMessage(user, testMessage);
        if (success) {
          // User is still reachable
          user.lastSeen = DateTime.now();
          logInfo(
              '${user.displayName} is still reachable after connection test');
          return;
        } else {
          failedAttempts++;
        }
      } catch (e) {
        failedAttempts++;
      }

      // Wait between attempts
      if (i < maxAttempts - 1) {
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    // All attempts failed - treat as silent disconnect
    if (failedAttempts == maxAttempts) {
      logWarning(
          '${user.displayName} appears to have silently disconnected (${failedAttempts}/$maxAttempts failed attempts)');

      // Mark as offline but keep stored status in case they come back
      user.isOnline = false;
      user.lastSeen = DateTime.now().subtract(const Duration(minutes: 5));

      // Don't remove from storage immediately - they might come back
      // But mark them as potentially disconnected
      notifyListeners();

      logInfo(
          'Marked ${user.displayName} as offline due to failed connectivity');
    }
  }

  Future<void> _performCleanup() async {
    // Clean up offline users and old requests
    final now = DateTime.now();
    bool hasChanges = false;

    // Mark users offline if no activity for more than 90 seconds
    // Remove users if offline for more than 5 minutes
    final usersToRemove = <String>[];

    for (final entry in _discoveredUsers.entries) {
      final user = entry.value;
      final timeSinceLastSeen = now.difference(user.lastSeen);

      // Mark offline if no activity for 90 seconds
      if (timeSinceLastSeen > _offlineTimeout && user.isOnline) {
        user.isOnline = false;
        hasChanges = true;
        logInfo(
            'Marked user ${user.displayName} as offline (last seen: ${timeSinceLastSeen.inSeconds}s ago)');
      }

      // Remove completely if offline for more than 5 minutes and not paired
      if (timeSinceLastSeen.inMinutes > 5 && !user.isPaired) {
        usersToRemove.add(entry.key);
        logInfo(
            'Removing stale user ${user.displayName} (offline for ${timeSinceLastSeen.inMinutes} minutes)');
      }
    }

    // Remove stale users
    for (final userId in usersToRemove) {
      _discoveredUsers.remove(userId);
      hasChanges = true;
    }

    // Remove old unprocessed pairing requests (older than 1 hour)
    final oldRequestCount = _pendingRequests.length;
    final expiredRequests = <PairingRequest>[];

    _pendingRequests.removeWhere((request) {
      final isExpired = now.difference(request.requestTime).inHours > 1;
      if (isExpired) {
        expiredRequests.add(request);
      }
      return isExpired;
    });

    // Also remove expired requests from storage
    if (expiredRequests.isNotEmpty) {
      try {
        final requestsBox =
            await Hive.openBox<PairingRequest>('pairing_requests');
        for (final expiredRequest in expiredRequests) {
          await requestsBox.delete(expiredRequest.id);
        }
        logInfo(
            'Removed ${expiredRequests.length} expired pairing requests from storage');
      } catch (e) {
        logError('Failed to remove expired requests from storage: $e');
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void _handleClientConnection(Socket socket) {
    logInfo('New client connected: ${socket.remoteAddress}');
    // Use a buffer for each connection to handle message framing
    final buffer = BytesBuilder();

    socket.listen(
      (data) {
        buffer.add(data);

        // Process all complete messages in the buffer
        while (true) {
          final currentBytes = buffer.toBytes();
          if (currentBytes.length < 4) {
            // Not enough data for the length header
            break;
          }

          final messageLength =
              ByteData.view(currentBytes.buffer).getUint32(0, Endian.big);

          if (currentBytes.length < messageLength + 4) {
            // The full message has not been received yet
            break;
          }

          // Extract the complete message
          final messageBytes = currentBytes.sublist(4, messageLength + 4);

          // Process the message
          _handleCompleteMessage(socket, messageBytes);

          // Remove the processed message from the buffer
          final remainingBytes = currentBytes.sublist(messageLength + 4);
          buffer.clear();
          buffer.add(remainingBytes);
        }
      },
      onError: (error) {
        logError('Socket error on ${socket.remoteAddress}: $error');
        _handleClientDisconnection(socket);
      },
      onDone: () => _handleClientDisconnection(socket),
      cancelOnError: true,
    );
  }

  // Renamed from _handleIncomingData to reflect it processes a complete message
  void _handleCompleteMessage(Socket socket, Uint8List messageBytes) {
    try {
      final jsonString = utf8.decode(messageBytes);
      final messageData = jsonDecode(jsonString);
      final message = P2PMessage.fromJson(messageData);

      _processMessage(socket, message);
    } catch (e) {
      logError('Failed to process complete message: $e');
    }
  }

  void _handleClientDisconnection(Socket socket) {
    logInfo('Client disconnected: ${socket.remoteAddress}');
    _connectedSockets.removeWhere((id, s) => s == socket);
  }

  Future<void> _processMessage(Socket socket, P2PMessage message) async {
    logInfo(
        '📨 Processing message: ${message.type} from ${message.fromUserId} to ${message.toUserId}');

    switch (message.type) {
      case P2PMessageTypes.discovery:
        await _handleDiscoveryMessage(socket, message);
        break;
      case P2PMessageTypes.pairingRequest:
        await _handlePairingRequest(message);
        break;
      case P2PMessageTypes.pairingResponse:
        await _handlePairingResponse(message);
        break;
      case P2PMessageTypes.dataTransferRequest:
        await _handleDataTransferRequest(message);
        break;
      case P2PMessageTypes.dataTransferResponse:
        await _handleDataTransferResponse(message);
        break;
      case P2PMessageTypes.dataChunk:
        await _handleDataChunk(message);
        break;
      case P2PMessageTypes.dataTransferComplete:
        await _handleDataTransferComplete(message);
        break;
      case P2PMessageTypes.dataTransferCancel:
        await _handleDataTransferCancel(message);
        break;
      case P2PMessageTypes.heartbeat:
        await _handleHeartbeat(message);
        break;
      case P2PMessageTypes.trustRequest:
        await _handleTrustRequest(message);
        break;
      case P2PMessageTypes.trustResponse:
        await _handleTrustResponse(message);
        break;
      case P2PMessageTypes.disconnect:
        logInfo('🔌 Processing disconnect message from ${message.fromUserId}');
        await _handleDisconnectMessage(message);
        break;
      default:
        logWarning('Unknown message type: ${message.type}');
    }
  }

  Future<void> _handleDiscoveryMessage(
      Socket socket, P2PMessage message) async {
    // Handle discovery and respond with our info - simple logic like old version
    final userData = message.data;
    final discoveredUser = P2PUser.fromJson(userData);

    if (discoveredUser.id == _currentUser?.id) {
      return; // Ignore discovery from ourselves
    }

    // Use the same merge logic as other discovery methods
    _handleDiscoveredUser(
      name: discoveredUser.id,
      ipAddress: discoveredUser.ipAddress,
      port: discoveredUser.port,
    );

    // Update display name if we have more info from the discovery message
    final existingUser = _discoveredUsers[discoveredUser.id];
    if (existingUser != null &&
        discoveredUser.displayName.isNotEmpty &&
        existingUser.displayName.startsWith('Device-') &&
        !discoveredUser.displayName.startsWith('Device-')) {
      existingUser.displayName = discoveredUser.displayName;
      logInfo(
          'Updated display name for ${discoveredUser.id}: ${discoveredUser.displayName}');
    }

    // Send discovery response
    final response = P2PMessage(
      type: P2PMessageTypes.discoveryResponse,
      fromUserId: _currentUser!.id,
      toUserId: discoveredUser.id,
      data: _currentUser!.toJson(),
    );

    await _sendMessageToSocket(socket, response);
  }

  Future<void> _handlePairingRequest(P2PMessage message) async {
    final request = PairingRequest.fromJson(message.data);
    _pendingRequests.add(request);
    await _savePairingRequest(request);
    notifyListeners();

    // Trigger callback for new pairing request (for auto-showing dialogs)
    if (_onNewPairingRequest != null) {
      _onNewPairingRequest!(request);
    }
  }

  Future<void> _handlePairingResponse(P2PMessage message) async {
    final data = message.data;
    final accepted = data['accepted'] as bool;

    if (accepted) {
      final user = _discoveredUsers[message.fromUserId];
      if (user != null) {
        user.isPaired = true;
        user.isTrusted = data['trusted'] ?? false;
        user.autoConnect = data['saveConnection'] ?? false;
        user.pairedAt = DateTime.now();

        // Mark as stored if connection was saved
        user.isStored = data['saveConnection'] ?? false;

        await _saveUser(user);
        logInfo(
            'Pairing response accepted for ${user.displayName}: paired=${user.isPaired}, trusted=${user.isTrusted}, stored=${user.isStored}');
      }
    } else {
      logInfo('Pairing response rejected from user ${message.fromUserId}');
    }

    notifyListeners();
  }

  Future<void> _handleDataTransferRequest(P2PMessage message) async {
    // Handle incoming data transfer request
    // Show notification/dialog to user for approval
  }

  Future<void> _handleDataTransferResponse(P2PMessage message) async {
    // Handle data transfer response (accept/reject)
    final data = message.data;
    final taskId = data['taskId'] as String;
    final accepted = data['accepted'] as bool;

    final task = _activeTransfers[taskId];
    if (task != null && accepted) {
      final targetUser = _discoveredUsers[task.targetUserId];
      if (targetUser != null) {
        await _startDataTransfer(task, targetUser);
      }
    } else if (task != null) {
      task.status = DataTransferStatus.failed;
      task.errorMessage = 'Transfer rejected by recipient';
      notifyListeners();
    }
  }

  Future<void> _handleDataChunk(P2PMessage message) async {
    final data = message.data;
    final taskId = data['taskId'] as String;
    final chunkDataBase64 = data['data'] as String;
    final isLast = data['isLast'] as bool? ?? false;

    logInfo('Received data chunk for task $taskId (isLast: $isLast)');

    try {
      final chunkData = base64Decode(chunkDataBase64);

      // Initialize chunks list if it's the first chunk
      _incomingFileChunks.putIfAbsent(taskId, () => []);

      // Append the new chunk
      _incomingFileChunks[taskId]!.add(chunkData);

      // If this is the last chunk, assemble the file
      if (isLast) {
        logInfo('Last chunk received for task $taskId, assembling file...');
        // We need the metadata which should arrive with the complete message.
        // Let's ensure we wait for it if necessary.
        await _assembleReceivedFile(taskId);
      }
    } catch (e) {
      logError('Failed to process data chunk for task $taskId: $e');
      // Clean up on error to prevent partial files
      _incomingFileChunks.remove(taskId);
      _incomingFileMetadata.remove(taskId);
    }
  }

  Future<void> _handleDataTransferComplete(P2PMessage message) async {
    final data = message.data;
    final taskId = data['taskId'] as String;
    final fileName = data['fileName'] as String;
    final fileSize = data['fileSize'] as int;

    logInfo('Data transfer completed for task $taskId: $fileName');

    // Store metadata for file assembly
    _incomingFileMetadata[taskId] = {
      'fileName': fileName,
      'fileSize': fileSize,
      'fromUserId': message.fromUserId,
    };

    // Try to assemble file if we have chunks
    if (_incomingFileChunks.containsKey(taskId)) {
      await _assembleReceivedFile(taskId);
    }

    // Update task status if it exists
    final task = _activeTransfers[taskId];
    if (task != null) {
      task.status = DataTransferStatus.completed;
      task.completedAt = DateTime.now();
      task.transferredBytes = task.fileSize;
      _cleanupTransfer(taskId);
      notifyListeners();
    }
  }

  Future<void> _handleDataTransferCancel(P2PMessage message) async {
    final data = message.data;
    final taskId = data['taskId'] as String;

    logInfo('Data transfer cancelled for task $taskId');

    // Clean up receiving data
    _incomingFileChunks.remove(taskId);
    _incomingFileMetadata.remove(taskId);

    // Update task status if it exists
    final task = _activeTransfers[taskId];
    if (task != null) {
      task.status = DataTransferStatus.cancelled;
      task.errorMessage = 'Transfer cancelled by sender';
      _cleanupTransfer(taskId);
      notifyListeners();
    }
  }

  Future<void> _assembleReceivedFile(String taskId) async {
    try {
      final chunks = _incomingFileChunks[taskId];
      final metadata = _incomingFileMetadata[taskId];

      if (chunks == null || metadata == null) {
        logError('Missing chunks or metadata for task $taskId');
        return;
      }

      final fileName = metadata['fileName'] as String;
      final expectedFileSize = metadata['fileSize'] as int;
      final fromUserId = metadata['fromUserId'] as String;

      // Get download path from settings
      String downloadPath;
      if (_fileStorageSettings != null) {
        downloadPath = _fileStorageSettings!.downloadPath;
      } else {
        // Default to Downloads folder
        downloadPath = Platform.isWindows
            ? '${Platform.environment['USERPROFILE']}\\Downloads'
            : '${Platform.environment['HOME']}/Downloads';
      }

      // Create directory if it doesn't exist
      final downloadDir = Directory(downloadPath);
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      // Generate unique filename if file already exists
      String finalFileName = fileName;
      String filePath = '$downloadPath${Platform.pathSeparator}$finalFileName';
      int counter = 1;

      while (await File(filePath).exists()) {
        final fileNameParts = fileName.split('.');
        if (fileNameParts.length > 1) {
          final baseName =
              fileNameParts.sublist(0, fileNameParts.length - 1).join('.');
          final extension = fileNameParts.last;
          finalFileName = '${baseName}_$counter.$extension';
        } else {
          finalFileName = '${fileName}_$counter';
        }
        filePath = '$downloadPath${Platform.pathSeparator}$finalFileName';
        counter++;
      }

      // Assemble file data
      final fileData = <int>[];
      for (final chunk in chunks) {
        if (chunk.isNotEmpty) {
          fileData.addAll(chunk);
        }
      }

      // Verify file size
      if (fileData.length != expectedFileSize) {
        logError(
            'File size mismatch for $fileName: expected $expectedFileSize, got ${fileData.length}');
        // Continue anyway - might be compression or other factors
      }

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(fileData);

      logInfo(
          '✅ File received and saved: $filePath (${fileData.length} bytes)');

      // Create incoming transfer task for UI
      final fromUser = _discoveredUsers[fromUserId];
      final incomingTask = DataTransferTask(
        id: taskId,
        fileName: finalFileName,
        filePath: filePath,
        fileSize: fileData.length,
        targetUserId: _currentUser!.id,
        targetUserName: _currentUser!.displayName,
        status: DataTransferStatus.completed,
        transferredBytes: fileData.length,
        isOutgoing: false,
        savePath: filePath,
      );

      incomingTask.startedAt =
          DateTime.now().subtract(const Duration(seconds: 10));
      incomingTask.completedAt = DateTime.now();

      _activeTransfers[taskId] = incomingTask;

      // Clean up
      _incomingFileChunks.remove(taskId);
      _incomingFileMetadata.remove(taskId);

      notifyListeners();

      logInfo(
          '📁 File transfer completed: ${fromUser?.displayName ?? 'Unknown'} sent $finalFileName');
    } catch (e) {
      logError('Failed to assemble received file for task $taskId: $e');

      // Clean up on error
      _incomingFileChunks.remove(taskId);
      _incomingFileMetadata.remove(taskId);
    }
  }

  Future<void> _handleHeartbeat(P2PMessage message) async {
    final user = _discoveredUsers[message.fromUserId];
    if (user != null) {
      user.lastSeen = DateTime.now();
      user.isOnline = true;
    }
  }

  Future<void> _handleTrustRequest(P2PMessage message) async {
    // Show trust request notification/dialog to user
    // For now, just log it
    final data = message.data;
    final fromUserName = data['fromUserName'] as String;
    logInfo('Received trust request from $fromUserName');

    // In a real implementation, you would show a dialog to the user
    // and let them approve/reject the trust request
  }

  Future<void> _handleTrustResponse(P2PMessage message) async {
    final data = message.data;
    final accepted = data['accepted'] as bool;

    if (accepted) {
      final user = _discoveredUsers[message.fromUserId];
      if (user != null) {
        user.isTrusted = true;
        await _saveUser(user);
        logInfo('Trust approved by ${user.displayName}');
      }
    } else {
      logInfo('Trust rejected by user ${message.fromUserId}');
    }

    notifyListeners();
  }

  Future<void> _handleDisconnectMessage(P2PMessage message) async {
    final data = message.data;
    final reason = data['reason'] as String? ?? 'unknown';
    final fromUserName = data['fromUserName'] as String? ?? 'Unknown User';
    final isEmergency = data['emergency'] as bool? ?? false;

    final user = _discoveredUsers[message.fromUserId];
    if (user != null) {
      if (isEmergency) {
        logInfo(
            '🚨 Received EMERGENCY disconnect from ${user.displayName}: $reason');
      } else {
        logInfo(
            'Received disconnect notification from ${user.displayName}: $reason');
      }

      // Remove from storage if stored
      if (user.isStored) {
        try {
          final box = await Hive.openBox<P2PUser>('p2p_users');
          await box.delete(user.id);
          logInfo('Removed ${user.displayName} from storage due to disconnect');
        } catch (e) {
          logError('Failed to remove user from storage: $e');
        }
      }

      // Reset connection status
      user.isPaired = false;
      user.isTrusted = false;
      user.isStored = false;
      user.autoConnect = false;
      user.pairedAt = null;

      // Mark as offline for any disconnect message (both emergency and normal)
      user.isOnline = false;
      if (isEmergency) {
        user.lastSeen = DateTime.now().subtract(const Duration(minutes: 1));
      } else {
        user.lastSeen = DateTime.now().subtract(const Duration(seconds: 30));
      }

      // Remove from discovered users since they disconnected
      _discoveredUsers.remove(user.id);

      logInfo(
          '🔄 Updated user state: ${user.displayName} - paired: ${user.isPaired}, stored: ${user.isStored}, online: ${user.isOnline}, removed from discovered users');

      notifyListeners();

      // Log for user awareness
      if (isEmergency) {
        logInfo('$fromUserName\'s app has closed (emergency disconnect).');
      } else {
        logInfo('$fromUserName has disconnected from you.');
      }

      logInfo('📊 Remaining discovered users: ${_discoveredUsers.length}');
    }
  }

  Future<bool> _sendMessage(P2PUser targetUser, P2PMessage message) async {
    try {
      // Always create a new connection for each message to avoid socket state issues
      final socket = await Socket.connect(
        targetUser.ipAddress,
        targetUser.port,
        timeout: const Duration(seconds: 5),
      );

      final success = await _sendMessageToSocket(socket, message);

      // Add small delay to ensure message is sent before closing
      await Future.delayed(const Duration(milliseconds: 100));

      // Close the socket after sending
      await socket.close();

      return success;
    } catch (e) {
      logError('Failed to send message to ${targetUser.displayName}: $e');
      // Clean up any stale socket references
      _connectedSockets.remove(targetUser.id);
      return false;
    }
  }

  Future<bool> _sendMessageToSocket(Socket socket, P2PMessage message) async {
    try {
      final messageBytes = utf8.encode(jsonEncode(message.toJson()));
      final lengthHeader = ByteData(4)
        ..setUint32(0, messageBytes.length, Endian.big);

      // Send the length header first, then the message
      socket.add(lengthHeader.buffer.asUint8List());
      socket.add(messageBytes);

      await socket.flush();
      return true;
    } catch (e) {
      logError(
          'Failed to send message to socket: $e for message type ${message.type}');
      return false;
    }
  }

  Future<void> _startDataTransfer(
      DataTransferTask task, P2PUser targetUser) async {
    try {
      task.status = DataTransferStatus.transferring;
      task.startedAt = DateTime.now();

      // Create isolate for data transfer
      final receivePort = ReceivePort();
      _transferPorts[task.id] = receivePort;

      final isolate = await Isolate.spawn(
        _dataTransferIsolate,
        {
          'sendPort': receivePort.sendPort,
          'task': task.toJson(),
          'targetUser': targetUser.toJson(),
          'currentUserId': _currentUser!.id,
          'encryptionKey': _encryptionKey.base64,
        },
      );

      _transferIsolates[task.id] = isolate;

      // Listen for progress updates
      receivePort.listen((data) {
        if (data is Map<String, dynamic>) {
          final progress = data['progress'] as double?;
          final completed = data['completed'] as bool? ?? false;
          final error = data['error'] as String?;

          if (progress != null) {
            task.transferredBytes = (task.fileSize * progress).round();
          }

          if (completed) {
            task.status = DataTransferStatus.completed;
            task.completedAt = DateTime.now();
            _cleanupTransfer(task.id);
          } else if (error != null) {
            task.status = DataTransferStatus.failed;
            task.errorMessage = error;
            _cleanupTransfer(task.id);
          }

          notifyListeners();
        }
      });

      notifyListeners();
    } catch (e) {
      task.status = DataTransferStatus.failed;
      task.errorMessage = e.toString();
      logError('Failed to start data transfer: $e');
      notifyListeners();
    }
  }

  static void _dataTransferIsolate(Map<String, dynamic> params) async {
    final sendPort = params['sendPort'] as SendPort;
    Socket? socket; // Re-use socket for the entire transfer

    try {
      // Parse parameters
      final taskData = params['task'] as Map<String, dynamic>;
      final targetUserData = params['targetUser'] as Map<String, dynamic>;
      final currentUserId = params['currentUserId'] as String;

      final task = DataTransferTask.fromJson(taskData);
      final targetUser = P2PUser.fromJson(targetUserData);

      // Connect to target once
      socket = await Socket.connect(
        targetUser.ipAddress,
        targetUser.port,
        timeout: const Duration(seconds: 10),
      );

      // Read file
      final file = File(task.filePath);
      if (!await file.exists()) {
        sendPort.send({'error': 'File does not exist: ${task.filePath}'});
        return;
      }

      final fileBytes = await file.readAsBytes();
      int totalSent = 0;

      // Dynamic chunking parameters
      int chunkSize = 32 * 1024; // Start with 32KB
      const int maxChunkSize = 512 * 1024; // Cap at 512KB
      int successfulChunksInRow = 0;
      Duration delay = const Duration(milliseconds: 50);

      final totalBytes = fileBytes.length;
      sendPort.send({'info': 'Starting transfer of $totalBytes bytes.'});

      while (totalSent < totalBytes) {
        final remainingBytes = totalBytes - totalSent;
        final currentChunkSize = min(chunkSize, remainingBytes);
        final chunk =
            fileBytes.sublist(totalSent, totalSent + currentChunkSize);

        try {
          final chunkMessage = P2PMessage(
            type: P2PMessageTypes.dataChunk,
            fromUserId: currentUserId,
            toUserId: targetUser.id,
            data: {
              'taskId': task.id,
              'data': base64Encode(chunk),
              'isLast': (totalSent + currentChunkSize == totalBytes),
            },
          );

          final messageBytes = utf8.encode(jsonEncode(chunkMessage.toJson()));
          final lengthHeader = ByteData(4)
            ..setUint32(0, messageBytes.length, Endian.big);

          socket!.add(lengthHeader.buffer.asUint8List());
          socket.add(messageBytes);
          await socket.flush();

          totalSent += currentChunkSize;
          successfulChunksInRow++;

          // Adjust chunk size and delay dynamically
          if (successfulChunksInRow > 10 && chunkSize < maxChunkSize) {
            chunkSize *= 2; // Double chunk size
            delay = Duration(
                milliseconds:
                    max(10, delay.inMilliseconds - 10)); // Decrease delay
            successfulChunksInRow = 0; // Reset counter
            sendPort.send({
              'info':
                  'Speed up: chunk size ${chunkSize ~/ 1024}KB, delay ${delay.inMilliseconds}ms'
            });
          }

          sendPort.send({
            'progress': totalSent / totalBytes,
            'transferredBytes': totalSent,
          });

          if (delay > Duration.zero) {
            await Future.delayed(delay);
          }
        } catch (e) {
          sendPort.send({'error': 'Chunk failed: $e. Retrying...'});

          // Slow down on error
          chunkSize = max(32 * 1024, chunkSize ~/ 2); // Halve chunk size
          delay = Duration(
              milliseconds:
                  min(100, delay.inMilliseconds + 20)); // Increase delay

          // Re-establish connection
          await socket?.close();
          socket = await Socket.connect(targetUser.ipAddress, targetUser.port,
              timeout: const Duration(seconds: 10));
        }
      }

      // Send completion message
      final completeMessage = P2PMessage(
        type: P2PMessageTypes.dataTransferComplete,
        fromUserId: currentUserId,
        toUserId: targetUser.id,
        data: {
          'taskId': task.id,
          'fileName': task.fileName,
          'fileSize': totalBytes
        },
      );
      final messageBytes = utf8.encode(jsonEncode(completeMessage.toJson()));
      final lengthHeader = ByteData(4)
        ..setUint32(0, messageBytes.length, Endian.big);
      socket!.add(lengthHeader.buffer.asUint8List());
      socket.add(messageBytes);
      await socket.flush();

      sendPort.send({'completed': true});
    } catch (e) {
      sendPort.send({'error': 'Transfer failed: $e'});
    } finally {
      await socket?.close();
    }
  }

  void _cleanupTransfer(String taskId) {
    final isolate = _transferIsolates.remove(taskId);
    isolate?.kill();

    final port = _transferPorts.remove(taskId);
    port?.close();
  }

  Future<void> _cancelAllTransfers() async {
    for (final taskId in _activeTransfers.keys.toList()) {
      await cancelDataTransfer(taskId);
    }
  }

  Future<void> _closeAllConnections() async {
    for (final socket in _connectedSockets.values) {
      try {
        await socket.close();
      } catch (e) {
        logError('Error closing socket: $e');
      }
    }
    _connectedSockets.clear();
  }

  Future<void> _saveUser(P2PUser user) async {
    try {
      // Ensure user is marked as stored when saving to storage
      user.isStored = true;

      final box = await Hive.openBox<P2PUser>('p2p_users');
      await box.put(user.id, user);
      logInfo(
          'Saved user to storage: ${user.displayName} (stored: ${user.isStored}, paired: ${user.isPaired}, trusted: ${user.isTrusted})');
    } catch (e) {
      logError('Failed to save user: $e');
    }
  }

  Future<void> _savePairingRequest(PairingRequest request) async {
    try {
      final box = await Hive.openBox<PairingRequest>('pairing_requests');
      await box.put(request.id, request);
    } catch (e) {
      logError('Failed to save pairing request: $e');
    }
  }

  /// Disconnect from user (remove stored connection)
  Future<bool> disconnectUser(String userId) async {
    try {
      final user = _discoveredUsers[userId];
      if (user == null) return false;

      // Send disconnect notification to the other user if they're online
      if (user.isOnline) {
        final message = P2PMessage(
          type: P2PMessageTypes.disconnect,
          fromUserId: _currentUser!.id,
          toUserId: user.id,
          data: {
            'reason': 'user_initiated',
            'message': 'User disconnected from you',
            'fromUserName': _currentUser!.displayName,
          },
        );

        try {
          await _sendMessage(user, message);
          logInfo('Sent disconnect notification to ${user.displayName}');
        } catch (e) {
          logWarning('Failed to send disconnect notification: $e');
          // Continue with disconnection even if notification fails
        }
      }

      // Remove from storage
      final box = await Hive.openBox<P2PUser>('p2p_users');
      await box.delete(userId);

      // Reset connection status but keep user as saved device (offline)
      user.isPaired = false;
      user.isTrusted = false;
      user.isStored = true; // Keep as saved device
      user.autoConnect = false;
      user.pairedAt = null;
      user.isOnline = false; // Mark as offline

      // Keep user in discovered list so they appear as saved but offline device
      // They will show in the "Saved Devices" section with gray color

      notifyListeners();
      logInfo(
          'Disconnected from user: ${user.displayName} (kept as saved offline device)');
      return true;
    } catch (e) {
      logError('Failed to disconnect user: $e');
      return false;
    }
  }

  /// Send trust request to user
  Future<bool> sendTrustRequest(P2PUser targetUser) async {
    try {
      if (!targetUser.isPaired) {
        throw Exception('User must be paired first');
      }

      final message = P2PMessage(
        type: P2PMessageTypes.trustRequest,
        fromUserId: _currentUser!.id,
        toUserId: targetUser.id,
        data: {
          'fromUserName': _currentUser!.displayName,
        },
      );

      return await _sendMessage(targetUser, message);
    } catch (e) {
      logError('Failed to send trust request: $e');
      return false;
    }
  }

  /// Respond to trust request
  Future<bool> respondToTrustRequest(String fromUserId, bool accept) async {
    try {
      final user = _discoveredUsers[fromUserId];
      if (user == null) return false;

      final message = P2PMessage(
        type: P2PMessageTypes.trustResponse,
        fromUserId: _currentUser!.id,
        toUserId: fromUserId,
        data: {
          'accepted': accept,
        },
      );

      if (accept) {
        user.isTrusted = true;
        await _saveUser(user);
      }

      await _sendMessage(user, message);
      notifyListeners();
      return true;
    } catch (e) {
      logError('Failed to respond to trust request: $e');
      return false;
    }
  }

  /// Remove trust from user
  Future<bool> removeTrust(String userId) async {
    try {
      final user = _discoveredUsers[userId];
      if (user == null) return false;

      user.isTrusted = false;
      await _saveUser(user);

      notifyListeners();
      logInfo('Removed trust from user: ${user.displayName}');
      return true;
    } catch (e) {
      logError('Failed to remove trust: $e');
      return false;
    }
  }

  /// Update file storage settings
  Future<bool> updateFileStorageSettings(
      P2PFileStorageSettings settings) async {
    try {
      final box =
          await Hive.openBox<P2PFileStorageSettings>('p2p_storage_settings');
      await box.clear();
      await box.add(settings);
      _fileStorageSettings = settings;

      logInfo('Updated file storage settings: ${settings.downloadPath}');
      return true;
    } catch (e) {
      logError('Failed to update file storage settings: $e');
      return false;
    }
  }

  /// Send emergency disconnect signal (for app termination)
  Future<bool> sendEmergencyDisconnect(P2PUser user, P2PMessage message) async {
    try {
      logInfo('🚨 Sending emergency disconnect to ${user.displayName}');

      // Create a new socket with shorter timeout for emergency situations
      final socket = await Socket.connect(
        user.ipAddress,
        user.port,
        timeout: const Duration(seconds: 2),
      );

      final jsonString = jsonEncode(message.toJson());
      final data = utf8.encode(jsonString);

      // Send the message
      socket.add(data);

      // Shorter delay for emergency situations
      await Future.delayed(const Duration(milliseconds: 50));

      // Close the socket
      await socket.close();

      logInfo('✅ Emergency disconnect sent to ${user.displayName}');
      return true;
    } catch (e) {
      logError(
          '❌ Failed to send emergency disconnect to ${user.displayName}: $e');
      return false;
    }
  }

  /// Send emergency disconnect to all paired users
  Future<void> sendEmergencyDisconnectToAll() async {
    if (_currentUser == null) return;

    final pairedUsers = _discoveredUsers.values
        .where((user) => user.isPaired && user.isOnline)
        .toList();

    if (pairedUsers.isEmpty) {
      logInfo('No paired users to send emergency disconnect');
      return;
    }

    logInfo(
        'Sending emergency disconnect to ${pairedUsers.length} paired users');

    final disconnectFutures = pairedUsers.map((user) async {
      final message = P2PMessage(
        type: P2PMessageTypes.disconnect,
        fromUserId: _currentUser!.id,
        toUserId: user.id,
        data: {
          'reason': 'app_termination',
          'message': 'App is closing',
          'fromUserName': _currentUser!.displayName,
          'emergency': true,
        },
      );

      return await sendEmergencyDisconnect(user, message);
    });

    // Wait for all emergency disconnects with timeout
    await Future.wait(disconnectFutures).timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        logWarning(
            'Emergency disconnect timeout - some messages may not have been sent');
        return pairedUsers.map((user) => false).toList();
      },
    );

    logInfo('Emergency disconnect sequence completed');
  }

  @override
  void dispose() {
    // Send emergency disconnect to all paired users before disposing
    sendEmergencyDisconnectToAll();
    stopNetworking();
    super.dispose();
  }
}
