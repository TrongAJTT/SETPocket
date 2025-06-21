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

  // File transfer management
  final Map<String, FileTransferTask> _activeTransfers = {};
  final Map<String, Isolate> _transferIsolates = {};
  final Map<String, ReceivePort> _transferPorts = {};

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
      Duration(seconds: 60); // More frequent cleanup
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
  List<FileTransferTask> get activeTransfers =>
      _activeTransfers.values.toList();

  /// Last discovery time for UI to show refresh status
  DateTime? _lastDiscoveryTime;
  DateTime? get lastDiscoveryTime => _lastDiscoveryTime;

  /// Initialize P2P service
  Future<void> initialize() async {
    try {
      // Initialize encryption
      _initializeEncryption();

      // Load saved data
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

      // Clear discovered users
      _discoveredUsers.clear();

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

      // Remove from pending
      _pendingRequests.removeWhere((r) => r.id == requestId);
      request.isProcessed = true;
      await _savePairingRequest(request);

      notifyListeners();
      return true;
    } catch (e) {
      logError('Failed to respond to pairing request: $e');
      return false;
    }
  }

  /// Send file to paired user
  Future<bool> sendFile(String filePath, P2PUser targetUser) async {
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

      final task = FileTransferTask(
        fileName: fileName,
        filePath: filePath,
        fileSize: fileSize,
        targetUserId: targetUser.id,
        targetUserName: targetUser.displayName,
        isOutgoing: true,
      );

      _activeTransfers[task.id] = task;

      // Send file transfer request
      if (!targetUser.isTrusted) {
        final message = P2PMessage(
          type: P2PMessageTypes.fileTransferRequest,
          fromUserId: _currentUser!.id,
          toUserId: targetUser.id,
          data: {
            'taskId': task.id,
            'fileName': fileName,
            'fileSize': fileSize,
          },
        );

        task.status = FileTransferStatus.requesting;
        await _sendMessage(targetUser, message);
      } else {
        // Start transfer immediately for trusted users
        await _startFileTransfer(task, targetUser);
      }

      notifyListeners();
      return true;
    } catch (e) {
      logError('Failed to send file: $e');
      return false;
    }
  }

  /// Cancel file transfer
  Future<bool> cancelFileTransfer(String taskId) async {
    try {
      final task = _activeTransfers[taskId];
      if (task == null) return false;

      task.status = FileTransferStatus.cancelled;

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
          type: P2PMessageTypes.fileTransferCancel,
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
      logError('Failed to cancel file transfer: $e');
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
      // Load saved users
      final usersBox = await Hive.openBox<P2PUser>('p2p_users');
      for (final user in usersBox.values) {
        _discoveredUsers[user.id] = user;
      }

      // Load pending requests
      final requestsBox =
          await Hive.openBox<PairingRequest>('pairing_requests');
      _pendingRequests.addAll(requestsBox.values.where((r) => !r.isProcessed));

      // Load file storage settings
      final storageBox =
          await Hive.openBox<P2PFileStorageSettings>('p2p_storage_settings');
      if (storageBox.isNotEmpty) {
        _fileStorageSettings = storageBox.values.first;
      }

      logInfo(
          'Loaded ${_discoveredUsers.length} users and ${_pendingRequests.length} pending requests');
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

      // Scan common subnets
      final subnets = [
        '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}', // Same subnet as current IP
        '192.168.1', // Common home subnet
        '192.168.0', // Another common subnet
      ];

      logInfo('Performing direct IP scan on subnets: ${subnets.join(", ")}');

      for (final subnet in subnets) {
        // Scan a few common IPs in each subnet
        final commonIPs = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 100, 101, 102, 254];

        for (final lastOctet in commonIPs) {
          final targetIP = '$subnet.$lastOctet';

          // Skip our own IP
          if (targetIP == currentIP) continue;

          // Try to connect to potential P2P service
          _tryConnectToIP(targetIP);
        }
      }
    } catch (e) {
      logError('Error during direct IP scan: $e');
    }
  }

  Future<void> _tryConnectToIP(String ipAddress) async {
    try {
      // Try to connect to potential P2P service on port 8080
      final socket = await Socket.connect(ipAddress, 8080,
          timeout: const Duration(seconds: 2));

      // Send a discovery message
      final discoveryMessage = P2PMessage(
        type: P2PMessageTypes.discovery,
        fromUserId: _currentUser!.id,
        toUserId: '', // Unknown target
        data: _currentUser!.toJson(),
      );

      final jsonString = jsonEncode(discoveryMessage.toJson());
      final data = utf8.encode(jsonString);
      socket.add(data);
      await socket.flush();

      logInfo('Sent discovery message to $ipAddress:8080');

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
    // The name from SRV record is like '<instance>.<service>.<local>'
    final discoveredId = name.split('.').first;

    if (discoveredId == _currentUser?.id) {
      return; // It's me
    }

    if (_discoveredUsers.containsKey(discoveredId)) {
      final user = _discoveredUsers[discoveredId]!;
      // Update connection info but preserve stored status
      if (user.ipAddress != ipAddress || user.port != port) {
        user.ipAddress = ipAddress;
        user.port = port;
        logInfo('User $discoveredId updated IP to $ipAddress:$port.');
      }
      user.lastSeen = DateTime.now();
      user.isOnline = true;
    } else {
      logInfo('Discovered new user: $discoveredId at $ipAddress:$port');
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
    }
    notifyListeners();
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

    _lastDiscoveryTime = DateTime.now();
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
        }
      } catch (e) {
        logError('Failed to send heartbeat to ${user.displayName}: $e');
        // Don't mark as offline immediately - might be temporary network issue
      }
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
    _pendingRequests.removeWhere((request) {
      return now.difference(request.requestTime).inHours > 1;
    });

    if (_pendingRequests.length != oldRequestCount) {
      hasChanges = true;
      logInfo(
          'Cleaned up ${oldRequestCount - _pendingRequests.length} old pairing requests');
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void _handleClientConnection(Socket socket) {
    logInfo('New client connected: ${socket.remoteAddress}');

    socket.listen(
      (data) => _handleIncomingData(socket, data),
      onError: (error) {
        logError('Socket error: $error');
        _handleClientDisconnection(socket);
      },
      onDone: () => _handleClientDisconnection(socket),
      cancelOnError: true,
    );
  }

  void _handleIncomingData(Socket socket, Uint8List data) {
    try {
      final jsonString = utf8.decode(data);
      final messageData = jsonDecode(jsonString);
      final message = P2PMessage.fromJson(messageData);

      _processMessage(socket, message);
    } catch (e) {
      logError('Failed to process incoming data: $e');
    }
  }

  void _handleClientDisconnection(Socket socket) {
    logInfo('Client disconnected: ${socket.remoteAddress}');
    _connectedSockets.removeWhere((id, s) => s == socket);
  }

  Future<void> _processMessage(Socket socket, P2PMessage message) async {
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
      case P2PMessageTypes.fileTransferRequest:
        await _handleFileTransferRequest(message);
        break;
      case P2PMessageTypes.fileTransferResponse:
        await _handleFileTransferResponse(message);
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
      default:
        logWarning('Unknown message type: ${message.type}');
    }
  }

  Future<void> _handleDiscoveryMessage(
      Socket socket, P2PMessage message) async {
    // Handle discovery and respond with our info
    final userData = message.data;
    final user = P2PUser.fromJson(userData);

    _discoveredUsers[user.id] = user;
    // Don't store the socket - we'll use new connections for each message

    // Send discovery response
    final response = P2PMessage(
      type: P2PMessageTypes.discoveryResponse,
      fromUserId: _currentUser!.id,
      toUserId: user.id,
      data: _currentUser!.toJson(),
    );

    await _sendMessageToSocket(socket, response);
    notifyListeners();
  }

  Future<void> _handlePairingRequest(P2PMessage message) async {
    final request = PairingRequest.fromJson(message.data);
    _pendingRequests.add(request);
    await _savePairingRequest(request);
    notifyListeners();
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
        await _saveUser(user);
      }
    }

    notifyListeners();
  }

  Future<void> _handleFileTransferRequest(P2PMessage message) async {
    // Handle incoming file transfer request
    // Show notification/dialog to user for approval
  }

  Future<void> _handleFileTransferResponse(P2PMessage message) async {
    // Handle file transfer response (accept/reject)
    final data = message.data;
    final taskId = data['taskId'] as String;
    final accepted = data['accepted'] as bool;

    final task = _activeTransfers[taskId];
    if (task != null && accepted) {
      final targetUser = _discoveredUsers[task.targetUserId];
      if (targetUser != null) {
        await _startFileTransfer(task, targetUser);
      }
    } else if (task != null) {
      task.status = FileTransferStatus.failed;
      task.errorMessage = 'Transfer rejected by recipient';
      notifyListeners();
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
      final jsonString = jsonEncode(message.toJson());
      final data = utf8.encode(jsonString);

      // Simple write without using streams to avoid conflicts
      socket.add(data);

      // Don't flush here - let the socket handle it
      return true;
    } catch (e) {
      logError('Failed to send message to socket: $e');
      return false;
    }
  }

  Future<void> _startFileTransfer(
      FileTransferTask task, P2PUser targetUser) async {
    try {
      task.status = FileTransferStatus.transferring;
      task.startedAt = DateTime.now();

      // Create isolate for file transfer
      final receivePort = ReceivePort();
      _transferPorts[task.id] = receivePort;

      final isolate = await Isolate.spawn(
        _fileTransferIsolate,
        {
          'sendPort': receivePort.sendPort,
          'task': task.toJson(),
          'targetUser': targetUser.toJson(),
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
            task.status = FileTransferStatus.completed;
            task.completedAt = DateTime.now();
            _cleanupTransfer(task.id);
          } else if (error != null) {
            task.status = FileTransferStatus.failed;
            task.errorMessage = error;
            _cleanupTransfer(task.id);
          }

          notifyListeners();
        }
      });

      notifyListeners();
    } catch (e) {
      task.status = FileTransferStatus.failed;
      task.errorMessage = e.toString();
      logError('Failed to start file transfer: $e');
      notifyListeners();
    }
  }

  static void _fileTransferIsolate(Map<String, dynamic> params) async {
    // This runs in a separate isolate for file transfer
    // Implementation would handle the actual file transfer with encryption
    // and send progress updates back to the main isolate
  }

  void _cleanupTransfer(String taskId) {
    final isolate = _transferIsolates.remove(taskId);
    isolate?.kill();

    final port = _transferPorts.remove(taskId);
    port?.close();
  }

  Future<void> _cancelAllTransfers() async {
    for (final taskId in _activeTransfers.keys.toList()) {
      await cancelFileTransfer(taskId);
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
      final box = await Hive.openBox<P2PUser>('p2p_users');
      await box.put(user.id, user);
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

      // Remove from storage
      final box = await Hive.openBox<P2PUser>('p2p_users');
      await box.delete(userId);

      // Reset stored status but keep if still discovered
      user.isPaired = false;
      user.isTrusted = false;
      user.isStored = false;
      user.autoConnect = false;
      user.pairedAt = null;

      // If not currently online, remove from discovered users
      if (!user.isOnline) {
        _discoveredUsers.remove(userId);
      }

      notifyListeners();
      logInfo('Disconnected from user: ${user.displayName}');
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

  @override
  void dispose() {
    stopNetworking();
    super.dispose();
  }
}
