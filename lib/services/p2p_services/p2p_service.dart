import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:multicast_dns/multicast_dns.dart';
import 'package:path_provider/path_provider.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/network_security_service.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/p2p_settings_adapter.dart';
import 'package:setpocket/services/p2p_services/p2p_notification_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:workmanager/workmanager.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';
import 'package:setpocket/utils/isar_utils.dart';

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

  // Private constructor
  P2PService._();

  // Public getter for the instance
  static P2PService get instance {
    _instance ??= P2PService._();
    return _instance!;
  }

  // Initialization method
  static Future<void> init() async {
    // Get singleton instance and initialize it.
    // The initialize() method itself handles the "already initialized" case.
    await instance.initialize();
  }

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

  // Store total file counts for each batch to ensure proper cleanup.
  final Map<String, int> _batchFileCounts = {};

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
  static const Duration _heartbeatInterval = Duration(seconds: 60);
  static const Duration _cleanupInterval =
      Duration(seconds: 5); // More frequent cleanup for faster detection
  static const Duration _offlineTimeout = Duration(
      seconds: 150); // Mark offline after 150s (2.5x heartbeat interval)

  // Timers - Keep only essential ones
  Timer? _heartbeatTimer; // Keep for paired devices
  Timer? _cleanupTimer; // Keep for cleanup
  Timer? _broadcastTimer; // New: Timer for periodic broadcast
  Timer? _memoryCleanupTimer; // 🔥 NEW: Timer for periodic memory cleanup
  Timer? _autoDiscoveryTimer; // 🔥 NEW: Timer for periodic auto discovery

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

  /// Check if notifications are available and should be used
  bool get _shouldUseNotifications {
    // Check if notifications are enabled in settings
    if (_transferSettings?.enableNotifications != true) {
      return false;
    }

    // Check if notification service is available
    final notificationService = P2PNotificationService.instanceOrNull;
    if (notificationService == null) {
      return false;
    }

    // Check if service is ready (initialized + permissions)
    return notificationService.isReady;
  }

  /// Safe wrapper for notification service calls
  Future<void> _safeNotificationCall(Future<void> Function() operation) async {
    if (!_shouldUseNotifications) {
      return; // Skip notification call entirely
    }

    try {
      await operation();
    } catch (e) {
      logWarning('Notification service call failed: $e');
    }
  }

  /// Safe wrapper for synchronous notification service calls
  void _safeNotificationCallSync(void Function() operation) {
    if (!_shouldUseNotifications) {
      return; // Skip notification call entirely
    }

    try {
      operation();
    } catch (e) {
      logWarning('Notification service call failed: $e');
    }
  }

  /// Initialize P2P service
  Future<void> initialize() async {
    if (_isServiceInitialized) {
      logInfo('P2P Service already initialized, skipping.');
      return;
    }
    _isServiceInitialized = true;
    logInfo('P2P Service initializing...');

    try {
      // Initialize encryption
      _initializeEncryption();

      // Initialize notifications service before any other P2P operations
      try {
        await P2PNotificationService.init();
        logInfo('P2P notification service initialized');
      } catch (e) {
        logError('Failed to initialize P2P notification service: $e');
      }

      // Load data from Isar instead of Hive
      await _loadTransferSettings();
      await _loadStoredUsers();
      await _loadPendingRequests();
      await _loadActiveTransfers();
      await _loadPendingFileTransferRequests();

      // Initialize Android-specific paths if needed
      await _initializeAndroidPath();

      logInfo('P2P Service initialized successfully');
    } catch (e) {
      _isServiceInitialized = false; // Allow re-initialization on failure
      logError('Failed to initialize P2P service: $e');
      rethrow;
    }
  }

  /// Load transfer settings using P2PSettingsAdapter
  Future<void> _loadTransferSettings() async {
    try {
      _transferSettings = await P2PSettingsAdapter.getSettings();
      logInfo('Loaded P2P transfer settings via adapter');
    } catch (e) {
      logError('Failed to load P2P transfer settings: $e');
      // Create fallback settings
      final dir = await getApplicationDocumentsDirectory();
      _transferSettings = P2PDataTransferSettings(
          downloadPath: '${dir.path}${Platform.pathSeparator}downloads',
          createDateFolders: false,
          maxReceiveFileSize: 1024 * 1024 * 1024,
          maxTotalReceiveSize: 5 * 1024 * 1024 * 1024,
          maxConcurrentTasks: 3,
          sendProtocol: 'TCP',
          maxChunkSize: 1024,
          createSenderFolders: true,
          uiRefreshRateSeconds: 0,
          enableNotifications: true);
      // Try to save through adapter
      try {
        await P2PSettingsAdapter.updateSettings(_transferSettings!);
        logInfo('Created and saved default P2P settings via adapter');
      } catch (saveError) {
        logWarning('Failed to save default settings: $saveError');
      }
    }
  }

  /// Save current transfer settings using P2PSettingsAdapter
  Future<void> _saveTransferSettings() async {
    if (_transferSettings == null) return;
    try {
      await P2PSettingsAdapter.updateSettings(_transferSettings!);
      logInfo('Saved P2P transfer settings via adapter');
    } catch (e) {
      logError('Failed to save P2P transfer settings: $e');
    }
  }

  /// Load stored users from Isar
  Future<void> _loadStoredUsers() async {
    final isar = IsarService.isar;
    final users = await isar.p2PUsers.filter().isStoredEqualTo(true).findAll();
    _discoveredUsers.clear();
    for (final user in users) {
      user.isOnline = false;
      _discoveredUsers[user.id] = user;
    }
    logInfo('Loaded ${_discoveredUsers.length} stored users from Isar.');
  }

  /// Load pending pairing requests from Isar
  Future<void> _loadPendingRequests() async {
    final isar = IsarService.isar;
    final reqs =
        await isar.pairingRequests.filter().isProcessedEqualTo(false).findAll();
    _pendingRequests.clear();
    _pendingRequests.addAll(reqs);
    logInfo('Loaded ${_pendingRequests.length} pending pairing requests.');
  }

  /// Load active (unfinished) data transfer tasks from Isar
  Future<void> _loadActiveTransfers() async {
    final isar = IsarService.isar;
    final tasks = await isar.dataTransferTasks
        .filter()
        .not()
        .statusEqualTo(DataTransferStatus.completed)
        .and()
        .not()
        .statusEqualTo(DataTransferStatus.failed)
        .and()
        .not()
        .statusEqualTo(DataTransferStatus.cancelled)
        .and()
        .not()
        .statusEqualTo(DataTransferStatus.rejected)
        .findAll();
    _activeTransfers.clear();
    for (final task in tasks) {
      _activeTransfers[task.id] = task;
    }
    logInfo('Loaded ${_activeTransfers.length} active transfers.');
  }

  /// Load pending file transfer requests from Isar
  Future<void> _loadPendingFileTransferRequests() async {
    final isar = IsarService.isar;
    _pendingFileTransferRequests.clear();
    final requests = await isar.fileTransferRequests.where().findAll();
    _pendingFileTransferRequests.addAll(requests);
    logInfo(
        'Loaded ${_pendingFileTransferRequests.length} pending file transfer requests.');
  }

  /// Save a user to Isar storage
  Future<void> _saveUser(P2PUser user) async {
    try {
      // Ensure user is marked as stored when saving to storage
      user.isStored = true;

      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.p2PUsers.put(user);
      });
      logInfo(
          'Saved user to storage: ${user.displayName} (stored: ${user.isStored}, paired: ${user.isPaired}, trusted: ${user.isTrusted})');
    } catch (e) {
      logError('Failed to save user: $e');
    }
  }

  /// Remove a user from Isar storage
  Future<void> _removeUser(String userId) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() => isar.p2PUsers.delete(fastHash(userId)));
  }

  /// Load a single stored user from Isar
  Future<P2PUser?> _loadStoredUser(String userId) async {
    return await IsarService.isar.p2PUsers.get(fastHash(userId));
  }

  /// Save a pairing request to Isar
  Future<void> _savePairingRequest(PairingRequest request) async {
    try {
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.pairingRequests.put(request);
      });
    } catch (e) {
      logError('Failed to save pairing request: $e');
    }
  }

  /// Update a pairing request in Isar
  Future<void> _updatePairingRequest(PairingRequest request) async {
    await _savePairingRequest(request);
  }

  /// Remove pairing request from isar
  Future<void> _removePairingRequest(String requestId) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() => isar.pairingRequests.delete(fastHash(requestId)));
  }

  /// Save a data transfer task to Isar
  Future<void> _saveTask(DataTransferTask task) async {
    final isar = IsarService.isar;
    await isar.writeTxn(() => isar.dataTransferTasks.put(task));
  }

  /// Save file transfer request to storage
  Future<void> _saveFileTransferRequest(FileTransferRequest request) async {
    try {
      await IsarService.isar
          .writeTxn(() => IsarService.isar.fileTransferRequests.put(request));
      logInfo('Saved file transfer request to storage: ${request.requestId}');
    } catch (e) {
      logError('Failed to save file transfer request: $e');
    }
  }

  /// Remove file transfer request from storage
  Future<void> _removeFileTransferRequest(String requestId) async {
    try {
      await IsarService.isar.writeTxn(() =>
          IsarService.isar.fileTransferRequests.delete(fastHash(requestId)));
      logInfo('Removed file transfer request from storage: ${requestId}');
    } catch (e) {
      logError('Failed to remove file transfer request: $e');
    }
  }

  /// Deletes all P2P-related data from Isar.
  Future<void> clearAllP2PData() async {
    final isar = IsarService.isar;
    await isar.writeTxn(() async {
      await isar.p2PUsers.clear();
      await isar.pairingRequests.clear();
      await isar.dataTransferTasks.clear();
      await isar.fileTransferRequests.clear();
    });
    _discoveredUsers.clear();
    _pendingRequests.clear();
    _activeTransfers.clear();
    logInfo('All P2P data has been cleared from Isar.');
    notifyListeners();
  }

  /// Enable P2P service
  Future<void> enable() async {
    if (_isEnabled) return;

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

    // Create current user profile
    await _createCurrentUser(_currentNetworkInfo!);

    // Start server
    await _startServer();

    // Start mDNS discovery
    await _startDiscovery();

    // 🔥 FIXED: Auto scan ngay khi enable network để phát hiện thiết bị có sẵn
    await Future.delayed(const Duration(seconds: 1)); // Đợi listener ready
    await manualDiscovery(); // Tự động scan

    // Start timers - heartbeat and cleanup
    _heartbeatTimer =
        Timer.periodic(_heartbeatInterval, (_) => _sendHeartbeats());
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) => _performCleanup());

    // 🔥 NEW: Start periodic memory cleanup timer (every 5 minutes)
    _memoryCleanupTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => _cleanupMemory());

    // 🔥 NEW: Start periodic auto discovery timer (every 2 minutes)
    _autoDiscoveryTimer = Timer.periodic(const Duration(minutes: 2), (_) async {
      if (_isEnabled && _currentUser != null) {
        logInfo('🔄 Periodic auto discovery');
        await manualDiscovery();
      }
    });

    _isEnabled = true;
    _connectionStatus = ConnectionStatus.discovering;

    // Register background task to keep the service alive on mobile
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Workmanager().registerPeriodicTask(
        "p2pKeepAliveUniqueName", // Unique name for the task
        p2pKeepAliveTask, // The task defined in main.dart
        frequency: const Duration(minutes: 15), // Minimum frequency
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );
      logInfo('Registered P2P keep-alive background task.');
    }

    // Show P2LAN status notification
    if (_currentUser != null) {
      await _safeNotificationCall(
          () => P2PNotificationService.instance.showP2LanStatus(
                deviceName: _currentUser!.displayName,
                ipAddress: _currentUser!.ipAddress,
                connectedDevices: pairedUsers.length,
              ));
    }

    notifyListeners();
    logInfo('P2P networking started');
  }

  /// Stop P2P networking
  Future<void> stopNetworking() async {
    if (!_isEnabled) return;

    // Immediately hide the status notification for quick user feedback
    await _safeNotificationCall(
        () => P2PNotificationService.instance.hideP2LanStatus());

    // Cancel the background task first on mobile
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Workmanager().cancelByUniqueName("p2pKeepAliveUniqueName");
      logInfo('Cancelled P2P keep-alive background task.');
    }

    await _stopServer();
    await _stopDiscovery();

    // Cancel timers
    _heartbeatTimer?.cancel();
    _cleanupTimer?.cancel();
    _broadcastTimer?.cancel();
    _memoryCleanupTimer?.cancel(); // 🔥 NEW: Cancel memory cleanup timer
    _autoDiscoveryTimer?.cancel(); // 🔥 NEW: Cancel auto discovery timer
    _isBroadcasting = false; // Reset broadcast state when stopping all timers

    // Send disconnect notifications to all paired users before stopping
    await _sendDisconnectNotifications();

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
    _batchDownloadPaths.clear();
    _batchFileCounts.clear();
    _activeBatchIdsByUser.clear();

    // Clean up task creation locks
    _taskCreationLocks.clear();

    // Hide P2LAN status notification
    await _safeNotificationCall(
        () => P2PNotificationService.instance.hideP2LanStatus());

    // Reset state flags to reflect that networking is stopped
    _isEnabled = false;
    _connectionStatus = ConnectionStatus.disconnected;
    _currentUser = null; // Clear current user profile

    notifyListeners();
    logInfo('P2P networking stopped and service lifecycle ended.');
  }

  /// Send pairing request to user
  Future<bool> sendPairingRequest(
      P2PUser targetUser, bool saveConnection) async {
    try {
      if (_currentUser == null) return false;

      final request = PairingRequest(
        id: const Uuid().v4(),
        fromUserId: _currentUser!.id,
        fromUserName: _currentUser!.displayName,
        fromAppInstallationId: _currentUser!.appInstallationId,
        fromIpAddress: _currentUser!.ipAddress,
        fromPort: _currentUser!.port,
        wantsSaveConnection: saveConnection,
        requestTime: DateTime.now(),
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
              lastSeen: DateTime.now(),
            );

        // Update pairing status
        user.isPaired = true;
        user.isTrusted = trustUser;
        user.autoConnect = saveConnection;
        user.pairedAt = DateTime.now();
        user.isStored = saveConnection; // Mark as stored if connection is saved

        _discoveredUsers[user.id] = user;
        await _saveUser(user);

        // Update P2LAN status notification with new connection count
        await _updateP2LanStatusNotification();
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
      request.isProcessed = true;

      // Remove from storage completely (don't save processed requests)
      await _removePairingRequest(requestId);

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
        requestId: 'ftr_${const Uuid().v4()}',
        batchId: const Uuid().v4(),
        fromUserId: _currentUser!.id,
        fromUserName: _currentUser!.displayName,
        files: files,
        totalSize: totalSize,
        protocol: transferSettings?.sendProtocol ?? 'tcp',
        maxChunkSize: transferSettings?.maxChunkSize,
        requestTime: DateTime.now(),
      );

      logInfo(
          '📤 FileTransferRequest created with totalSize: ${request.totalSize} bytes');

      // Create transfer tasks in waiting state
      for (int i = 0; i < filePaths.length; i++) {
        final filePath = filePaths[i];
        final fileInfo = files[i];

        final task = DataTransferTask.create(
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
        // 🔥 REGISTER: Register active file transfer batch
        _registerActiveFileTransferBatch(request.batchId);

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

        // 🔥 CLEANUP: Safe cleanup after complete failure
        cleanupFilePickerCacheIfSafe();
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

    bool hasOutgoingTasks = false;
    for (final task in tasksToCancel) {
      if (task.isOutgoing) hasOutgoingTasks = true;
      task.status = DataTransferStatus.cancelled;
      task.errorMessage = 'File transfer request failed';
      _cleanupTransfer(task.id);
    }

    // 🔥 UNREGISTER: Unregister batch when cancelled
    if (hasOutgoingTasks && batchId.isNotEmpty) {
      _unregisterFileTransferBatch(batchId);
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

    if (tasksToCancel.isNotEmpty) {
      // Get batch IDs to unregister
      final batchIds = tasksToCancel
          .where((task) => task.batchId?.isNotEmpty == true)
          .map((task) => task.batchId!)
          .toSet();

      for (final task in tasksToCancel) {
        task.status = DataTransferStatus.cancelled;
        task.errorMessage = 'No response from receiver (timeout)';
        _cleanupTransfer(task.id);
      }

      // 🔥 UNREGISTER: Unregister batches when timed out
      for (final batchId in batchIds) {
        _unregisterFileTransferBatch(batchId);
      }
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

  Future<void> _createCurrentUser(NetworkInfo networkInfo) async {
    final appInstallationId =
        await NetworkSecurityService.getAppInstallationId();
    final deviceName = await NetworkSecurityService.getDeviceName();

    // Use custom display name from settings if available, otherwise use device name
    final customDisplayName = _transferSettings?.customDisplayName;

    _currentUser = P2PUser(
      id: appInstallationId,
      displayName: customDisplayName ?? deviceName,
      appInstallationId: appInstallationId,
      ipAddress: networkInfo.ipAddress ?? '127.0.0.1',
      port: _basePort,
      isOnline: true,
      lastSeen: DateTime.now(),
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
                case 'force_profile_sync_request':
                  _handleForceProfileSyncRequest(data);
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
          '📡 Device B: Processing scan request from ${request.fromUserName} (${request.fromUserId})');

      // 🔥 FIXED: Check if this device exists in our storage (CORRECT LOGIC)
      final existingUserInStorage = await _loadStoredUser(request.fromUserId);
      final responseCode = existingUserInStorage != null
          ? DiscoveryResponseCode.deviceUpdate
          : DiscoveryResponseCode.deviceNew;

      logInfo(
          '📡 Device B: Determined response code: ${responseCode.name} (inStorage: ${existingUserInStorage != null})');

      // 🔥 FIXED: Update UI ĐỒNG THỜI theo đúng spec gốc
      await _processDeviceBScanRequest(
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
          '✅ Device B: Sent ${responseCode.name} response to ${request.fromUserName} & updated UI');
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

  /// 🔥 FIXED: Device B xử lý scan request theo đúng spec gốc
  /// Khi thiết bị B nhận scan request từ A:
  /// - Code = update: Cập nhật profile từ offline (xám) → online (xanh lá)
  /// - Code = new: Thêm profile mới (xanh dương)
  Future<void> _processDeviceBScanRequest(
      DiscoveryScanRequest request,
      P2PUser? existingUserInStorage,
      DiscoveryResponseCode responseCode) async {
    try {
      logInfo(
          '🎯 Device B: Processing scan request according to original spec: ${request.fromUserName} -> ${responseCode.name}');

      switch (responseCode) {
        case DiscoveryResponseCode.deviceUpdate:
          // 🟢 SPEC: Device exists in storage - update offline → online (green background)
          logInfo(
              '🟢 Device B: Code=UPDATE - Updating stored device to ONLINE: ${request.fromUserName}');

          // Load stored user and update to online
          if (existingUserInStorage != null) {
            existingUserInStorage.ipAddress = request.ipAddress;
            existingUserInStorage.port = request.port;
            existingUserInStorage.isOnline = true;
            existingUserInStorage.lastSeen = DateTime.now();

            // Update display name if newer
            if (request.fromUserName.isNotEmpty &&
                !request.fromUserName.startsWith('Device-') &&
                (existingUserInStorage.displayName.startsWith('Device-') ||
                    existingUserInStorage.displayName.isEmpty)) {
              existingUserInStorage.displayName = request.fromUserName;
            }

            _discoveredUsers[existingUserInStorage.id] = existingUserInStorage;
            await _saveUser(existingUserInStorage);
            logInfo(
                '✅ Device B: Updated ${existingUserInStorage.displayName} to ONLINE (green)');
          }
          break;

        case DiscoveryResponseCode.deviceNew:
          // 🔵 SPEC: Device is new - create new profile (blue background)
          logInfo(
              '🔵 Device B: Code=NEW - Adding NEW device profile: ${request.fromUserName}');

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
            isStored:
                false, // New devices are not stored initially (blue background)
          );

          _discoveredUsers[newUser.id] = newUser;
          logInfo('✅ Device B: Added new device ${newUser.displayName} (blue)');
          break;

        case DiscoveryResponseCode.error:
          logWarning(
              'Device B: Error response code in scan request processing');
          break;
      }

      // Notify UI to update
      notifyListeners();
    } catch (e) {
      logError('Device B: Error processing scan request: $e');
    }
  }

  // 🔥 REMOVED: Old methods no longer needed after fixing logic according to original spec

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

  /// 🔥 FIXED: Device A xử lý response theo đúng spec gốc
  /// 4 trường hợp duy nhất:
  /// 1. code=new & trong storage → Xóa profile cũ, tạo mới (xanh dương)
  /// 2. code=new & không trong storage → Tạo mới (xanh dương)
  /// 3. code=update & trong storage → Offline (xám) → Online (xanh lá)
  /// 4. code=update & không trong storage → Tạo mới (xanh dương) + Gửi "force sync"
  Future<void> _processDiscoveryResponse(DiscoveryResponse response) async {
    final receivedUser = response.userProfile;
    final isInStorage = await _loadStoredUser(receivedUser.id) != null;

    logInfo(
        '🎯 Device A: Processing response from ${receivedUser.displayName}: code=${response.responseCode.name}, inStorage=$isInStorage');

    switch (response.responseCode) {
      case DiscoveryResponseCode.deviceNew:
        if (isInStorage) {
          // 🔵 CASE 1: code=new & trong storage → Xóa profile cũ, tạo mới (xanh dương)
          logInfo(
              '🔵 Device A: Case 1 - NEW+InStorage: Remove old profile, create new for ${receivedUser.displayName}');
          await _removeUser(receivedUser.id);
          _discoveredUsers.remove(receivedUser.id);
          await _createNewDeviceProfile(receivedUser, isNewDevice: true);
        } else {
          // 🔵 CASE 2: code=new & không trong storage → Tạo mới (xanh dương)
          logInfo(
              '🔵 Device A: Case 2 - NEW+NotInStorage: Create new profile for ${receivedUser.displayName}');
          await _createNewDeviceProfile(receivedUser, isNewDevice: true);
        }
        break;

      case DiscoveryResponseCode.deviceUpdate:
        if (isInStorage) {
          // 🟢 CASE 3: code=update & trong storage → Offline (xám) → Online (xanh lá)
          logInfo(
              '🟢 Device A: Case 3 - UPDATE+InStorage: Offline→Online for ${receivedUser.displayName}');
          await _updateDeviceOnline(receivedUser);
        } else {
          // 🔵 CASE 4: code=update & không trong storage → Tạo mới (xanh dương) + Gửi "force sync"
          logInfo(
              '🔵 Device A: Case 4 - UPDATE+NotInStorage: Create new + force sync for ${receivedUser.displayName}');
          await _createNewDeviceProfile(receivedUser, isNewDevice: true);
          await _sendForceProfileSyncRequest(receivedUser);
        }
        break;

      case DiscoveryResponseCode.error:
        logWarning(
            'Device A: Discovery response error: ${response.errorMessage}');
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

  /// 🔥 NEW: Send "force profile sync" request (CASE 4 trong spec gốc)
  /// Khi Device A nhận code=update nhưng không có device trong storage,
  /// gửi request "buộc chuyển profile mới" để Device B cập nhật profile từ offline (xám) → new (xanh dương)
  Future<void> _sendForceProfileSyncRequest(P2PUser targetUser) async {
    try {
      final forceSync = {
        'type': 'force_profile_sync_request',
        'fromUserId': _currentUser!.id,
        'toUserId': targetUser.id,
        'updatedProfile': _currentUser!.toJson(),
        'reason':
            'Device A received UPDATE response but device not in storage - forcing profile conversion',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final data = utf8.encode(jsonEncode(forceSync));
      final tempSocket =
          await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      tempSocket.send(data, InternetAddress(targetUser.ipAddress), 8082);
      tempSocket.close();

      logInfo(
          '📤 Device A: Sent FORCE profile sync to ${targetUser.displayName} (Case 4)');
    } catch (e) {
      logError('Device A: Failed to send force profile sync: $e');
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
        await _removeUser(fromUserId);
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

  /// 🔥 NEW: Handle force profile sync request (CASE 4 implementation)
  /// Device B nhận "force sync" từ Device A và chuyển profile từ offline (xám) → new (xanh dương)
  Future<void> _handleForceProfileSyncRequest(Map<String, dynamic> data) async {
    try {
      final fromUserId = data['fromUserId'] as String;
      final toUserId = data['toUserId'] as String;
      final reason = data['reason'] as String? ?? 'No reason provided';

      if (toUserId != _currentUser!.id) {
        return; // Not for us
      }

      final updatedProfile =
          P2PUser.fromJson(data['updatedProfile'] as Map<String, dynamic>);

      logInfo(
          '📥 Device B: Received FORCE profile sync from ${updatedProfile.displayName}');
      logInfo('📥 Device B: Reason: $reason');

      // Tìm profile offline (stored but not online) và convert thành new profile
      final existingUser = _discoveredUsers[fromUserId];
      final storedUser = await _loadStoredUser(fromUserId);

      if (storedUser != null && !storedUser.isOnline) {
        logInfo(
            '🔄 Device B: Converting OFFLINE profile → NEW profile: ${storedUser.displayName}');

        // Remove old offline profile from storage và memory
        await _removeUser(fromUserId);
        _discoveredUsers.remove(fromUserId);

        // Create new device profile (blue background) với thông tin mới nhất
        final newProfile = P2PUser(
          id: updatedProfile.id,
          displayName: updatedProfile.displayName,
          appInstallationId: updatedProfile.appInstallationId,
          ipAddress: updatedProfile.ipAddress,
          port: updatedProfile.port,
          isOnline: true,
          lastSeen: DateTime.now(),
          isStored: false, // New device profile (blue background)
        );

        _discoveredUsers[newProfile.id] = newProfile;
        notifyListeners();

        logInfo(
            '✅ Device B: Successfully converted ${storedUser.displayName} from OFFLINE→NEW (blue)');
      } else {
        logInfo(
            '⚠️ Device B: No offline profile found for ${updatedProfile.displayName} to convert');
      }
    } catch (e) {
      logError('Device B: Error handling force profile sync request: $e');
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
    _autoDiscoveryTimer?.cancel(); // 🔥 NEW: Cancel auto discovery timer
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
        // Dismiss the notification as the request is now handled
        await _safeNotificationCall(() => P2PNotificationService.instance
            .cancelNotification(request.requestId.hashCode));
        return;
      }

      // If user is trusted, auto-accept without notification
      if (fromUser.isTrusted) {
        logInfo(
            'Auto-accepting file transfer from trusted user: ${fromUser.displayName}');
        // Cancel timeout timer since we're auto-accepting
        _fileTransferRequestTimers[request.requestId]?.cancel();
        _fileTransferRequestTimers.remove(request.requestId);
        await _acceptFileTransferRequest(request);
        return;
      }

      // Show notification for file transfer request (only for non-trusted users)
      await _safeNotificationCall(
          () => P2PNotificationService.instance.showFileTransferRequest(
                request: request,
                enableActions: true,
              ));

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

    // Check total size limit, skipping if set to unlimited (-1)
    if (settings.maxTotalReceiveSize != -1 &&
        request.totalSize > settings.maxTotalReceiveSize) {
      final maxSizeMB = settings.maxTotalReceiveSize ~/ (1024 * 1024);
      final requestSizeMB = request.totalSize / (1024 * 1024);
      return _FileTransferValidationResult.invalid(
          FileTransferRejectReason.totalSizeExceeded,
          'Total size ${requestSizeMB.toStringAsFixed(1)}MB exceeds limit ${maxSizeMB}MB');
    }

    // Check individual file size limits, skipping if set to unlimited (-1)
    for (final file in request.files) {
      if (settings.maxReceiveFileSize != -1 &&
          file.fileSize > settings.maxReceiveFileSize) {
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

      // Create sender folder if enabled
      if (_transferSettings!.createSenderFolders) {
        // Get sender's display name from discovered users or use a fallback
        String senderFolderName = 'Unknown';
        final sender = _discoveredUsers[request.fromUserId];
        if (sender != null && sender.displayName.isNotEmpty) {
          // Sanitize sender name for folder creation
          senderFolderName = _sanitizeFileName(sender.displayName);
        } else if (request.fromUserName.isNotEmpty) {
          senderFolderName = _sanitizeFileName(request.fromUserName);
        } else {
          senderFolderName = 'User-${request.fromUserId.substring(0, 8)}';
        }

        downloadPath =
            '$downloadPath${Platform.pathSeparator}$senderFolderName';

        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
          logInfo('Created sender folder: $downloadPath');
        }
      }
      // Create date folder if enabled (can be combined with sender folders)
      else if (_transferSettings!.createDateFolders) {
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
    // Dismiss the notification as the request is now handled
    await _safeNotificationCall(() => P2PNotificationService.instance
        .cancelNotification(request.requestId.hashCode));

    // Calculate downloadPath with date/sender folder
    String? downloadPath;
    if (_transferSettings != null) {
      downloadPath = _transferSettings!.downloadPath;

      // Create sender folder if enabled
      if (_transferSettings!.createSenderFolders) {
        // Get sender's display name from discovered users or use a fallback
        String senderFolderName = 'Unknown';
        final sender = _discoveredUsers[request.fromUserId];
        if (sender != null && sender.displayName.isNotEmpty) {
          // Sanitize sender name for folder creation
          senderFolderName = _sanitizeFileName(sender.displayName);
        } else if (request.fromUserName.isNotEmpty) {
          senderFolderName = _sanitizeFileName(request.fromUserName);
        } else {
          senderFolderName = 'User-${request.fromUserId.substring(0, 8)}';
        }

        downloadPath =
            '$downloadPath${Platform.pathSeparator}$senderFolderName';

        final dir = Directory(downloadPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
          logInfo('Created sender folder for accepted request: $downloadPath');
        }
      }
      // Create date folder if enabled (can be combined with sender folders)
      else if (_transferSettings!.createDateFolders) {
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
      _batchFileCounts[request.batchId] =
          request.files.length; // Store file count
      logInfo(
          'Stored downloadPath for batch ${request.batchId} (${request.files.length} files): $downloadPath');
    }

    // Map sender user to this batch for incoming tasks
    _activeBatchIdsByUser[request.fromUserId] = request.batchId;
    logInfo('Mapped user ${request.fromUserId} to batch ${request.batchId}');

    await _sendFileTransferResponse(request, true, null, null);

    // Remove from pending list
    _pendingFileTransferRequests
        .removeWhere((r) => r.requestId == request.requestId);

    // Mark request as processed and remove from storage
    await _removeFileTransferRequest(request.requestId);

    notifyListeners();
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

    // Dismiss the notification as the request has timed out
    _safeNotificationCallSync(() => P2PNotificationService.instance
        .cancelNotification(request.requestId.hashCode));

    // Send rejection response
    _sendFileTransferResponse(request, false, FileTransferRejectReason.timeout,
        'Request timed out (no response)');

    // Remove from pending list
    _pendingFileTransferRequests.removeWhere((r) => r.requestId == requestId);

    // Remove from storage
    _removeFileTransferRequest(request.requestId);

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
      await _removeUser(userId); // Also remove from Isar
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
      for (final expiredRequest in expiredRequests) {
        await _removePairingRequest(expiredRequest.id);
      }
      logInfo(
          'Removed ${expiredRequests.length} expired pairing requests from storage');
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void _handleClientConnection(Socket socket) {
    logInfo('New client connected: ${socket.remoteAddress}');

    // Optimize socket for high throughput
    socket.setOption(SocketOption.tcpNoDelay, true);

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
    final userId = _connectedSockets.entries
        .firstWhere((entry) => entry.value == socket,
            orElse: () => MapEntry('', socket))
        .key;
    if (userId.isNotEmpty) {
      final user = _discoveredUsers[userId];
      if (user != null && !user.isStored) {
        user.isOnline = false;
        _saveUser(user);
        logInfo('Marked user $userId as offline.');
      }
      _connectedSockets.remove(userId);
      logInfo('Removed socket for user $userId');
      notifyListeners();
    }
  }

  Future<void> _processMessage(Socket socket, P2PMessage message) async {
    logInfo(
        '📨 Processing message: ${message.type} from ${message.fromUserId} to ${message.toUserId}');

    // Associate socket with user ID upon receiving the first message
    if (!_connectedSockets.containsKey(message.fromUserId)) {
      _connectedSockets[message.fromUserId] = socket;
    }

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
    if (!_pendingRequests.any((r) => r.id == request.id)) {
      _pendingRequests.add(request);
      await _savePairingRequest(request);
      notifyListeners();

      // Show notification for pairing request
      await _safeNotificationCall(
          () => P2PNotificationService.instance.showPairingRequest(
                request: request,
                enableActions: true,
              ));

      // Trigger callback for new pairing request (for auto-showing dialogs)
      if (_onNewPairingRequest != null) {
        _onNewPairingRequest!(request);
      }
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

        // Update P2LAN status notification with new connection count
        await _updateP2LanStatusNotification();
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
        task.startedAt ??= DateTime.now(); // Set startedAt on first chunk
      }

      // 🔥 FIX: Cap transferredBytes to fileSize to prevent overflow
      if (task.transferredBytes > task.fileSize) {
        logWarning(
            'Transfer bytes overflow for task $taskId: ${task.transferredBytes} > ${task.fileSize}. Capping to fileSize.');
        task.transferredBytes = task.fileSize;
      }

      final progressPercent = (task.fileSize > 0)
          ? ((task.transferredBytes / task.fileSize) * 100)
              .round()
              .clamp(0, 100)
          : 0;

      // Show progress notification for incoming files
      // Show at start, every 5%, and for final stages
      if (progressPercent == 0 ||
          progressPercent % 5 == 0 ||
          progressPercent > 90 ||
          isLast) {
        // Calculate speed and ETA
        String? speed;
        String? eta;
        if (task.startedAt != null &&
            progressPercent > 0 &&
            task.transferredBytes > 0) {
          final elapsed = DateTime.now().difference(task.startedAt!);
          if (elapsed.inSeconds > 0) {
            final speedBps = task.transferredBytes / elapsed.inSeconds;
            final speedFormatted = _formatSpeed(speedBps);
            if (speedFormatted != null) {
              speed = speedFormatted;

              // Calculate ETA
              final remainingBytes = task.fileSize - task.transferredBytes;
              if (remainingBytes > 0 && speedBps > 0) {
                final etaSeconds = (remainingBytes / speedBps).round();
                eta = _formatEta(etaSeconds);
              }
            }
          }
        }
        // Use enhanced file transfer status notification
        await _safeNotificationCall(
            () => P2PNotificationService.instance.showFileTransferStatus(
                  task: task,
                  progress: progressPercent,
                  speed: speed,
                  eta: eta,
                ));
      }

      // Only notify UI every 10 chunks to reduce overhead
      if (_incomingFileChunks[taskId]!.length % 10 == 0 || isLast) {
        notifyListeners();
      }

      // If this is the last chunk, assemble the file
      if (isLast) {
        logInfo(
            '🏁 Last chunk received for task $taskId (${task.fileName}), assembling file...');
        logInfo(
            'Final stats: ${task.transferredBytes}/${task.fileSize} bytes, ${_incomingFileChunks[taskId]?.length ?? 0} chunks');
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

  String? _formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '${bytesPerSecond.round()} B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).round()} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  String? _formatEta(int totalSeconds) {
    if (totalSeconds < 60) {
      return '${totalSeconds}s left';
    } else if (totalSeconds < 3600) {
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;
      return '${minutes}m ${seconds}s left';
    } else {
      final hours = totalSeconds ~/ 3600;
      final minutes = (totalSeconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m left';
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

            // 🔥 FIX: Cap transferredBytes to fileSize to prevent overflow in buffered chunks too
            if (task.transferredBytes > task.fileSize) {
              logWarning(
                  'Buffered chunk overflow for task $taskId: ${task.transferredBytes} > ${task.fileSize}. Capping to fileSize.');
              task.transferredBytes = task.fileSize;
            }

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
          final finalFileName = '${baseName}_$counter.$extension';
        } else {
          final finalFileName = '${fileName}_$counter';
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
        logError(
            'This might cause issues. Task transferredBytes: ${task.transferredBytes}');

        // 🔥 FIX: Update task's final transferred bytes to match actual file size
        task.transferredBytes = fileData.length;

        // Continue anyway - file might still be valid
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

      // Show completion notification for received file
      await _safeNotificationCall(
          () => P2PNotificationService.instance.showFileTransferCompleted(
                task: task,
                success: true,
              ));

      // Clean up
      _incomingFileChunks.remove(taskId);

      // Clean up batch-specific data if this was the last file in the batch
      if (task.batchId != null) {
        final totalFilesInBatch = _batchFileCounts[task.batchId] ?? 0;

        // 🔥 FIX: Use a more robust approach - wait a bit before counting to ensure all tasks are updated
        await Future.delayed(const Duration(milliseconds: 100));

        final completedInBatch = _activeTransfers.values
            .where((t) =>
                t.batchId == task.batchId &&
                !t.isOutgoing &&
                t.status == DataTransferStatus.completed)
            .length;

        logInfo(
            'Batch ${task.batchId} cleanup check: $completedInBatch / $totalFilesInBatch files completed.');
        logInfo(
            'All tasks in batch ${task.batchId}: ${_activeTransfers.values.where((t) => t.batchId == task.batchId && !t.isOutgoing).map((t) => '${t.fileName}:${t.status}').join(', ')}');

        if (totalFilesInBatch > 0 && completedInBatch >= totalFilesInBatch) {
          logInfo('✅ Batch ${task.batchId} complete. Cleaning up resources.');
          _batchDownloadPaths.remove(task.batchId);
          _batchFileCounts.remove(task.batchId);

          // Also clean up user batch mapping
          final userToRemove = _activeBatchIdsByUser.entries
              .firstWhere((entry) => entry.value == task.batchId,
                  orElse: () => const MapEntry('', ''))
              .key;

          if (userToRemove.isNotEmpty) {
            _activeBatchIdsByUser.remove(userToRemove);
            logInfo('Cleaned up user batch mapping for $userToRemove');
          }
        } else {
          logInfo(
              'Batch ${task.batchId} not yet complete. Waiting for remaining files.');
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
    final fromUserId = message.fromUserId;
    final user = _discoveredUsers[fromUserId];
    if (user != null) {
      // For now, auto-approve trust requests for simplicity in this refactor
      user.isTrusted = true;
      await _saveUser(user);
      logInfo('Auto-approved trust for ${user.displayName}');

      // Send response
      final response = P2PMessage(
          type: P2PMessageTypes.trustResponse,
          fromUserId: _currentUser!.id,
          toUserId: fromUserId,
          data: {'approved': true});
      await _sendMessage(user, response);
    }
  }

  Future<void> _handleTrustResponse(P2PMessage message) async {
    final fromUserId = message.fromUserId;
    final approved = message.data['approved'] as bool? ?? false;

    if (approved) {
      final user = _discoveredUsers[fromUserId];
      if (user != null) {
        user.isTrusted = true;
        await _saveUser(user);
        logInfo('Trust approved by ${user.displayName}');
      }
    }
  }

  Future<void> _handleDisconnectMessage(P2PMessage message) async {
    final fromUserId = message.fromUserId;
    final user = _discoveredUsers[fromUserId];
    if (user != null) {
      user.isOnline = false;
      await _saveUser(user);
      notifyListeners();
      logInfo('${user.displayName} has disconnected.');
    }
    _connectedSockets[fromUserId]?.destroy();
    _connectedSockets.remove(fromUserId);
  }

  /// Handles a notification that a user has unpaired.
  Future<void> _handleUnpairNotification(
      P2PUser user, String reason, String fromUserName) async {
    logInfo(
        '💔 Received UNPAIR notification from ${user.displayName}: $reason');

    // On unpair, remove from storage
    if (user.isStored) {
      try {
        await IsarService.isar.writeTxn(() async {
          await IsarService.isar.p2PUsers.delete(fastHash(user.id));
        });
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

  /// Start transfers with concurrency limit - Fixed implementation
  Future<void> _startTransfersWithConcurrencyLimit(
      List<DataTransferTask> tasks) async {
    final limit = _transferSettings?.maxConcurrentTasks ?? 3;

    logInfo('Starting transfers with concurrency limit: ${limit}');
    logInfo('Total tasks to transfer: ${tasks.length}');

    // Set all tasks to pending status first
    for (final task in tasks) {
      if (task.status == DataTransferStatus.waitingForApproval) {
        task.status = DataTransferStatus.pending;
      }
    }

    // Start initial batch of transfers (up to the limit)
    await _startNextAvailableTransfers();

    logInfo(
        'Initial batch started. Use _startNextQueuedTransfer() to continue when tasks complete.');
  }

  /// Start next available transfers up to concurrency limit
  Future<void> _startNextAvailableTransfers() async {
    final maxConcurrent = _transferSettings?.maxConcurrentTasks ?? 3;

    // Count currently running outgoing transfers
    final currentlyRunning = _activeTransfers.values
        .where(
            (t) => t.isOutgoing && t.status == DataTransferStatus.transferring)
        .length;

    logInfo('Currently running transfers: $currentlyRunning / $maxConcurrent');

    // Start pending tasks up to the limit
    int started = 0;
    final availableSlots = maxConcurrent - currentlyRunning;

    if (availableSlots <= 0) {
      logInfo('No available slots for new transfers');
      return;
    }

    // Find pending outgoing tasks
    final pendingTasks = _activeTransfers.values
        .where((t) => t.isOutgoing && t.status == DataTransferStatus.pending)
        .take(availableSlots)
        .toList();

    for (final task in pendingTasks) {
      final targetUser = _discoveredUsers[task.targetUserId];
      if (targetUser != null) {
        logInfo(
            'Starting transfer for ${task.fileName} (${started + 1}/${availableSlots})');
        task.status = DataTransferStatus.transferring;
        task.startedAt = DateTime.now();
        await _startDataTransfer(task, targetUser);
        started++;
      }
    }

    logInfo(
        'Started $started new transfers. Total running: ${currentlyRunning + started}/$maxConcurrent');

    if (started > 0) {
      notifyListeners();
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

      // Initial progress notification will be shown in the progress listener

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
      receivePort.listen((data) async {
        if (data is Map<String, dynamic>) {
          final progress = data['progress'] as double?;
          final completed = data['completed'] as bool? ?? false;
          final error = data['error'] as String?;

          if (progress != null) {
            task.transferredBytes = (task.fileSize * progress).round();

            // Show enhanced progress notification - more frequent updates
            if (_transferSettings?.enableNotifications == true) {
              final progressPercent = (progress * 100).round();
              // Show at start, every 5%, and for final stages
              if (progressPercent == 0 ||
                  progressPercent % 5 == 0 ||
                  progressPercent > 90) {
                try {
                  // Calculate speed and ETA
                  String? speed;
                  String? eta;
                  if (task.startedAt != null &&
                      progressPercent > 0 &&
                      task.transferredBytes > 0) {
                    final elapsed = DateTime.now().difference(task.startedAt!);
                    if (elapsed.inSeconds > 0) {
                      final speedBps =
                          task.transferredBytes / elapsed.inSeconds;
                      final speedKB = (speedBps / 1024).round();
                      if (speedKB > 0) {
                        speed = '${speedKB}KB/s';

                        // Calculate ETA
                        final remainingBytes =
                            task.fileSize - task.transferredBytes;
                        if (remainingBytes > 0) {
                          final etaSeconds =
                              (remainingBytes / speedBps).round();
                          if (etaSeconds < 60) {
                            eta = '${etaSeconds}s left';
                          } else {
                            final etaMinutes = (etaSeconds / 60).round();
                            eta = '${etaMinutes}m left';
                          }
                        }
                      }
                    }
                  }

                  // Use enhanced file transfer status notification
                  await _safeNotificationCall(() =>
                      P2PNotificationService.instance.showFileTransferStatus(
                        task: task,
                        progress: progressPercent,
                        speed: speed,
                        eta: eta,
                      ));
                } catch (e) {
                  logError(
                      'Failed to show file transfer status notification: $e');
                  // Continue without notification
                }
              }
            }
          }

          if (completed) {
            task.status = DataTransferStatus.completed;
            task.completedAt = DateTime.now();

            // Cancel progress notification and show completion notification
            // Cancel the progress notification first
            await _safeNotificationCall(() => P2PNotificationService.instance
                .cancelFileTransferStatus(task.id));

            // Show completion notification
            await _safeNotificationCall(
                () => P2PNotificationService.instance.showFileTransferCompleted(
                      task: task,
                      success: true,
                    ));

            _cleanupTransfer(task.id);
          } else if (error != null) {
            task.status = DataTransferStatus.failed;
            task.errorMessage = error;

            // Cancel progress notification and show failure notification
            // Cancel the progress notification first
            await _safeNotificationCall(() => P2PNotificationService.instance
                .cancelFileTransferStatus(task.id));

            // Show failure notification
            await _safeNotificationCall(
                () => P2PNotificationService.instance.showFileTransferCompleted(
                      task: task,
                      success: false,
                      errorMessage: error,
                    ));

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
        // Default to TCP with optimized settings
        tcpSocket = await Socket.connect(
          targetUser.ipAddress,
          targetUser.port,
          timeout: const Duration(seconds: 10),
        );

        // Optimize TCP socket for high throughput
        tcpSocket.setOption(SocketOption.tcpNoDelay, true);
        sendPort
            .send({'info': 'TCP connection established with optimizations'});
      }

      // Read file
      final file = File(task.filePath);
      if (!await file.exists()) {
        sendPort.send({'error': 'File does not exist: ${task.filePath}'});
        return;
      }

      final fileBytes = await file.readAsBytes();
      int totalSent = 0;

      // Dynamic chunking parameters - Start with larger chunk size for better speed
      int chunkSize = min(128 * 1024,
          maxChunkSizeFromSettings); // Start with 128KB or setting max, whichever is smaller
      final int maxChunkSize = maxChunkSizeFromSettings; // Use setting value
      int successfulChunksInRow = 0;
      Duration delay =
          const Duration(milliseconds: 5); // Reduce initial delay significantly

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
            // TCP: Send with length header and immediate flush
            final lengthHeader = ByteData(4)
              ..setUint32(0, messageBytes.length, Endian.big);
            tcpSocket!.add(lengthHeader.buffer.asUint8List());
            tcpSocket!.add(messageBytes);
            await tcpSocket!.flush(); // Force immediate send
          }

          totalSent += currentChunkSize;
          successfulChunksInRow++;

          // Adjust chunk size and delay dynamically - More aggressive scaling
          if (successfulChunksInRow > 3 && chunkSize < maxChunkSize) {
            chunkSize = min(chunkSize * 2,
                maxChunkSize); // Double chunk size but cap at max
            delay = Duration(
                milliseconds: max(
                    1,
                    delay.inMilliseconds -
                        2)); // Decrease delay more aggressively
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

          // Slow down on error but not too much
          chunkSize = max(64 * 1024,
              chunkSize ~/ 2); // Halve chunk size but keep reasonable minimum
          delay = Duration(
              milliseconds: min(50,
                  delay.inMilliseconds + 10)); // Increase delay more moderately

          // Re-establish connection based on protocol
          if (protocol.toLowerCase() == 'udp') {
            // UDP doesn't need reconnection, just continue
            sendPort.send({'info': 'UDP error recovery, continuing...'});
          } else {
            // TCP: Re-establish connection with optimizations
            await tcpSocket?.close();
            tcpSocket = await Socket.connect(
                targetUser.ipAddress, targetUser.port,
                timeout: const Duration(seconds: 10));
            tcpSocket?.setOption(SocketOption.tcpNoDelay, true);
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

  /// 🔥 NEW: Check if all tasks in a batch are finished and unregister if so
  void _checkAndUnregisterBatchIfComplete(String? batchId) {
    if (batchId == null || batchId.isEmpty) return;

    // Check if the batch is still registered
    if (!_activeFileTransferBatches.contains(batchId)) {
      return;
    }

    final batchTasks = _activeTransfers.values
        .where((task) => task.batchId == batchId)
        .toList();

    // If there are no tasks for this batch somehow, unregister it.
    if (batchTasks.isEmpty) {
      _unregisterFileTransferBatch(batchId);
      return;
    }

    final allTasksFinished = batchTasks.every((task) =>
        task.status == DataTransferStatus.completed ||
        task.status == DataTransferStatus.failed ||
        task.status == DataTransferStatus.cancelled ||
        task.status == DataTransferStatus.rejected);

    if (allTasksFinished) {
      // Check if there are any successful outgoing transfers in this batch
      final hasSuccessfulOutgoing = batchTasks.any((task) =>
          task.isOutgoing && task.status == DataTransferStatus.completed);

      logInfo(
          'P2PService: All tasks in batch $batchId are finished. Unregistering.');
      _unregisterFileTransferBatch(batchId);

      // Schedule additional cache cleanup for successful outgoing transfers
      if (hasSuccessfulOutgoing) {
        logInfo(
            'P2PService: Scheduling additional cache cleanup for successful outgoing batch $batchId');
        Future.delayed(const Duration(seconds: 3), () {
          cleanupFilePickerCacheIfSafe();
        });
      }
    } else {
      logInfo(
          'P2PService: Batch $batchId still has active tasks. Not unregistering.');
    }
  }

  void _cleanupTransfer(String taskId) {
    final task =
        _activeTransfers[taskId]; // Get task before removing isolate info
    final isolate = _transferIsolates.remove(taskId);
    isolate?.kill();

    final port = _transferPorts.remove(taskId);
    port?.close();

    // 🔥 FIX: After cleaning up task resources, check if its batch is now complete.
    if (task != null) {
      _checkAndUnregisterBatchIfComplete(task.batchId);

      // Schedule immediate cache cleanup if this was the last outgoing task in any batch
      if (task.isOutgoing && task.status == DataTransferStatus.completed) {
        // Check if there are any other active outgoing transfers
        final remainingOutgoingTasks = _activeTransfers.values
            .where((t) =>
                t.id != taskId &&
                t.isOutgoing &&
                (t.status == DataTransferStatus.transferring ||
                    t.status == DataTransferStatus.pending))
            .toList();

        if (remainingOutgoingTasks.isEmpty) {
          logInfo(
              'P2PService: Last outgoing task completed, scheduling cache cleanup');
          Future.delayed(const Duration(seconds: 2), () {
            cleanupFilePickerCacheIfSafe();
          });
        }
      }
    }

    // Check if we can start any queued transfers
    _startNextQueuedTransfer();
  }

  /// Get protocol for a specific batch based on stored FileTransferRequest
  Future<String> _getProtocolForBatch(String batchId) async {
    try {
      final requests =
          await IsarService.isar.fileTransferRequests.where().findAll();
      for (final request in requests) {
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

  /// Start next queued transfer if there are available slots - Fixed implementation
  void _startNextQueuedTransfer() async {
    logInfo(
        '_startNextQueuedTransfer: Checking for pending transfers to start...');

    // Use the improved _startNextAvailableTransfers which handles multiple tasks
    await _startNextAvailableTransfers();
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
      await IsarService.isar.writeTxn(() async {
        await IsarService.isar.p2PUsers.delete(fastHash(userId));
      });

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
    return P2PDataTransferSettings(
      downloadPath: 'downloads',
      createDateFolders: false,
      maxReceiveFileSize: 1024 * 1024 * 100, // 100MB
      maxTotalReceiveSize: 1024 * 1024 * 1024, // 1GB
      maxConcurrentTasks: 3,
      sendProtocol: 'TCP',
      maxChunkSize: 1024,
      createSenderFolders: true,
      uiRefreshRateSeconds: 0,
      enableNotifications: true,
    );
  }

  /// Get default download path based on platform
  String _getDefaultDownloadPath() {
    if (Platform.isWindows) {
      return '${Platform.environment['USERPROFILE']}\\Downloads';
    } else if (Platform.isAndroid) {
      // This will be replaced with actual path during initialization
      return '/data/data/com.setpocket.app/files/p2lan_transfer';
    } else {
      return '${Platform.environment['HOME']}/Downloads';
    }
  }

  /// Initialize default Android path using path_provider
  Future<void> _initializeAndroidPath() async {
    if (Platform.isAndroid && _transferSettings != null) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final androidPath = '${appDocDir.parent.path}/files/p2lan_transfer';

        // Create directory if it doesn't exist
        final directory = Directory(androidPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        // Update settings if still using default path
        if (_transferSettings!.downloadPath
            .contains('/data/data/com.setpocket.app/files/p2lan_transfer')) {
          _transferSettings =
              _transferSettings!.copyWith(downloadPath: androidPath);

          // Save updated settings through adapter
          await P2PSettingsAdapter.updateSettings(_transferSettings!);

          logInfo('Updated Android download path to: $androidPath');
        }
      } catch (e) {
        logError('Failed to initialize Android path: $e');
      }
    }
  }

  /// Update P2LAN status notification with current connection count
  Future<void> _updateP2LanStatusNotification() async {
    if (!_isEnabled || _currentUser == null) {
      return;
    }

    final connectedDevices = pairedUsers.where((u) => u.isOnline).length;
    await _safeNotificationCall(
        () => P2PNotificationService.instance.showP2LanStatus(
              deviceName: _currentUser!.displayName,
              ipAddress: _currentUser!.ipAddress,
              connectedDevices: connectedDevices,
            ));
  }

  /// Update transfer settings
  Future<bool> updateTransferSettings(P2PDataTransferSettings settings) async {
    try {
      final bool notificationsWereEnabled =
          _transferSettings?.enableNotifications ?? false;

      await P2PSettingsAdapter.updateSettings(settings);
      _transferSettings = settings;

      // If notifications were just toggled on, ensure permissions are updated.
      if (!notificationsWereEnabled && settings.enableNotifications) {
        logInfo(
            'Notifications have been enabled in settings. Updating permissions status...');
        await P2PNotificationService.instance.updatePermissions();
      }

      // 🔥 Update current user's display name if it has changed
      if (_currentUser != null && settings.customDisplayName != null) {
        if (_currentUser!.displayName != settings.customDisplayName) {
          _currentUser!.displayName = settings.customDisplayName!;
          logInfo(
              'Updated current user display name to: ${settings.customDisplayName}');
          notifyListeners(); // Notify UI of the change
        }
      }

      logInfo('Updated transfer settings: ${settings.toJson()}');
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
      maxReceiveFileSize: settings.maxFileSize * 1024 * 1024, // MB to Bytes
      maxTotalReceiveSize:
          1 * 1024 * 1024 * 1024, // Default 1GB in bytes for old settings
      maxConcurrentTasks: 3,
      sendProtocol: 'TCP', // Default
      maxChunkSize: 512, // Default 512KB
      uiRefreshRateSeconds: 0, // Default
      enableNotifications: true, // Default
      createSenderFolders: false, // Default
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
    for (final user in pairedUsers) {
      final message = P2PMessage(
        type: P2PMessageTypes.disconnect,
        fromUserId: _currentUser!.id,
        toUserId: user.id,
        data: {},
      );
      await _sendMessage(user, message);
    }
  }

  /// Clean up users when network stops - keep stored users, remove discovered ones
  void _cleanupUsersOnNetworkStop() {
    _discoveredUsers.removeWhere((key, user) => !user.isStored);
    for (final user in _discoveredUsers.values) {
      user.isOnline = false;
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
    logInfo('P2PService: Disposing service...');

    // Send emergency disconnect to all paired users before disposing
    sendEmergencyDisconnectToAll();
    stopNetworking();

    // Cancel all timers
    _heartbeatTimer?.cancel();
    _cleanupTimer?.cancel();
    _broadcastTimer?.cancel();
    _memoryCleanupTimer?.cancel();

    // Cancel all file transfer request timers
    for (final timer in _fileTransferRequestTimers.values) {
      timer.cancel();
    }
    _fileTransferRequestTimers.clear();

    // Close all sockets
    _broadcastSocket?.close();
    _udpListenerSocket?.close();

    // 🔥 CLEANUP: Clear all memory caches
    _incomingFileChunks.clear();
    _discoveredUsers.clear();
    _pendingRequests.clear();
    _pendingFileTransferRequests.clear();
    _activeTransfers.clear();

    // 🔥 CLEANUP: Clear file picker cache on dispose
    _cleanupFilePickerCacheSync();

    _isEnabled = false;
    _isDiscovering = false;
    _isBroadcasting = false;

    logInfo('P2PService: Service disposed');
    super.dispose();
  }

  /// 🔥 NEW: Synchronous cleanup for dispose
  void _cleanupFilePickerCacheSync() {
    try {
      // Use Future.microtask to avoid blocking dispose
      Future.microtask(() async {
        try {
          // Force cleanup on dispose regardless of active transfers
          await FilePicker.platform.clearTemporaryFiles();
          _lastFilePickerCleanup = DateTime.now();
          logInfo('P2PService: Force cleared file picker cache on dispose');
        } catch (e) {
          logWarning(
              'P2PService: Failed to clear file picker cache on dispose: $e');
        }
      });
    } catch (e) {
      logWarning('P2PService: Error scheduling file picker cleanup: $e');
    }
  }

  /// Clear a transfer from the list
  void clearTransfer(String taskId) {
    final task = _activeTransfers.remove(taskId);
    if (task != null) {
      logInfo('Cleared transfer from UI: ${task.fileName}');
      notifyListeners();
    }
  }

  /// Clear a transfer from the list and optionally delete the downloaded file
  Future<bool> clearTransferWithFile(String taskId, bool deleteFile) async {
    final task = _activeTransfers.remove(taskId);
    if (task == null) {
      logWarning('Task $taskId not found for clear operation');
      return false;
    }

    // 🔥 CLEANUP: Clear file chunks for this task
    _incomingFileChunks.remove(taskId);

    bool fileDeleted = false;
    String? errorMessage;

    if (deleteFile && !task.isOutgoing && task.savePath != null) {
      try {
        final file = File(task.savePath!);
        if (await file.exists()) {
          await file.delete();
          fileDeleted = true;
          logInfo('Successfully deleted file: ${task.savePath}');
        } else {
          logWarning('File not found for deletion: ${task.savePath}');
          errorMessage = 'File not found at ${task.savePath}';
        }
      } catch (e) {
        logError('Failed to delete file ${task.savePath}: $e');
        errorMessage = 'Failed to delete file: $e';
      }
    }

    logInfo(
        'Cleared transfer from UI: ${task.fileName}${deleteFile ? (fileDeleted ? ' (file deleted)' : ' (file deletion failed)') : ''}');

    // 🔥 CLEANUP: Trigger memory cleanup after clearing transfer
    Future.microtask(() => _cleanupMemory());

    notifyListeners();

    // Return true if task was cleared successfully, regardless of file deletion result
    // Error message will be handled by the caller if needed
    return errorMessage == null || !deleteFile;
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

      // Dismiss the notification as the request is now handled
      await _safeNotificationCall(() => P2PNotificationService.instance
          .cancelNotification(request.requestId.hashCode));

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

        // Remove from storage using Isar
        await _removeFileTransferRequest(request.requestId);
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
    // Replace invalid characters with underscores
    // This is a basic sanitizer, may need to be more comprehensive
    return fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
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

      // 🔥 CLEANUP: Perform memory cleanup when stopping discovery
      await _cleanupMemory();

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

  /// Cleanup memory and temporary files
  Future<void> _cleanupMemory() async {
    try {
      // 🔥 CLEANUP: Clear file chunks for completed/failed transfers
      final completedTaskIds = _activeTransfers.entries
          .where((entry) =>
              entry.value.status == DataTransferStatus.completed ||
              entry.value.status == DataTransferStatus.failed ||
              entry.value.status == DataTransferStatus.cancelled)
          .map((entry) => entry.key)
          .toList();

      for (final taskId in completedTaskIds) {
        _incomingFileChunks.remove(taskId);
        logInfo(
            'P2PService: Cleaned up file chunks for completed task: $taskId');
      }

      // 🔥 CLEANUP: Safe file picker cleanup
      await cleanupFilePickerCacheIfSafe();

      // 🔥 CLEANUP: Clear old file transfer requests (older than 24 hours)
      await _cleanupOldFileTransferRequests();

      logInfo('P2PService: Memory cleanup completed');
    } catch (e) {
      logError('P2PService: Error during memory cleanup: $e');
    }
  }

  /// 🔥 NEW: Cleanup old file transfer requests
  Future<void> _cleanupOldFileTransferRequests() async {
    try {
      final isar = IsarService.isar;
      final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

      final requestsToDelete = await isar.fileTransferRequests
          .filter()
          .requestTimeLessThan(cutoffTime)
          .findAll();

      if (requestsToDelete.isNotEmpty) {
        final idsToDelete = requestsToDelete.map((r) => r.isarId).toList();
        await isar.writeTxn(() async {
          await isar.fileTransferRequests.deleteAll(idsToDelete);
        });
        logInfo(
            'P2PService: Cleaned up ${idsToDelete.length} old file transfer requests');
      }
    } catch (e) {
      logError('P2PService: Error cleaning up old file transfer requests: $e');
    }
  }

  // 🔥 NEW: File picker cache management
  static final Set<String> _activeFileTransferBatches = <String>{};
  static DateTime? _lastFilePickerCleanup;
  static const Duration _cleanupCooldown = Duration(minutes: 2);

  /// 🔥 NEW: Register active file transfer batch to prevent cache cleanup
  void _registerActiveFileTransferBatch(String batchId) {
    _activeFileTransferBatches.add(batchId);
    logInfo('P2PService: Registered active file transfer batch: $batchId');
  }

  /// 🔥 NEW: Unregister file transfer batch when completed/failed
  void _unregisterFileTransferBatch(String batchId) {
    _activeFileTransferBatches.remove(batchId);
    logInfo('P2PService: Unregistered file transfer batch: $batchId');

    // Trigger cleanup after batch is unregistered
    Future.delayed(const Duration(seconds: 5), () {
      cleanupFilePickerCacheIfSafe();
    });
  }

  /// 🔥 NEW: Safe file picker cache cleanup - only if no active transfers
  Future<void> cleanupFilePickerCacheIfSafe() async {
    try {
      // Check cooldown period to avoid too frequent cleanups
      final now = DateTime.now();
      if (_lastFilePickerCleanup != null &&
          now.difference(_lastFilePickerCleanup!) < _cleanupCooldown) {
        logInfo('P2PService: Skipped file picker cleanup - cooldown period');
        return;
      }

      // Check if there are any active outgoing transfers
      final hasActiveOutgoingTransfers = _activeTransfers.values.any((task) =>
          task.isOutgoing &&
          (task.status == DataTransferStatus.transferring ||
              task.status == DataTransferStatus.waitingForApproval ||
              task.status == DataTransferStatus.pending));

      // Check if there are any registered active file transfer batches
      final hasActiveFileTransferBatches =
          _activeFileTransferBatches.isNotEmpty;

      if (!hasActiveOutgoingTransfers && !hasActiveFileTransferBatches) {
        await FilePicker.platform.clearTemporaryFiles();
        _lastFilePickerCleanup = now;
        logInfo('P2PService: Safely cleaned up file picker cache');
      } else {
        logInfo(
            'P2PService: Skipped file picker cleanup - active transfers detected '
            '(outgoing: $hasActiveOutgoingTransfers, batches: $hasActiveFileTransferBatches)');
      }
    } catch (e) {
      logWarning('P2PService: Failed to cleanup file picker cache safely: $e');
    }
  }
}
