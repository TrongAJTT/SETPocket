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
import 'package:setpocket/services/hive_service.dart';

/// Validation result for file transfer request
class _FileTransferValidationResult {
  final bool isValid;
  final FileTransferRejectReason? rejectReason;
  final String? rejectMessage;

  _FileTransferValidationResult.valid()
      : isValid = true,
        rejectReason = null,
        rejectMessage = null;
  _FileTransferValidationResult.invalid(this.rejectReason, this.rejectMessage)
      : isValid = false;
}

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
  bool _isServiceInitialized = false;
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

  // File transfer request management
  final List<FileTransferRequest> _pendingFileTransferRequests = [];

  // Callback for new file transfer requests
  Function(FileTransferRequest)? _onNewFileTransferRequest;

  // File transfer responses pending timeout
  final Map<String, Timer> _fileTransferResponseTimers = {};
  final Map<String, Timer> _fileTransferRequestTimers = {};

  // Store download paths for batches (with date folders)
  final Map<String, String> _batchDownloadPaths = {};

  // Map from sender userId to current active batchId for incoming transfers
  final Map<String, String> _activeBatchIdsByUser = {};

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
  Timer? _broadcastTimer; // New: Timer for periodic broadcast

  // Stream subscriptions
  StreamSubscription? _mdnsSubscription;

  // Broadcast socket for UDP announcements
  RawDatagramSocket? _broadcastSocket;
  RawDatagramSocket? _udpListenerSocket; // Dedicated listener on port 8082
  bool _isBroadcasting = false; // New: Track broadcast state

  // Getters
  bool get isEnabled => _isEnabled;
  bool get isDiscovering => _isDiscovering;
  bool get isMdnsEnabled => _mdnsClient != null;
  bool get isBroadcasting => _isBroadcasting; // New getter
  String get discoveryMode => 'UDP Broadcast Only';
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
      maxFileSize: _transferSettings!.maxReceiveFileSize ~/
          (1024 * 1024), // Convert to MB
      maxConcurrentTasks: _transferSettings!.maxConcurrentTasks,
    );
  }

  List<PairingRequest> get pendingRequests =>
      List.unmodifiable(_pendingRequests);
  List<FileTransferRequest> get pendingFileTransferRequests =>
      List.unmodifiable(_pendingFileTransferRequests);
  List<DataTransferTask> get activeTransfers =>
      _activeTransfers.values.toList();

  /// Last discovery time for UI to show refresh status
  DateTime? lastDiscoveryTime;

  /// Set callback for new pairing requests
  void setNewPairingRequestCallback(Function(PairingRequest)? callback) {
    _onNewPairingRequest = callback;
  }

  /// Set callback for new file transfer requests
  void setNewFileTransferRequestCallback(
      Function(FileTransferRequest)? callback) {
    _onNewFileTransferRequest = callback;
  }

  /// Initialize P2P service
  Future<void> initialize() async {
    if (_isServiceInitialized) {
      logInfo('P2P Service already initialized, skipping.');
      return;
    }
    try {
      // Initialize encryption
      _initializeEncryption();

      // Load saved data - simple approach like the old version
      await _loadSavedData();

      _isServiceInitialized = true;
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

      // Start timers - heartbeat and cleanup
      _heartbeatTimer =
          Timer.periodic(_heartbeatInterval, (_) => _sendHeartbeats());
      _cleanupTimer =
          Timer.periodic(_cleanupInterval, (_) => _performCleanup());

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

      // Reset the initialization flag to allow for a clean restart
      _isServiceInitialized = false;

      notifyListeners();
      logInfo('P2P networking stopped and service lifecycle ended.');
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

  /// Send file to paired user (legacy method - redirects to new file transfer request)
  Future<bool> sendData(String filePath, P2PUser targetUser) async {
    return await sendMultipleFiles([filePath], targetUser);
  }

  /// Send multiple files to paired user with pre-request approval
  Future<bool> sendMultipleFiles(
      List<String> filePaths, P2PUser targetUser) async {
    try {
      if (!targetUser.isPaired) {
        throw Exception('User is not paired');
      }

      if (filePaths.isEmpty) {
        throw Exception('No files selected');
      }

      // Check all files exist and prepare file info list
      final files = <FileTransferInfo>[];
      int totalSize = 0;

      for (final filePath in filePaths) {
        final file = File(filePath);
        if (!await file.exists()) {
          throw Exception('File does not exist: $filePath');
        }

        final fileSize = await file.length();
        final fileName = file.path.split(Platform.pathSeparator).last;

        files.add(FileTransferInfo(fileName: fileName, fileSize: fileSize));
        totalSize += fileSize;
      }

      // Create file transfer request
      final transferSettings = _transferSettings;

      logInfo('📊 Creating file transfer request:');
      logInfo('  - Number of files: ${files.length}');
      logInfo(
          '  - Individual file sizes: ${files.map((f) => '${f.fileName}: ${f.fileSize} bytes').join(', ')}');
      logInfo('  - Calculated total size: $totalSize bytes');

      final request = FileTransferRequest(
        fromUserId: _currentUser!.id,
        fromUserName: _currentUser!.displayName,
        files: files,
        totalSize: totalSize,
        protocol: transferSettings?.sendProtocol ?? 'tcp',
        maxChunkSize: transferSettings?.maxChunkSize,
      );

      logInfo(
          '📤 FileTransferRequest created with totalSize: ${request.totalSize} bytes');

      // Create transfer tasks in waiting state
      for (int i = 0; i < filePaths.length; i++) {
        final filePath = filePaths[i];
        final fileInfo = files[i];

        final task = DataTransferTask(
          fileName: fileInfo.fileName,
          filePath: filePath,
          fileSize: fileInfo.fileSize,
          targetUserId: targetUser.id,
          targetUserName: targetUser.displayName,
          status: DataTransferStatus.waitingForApproval,
          isOutgoing: true,
          batchId: request.batchId,
        );

        _activeTransfers[task.id] = task;
      }

      // Send file transfer request
      final requestJson = request.toJson();
      logInfo('📤 Sending file transfer request JSON:');
      logInfo('  - totalSize in JSON: ${requestJson['totalSize']}');
      logInfo('  - files count: ${(requestJson['files'] as List).length}');

      final message = P2PMessage(
        type: P2PMessageTypes.fileTransferRequest,
        fromUserId: _currentUser!.id,
        toUserId: targetUser.id,
        data: requestJson,
      );

      final success = await _sendMessage(targetUser, message);
      if (success) {
        // Set up response timeout timer
        _fileTransferResponseTimers[request.requestId] = Timer(
          const Duration(seconds: 65),
          () => _handleFileTransferTimeout(request.requestId),
        );

        logInfo(
            'Sent file transfer request for ${files.length} files to ${targetUser.displayName}');
      } else {
        // Clean up tasks if request failed
        _cancelTasksByBatchId(request.batchId);
      }

      notifyListeners();
      return success;
    } catch (e) {
      logError('Failed to send file transfer request: $e');
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

      // Clean up and start next queued transfer
      _cleanupTransfer(taskId);

      notifyListeners();
      return true;
    } catch (e) {
      logError('Failed to cancel data transfer: $e');
      return false;
    }
  }

  /// Cancel all tasks with the given batch ID
  void _cancelTasksByBatchId(String batchId) {
    final tasksToCancel = _activeTransfers.values
        .where((task) => task.batchId == batchId)
        .toList();

    for (final task in tasksToCancel) {
      task.status = DataTransferStatus.cancelled;
      task.errorMessage = 'File transfer request failed';
      _cleanupTransfer(task.id);
    }

    logInfo('Cancelled ${tasksToCancel.length} tasks for batch $batchId');
    notifyListeners();
  }

  /// Handle file transfer request timeout
  void _handleFileTransferTimeout(String requestId) {
    _fileTransferResponseTimers.remove(requestId);

    // Find tasks waiting for this request and cancel them
    final tasksToCancel = _activeTransfers.values
        .where((task) =>
            task.status == DataTransferStatus.waitingForApproval &&
            task.isOutgoing)
        .toList();

    for (final task in tasksToCancel) {
      task.status = DataTransferStatus.cancelled;
      task.errorMessage = 'No response from receiver (timeout)';
      _cleanupTransfer(task.id);
    }

    logInfo('File transfer request $requestId timed out');
    notifyListeners();
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
      if (settingsBox.containsKey('settings')) {
        _transferSettings = settingsBox.get('settings');
        logInfo(
            'Loaded transfer settings: downloadPath=${_transferSettings?.downloadPath}');
      } else {
        // Create default settings if none exist
        _transferSettings = _createDefaultTransferSettings();
        // Save default settings to storage
        await settingsBox.put('settings', _transferSettings!);
        logInfo(
            'Created and saved default transfer settings: ${_transferSettings!.downloadPath}');
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
        // Start TCP server
        _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
        _currentUser!.port = port;
        _serverSocket!.listen(_handleClientConnection);

        // Start UDP server on same port
        await _startUdpServer(port);

        logInfo('P2P TCP/UDP servers started on port $port');
        return;
      } catch (e) {
        if (port == _maxPort) {
          throw Exception(
              'Failed to bind to any port in range $_basePort-$_maxPort');
        }
      }
    }
  }

  RawDatagramSocket? _udpServerSocket;

  Future<void> _startUdpServer(int port) async {
    try {
      _udpServerSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
      _udpServerSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpServerSocket!.receive();
          if (datagram != null) {
            _handleUdpMessage(datagram.data, datagram.address, datagram.port);
          }
        }
      });
      logInfo('UDP server started on port $port');
    } catch (e) {
      logWarning('Failed to start UDP server on port $port: $e');
    }
  }

  void _handleUdpMessage(Uint8List data, InternetAddress address, int port) {
    try {
      final messageJson = utf8.decode(data);
      final messageData = jsonDecode(messageJson) as Map<String, dynamic>;
      final message = P2PMessage.fromJson(messageData);

      logInfo(
          'Received UDP message from ${address.address}:$port - Type: ${message.type}');

      // Handle UDP messages (mainly data chunks)
      if (message.type == P2PMessageTypes.dataChunk) {
        _handleDataChunk(message);
      } else {
        logWarning('Received unsupported UDP message type: ${message.type}');
      }
    } catch (e) {
      logError('Failed to process UDP message: $e');
    }
  }

  Future<void> _stopServer() async {
    await _serverSocket?.close();
    _serverSocket = null;

    _udpServerSocket?.close();
    _udpServerSocket = null;

    logInfo('TCP and UDP servers stopped');
  }

  /// Enhanced discovery logic - scan request/response pattern
  Future<void> _startDiscovery() async {
    if (_currentUser == null) {
      logError("Cannot start discovery: current user is null.");
      return;
    }

    try {
      logInfo(
          'Starting optimized discovery with scan request-response pattern');

      // Initialize UDP listener for receiving scan requests and responses
      await _startUDPListener();

      _isDiscovering = true;
      logInfo('Optimized discovery started - ready to receive scan requests');
    } catch (e) {
      logError('Failed to start discovery: $e');
      rethrow;
    }
  }

  /// Start dedicated UDP listener for optimized discovery
  Future<void> _startUDPListener() async {
    try {
      if (_udpListenerSocket != null) {
        return;
      }

      _udpListenerSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 8082);

      _udpListenerSocket!.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = _udpListenerSocket!.receive();
          if (datagram != null) {
            try {
              final message = utf8.decode(datagram.data);
              final data = jsonDecode(message) as Map<String, dynamic>;

              final messageType = data['type'] as String;
              logInfo('UDP: Received $messageType from ${datagram.address}');

              switch (messageType) {
                case 'discovery_scan_request':
                  _handleDiscoveryScanRequest(data, datagram.address);
                  break;
                case 'discovery_response':
                  _handleDiscoveryResponse(data);
                  break;
                case 'profile_sync_request':
                  _handleProfileSyncRequest(data);
                  break;
                default:
                  // Handle legacy announcements for backward compatibility
                  if (messageType == 'setpocket_service_announcement') {
                    _processEnhancedAnnouncement(data);
                  }
              }
            } catch (e) {
              logWarning('UDP: Failed to parse packet: $e');
            }
          }
        }
      });

      logInfo('UDP listener started - ready for optimized discovery');
    } catch (e) {
      logError('Failed to start UDP listener: $e');
    }
  }

  /// Handle incoming discovery scan request
  Future<void> _handleDiscoveryScanRequest(
      Map<String, dynamic> data, InternetAddress senderAddress) async {
    try {
      final request = DiscoveryScanRequest.fromJson(data);

      if (request.fromUserId == _currentUser!.id) {
        return; // Ignore our own requests
      }

      logInfo(
          '📡 Processing scan request from ${request.fromUserName} (${request.fromUserId})');

      // Check if this device exists in our storage
      final existingUserInStorage = await _loadStoredUser(request.fromUserId);
      final responseCode = existingUserInStorage != null
          ? DiscoveryResponseCode.deviceUpdate
          : DiscoveryResponseCode.deviceNew;

      // 🔥 NEW LOGIC: Update UI of receiving device (B) immediately
      // Process the sender as a discovered device and update our UI
      await _processIncomingScanRequestForUI(
          request, existingUserInStorage, responseCode);

      // Create response with our current profile
      final response = DiscoveryResponse(
        toUserId: request.fromUserId,
        responseCode: responseCode,
        userProfile: _currentUser!,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Send response back to sender
      await _sendDiscoveryResponse(response, senderAddress);

      logInfo(
          '✅ Sent discovery response ($responseCode) to ${request.fromUserName} & updated local UI');
    } catch (e) {
      logError('Error handling discovery scan request: $e');
    }
  }

  /// Send discovery response to requesting device
  Future<void> _sendDiscoveryResponse(
      DiscoveryResponse response, InternetAddress targetAddress) async {
    try {
      final responseData = {
        'type': 'discovery_response',
        ...response.toJson(),
      };

      final data = utf8.encode(jsonEncode(responseData));

      // Create a temporary socket for sending response
      final tempSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      tempSocket.send(data, targetAddress, 8082);
      tempSocket.close();

      logInfo('📤 Sent discovery response to ${targetAddress.address}');
    } catch (e) {
      logError('Failed to send discovery response: $e');
    }
  }

  /// Process incoming scan request to update receiving device's UI immediately
  /// This ensures that when device B receives scan request from A,
  /// B's UI shows A's profile immediately according to the new logic
  Future<void> _processIncomingScanRequestForUI(
      DiscoveryScanRequest request,
      P2PUser? existingUserInStorage,
      DiscoveryResponseCode responseCode) async {
    try {
      logInfo(
          '🎯 Processing scan request for UI update: ${request.fromUserName} -> $responseCode');

      // Create user profile from the scan request
      final requestingUser = P2PUser(
        id: request.fromUserId,
        displayName: request.fromUserName.isNotEmpty
            ? request.fromUserName
            : 'Device-${request.fromUserId.substring(0, 8)}',
        appInstallationId: request.fromAppInstallationId,
        ipAddress: request.ipAddress,
        port: request.port,
        isOnline: true,
        lastSeen: DateTime.now(),
        isStored: existingUserInStorage != null,
      );

      switch (responseCode) {
        case DiscoveryResponseCode.deviceUpdate:
          // Device exists in storage - update to online (green background)
          logInfo(
              '🟢 Updating stored device to online: ${request.fromUserName}');
          await _updateDeviceOnlineFromScanRequest(
              requestingUser, existingUserInStorage!);
          break;

        case DiscoveryResponseCode.deviceNew:
          // Device is new - create new device profile (blue background)
          logInfo('🔵 Creating new device profile: ${request.fromUserName}');
          await _createNewDeviceProfileFromScanRequest(requestingUser);
          break;

        case DiscoveryResponseCode.error:
          logWarning('Error response code in scan request processing');
          break;
      }

      // Notify UI to update
      notifyListeners();
    } catch (e) {
      logError('Error processing incoming scan request for UI: $e');
    }
  }

  /// Update device to online status from scan request (green background)
  Future<void> _updateDeviceOnlineFromScanRequest(
      P2PUser requestingUser, P2PUser storedUser) async {
    // Merge stored user data with current scan request data
    storedUser.ipAddress = requestingUser.ipAddress;
    storedUser.port = requestingUser.port;
    storedUser.isOnline = true;
    storedUser.lastSeen = DateTime.now();

    // Update display name if the requesting user has a better name
    if (requestingUser.displayName.isNotEmpty &&
        !requestingUser.displayName.startsWith('Device-') &&
        (storedUser.displayName.startsWith('Device-') ||
            storedUser.displayName.isEmpty)) {
      storedUser.displayName = requestingUser.displayName;
    }

    // Update app installation ID if different
    if (requestingUser.appInstallationId.isNotEmpty &&
        storedUser.appInstallationId != requestingUser.appInstallationId) {
      storedUser.appInstallationId = requestingUser.appInstallationId;
    }

    // Add to discovered users and save
    _discoveredUsers[storedUser.id] = storedUser;
    await _saveUser(storedUser);

    logInfo(
        '✅ Updated device to online from scan request: ${storedUser.displayName}');
  }

  /// Create new device profile from scan request (blue background)
  Future<void> _createNewDeviceProfileFromScanRequest(
      P2PUser requestingUser) async {
    // Set as new device (not stored initially)
    requestingUser.isStored = false;

    // Add to discovered users
    _discoveredUsers[requestingUser.id] = requestingUser;

    logInfo(
        '🆕 Created new device profile from scan request: ${requestingUser.displayName}');
  }

  /// Handle incoming discovery response
  Future<void> _handleDiscoveryResponse(Map<String, dynamic> data) async {
    try {
      final response = DiscoveryResponse.fromJson(data);

      if (response.toUserId != _currentUser!.id) {
        return; // Not for us
      }

      logInfo(
          '📥 Received discovery response: ${response.responseCode.name} from ${response.userProfile.displayName}');

      await _processDiscoveryResponse(response);
    } catch (e) {
      logError('Error handling discovery response: $e');
    }
  }

  /// Process discovery response according to the new logic
  Future<void> _processDiscoveryResponse(DiscoveryResponse response) async {
    final receivedUser = response.userProfile;
    final existingUser = _discoveredUsers[receivedUser.id];
    final isInStorage = await _loadStoredUser(receivedUser.id) != null;

    logInfo(
        'Processing discovery response: code=${response.responseCode.name}, inMemory=${existingUser != null}, inStorage=$isInStorage');

    switch (response.responseCode) {
      case DiscoveryResponseCode.deviceNew:
        if (isInStorage) {
          // Device was reinstalled/reset - remove old profile, create new one
          logInfo(
              '🔄 Device ${receivedUser.displayName} was reinstalled - creating new profile');
          await _removeStoredUser(receivedUser.id);
          _discoveredUsers.remove(receivedUser.id);
          await _createNewDeviceProfile(receivedUser, isNewDevice: true);
        } else {
          // Completely new device
          logInfo('🆕 Completely new device: ${receivedUser.displayName}');
          await _createNewDeviceProfile(receivedUser, isNewDevice: true);
        }
        break;

      case DiscoveryResponseCode.deviceUpdate:
        if (isInStorage) {
          // Known device coming back online
          logInfo('✅ Known device ${receivedUser.displayName} is back online');
          await _updateDeviceOnline(receivedUser);
        } else {
          // Storage sync error - create new profile and sync back
          logInfo(
              '🔄 Storage sync error for ${receivedUser.displayName} - syncing profiles');
          await _createNewDeviceProfile(receivedUser, isNewDevice: true);
          await _sendProfileSyncRequest(receivedUser);
        }
        break;

      case DiscoveryResponseCode.error:
        logWarning('Discovery response error: ${response.errorMessage}');
        break;
    }

    notifyListeners();
  }

  /// Send profile sync request to update remote device's stored profile
  Future<void> _sendProfileSyncRequest(P2PUser targetUser) async {
    try {
      final syncRequest = {
        'type': 'profile_sync_request',
        'fromUserId': _currentUser!.id,
        'toUserId': targetUser.id,
        'updatedProfile': _currentUser!.toJson(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final data = utf8.encode(jsonEncode(syncRequest));
      final tempSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      tempSocket.send(data, InternetAddress(targetUser.ipAddress), 8082);
      tempSocket.close();

      logInfo('📤 Sent profile sync request to ${targetUser.displayName}');
    } catch (e) {
      logError('Failed to send profile sync request: $e');
    }
  }

  /// Handle profile sync request
  Future<void> _handleProfileSyncRequest(Map<String, dynamic> data) async {
    try {
      final fromUserId = data['fromUserId'] as String;
      final toUserId = data['toUserId'] as String;

      if (toUserId != _currentUser!.id) {
        return; // Not for us
      }

      final updatedProfile =
          P2PUser.fromJson(data['updatedProfile'] as Map<String, dynamic>);

      // Update stored profile from offline to new device
      final existingUser = _discoveredUsers[fromUserId];
      if (existingUser != null &&
          existingUser.isStored &&
          !existingUser.isOnline) {
        logInfo(
            '🔄 Converting offline profile to new device: ${updatedProfile.displayName}');

        // Remove old offline profile
        await _removeStoredUser(fromUserId);
        _discoveredUsers.remove(fromUserId);

        // Create new device profile
        await _createNewDeviceProfile(updatedProfile, isNewDevice: true);
        notifyListeners();
      }

      logInfo(
          '✅ Processed profile sync request from ${updatedProfile.displayName}');
    } catch (e) {
      logError('Error handling profile sync request: $e');
    }
  }

  /// Create new device profile (blue background - new device)
  Future<void> _createNewDeviceProfile(P2PUser user,
      {required bool isNewDevice}) async {
    user.isOnline = true;
    user.lastSeen = DateTime.now();
    user.isStored = false; // New devices are not stored initially

    _discoveredUsers[user.id] = user;
    logInfo(
        '🆕 Created new device profile: ${user.displayName} (isNewDevice: $isNewDevice)');
  }

  /// Update device to online status (green background - online saved)
  Future<void> _updateDeviceOnline(P2PUser receivedUser) async {
    P2PUser? user = _discoveredUsers[receivedUser.id];

    if (user == null) {
      // Load from storage
      user = await _loadStoredUser(receivedUser.id);
      if (user != null) {
        _discoveredUsers[receivedUser.id] = user;
      }
    }

    if (user != null) {
      // Update network info and status
      user.ipAddress = receivedUser.ipAddress;
      user.port = receivedUser.port;
      user.isOnline = true;
      user.lastSeen = DateTime.now();

      // Update other info if newer
      if (receivedUser.displayName.isNotEmpty &&
          !receivedUser.displayName.startsWith('Device-')) {
        user.displayName = receivedUser.displayName;
      }

      await _saveUser(user);
      logInfo('✅ Updated device to online: ${user.displayName}');
    } else {
      // Fallback to creating new profile
      await _createNewDeviceProfile(receivedUser, isNewDevice: true);
    }
  }

  /// Process discovered device from scan request
  Future<void> _processDiscoveredDevice(DiscoveryScanRequest request) async {
    final existingUser = _discoveredUsers[request.fromUserId];
    final isInStorage = await _loadStoredUser(request.fromUserId) != null;

    if (existingUser != null) {
      // Update existing device info
      existingUser.ipAddress = request.ipAddress;
      existingUser.port = request.port;
      existingUser.isOnline = true;
      existingUser.lastSeen = DateTime.now();

      if (request.fromUserName.isNotEmpty &&
          !request.fromUserName.startsWith('Device-')) {
        existingUser.displayName = request.fromUserName;
      }
    } else {
      // Create new device profile
      final newUser = P2PUser(
        id: request.fromUserId,
        displayName: request.fromUserName.isNotEmpty
            ? request.fromUserName
            : 'Device-${request.fromUserId.substring(0, 8)}',
        appInstallationId: request.fromAppInstallationId,
        ipAddress: request.ipAddress,
        port: request.port,
        isOnline: true,
        lastSeen: DateTime.now(),
        isStored: isInStorage,
      );

      _discoveredUsers[request.fromUserId] = newUser;
    }
  }

  /// Manual discovery - now optimized to single broadcast
  Future<void> manualDiscovery() async {
    if (!_isEnabled || _currentUser == null) return;

    lastDiscoveryTime = DateTime.now();
    logInfo('🔍 Starting optimized manual discovery...');

    // Send discovery scan request
    await _sendDiscoveryScanRequest();

    logInfo('✅ Manual discovery scan request sent');
    notifyListeners();
  }

  /// Send discovery scan request (only one device needs to do this)
  Future<void> _sendDiscoveryScanRequest() async {
    if (_currentUser == null) return;

    try {
      final scanRequest = DiscoveryScanRequest(
        fromUserId: _currentUser!.id,
        fromUserName: _currentUser!.displayName,
        fromAppInstallationId: _currentUser!.appInstallationId,
        ipAddress: _currentUser!.ipAddress,
        port: _currentUser!.port,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      final requestData = {
        'type': 'discovery_scan_request',
        ...scanRequest.toJson(),
      };

      final data = utf8.encode(jsonEncode(requestData));

      // Create temporary socket for broadcasting
      final tempSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      tempSocket.broadcastEnabled = true;

      // Send to broadcast addresses
      final broadcastAddresses = _getBroadcastAddresses();

      for (final address in broadcastAddresses) {
        try {
          tempSocket.send(data, InternetAddress(address), 8082);
          logInfo('📡 Sent discovery scan request to: $address:8082');
        } catch (e) {
          logWarning('Failed to send to broadcast $address: $e');
        }
      }

      tempSocket.close();
      logInfo('📡 Discovery scan request broadcast completed');
    } catch (e) {
      logError('Failed to send discovery scan request: $e');
    }
  }

  /// Get broadcast addresses for discovery
  List<String> _getBroadcastAddresses() {
    final broadcastAddresses = <String>[
      '255.255.255.255', // Global broadcast
    ];

    // Add subnet broadcasts based on current IP
    final currentIP = _currentUser!.ipAddress;
    final ipParts = currentIP.split('.');
    if (ipParts.length == 4) {
      final subnet = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}.255';
      broadcastAddresses.add(subnet);
    }

    // Add common subnets
    if (!broadcastAddresses.contains('192.168.1.255')) {
      broadcastAddresses.add('192.168.1.255');
    }
    if (!broadcastAddresses.contains('192.168.0.255')) {
      broadcastAddresses.add('192.168.0.255');
    }

    return broadcastAddresses;
  }

  /// Legacy method for backward compatibility
  Future<void> _sendUDPAnnouncement() async {
    // Convert to new discovery scan request for backward compatibility
    await _sendDiscoveryScanRequest();
  }

  void _stopTimers() {
    _heartbeatTimer?.cancel();
    _cleanupTimer?.cancel();
    _broadcastTimer?.cancel();
    _isBroadcasting = false; // Reset broadcast state when stopping all timers
  }

  /// Toggle broadcast announcements on/off
  Future<void> toggleBroadcast() async {
    if (!_isEnabled || _currentUser == null) {
      logError('Cannot toggle broadcast: networking not enabled');
      return;
    }

    if (_isBroadcasting) {
      await _stopBroadcast();
    } else {
      await _startBroadcast();
    }
  }

  /// Start periodic broadcast announcements every 10 seconds
  Future<void> _startBroadcast() async {
    if (_isBroadcasting) return;

    try {
      // Initialize broadcast socket if not already done
      if (_broadcastSocket == null) {
        await _announceServiceViaBroadcast();
      }

      _isBroadcasting = true;

      // Send initial announcement immediately
      await _sendUDPAnnouncement();

      // Set up timer for periodic announcements every 10 seconds
      _broadcastTimer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (_isBroadcasting && _currentUser != null) {
          _sendUDPAnnouncement();
        }
      });

      logInfo('🎯 Broadcast started - sending announcements every 10 seconds');
      notifyListeners();
    } catch (e) {
      logError('Failed to start broadcast: $e');
      _isBroadcasting = false;
      notifyListeners();
    }
  }

  /// Stop periodic broadcast announcements
  Future<void> _stopBroadcast() async {
    _isBroadcasting = false;
    _broadcastTimer?.cancel();
    _broadcastTimer = null;

    logInfo('🔇 Broadcast stopped');
    notifyListeners();
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

  /// Handle incoming file transfer request
  Future<void> _handleFileTransferRequest(P2PMessage message) async {
    try {
      logInfo('📨 Received file transfer request JSON:');
      logInfo('  - totalSize in received JSON: ${message.data['totalSize']}');
      logInfo(
          '  - files count in JSON: ${(message.data['files'] as List).length}');

      final request = FileTransferRequest.fromJson(message.data);

      // Set received time to current local time (avoids timezone/clock skew issues)
      request.receivedTime = DateTime.now();

      logInfo(
          '📨 Received file transfer request from ${request.fromUserName} for ${request.files.length} files');
      logInfo('  - Parsed totalSize: ${request.totalSize} bytes');
      logInfo('  - Received time: ${request.receivedTime}');

      // Validate sender is paired
      final fromUser = _discoveredUsers[request.fromUserId];
      if (fromUser == null || !fromUser.isPaired) {
        await _sendFileTransferResponse(request, false,
            FileTransferRejectReason.unknown, 'User not paired');
        return;
      }

      // Check transfer settings and validate the request
      final validationResult =
          await _validateFileTransferRequest(request, fromUser);

      if (!validationResult.isValid) {
        await _sendFileTransferResponse(request, false,
            validationResult.rejectReason!, validationResult.rejectMessage!);
        return;
      }

      // If user is trusted, auto-accept
      if (fromUser.isTrusted) {
        logInfo(
            'Auto-accepting file transfer from trusted user: ${fromUser.displayName}');
        // Cancel timeout timer since we're auto-accepting
        _fileTransferRequestTimers[request.requestId]?.cancel();
        _fileTransferRequestTimers.remove(request.requestId);
        await _acceptFileTransferRequest(request);
        return;
      }

      // Add to pending requests and show dialog
      _pendingFileTransferRequests.add(request);
      await _saveFileTransferRequest(request);
      notifyListeners();

      // Trigger callback for auto-showing dialog
      if (_onNewFileTransferRequest != null) {
        _onNewFileTransferRequest!(request);
      }

      // Set timeout timer for user response and store it
      _fileTransferRequestTimers[request.requestId] =
          Timer(const Duration(seconds: 60), () {
        _handleFileTransferRequestTimeout(request.requestId);
      });
    } catch (e) {
      logError('Failed to handle file transfer request: $e');
    }
  }

  /// Handle file transfer response
  Future<void> _handleFileTransferResponse(P2PMessage message) async {
    try {
      final response = FileTransferResponse.fromJson(message.data);

      // Cancel timeout timer
      _fileTransferResponseTimers[response.requestId]?.cancel();
      _fileTransferResponseTimers.remove(response.requestId);

      // Find tasks for this batch
      final batchTasks = _activeTransfers.values
          .where((task) => task.batchId == response.batchId && task.isOutgoing)
          .toList();

      if (response.accepted) {
        logInfo(
            '✅ File transfer accepted by receiver for batch ${response.batchId}');

        // Start transferring files in the batch with concurrent limit
        await _startTransfersWithConcurrencyLimit(batchTasks);
      } else {
        logInfo('❌ File transfer rejected: ${response.rejectMessage}');

        // Cancel all tasks in the batch
        for (final task in batchTasks) {
          task.status = DataTransferStatus.rejected;
          task.errorMessage = response.rejectMessage ?? 'Transfer rejected';
          _cleanupTransfer(task.id);
        }
      }

      notifyListeners();
    } catch (e) {
      logError('Failed to handle file transfer response: $e');
    }
  }

  /// Validate file transfer request against settings
  Future<_FileTransferValidationResult> _validateFileTransferRequest(
      FileTransferRequest request, P2PUser fromUser) async {
    final settings = _transferSettings;
    if (settings == null) {
      return _FileTransferValidationResult.invalid(
          FileTransferRejectReason.unknown, 'Transfer settings not configured');
    }

    logInfo('📨 Validating file transfer request:');
    logInfo('  - Number of files: ${request.files.length}');
    logInfo(
        '  - Individual file sizes: ${request.files.map((f) => '${f.fileName}: ${f.fileSize} bytes').join(', ')}');
    logInfo('  - Request total size: ${request.totalSize} bytes');
    logInfo(
        '  - Settings max total size: ${settings.maxTotalReceiveSize} bytes');

    // Check total size limit
    if (request.totalSize > settings.maxTotalReceiveSize) {
      final maxSizeMB = settings.maxTotalReceiveSize ~/ (1024 * 1024);
      final requestSizeMB = request.totalSize / (1024 * 1024);
      return _FileTransferValidationResult.invalid(
          FileTransferRejectReason.totalSizeExceeded,
          'Total size ${requestSizeMB.toStringAsFixed(1)}MB exceeds limit ${maxSizeMB}MB');
    }

    // Check individual file size limits
    for (final file in request.files) {
      if (file.fileSize > settings.maxReceiveFileSize) {
        final maxSizeMB = settings.maxReceiveFileSize ~/ (1024 * 1024);
        final fileSizeMB = file.fileSize / (1024 * 1024);
        return _FileTransferValidationResult.invalid(
            FileTransferRejectReason.fileSizeExceeded,
            'File ${file.fileName} size ${fileSizeMB.toStringAsFixed(1)}MB exceeds limit ${maxSizeMB}MB');
      }
    }

    return _FileTransferValidationResult.valid();
  }

  /// Send file transfer response
  Future<void> _sendFileTransferResponse(
      FileTransferRequest request,
      bool accepted,
      FileTransferRejectReason? rejectReason,
      String? rejectMessage) async {
    final targetUser = _discoveredUsers[request.fromUserId];
    if (targetUser == null) {
      logError('Cannot send response: target user not found');
      return;
    }

    String? downloadPath;
    if (accepted && _transferSettings != null) {
      downloadPath = _transferSettings!.downloadPath;

      // Create date folder if enabled
      if (_transferSettings!.createDateFolders) {
        final dateFolder =
            DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
        downloadPath = '$downloadPath${Platform.pathSeparator}$dateFolder';

        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
          logInfo('Created date folder: $downloadPath');
        }
      }
    }

    final response = FileTransferResponse(
      requestId: request.requestId,
      batchId: request.batchId,
      accepted: accepted,
      rejectReason: rejectReason,
      rejectMessage: rejectMessage,
      downloadPath: downloadPath,
    );

    final message = P2PMessage(
      type: P2PMessageTypes.fileTransferResponse,
      fromUserId: _currentUser!.id,
      toUserId: request.fromUserId,
      data: response.toJson(),
    );

    await _sendMessage(targetUser, message);
    logInfo('Sent file transfer response: accepted=$accepted');
  }

  /// Accept file transfer request (for trusted users or manual approval)
  Future<void> _acceptFileTransferRequest(FileTransferRequest request) async {
    // Calculate downloadPath with date folder
    String? downloadPath;
    if (_transferSettings != null) {
      downloadPath = _transferSettings!.downloadPath;

      // Create date folder if enabled
      if (_transferSettings!.createDateFolders) {
        final dateFolder =
            DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD
        downloadPath = '$downloadPath${Platform.pathSeparator}$dateFolder';

        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
          logInfo('Created date folder for accepted request: $downloadPath');
        }
      }
    }

    // Store downloadPath for future incoming tasks in this batch
    if (downloadPath != null) {
      _batchDownloadPaths[request.batchId] = downloadPath;
      logInfo(
          'Stored downloadPath for batch ${request.batchId}: $downloadPath');
    }

    // Map sender user to this batch for incoming tasks
    _activeBatchIdsByUser[request.fromUserId] = request.batchId;
    logInfo('Mapped user ${request.fromUserId} to batch ${request.batchId}');

    await _sendFileTransferResponse(request, true, null, null);

    // Remove from pending list
    _pendingFileTransferRequests
        .removeWhere((r) => r.requestId == request.requestId);

    // Mark request as processed and remove from storage
    try {
      final requestsBox =
          await Hive.openBox<FileTransferRequest>('file_transfer_requests');
      await requestsBox.delete(request.requestId);
      logInfo(
          'Removed processed file transfer request from storage: ${request.requestId}');
    } catch (e) {
      logError('Failed to remove file transfer request from storage: $e');

      // If it's a type error from corrupted data, clear the box
      if (e.toString().contains('is not a subtype of type')) {
        try {
          logWarning(
              'Detected corrupted file transfer requests box, clearing...');
          await Hive.deleteBoxFromDisk('file_transfer_requests');
          logInfo('Cleared corrupted file_transfer_requests box');
        } catch (cleanupError) {
          logError('Failed to clear corrupted box: $cleanupError');
        }
      }
    }

    notifyListeners();
  }

  /// Save file transfer request to storage
  Future<void> _saveFileTransferRequest(FileTransferRequest request) async {
    try {
      final box =
          await Hive.openBox<FileTransferRequest>('file_transfer_requests');
      await box.put(request.requestId, request);
      logInfo('Saved file transfer request to storage: ${request.requestId}');
    } catch (e) {
      logError('Failed to save file transfer request: $e');

      // If it's a type error from corrupted data, clear the box and retry
      if (e.toString().contains('is not a subtype of type')) {
        try {
          logWarning(
              'Detected corrupted file transfer requests box, clearing and retrying...');
          await Hive.deleteBoxFromDisk('file_transfer_requests');

          // Retry after clearing
          final box =
              await Hive.openBox<FileTransferRequest>('file_transfer_requests');
          await box.put(request.requestId, request);
          logInfo(
              'Successfully saved file transfer request after cleanup: ${request.requestId}');
        } catch (retryError) {
          logError(
              'Failed to save file transfer request even after cleanup: $retryError');
        }
      }
    }
  }

  /// Handle file transfer request timeout (user didn't respond)
  void _handleFileTransferRequestTimeout(String requestId) {
    // Remove timer from map first
    _fileTransferRequestTimers.remove(requestId);

    // Find the request, return early if not found (already processed)
    final request = _pendingFileTransferRequests
        .where((r) => r.requestId == requestId)
        .firstOrNull;

    if (request == null) {
      logInfo(
          'File transfer request $requestId already processed, skipping timeout');
      return;
    }

    logInfo('File transfer request timed out: ${request.requestId}');

    // Send rejection response
    _sendFileTransferResponse(request, false, FileTransferRejectReason.timeout,
        'Request timed out (no response)');

    // Remove from pending list
    _pendingFileTransferRequests.removeWhere((r) => r.requestId == requestId);

    // Remove from storage
    Hive.openBox<FileTransferRequest>('file_transfer_requests').then((box) {
      box.delete(requestId);
    }).catchError((e) {
      logError('Failed to remove file transfer request from storage: $e');

      // If it's a type error from corrupted data, clear the box
      if (e.toString().contains('is not a subtype of type')) {
        Hive.deleteBoxFromDisk('file_transfer_requests').then((_) {
          logInfo('Cleared corrupted file_transfer_requests box');
        }).catchError((cleanupError) {
          logError('Failed to clear corrupted box: $cleanupError');
        });
      }
    });

    notifyListeners();
  }

  Future<void> _performCleanup() async {
    if (_currentUser == null) return;

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
      case P2PMessageTypes.fileTransferRequest:
        await _handleFileTransferRequest(message);
        break;
      case P2PMessageTypes.fileTransferResponse:
        await _handleFileTransferResponse(message);
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

    // Use the new discovery logic for processing the discovered user
    await _processDiscoveredDevice(DiscoveryScanRequest(
      fromUserId: discoveredUser.id,
      fromUserName: discoveredUser.displayName,
      fromAppInstallationId: discoveredUser.appInstallationId,
      ipAddress: discoveredUser.ipAddress,
      port: discoveredUser.port,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));

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

        // Get batchId for this incoming transfer
        final batchId = _activeBatchIdsByUser[message.fromUserId];
        logInfo(
            'Creating incoming task with batchId: $batchId for user ${message.fromUserId}');

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
          batchId: batchId,
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

      // Get download path - check if we have a batch-specific path first
      String downloadPath;
      logInfo('🗂️ Determining download path for task ${task.id}:');
      logInfo('  - Task batchId: ${task.batchId}');
      logInfo(
          '  - Available batch paths: ${_batchDownloadPaths.keys.toList()}');
      logInfo(
          '  - Settings createDateFolders: ${_transferSettings?.createDateFolders}');

      if (task.batchId != null &&
          _batchDownloadPaths.containsKey(task.batchId)) {
        downloadPath = _batchDownloadPaths[task.batchId]!;
        logInfo('✅ Using batch-specific downloadPath: $downloadPath');
      } else if (_transferSettings != null) {
        downloadPath = _transferSettings!.downloadPath;
        logInfo(
            '⚠️ Using default downloadPath (no batch path found): $downloadPath');
      } else {
        // Default to Downloads folder
        downloadPath = Platform.isWindows
            ? '${Platform.environment['USERPROFILE']}\\Downloads'
            : '${Platform.environment['HOME']}/Downloads';
        logInfo('⚠️ Using fallback downloadPath: $downloadPath');
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

      // Update the task to completed state
      task.status = DataTransferStatus.completed;
      task.completedAt = DateTime.now();
      task.filePath = filePath; // Update final path
      task.savePath = filePath;
      task.transferredBytes = fileData.length; // Finalize byte count
      logInfo('✅ ASSEMBLE: Updated task $taskId to completed state.');

      // Clean up
      _incomingFileChunks.remove(taskId);

      // Clean up batch download path if this was the last file in the batch
      if (task.batchId != null &&
          _batchDownloadPaths.containsKey(task.batchId)) {
        final remainingTasksInBatch = _activeTransfers.values
            .where((t) =>
                t.batchId == task.batchId &&
                !t.isOutgoing &&
                t.status != DataTransferStatus.completed &&
                t.status != DataTransferStatus.cancelled &&
                t.status != DataTransferStatus.failed)
            .length;

        if (remainingTasksInBatch == 0) {
          _batchDownloadPaths.remove(task.batchId);

          // Also clean up user batch mapping
          final userToRemove = _activeBatchIdsByUser.entries
              .where((entry) => entry.value == task.batchId)
              .map((entry) => entry.key)
              .firstOrNull;
          if (userToRemove != null) {
            _activeBatchIdsByUser.remove(userToRemove);
            logInfo('Cleaned up user batch mapping for $userToRemove');
          }

          logInfo('Cleaned up batch downloadPath for ${task.batchId}');
        }
      }

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

  /// Start transfers with concurrency limit
  Future<void> _startTransfersWithConcurrencyLimit(
      List<DataTransferTask> tasks) async {
    final maxConcurrent = _transferSettings?.maxConcurrentTasks ?? 3;

    // Count currently running outgoing transfers
    final currentlyRunning = _activeTransfers.values
        .where(
            (t) => t.isOutgoing && t.status == DataTransferStatus.transferring)
        .length;

    int availableSlots = maxConcurrent - currentlyRunning;
    logInfo(
        'Starting transfers: max=$maxConcurrent, running=$currentlyRunning, available=$availableSlots');

    // Start as many tasks as we have available slots
    for (int i = 0; i < tasks.length && availableSlots > 0; i++) {
      final task = tasks[i];
      final targetUser = _discoveredUsers[task.targetUserId];

      if (targetUser != null) {
        logInfo(
            'Starting transfer for ${task.fileName} (${i + 1}/${tasks.length})');
        task.status = DataTransferStatus.transferring;
        await _startDataTransfer(task, targetUser);
        availableSlots--;
      }
    }

    // Queue remaining tasks
    final queuedTasks = tasks.skip(maxConcurrent - currentlyRunning).toList();
    if (queuedTasks.isNotEmpty) {
      for (final task in queuedTasks) {
        task.status = DataTransferStatus.pending;
        logInfo(
            'Queued transfer for ${task.fileName} (will start when slot available)');
      }
    }
  }

  Future<void> _startDataTransfer(
      DataTransferTask task, P2PUser targetUser) async {
    try {
      task.status = DataTransferStatus.transferring;
      task.startedAt = DateTime.now();

      final chunkSizeKB = _transferSettings?.maxChunkSize ?? 512;
      final chunkSizeBytes = chunkSizeKB * 1024;
      logInfo(
          'Starting transfer for ${task.fileName} with chunk size: ${chunkSizeKB}KB (${chunkSizeBytes} bytes) - Settings value: ${_transferSettings?.maxChunkSize}');

      // Create isolate for data transfer
      final receivePort = ReceivePort();
      _transferPorts[task.id] = receivePort;

      final isolate = await Isolate.spawn(
        _staticDataTransferIsolate,
        {
          'sendPort': receivePort.sendPort,
          'task': task.toJson(),
          'targetUser': targetUser.toJson(),
          'currentUserId': _currentUser!.id,
          'encryptionKey': _encryptionKey.base64,
          'maxChunkSize': (_transferSettings?.maxChunkSize ?? 512) *
              1024, // Convert KB to bytes
          'protocol': task.batchId != null
              ? await _getProtocolForBatch(task.batchId!)
              : 'tcp',
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

  static void _staticDataTransferIsolate(Map<String, dynamic> params) async {
    final sendPort = params['sendPort'] as SendPort;
    Socket? tcpSocket; // For TCP transfers
    RawDatagramSocket? udpSocket; // For UDP transfers

    try {
      // Parse parameters
      final taskData = params['task'] as Map<String, dynamic>;
      final targetUserData = params['targetUser'] as Map<String, dynamic>;
      final currentUserId = params['currentUserId'] as String;
      final maxChunkSizeFromSettings = (params['maxChunkSize'] as int? ??
          512 * 1024); // Already converted to bytes
      final protocol = params['protocol'] as String? ?? 'tcp';

      final task = DataTransferTask.fromJson(taskData);
      final targetUser = P2PUser.fromJson(targetUserData);

      sendPort.send({
        'info':
            'Using maxChunkSize from settings: ${maxChunkSizeFromSettings ~/ 1024}KB (${maxChunkSizeFromSettings} bytes)'
      });

      sendPort.send({'info': 'Using protocol: $protocol'});

      // Initialize connection based on protocol
      if (protocol.toLowerCase() == 'udp') {
        udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        sendPort.send({'info': 'UDP socket bound to port ${udpSocket!.port}'});
      } else {
        // Default to TCP
        tcpSocket = await Socket.connect(
          targetUser.ipAddress,
          targetUser.port,
          timeout: const Duration(seconds: 10),
        );
        sendPort.send({'info': 'TCP connection established'});
      }

      // Read file
      final file = File(task.filePath);
      if (!await file.exists()) {
        sendPort.send({'error': 'File does not exist: ${task.filePath}'});
        return;
      }

      final fileBytes = await file.readAsBytes();
      int totalSent = 0;

      // Dynamic chunking parameters
      int chunkSize = min(32 * 1024,
          maxChunkSizeFromSettings); // Start with 32KB or setting max, whichever is smaller
      final int maxChunkSize = maxChunkSizeFromSettings; // Use setting value
      int successfulChunksInRow = 0;
      Duration delay = const Duration(milliseconds: 50);

      sendPort.send({
        'info':
            'Starting transfer with initial chunk size: ${chunkSize ~/ 1024}KB, max: ${maxChunkSize ~/ 1024}KB'
      });

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

          // Send based on protocol
          if (protocol.toLowerCase() == 'udp') {
            // UDP: Send message directly (no length header needed)
            final targetAddress = InternetAddress(targetUser.ipAddress);
            udpSocket!.send(messageBytes, targetAddress, targetUser.port);
          } else {
            // TCP: Send with length header
            final lengthHeader = ByteData(4)
              ..setUint32(0, messageBytes.length, Endian.big);
            tcpSocket!.add(lengthHeader.buffer.asUint8List());
            tcpSocket.add(messageBytes);
            await tcpSocket.flush();
          }

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

          // Re-establish connection based on protocol
          if (protocol.toLowerCase() == 'udp') {
            // UDP doesn't need reconnection, just continue
            sendPort.send({'info': 'UDP error recovery, continuing...'});
          } else {
            // TCP: Re-establish connection
            await tcpSocket?.close();
            tcpSocket = await Socket.connect(
                targetUser.ipAddress, targetUser.port,
                timeout: const Duration(seconds: 10));
          }

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
      await tcpSocket?.close();
      udpSocket?.close();
    }
  }

  void _cleanupTransfer(String taskId) {
    final isolate = _transferIsolates.remove(taskId);
    isolate?.kill();

    final port = _transferPorts.remove(taskId);
    port?.close();

    // Check if we can start any queued transfers
    _startNextQueuedTransfer();
  }

  /// Get protocol for a specific batch based on stored FileTransferRequest
  Future<String> _getProtocolForBatch(String batchId) async {
    try {
      final box =
          await Hive.openBox<FileTransferRequest>('file_transfer_requests');
      for (final request in box.values) {
        if (request.batchId == batchId) {
          return request.protocol;
        }
      }
      return 'tcp'; // Default fallback
    } catch (e) {
      logWarning('Failed to get protocol for batch $batchId: $e');
      return 'tcp';
    }
  }

  /// Start next queued transfer if there are available slots
  void _startNextQueuedTransfer() async {
    final maxConcurrent = _transferSettings?.maxConcurrentTasks ?? 3;

    // Count currently running outgoing transfers
    final currentlyRunning = _activeTransfers.values
        .where(
            (t) => t.isOutgoing && t.status == DataTransferStatus.transferring)
        .length;

    if (currentlyRunning >= maxConcurrent) {
      return; // No available slots
    }

    // Find next pending outgoing task
    final pendingTask = _activeTransfers.values
        .where((t) => t.isOutgoing && t.status == DataTransferStatus.pending)
        .firstOrNull;

    if (pendingTask != null) {
      final targetUser = _discoveredUsers[pendingTask.targetUserId];
      if (targetUser != null) {
        logInfo('Starting queued transfer for ${pendingTask.fileName}');
        pendingTask.status = DataTransferStatus.transferring;
        await _startDataTransfer(pendingTask, targetUser);
      }
    }
  }

  Future<void> _cancelAllTransfers() async {
    for (final taskId in _activeTransfers.keys.toList()) {
      final task = _activeTransfers[taskId];
      if (task != null && task.status == DataTransferStatus.transferring) {
        task.status = DataTransferStatus.cancelled;
        task.errorMessage = 'Transfer cancelled during network stop';
        _cleanupTransfer(taskId);
      }
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

  /// Add trust to user (manually trust without request)
  Future<bool> addTrust(String userId) async {
    try {
      final user = _discoveredUsers[userId];
      if (user == null) return false;

      user.isTrusted = true;
      await _saveUser(user);

      notifyListeners();
      logInfo('Added trust to user: ${user.displayName}');
      return true;
    } catch (e) {
      logError('Failed to add trust: $e');
      return false;
    }
  }

  /// Create default transfer settings
  P2PDataTransferSettings _createDefaultTransferSettings() {
    // Get default download path based on platform
    String defaultDownloadPath;
    if (Platform.isWindows) {
      defaultDownloadPath = '${Platform.environment['USERPROFILE']}\\Downloads';
    } else if (Platform.isAndroid) {
      defaultDownloadPath = '/storage/emulated/0/Download';
    } else {
      defaultDownloadPath = '${Platform.environment['HOME']}/Downloads';
    }

    return P2PDataTransferSettings(
      downloadPath: defaultDownloadPath,
      createDateFolders: true,
      maxReceiveFileSize: 100 * 1024 * 1024, // 100MB
      maxTotalReceiveSize: 1 * 1024 * 1024 * 1024, // 1GB
      maxConcurrentTasks: 3,
      sendProtocol: 'TCP',
      maxChunkSize: 512, // 512KB
    );
  }

  /// Update transfer settings
  Future<bool> updateTransferSettings(P2PDataTransferSettings settings) async {
    try {
      final box =
          await Hive.openBox<P2PDataTransferSettings>('p2p_transfer_settings');
      await box.put('settings', settings); // Use fixed key instead of add
      _transferSettings = settings;

      logInfo('Updated transfer settings: ${settings.toJson()}');
      return true;
    } catch (e) {
      logError('Failed to update transfer settings: $e');

      // If it's a type error from corrupted data, try to clean up and retry
      if (e.toString().contains('is not a subtype of type')) {
        try {
          logWarning(
              'Detected data type error, attempting to clear corrupted boxes...');

          // Delete corrupted boxes
          await Hive.deleteBoxFromDisk('p2p_transfer_settings');
          await Hive.deleteBoxFromDisk('file_transfer_requests');

          logInfo('Cleared corrupted boxes, retrying...');

          // Retry after clearing
          final box = await Hive.openBox<P2PDataTransferSettings>(
              'p2p_transfer_settings');
          await box.put('settings', settings);
          _transferSettings = settings;

          logInfo('Successfully updated transfer settings after cleanup');
          return true;
        } catch (retryError) {
          logError('Failed to update settings even after cleanup: $retryError');
          return false;
        }
      }

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
      maxReceiveFileSize: settings.maxFileSize * 1024 * 1024, // MB to Bytes
      maxTotalReceiveSize:
          1 * 1024 * 1024 * 1024, // Default 1GB in bytes for old settings
      maxConcurrentTasks: 3,
      sendProtocol: 'TCP', // Default
      maxChunkSize: 512, // Default 512KB
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

  /// Send multiple files to user with approval request
  Future<bool> sendMultipleFilesToUser(
      List<String> filePaths, P2PUser targetUser) async {
    return await sendMultipleFiles(filePaths, targetUser);
  }

  /// Respond to file transfer request
  Future<bool> respondToFileTransferRequest(
      String requestId, bool accept, String? rejectMessage) async {
    try {
      final request = _pendingFileTransferRequests
          .firstWhere((r) => r.requestId == requestId);

      // Cancel timeout timer before processing response
      _fileTransferRequestTimers[requestId]?.cancel();
      _fileTransferRequestTimers.remove(requestId);

      if (accept) {
        await _acceptFileTransferRequest(request);
      } else {
        await _sendFileTransferResponse(
            request,
            false,
            FileTransferRejectReason.userRejected,
            rejectMessage ?? 'Rejected by user');

        // Remove from pending list
        _pendingFileTransferRequests
            .removeWhere((r) => r.requestId == requestId);

        // Remove from storage
        try {
          final requestsBox =
              await Hive.openBox<FileTransferRequest>('file_transfer_requests');
          await requestsBox.delete(requestId);
        } catch (e) {
          logError('Failed to remove file transfer request from storage: $e');

          // If it's a type error from corrupted data, clear the box
          if (e.toString().contains('is not a subtype of type')) {
            try {
              logWarning(
                  'Detected corrupted file transfer requests box, clearing...');
              await Hive.deleteBoxFromDisk('file_transfer_requests');
              logInfo('Cleared corrupted file_transfer_requests box');
            } catch (cleanupError) {
              logError('Failed to clear corrupted box: $cleanupError');
            }
          }
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      logError('Failed to respond to file transfer request: $e');
      return false;
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

  /// Remove stored user from storage
  Future<void> _removeStoredUser(String userId) async {
    try {
      final userBox = await HiveService.getBox<P2PUser>('p2p_users');
      await userBox.delete(userId);
      logInfo('🗑️ Removed stored user: $userId');
    } catch (e) {
      logError('Failed to remove stored user $userId: $e');
    }
  }

  /// Load stored user from storage
  Future<P2PUser?> _loadStoredUser(String userId) async {
    try {
      final userBox = await HiveService.getBox<P2PUser>('p2p_users');
      final user = userBox.get(userId);
      return user;
    } catch (e) {
      logWarning('Failed to load stored user $userId: $e');
      return null;
    }
  }

  /// Stop discovery services
  Future<void> _stopDiscovery() async {
    try {
      _isDiscovering = false;

      // Close UDP listener socket
      _udpListenerSocket?.close();
      _udpListenerSocket = null;

      // Close broadcast socket
      _broadcastSocket?.close();
      _broadcastSocket = null;

      logInfo('Discovery services stopped');
    } catch (e) {
      logError('Error stopping discovery: $e');
    }
  }

  /// Process enhanced announcement for backward compatibility
  Future<void> _processEnhancedAnnouncement(Map<String, dynamic> data) async {
    try {
      final userId = data['userId'] as String;
      final userName = data['userName'] as String?;
      final ipAddress = data['ipAddress'] as String;
      final port = data['port'] as int;

      if (userId == _currentUser?.id) {
        return; // Ignore our own announcements
      }

      // Convert to discovery scan request format
      final scanRequest = DiscoveryScanRequest(
        fromUserId: userId,
        fromUserName: userName ?? 'Device-${userId.substring(0, 8)}',
        fromAppInstallationId: userId,
        ipAddress: ipAddress,
        port: port,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      await _processDiscoveredDevice(scanRequest);
      logInfo('Processed legacy announcement from ${scanRequest.fromUserName}');
    } catch (e) {
      logError('Error processing enhanced announcement: $e');
    }
  }

  /// Initialize broadcast service for backward compatibility
  Future<void> _announceServiceViaBroadcast() async {
    try {
      if (_broadcastSocket != null) {
        return;
      }

      _broadcastSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      _broadcastSocket!.broadcastEnabled = true;
      logInfo(
          'Broadcast service initialized on port ${_broadcastSocket!.port}');
    } catch (e) {
      logError('Failed to initialize broadcast service: $e');
    }
  }
}
