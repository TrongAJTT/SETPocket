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
  P2PDataTransferSettings? _transferSettings;

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

  // Encryption
  late Encrypter _encrypter;
  late Key _encryptionKey;

  // Task creation synchronization to prevent race conditions
  final Map<String, Completer<DataTransferTask?>> _taskCreationLocks = {};

  // Buffer chunks that arrive before task is created
  final Map<String, List<Map<String, dynamic>>> _pendingChunks = {};

  // Constants
  static const int _basePort = 8080;
  static const int _maxPort = 8090;
  static const String _serviceType = '_setpocket_p2p._tcp';
  // ignore: unused_field
  static const int _chunkSize = 64 * 1024; // 64KB chunks
  // ignore: unused_field
  static const Duration _discoveryInterval = Duration(seconds: 30);
  static const Duration _heartbeatInterval = Duration(seconds: 60);
  static const Duration _cleanupInterval =
      Duration(seconds: 5); // More frequent cleanup for faster detection
  // ignore: unused_field
  static const Duration _announcementInterval =
      Duration(seconds: 15); // Faster announcements
  static const Duration _offlineTimeout = Duration(
      seconds: 150); // Mark offline after 150s (2.5x heartbeat interval)

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
  P2PDataTransferSettings? get transferSettings => _transferSettings;

  // Backward compatibility - keep the old getter
  P2PFileStorageSettings? get fileStorageSettings {
    if (_transferSettings == null) return null;
    return P2PFileStorageSettings(
      downloadPath: _transferSettings!.downloadPath,
      askBeforeDownload: true, // Default value for backward compatibility
      createDateFolders: _transferSettings!.createDateFolders,
      maxFileSize: _transferSettings!.maxReceiveFileSize,
    );
  }

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

      // Send disconnect notifications to all paired users before stopping
      await _sendDisconnectNotifications();

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

      // Only clear non-stored users, keep stored users but mark them offline
      _cleanupUsersOnNetworkStop();

      // Clean up receiving data
      _incomingFileChunks.clear();

      // Clean up task creation locks
      _taskCreationLocks.clear();

      // Clean up pending chunks buffer
      _pendingChunks.clear();

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
        fromAppInstallationId: _currentUser!.appInstallationId,
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
              appInstallationId: request.fromAppInstallationId,
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
      // Extract filename cross-platform (handles both Windows \ and Unix /)
      final fileName = file.path.split(Platform.pathSeparator).last;

      final task = DataTransferTask(
        fileName: fileName,
        filePath: filePath,
        fileSize: fileSize,
        targetUserId: targetUser.id,
        targetUserName: targetUser.displayName,
        isOutgoing: true,
      );

      _activeTransfers[task.id] = task;

      // Start data transfer directly for all users
      // The receiving side will create the task when it receives the first chunk with metadata
      await _startDataTransfer(task, targetUser);

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

      // Only cancel transfers that are actually in progress
      if (task.status != DataTransferStatus.transferring) {
        logInfo(
            'Skipping cancellation for task ${task.id} with status ${task.status}');
        return false;
      }

      // Stop isolate if running
      final isolate = _transferIsolates[taskId];
      if (isolate != null) {
        isolate.kill(priority: Isolate.immediate);
        _transferIsolates.remove(taskId);
        _transferPorts[taskId]?.close();
        _transferPorts.remove(taskId);
      }

      task.status = DataTransferStatus.cancelled;
      task.errorMessage = 'Bị hủy bởi người dùng';

      // Notify other user
      final targetUser = _discoveredUsers[task.targetUserId];
      if (targetUser != null && targetUser.isOnline) {
        final message = P2PMessage(
          type: P2PMessageTypes.dataTransferCancel,
          fromUserId: _currentUser!.id,
          toUserId: targetUser.id,
          data: {'taskId': taskId},
        );
        await _sendMessage(targetUser, message);
      }

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
      // Clear previous state before loading
      _discoveredUsers.clear();
      _pendingRequests.clear();

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

      // Load transfer settings
      final settingsBox =
          await Hive.openBox<P2PDataTransferSettings>('p2p_transfer_settings');
      if (settingsBox.isNotEmpty) {
        _transferSettings = settingsBox.values.first;
      }

      logInfo(
          'Loaded ${_discoveredUsers.length} stored users and ${_pendingRequests.length} pending requests');
    } catch (e) {
      logError('Failed to load saved data: $e');
    }
  }

  Future<void> _createCurrentUser(NetworkInfo networkInfo) async {
    final appInstallationId =
        await NetworkSecurityService.getAppInstallationId();
    final deviceName = await NetworkSecurityService.getDeviceName();

    _currentUser = P2PUser(
      id: appInstallationId,
      displayName: deviceName,
      appInstallationId: appInstallationId,
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

                // Process enhanced announcement with user data sync
                _processEnhancedAnnouncement(data);
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

  /// Process enhanced announcement with encrypted user data synchronization
  Future<void> _processEnhancedAnnouncement(Map<String, dynamic> data) async {
    try {
      final userId = data['userId'] as String;
      final ipAddress = data['ipAddress'] as String;
      final port = data['port'] as int;
      final userName = data['userName'] as String?;

      // Handle basic discovery first
      _handleDiscoveredUser(
        name: userId,
        ipAddress: ipAddress,
        port: port,
      );

      // Try to process encrypted user data if available
      final encryptedUserData = data['encryptedUserData'] as String?;
      final ivBase64 = data['iv'] as String?;
      // ignore: unused_local_variable
      final protocolVersion = data['protocolVersion'] as String? ?? '1.0';

      if (encryptedUserData != null && ivBase64 != null) {
        try {
          final iv = IV.fromBase64(ivBase64);
          final encrypted = Encrypted.fromBase64(encryptedUserData);
          final decryptedJson = _encrypter.decrypt(encrypted, iv: iv);
          final userData = jsonDecode(decryptedJson) as Map<String, dynamic>;

          // Create P2PUser from decrypted data
          final announcedUser = P2PUser.fromJson(userData);

          // Sync with existing user data
          await _syncUserFromAnnouncement(announcedUser);

          logInfo(
              '✅ Successfully synced user data from encrypted announcement: ${announcedUser.displayName}');
        } catch (e) {
          logWarning(
              'Failed to decrypt or process user data from announcement: $e');
          // Fallback to basic discovery
          _updateBasicUserInfo(userId, userName);
        }
      } else {
        // Legacy announcement without encrypted data
        _updateBasicUserInfo(userId, userName);
      }
    } catch (e) {
      logError('Error processing enhanced announcement: $e');
    }
  }

  /// Sync user data from announcement with existing stored data
  Future<void> _syncUserFromAnnouncement(P2PUser announcedUser) async {
    final existingUser = _discoveredUsers[announcedUser.id];

    if (existingUser != null) {
      // User already exists - merge data intelligently
      bool hasChanges = false;

      // Security check: If a paired user suddenly appears with a new IP, invalidate the pairing.
      if (existingUser.isPaired &&
          existingUser.ipAddress != announcedUser.ipAddress) {
        logWarning(
            'Paired user ${existingUser.displayName} appeared with a new IP address.');
        logWarning(
            'Old IP: ${existingUser.ipAddress}, New IP: ${announcedUser.ipAddress}');
        // For security, revoke pairing and trust. Re-pairing will be required.
        existingUser.isPaired = false;
        existingUser.isTrusted = false;
        logInfo(
            'Pairing and trust have been revoked for ${existingUser.displayName} due to IP address change.');
        hasChanges = true;
      }

      // Update network info
      if (existingUser.ipAddress != announcedUser.ipAddress ||
          existingUser.port != announcedUser.port) {
        logInfo('🔄 Network info changed for ${existingUser.displayName}: '
            '${existingUser.ipAddress}:${existingUser.port} -> '
            '${announcedUser.ipAddress}:${announcedUser.port}');
        existingUser.ipAddress = announcedUser.ipAddress;
        existingUser.port = announcedUser.port;
        hasChanges = true;
      }

      // Update online status
      if (!existingUser.isOnline) {
        existingUser.isOnline = true;
        hasChanges = true;
        logInfo(
            '✅ User ${existingUser.displayName} is back online via announcement');
      }

      // Update last seen
      existingUser.lastSeen = DateTime.now();

      // Update appInstallationId if it's different (important for migration from old format)
      if (existingUser.appInstallationId != announcedUser.appInstallationId) {
        logInfo(
            '🔄 Updating appInstallationId for ${existingUser.displayName}: '
            '${existingUser.appInstallationId} -> ${announcedUser.appInstallationId}');
        existingUser.appInstallationId = announcedUser.appInstallationId;
        hasChanges = true;
      }

      // Preserve stored/paired status from existing user (don't override from announcement)
      // But update other non-critical info
      if (existingUser.displayName.startsWith('Device-') &&
          !announcedUser.displayName.startsWith('Device-')) {
        existingUser.displayName = announcedUser.displayName;
        hasChanges = true;
        logInfo('📝 Updated display name: ${announcedUser.displayName}');
      }

      if (hasChanges) {
        notifyListeners();

        // Save to storage if this is a stored user
        if (existingUser.isStored) {
          await _saveUser(existingUser);
        }
      }
    } else {
      // New user - add to discovered list
      announcedUser.isOnline = true;
      announcedUser.lastSeen = DateTime.now();
      announcedUser.isStored = false; // New discovery is not stored

      _discoveredUsers[announcedUser.id] = announcedUser;
      notifyListeners();

      logInfo(
          '🆕 Added new user from announcement: ${announcedUser.displayName} (appInstallationId: ${announcedUser.appInstallationId})');
    }
  }

  /// Update basic user info for legacy announcements
  void _updateBasicUserInfo(String userId, String? userName) {
    final existingUser = _discoveredUsers[userId];
    if (existingUser != null &&
        userName != null &&
        userName.isNotEmpty &&
        existingUser.displayName.startsWith('Device-') &&
        !userName.startsWith('Device-')) {
      existingUser.displayName = userName;
      logInfo('Updated display name via legacy UDP: $userId -> $userName');
      notifyListeners();
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
      final wasOffline = !existingUser.isOnline;

      if (existingUser.ipAddress != ipAddress || existingUser.port != port) {
        logInfo('🔄 Updated network info for ${existingUser.displayName}: '
            '${existingUser.ipAddress}:${existingUser.port} -> '
            '$ipAddress:$port');
        existingUser.ipAddress = ipAddress;
        existingUser.port = port;
        hasChanges = true;
      }
      if (!existingUser.isOnline) {
        existingUser.isOnline = true;
        hasChanges = true;
        logInfo('✅ User ${existingUser.displayName} is back online');
      }
      existingUser.lastSeen = DateTime.now();

      if (wasOffline || hasChanges) {
        logInfo(
            '📡 Updated lastSeen for ${existingUser.displayName} (was offline: $wasOffline)');
      }

      if (hasChanges) {
        notifyListeners();
      }
    } else {
      // New user discovery
      final newUser = P2PUser(
        id: discoveredId,
        displayName:
            'Device-${discoveredId.substring(0, 8)}', // Placeholder name
        appInstallationId: discoveredId, // Use the stable ID
        ipAddress: ipAddress,
        port: port,
        isOnline: true,
        lastSeen: DateTime.now(),
        isStored: false, // New discovery is not stored
      );
      _discoveredUsers[discoveredId] = newUser;
      notifyListeners();

      logInfo(
          '🆕 Discovered new user: ${newUser.displayName} (appInstallationId: ${newUser.appInstallationId})');
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
      // Create comprehensive announcement with encrypted user data
      final userInfo = _currentUser!.toJson();

      // Encrypt the user info for security
      final iv = IV.fromSecureRandom(16);
      final encrypted = _encrypter.encrypt(jsonEncode(userInfo), iv: iv);

      final announcement = {
        'type': 'setpocket_service_announcement',
        'service': _serviceType,
        'userId': _currentUser!.id,
        'userName': _currentUser!.displayName,
        'deviceId': _currentUser!.deviceId,
        'ipAddress': _currentUser!.ipAddress,
        'port': _currentUser!.port,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        // Add encrypted full user data for automatic sync
        'encryptedUserData': encrypted.base64,
        'iv': iv.base64,
        // Add version for future compatibility
        'protocolVersion': '1.0',
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

      logInfo('📡 Sent enhanced UDP announcement with encrypted user data');
    } catch (e) {
      logError('Failed to send enhanced UDP announcement: $e');
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
          if (timeSinceLastSeen > const Duration(seconds: 30) &&
              user.isStored) {
            // If stored user has been unreachable for 30+ seconds, check if they disconnected
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
          '${user.displayName} appears to have silently disconnected ($failedAttempts/$maxAttempts failed attempts)');

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

      // Mark offline if no activity for 150 seconds (2.5x heartbeat interval)
      if (timeSinceLastSeen > _offlineTimeout && user.isOnline) {
        user.isOnline = false;
        hasChanges = true;
        logInfo(
            '⏰ Marked user ${user.displayName} as offline (last seen: ${timeSinceLastSeen.inSeconds}s ago, threshold: ${_offlineTimeout.inSeconds}s)');
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
      case P2PMessageTypes.dataChunk:
        await _handleDataChunk(message);
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

    // Update user with full information from discovery message
    final existingUser = _discoveredUsers[discoveredUser.id];
    if (existingUser != null) {
      bool hasChanges = false;

      // Update display name if we have more info from the discovery message
      if (discoveredUser.displayName.isNotEmpty &&
          existingUser.displayName.startsWith('Device-') &&
          !discoveredUser.displayName.startsWith('Device-')) {
        existingUser.displayName = discoveredUser.displayName;
        hasChanges = true;
        logInfo(
            'Updated display name for ${discoveredUser.id}: ${discoveredUser.displayName}');
      }

      // Update appInstallationId if it's available and different
      if (discoveredUser.appInstallationId.isNotEmpty &&
          existingUser.appInstallationId != discoveredUser.appInstallationId) {
        logInfo(
            '🔄 Updating appInstallationId from discovery for ${existingUser.displayName}: '
            '${existingUser.appInstallationId} -> ${discoveredUser.appInstallationId}');
        existingUser.appInstallationId = discoveredUser.appInstallationId;
        hasChanges = true;
      }

      if (hasChanges) {
        notifyListeners();
        // Save to storage if this is a stored user
        if (existingUser.isStored) {
          await _saveUser(existingUser);
        }
      }
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

  Future<void> _handleDataChunk(P2PMessage message) async {
    final data = message.data;
    final taskId = data['taskId'] as String;
    final chunkDataBase64 = data['data'] as String;
    final isLast = data['isLast'] as bool? ?? false;

    logInfo('Received data chunk for task $taskId (isLast: $isLast)');

    try {
      final chunkData = base64Decode(chunkDataBase64);

      // Use lock mechanism to prevent race conditions in task creation
      DataTransferTask? task = await _getOrCreateTask(taskId, message, data);
      if (task == null) {
        logError('❌ CHUNK_RX: Could not get or create task for $taskId');

        // Buffer this chunk for later processing
        _pendingChunks.putIfAbsent(taskId, () => []);
        _pendingChunks[taskId]!.add({
          'chunkData': chunkData,
          'isLast': isLast,
          'data': data,
        });
        logInfo(
            '📦 BUFFERED: Chunk for task $taskId (buffer size: ${_pendingChunks[taskId]!.length})');
        return;
      }

      // Initialize chunks list if it's the first chunk
      _incomingFileChunks.putIfAbsent(taskId, () => []);

      // Append the new chunk
      _incomingFileChunks[taskId]!.add(chunkData);

      // Update the progress of the active transfer task
      // task should not be null here because we either found it or created it.
      task.transferredBytes += chunkData.length;
      if (task.status != DataTransferStatus.transferring) {
        task.status = DataTransferStatus.transferring;
      }
      notifyListeners();

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
    }
  }

  /// Get existing task or create new one with race condition protection
  Future<DataTransferTask?> _getOrCreateTask(
      String taskId, P2PMessage message, Map<String, dynamic> data) async {
    logInfo(
        '🔍 GET_OR_CREATE_TASK: Checking task $taskId from ${message.fromUserId}');
    logInfo(
        '📋 CHUNK_DATA: keys=${data.keys.toList()}, isLast=${data['isLast']}, hasFileName=${data.containsKey('fileName')}, hasFileSize=${data.containsKey('fileSize')}');

    // Check if task already exists
    DataTransferTask? task = _activeTransfers[taskId];
    if (task != null) {
      logInfo('✅ TASK_EXISTS: Found existing task $taskId');
      return task;
    }

    logInfo(
        '❓ TASK_NOT_FOUND: Task $taskId not in active transfers (${_activeTransfers.length} active)');

    // Check if another thread is already creating this task
    Completer<DataTransferTask?>? existingLock = _taskCreationLocks[taskId];
    if (existingLock != null) {
      logInfo('🔒 Task $taskId is being created by another thread, waiting...');
      return await existingLock.future;
    }

    // Create lock for this task creation
    final completer = Completer<DataTransferTask?>();
    _taskCreationLocks[taskId] = completer;

    try {
      // Double-check pattern: task might have been created while we were setting up the lock
      task = _activeTransfers[taskId];
      if (task != null) {
        completer.complete(task);
        return task;
      }

      // Extract metadata for first chunk
      final fileName = data['fileName'] as String?;
      final fileSize = data['fileSize'] as int?;

      if (fileName != null && fileSize != null) {
        logInfo(
            '✅ FIRST_CHUNK_RX: First chunk for new task $taskId ($fileName). Creating task.');

        // Check if user exists, if not try to request user info
        P2PUser? fromUser = _discoveredUsers[message.fromUserId];
        if (fromUser == null) {
          logWarning(
              '❓ UNKNOWN_USER: Received first chunk from unknown user: ${message.fromUserId}');

          // Send a quick discovery request to get user info
          await _requestUserInfo(message.fromUserId, message);

          // Try again after discovery request
          fromUser = _discoveredUsers[message.fromUserId];

          if (fromUser == null) {
            // Create a temporary user entry for this transfer
            fromUser = P2PUser(
              id: message.fromUserId,
              displayName:
                  'Unknown User (${message.fromUserId.substring(0, 8)})',
              appInstallationId: message.fromUserId,
              ipAddress: 'Unknown',
              port: 0,
              isOnline: true,
              lastSeen: DateTime.now(),
              isStored: false,
            );
            _discoveredUsers[message.fromUserId] = fromUser;
            logInfo(
                '📝 Created temporary user entry for transfer: ${fromUser.displayName}');
          }
        }

        task = DataTransferTask(
          id: taskId,
          fileName: fileName,
          filePath: '', // File path is not known yet on receiver side
          fileSize: fileSize,
          targetUserId: fromUser.id,
          targetUserName: fromUser.displayName,
          status: DataTransferStatus.transferring,
          isOutgoing: false,
          createdAt: DateTime.now(),
          startedAt: DateTime.now(),
        );

        // Atomically add task to active transfers
        _activeTransfers[taskId] = task;
        logInfo('🔒 Task $taskId created and added to active transfers');

        // Process any buffered chunks for this task
        final bufferedChunks = _pendingChunks.remove(taskId);
        if (bufferedChunks != null && bufferedChunks.isNotEmpty) {
          logInfo(
              '🔄 PROCESSING ${bufferedChunks.length} buffered chunks for task $taskId');
          for (final bufferedChunk in bufferedChunks) {
            final chunkData = bufferedChunk['chunkData'] as Uint8List;
            final isLast = bufferedChunk['isLast'] as bool;

            // Initialize chunks list if it's the first chunk
            _incomingFileChunks.putIfAbsent(taskId, () => []);

            // Append the buffered chunk
            _incomingFileChunks[taskId]!.add(chunkData);

            // Update task progress
            task.transferredBytes += chunkData.length;
            if (task.status != DataTransferStatus.transferring) {
              task.status = DataTransferStatus.transferring;
            }

            logInfo(
                '📦 PROCESSED buffered chunk: ${chunkData.length} bytes (total: ${task.transferredBytes}/${task.fileSize})');

            // If this buffered chunk was the last one, assemble the file
            if (isLast) {
              logInfo(
                  '🏁 Last buffered chunk processed for task $taskId, assembling file...');
              // We need to call this after completing the task creation
              // Schedule it to run after this method completes
              Future.microtask(() => _assembleReceivedFile(taskId));
            }
          }
          notifyListeners();
        }

        completer.complete(task);
        return task;
      } else {
        logError(
            '❌ CHUNK_RX: Received chunk for task NOT in active transfers, and no metadata found to create it: $taskId');
        logError('❌ DATA_KEYS: ${data.keys.toList()}');
        logError('❌ ACTIVE_TRANSFERS: ${_activeTransfers.keys.toList()}');
        completer.complete(null);
        return null;
      }
    } catch (e) {
      logError('Failed to create task $taskId: $e');
      completer.complete(null);
      return null;
    } finally {
      // Always clean up the lock
      _taskCreationLocks.remove(taskId);
    }
  }

  Future<void> _handleDataTransferCancel(P2PMessage message) async {
    final data = message.data;
    final taskId = data['taskId'] as String;

    logInfo('Data transfer cancelled for task $taskId');

    // Clean up receiving data
    _incomingFileChunks.remove(taskId);

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
      final task = _activeTransfers[taskId];

      if (chunks == null || task == null) {
        logError('❌ ASSEMBLE: Missing chunks or task for $taskId');
        return;
      }

      final originalFileName = task.fileName;
      // Sanitize filename for the receiving platform
      final fileName = _sanitizeFileName(originalFileName);
      final expectedFileSize = task.fileSize;
      final fromUserId = task.targetUserId;

      // Get download path from settings
      String downloadPath;
      if (_transferSettings != null) {
        downloadPath = _transferSettings!.downloadPath;
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
          finalFileName = '${baseName}_${counter}.$extension';
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

      // Update the task to completed state
      task.status = DataTransferStatus.completed;
      task.completedAt = DateTime.now();
      task.filePath = filePath; // Update final path
      task.savePath = filePath;
      task.transferredBytes = fileData.length; // Finalize byte count
      logInfo('✅ ASSEMBLE: Updated task $taskId to completed state.');

      // Clean up
      _incomingFileChunks.remove(taskId);

      notifyListeners();

      final fromUser = _discoveredUsers[fromUserId];
      logInfo(
          '📁 File transfer completed: ${fromUser?.displayName ?? 'Unknown'} sent $finalFileName');
    } catch (e) {
      logError('Failed to assemble received file for task $taskId: $e');

      // Clean up on error
      _incomingFileChunks.remove(taskId);
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
    final isUnpair = data['unpair'] as bool? ?? false;

    final user = _discoveredUsers[message.fromUserId];
    if (user == null) {
      logWarning(
          "Received disconnect from unknown user: ${message.fromUserId}");
      return;
    }

    if (isUnpair) {
      await _handleUnpairNotification(user, reason, fromUserName);
    } else {
      _handleRegularDisconnect(user, reason, fromUserName);
    }

    notifyListeners();
  }

  /// Handles a notification that a user has unpaired.
  Future<void> _handleUnpairNotification(
      P2PUser user, String reason, String fromUserName) async {
    logInfo(
        '💔 Received UNPAIR notification from ${user.displayName}: $reason');

    // On unpair, remove from storage
    if (user.isStored) {
      try {
        final box = await Hive.openBox<P2PUser>('p2p_users');
        await box.delete(user.id);
        logInfo('Removed ${user.displayName} from storage due to unpair');
      } catch (e) {
        logError('Failed to remove user from storage on unpair: $e');
      }
    }

    // And remove from the current session
    _discoveredUsers.remove(user.id);
    logInfo('💔 Unpaired from ${user.displayName}: removed completely.');
    logInfo('$fromUserName has unpaired from you.');
  }

  /// Handles a regular disconnect notification (e.g., network stop).
  void _handleRegularDisconnect(
      P2PUser user, String reason, String fromUserName) {
    // This is a regular disconnect (e.g., network stop)
    logInfo(
        '🔌 Received disconnect notification from ${user.displayName}: $reason');

    // Just mark the user as offline. Do NOT remove from storage or discovered list.
    user.isOnline = false;
    user.lastSeen = DateTime.now();

    logInfo('🔄 Marked user as offline: ${user.displayName}');
    logInfo('$fromUserName has disconnected.');
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
      bool isFirstChunk = true;

      while (totalSent < totalBytes) {
        final remainingBytes = totalBytes - totalSent;
        final currentChunkSize = min(chunkSize, remainingBytes);
        final chunk =
            fileBytes.sublist(totalSent, totalSent + currentChunkSize);

        try {
          final dataPayload = {
            'taskId': task.id,
            'data': base64Encode(chunk),
            'isLast': (totalSent + currentChunkSize == totalBytes),
          };

          if (isFirstChunk) {
            dataPayload['fileName'] = task.fileName;
            dataPayload['fileSize'] = task.fileSize;
            isFirstChunk = false;
            sendPort.send({
              'info':
                  '🔥 SENDING FIRST CHUNK with metadata: ${task.fileName} (${task.fileSize} bytes) for task ${task.id}'
            });
          }

          final chunkMessage = P2PMessage(
            type: P2PMessageTypes.dataChunk,
            fromUserId: currentUserId,
            toUserId: targetUser.id,
            data: dataPayload,
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

          // IMPORTANT: If this was the first chunk that failed, we need to resend with metadata
          if (totalSent == 0) {
            isFirstChunk = true; // Reset to resend metadata
            sendPort.send({
              'info':
                  '🔄 Connection lost on first chunk, will resend with metadata'
            });
          }
        }
      }

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

  /// Unpair from user (remove pairing completely from both devices)
  Future<bool> unpairUser(String userId) async {
    try {
      final user = _discoveredUsers[userId];
      if (user == null) return false;

      // Send unpair notification to the other user if they're online
      if (user.isOnline) {
        final message = P2PMessage(
          type: P2PMessageTypes.disconnect,
          fromUserId: _currentUser!.id,
          toUserId: user.id,
          data: {
            'reason': 'unpair_initiated',
            'message': 'User unpaired from you',
            'fromUserName': _currentUser!.displayName,
            'unpair': true, // Flag to indicate this is an unpair action
          },
        );

        try {
          await _sendMessage(user, message);
          logInfo('Sent unpair notification to ${user.displayName}');
        } catch (e) {
          logWarning('Failed to send unpair notification: $e');
          // Continue with unpairing even if notification fails
        }
      }

      // Remove from storage completely
      final box = await Hive.openBox<P2PUser>('p2p_users');
      await box.delete(userId);

      // Remove from discovered users completely - this user should disappear from UI
      _discoveredUsers.remove(userId);

      notifyListeners();
      logInfo(
          'Unpaired from user: ${user.displayName} (removed completely from both devices)');
      return true;
    } catch (e) {
      logError('Failed to unpair user: $e');
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

  /// Update transfer settings
  Future<bool> updateTransferSettings(P2PDataTransferSettings settings) async {
    try {
      final box =
          await Hive.openBox<P2PDataTransferSettings>('p2p_transfer_settings');
      await box.clear();
      await box.add(settings);
      _transferSettings = settings;

      logInfo('Updated transfer settings: ${settings.downloadPath}');
      return true;
    } catch (e) {
      logError('Failed to update transfer settings: $e');
      return false;
    }
  }

  /// Update file storage settings (backward compatibility)
  Future<bool> updateFileStorageSettings(
      P2PFileStorageSettings settings) async {
    // Convert old settings to new format
    final newSettings = P2PDataTransferSettings(
      downloadPath: settings.downloadPath,
      createDateFolders: settings.createDateFolders,
      maxReceiveFileSize: settings.maxFileSize,
      sendProtocol: 'TCP', // Default
      maxChunkSize: 512, // Default
    );
    return await updateTransferSettings(newSettings);
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

  /// Send disconnect notifications to all paired users when stopping networking
  Future<void> _sendDisconnectNotifications() async {
    if (_currentUser == null) return;

    final pairedUsers = _discoveredUsers.values
        .where((user) => user.isPaired && user.isOnline)
        .toList();

    if (pairedUsers.isEmpty) {
      logInfo('No paired users to notify about disconnect');
      return;
    }

    logInfo(
        'Sending disconnect notifications to ${pairedUsers.length} paired users');

    final disconnectFutures = pairedUsers.map((user) async {
      final message = P2PMessage(
        type: P2PMessageTypes.disconnect,
        fromUserId: _currentUser!.id,
        toUserId: user.id,
        data: {
          'reason': 'network_stop',
          'message': 'User stopped P2P networking',
          'fromUserName': _currentUser!.displayName,
          'unpair': false, // Explicitly state this is not an unpair action
        },
      );

      try {
        await _sendMessage(user, message);
        logInfo('Sent disconnect notification to ${user.displayName}');
        return true;
      } catch (e) {
        logWarning(
            'Failed to send disconnect notification to ${user.displayName}: $e');
        return false;
      }
    });

    // Wait for all disconnect notifications with timeout
    await Future.wait(disconnectFutures).timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        logWarning(
            'Disconnect notification timeout - some messages may not have been sent');
        return pairedUsers.map((user) => false).toList();
      },
    );

    logInfo('Disconnect notification sequence completed');
  }

  /// Clean up users when network stops - keep stored users, remove discovered ones
  void _cleanupUsersOnNetworkStop() {
    final usersToRemove = <String>[];

    for (final entry in _discoveredUsers.entries) {
      final user = entry.value;

      if (user.isStored) {
        // Keep stored users but mark them as offline
        user.isOnline = false;
        user.lastSeen = DateTime.now().subtract(const Duration(minutes: 1));
        logInfo('Marked stored user ${user.displayName} as offline');
      } else {
        // Remove non-stored (discovered only) users
        usersToRemove.add(entry.key);
        logInfo('Removing non-stored user ${user.displayName}');
      }
    }

    // Remove non-stored users
    for (final userId in usersToRemove) {
      _discoveredUsers.remove(userId);
    }

    logInfo(
        'Network stop cleanup: kept ${_discoveredUsers.length} stored users, removed ${usersToRemove.length} discovered users');
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

  /// Clear a transfer from the list
  void clearTransfer(String taskId) {
    final task = _activeTransfers.remove(taskId);
    if (task != null) {
      logInfo('Cleared transfer from UI: ${task.fileName}');
      notifyListeners();
    }
  }

  /// Sanitize filename for cross-platform compatibility
  String _sanitizeFileName(String fileName) {
    // Remove invalid characters for file systems
    String sanitized = fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_') // Windows invalid chars
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '_'); // Control characters

    // Handle cases where full path might be passed as filename
    // Extract just the filename part from any path format
    if (sanitized.contains('\\')) {
      sanitized = sanitized.split('\\').last;
    }
    if (sanitized.contains('/')) {
      sanitized = sanitized.split('/').last;
    }

    // Ensure filename is not empty and not just dots
    if (sanitized.isEmpty || sanitized.replaceAll('.', '').isEmpty) {
      sanitized = 'received_file_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Limit filename length to avoid filesystem issues
    if (sanitized.length > 250) {
      final extension =
          sanitized.contains('.') ? sanitized.split('.').last : '';
      final baseName = sanitized.contains('.')
          ? sanitized.substring(0, sanitized.lastIndexOf('.'))
          : sanitized;

      // Keep extension but truncate base name
      sanitized = extension.isNotEmpty
          ? '${baseName.substring(0, 250 - extension.length - 1)}.$extension'
          : baseName.substring(0, 250);
    }

    logInfo('📝 Sanitized filename: "$fileName" → "$sanitized"');
    return sanitized;
  }

  /// Request user info from unknown sender during transfer
  Future<void> _requestUserInfo(
      String userId, P2PMessage originalMessage) async {
    try {
      // Extract IP from original message if available, otherwise try to respond via broadcast
      logInfo('🔍 Requesting user info for unknown user: $userId');

      // Send a broadcast announcement to trigger the unknown user to announce themselves
      await _sendUDPAnnouncement();

      // Give a short time for the user to respond
      await Future.delayed(const Duration(milliseconds: 500));

      logInfo(
          '📡 Sent discovery broadcast to help identify unknown user: $userId');
    } catch (e) {
      logWarning('Failed to request user info for $userId: $e');
    }
  }
}
