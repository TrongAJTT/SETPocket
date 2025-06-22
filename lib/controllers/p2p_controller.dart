import 'package:flutter/material.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/network_security_service.dart';
import 'package:setpocket/services/p2p_service.dart';
import 'package:setpocket/services/app_logger.dart';

class P2PController with ChangeNotifier {
  final P2PService _p2pService = P2PService.instance;

  // UI State
  bool _isInitialized = false;
  bool _showSecurityWarning = false;
  String? _errorMessage;

  // Network state
  NetworkInfo? _networkInfo;

  // Selected items
  P2PUser? _selectedUser;
  String? _selectedFile;

  // Discovery state
  bool _isRefreshing = false;
  bool _hasPerformedInitialDiscovery = false;

  // Callback for new pairing requests
  Function(PairingRequest)? _onNewPairingRequest;

  P2PController() {
    _p2pService.addListener(_onP2PServiceChanged);
  }

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isEnabled => _p2pService.isEnabled;
  bool get isDiscovering => _p2pService.isDiscovering;
  bool get showSecurityWarning => _showSecurityWarning;
  String? get errorMessage => _errorMessage;
  NetworkInfo? get networkInfo => _networkInfo;
  ConnectionStatus get connectionStatus => _p2pService.connectionStatus;
  P2PUser? get currentUser => _p2pService.currentUser;
  List<P2PUser> get discoveredUsers => _p2pService.discoveredUsers;
  List<P2PUser> get pairedUsers => _p2pService.pairedUsers;

  /// Saved devices (stored connections) - ensure no duplicates
  List<P2PUser> get connectedUsers {
    final users = _p2pService.connectedUsers; // This returns isStored users
    return _deduplicateUsers(users);
  }

  /// Available devices (discovered but not stored) - ensure no duplicates
  List<P2PUser> get unconnectedUsers {
    final users = _p2pService.unconnectedUsers; // This returns !isStored users
    final connectedUserIds = connectedUsers.map((u) => u.id).toSet();

    // Filter out users that are already in connected list
    final filteredUsers =
        users.where((u) => !connectedUserIds.contains(u.id)).toList();

    return _deduplicateUsers(filteredUsers);
  }

  /// Deduplicate users by multiple criteria to prevent UI duplicates
  List<P2PUser> _deduplicateUsers(List<P2PUser> users) {
    final uniqueUsers = <String, P2PUser>{};
    final ipPortCombos = <String, P2PUser>{};

    for (final user in users) {
      final ipPortKey = '${user.ipAddress}:${user.port}';

      // Check for duplicates by ID first
      final existingById = uniqueUsers[user.id];
      if (existingById == null) {
        // Check for duplicates by IP:Port
        final existingByIpPort = ipPortCombos[ipPortKey];
        if (existingByIpPort == null) {
          // No duplicates found, add user
          uniqueUsers[user.id] = user;
          ipPortCombos[ipPortKey] = user;
        } else {
          // Found duplicate by IP:Port, keep the better one
          final betterUser = _chooseBetterUser(existingByIpPort, user);

          // Remove old entries
          uniqueUsers.remove(existingByIpPort.id);
          ipPortCombos.remove(ipPortKey);

          // Add better user
          uniqueUsers[betterUser.id] = betterUser;
          ipPortCombos[ipPortKey] = betterUser;
        }
      } else {
        // Found duplicate by ID, merge data and keep the better one
        final mergedUser = _mergeUserData(existingById, user);
        uniqueUsers[user.id] = mergedUser;
        ipPortCombos[ipPortKey] = mergedUser;
      }
    }

    return uniqueUsers.values.toList();
  }

  /// Choose the better user when duplicates are found
  P2PUser _chooseBetterUser(P2PUser user1, P2PUser user2) {
    // Priority order:
    // 1. Stored users over non-stored
    // 2. Paired users over non-paired
    // 3. Trusted users over non-trusted
    // 4. Online users over offline
    // 5. More recent lastSeen

    if (user1.isStored != user2.isStored) {
      return user1.isStored ? user1 : user2;
    }

    if (user1.isPaired != user2.isPaired) {
      return user1.isPaired ? user1 : user2;
    }

    if (user1.isTrusted != user2.isTrusted) {
      return user1.isTrusted ? user1 : user2;
    }

    if (user1.isOnline != user2.isOnline) {
      return user1.isOnline ? user1 : user2;
    }

    // Choose more recent
    return user1.lastSeen.isAfter(user2.lastSeen) ? user1 : user2;
  }

  /// Merge data from two user objects
  P2PUser _mergeUserData(P2PUser primary, P2PUser secondary) {
    // Use primary as base and update with better data from secondary
    if (secondary.isStored && !primary.isStored) {
      primary.isStored = secondary.isStored;
      primary.isPaired = secondary.isPaired;
      primary.isTrusted = secondary.isTrusted;
      primary.autoConnect = secondary.autoConnect;
      primary.pairedAt = secondary.pairedAt;
    }

    // Update network info if secondary is more recent
    if (secondary.lastSeen.isAfter(primary.lastSeen)) {
      primary.ipAddress = secondary.ipAddress;
      primary.port = secondary.port;
      primary.lastSeen = secondary.lastSeen;
      primary.isOnline = secondary.isOnline;
    }

    // Update display name if secondary has a better name
    if (primary.displayName.startsWith('Device-') &&
        !secondary.displayName.startsWith('Device-')) {
      primary.displayName = secondary.displayName;
    }

    return primary;
  }

  List<PairingRequest> get pendingRequests => _p2pService.pendingRequests;
  List<DataTransferTask> get activeTransfers => _p2pService.activeTransfers;
  P2PUser? get selectedUser => _selectedUser;
  String? get selectedFile => _selectedFile;
  bool get isRefreshing => _isRefreshing;
  bool get hasPerformedInitialDiscovery => _hasPerformedInitialDiscovery;
  DateTime? get lastDiscoveryTime => _p2pService.lastDiscoveryTime;

  /// Initialize the controller
  Future<void> initialize() async {
    try {
      await _p2pService.initialize();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Check network and start P2P if conditions are met
  Future<bool> checkAndStartNetworking() async {
    try {
      _errorMessage = null;

      // Check network security
      _networkInfo = await NetworkSecurityService.checkNetworkSecurity();

      // Show warning for unsecure networks
      if (_networkInfo!.securityLevel == NetworkSecurityLevel.unsecure) {
        _showSecurityWarning = true;
        notifyListeners();
        return false; // Wait for user confirmation
      }

      // Start networking
      final started = await _p2pService.startNetworking();
      if (!started) {
        _errorMessage = 'Failed to start P2P networking';
      } else {
        // Perform initial discovery after successfully starting networking
        await _performInitialDiscovery();
      }

      notifyListeners();
      return started;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Start networking after security warning confirmation
  Future<bool> startNetworkingWithWarning() async {
    try {
      _showSecurityWarning = false;
      _errorMessage = null;

      final started = await _p2pService.startNetworking();
      if (!started) {
        _errorMessage = 'Failed to start P2P networking';
      } else {
        // Perform initial discovery after successfully starting networking
        await _performInitialDiscovery();
      }

      notifyListeners();
      return started;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Stop P2P networking
  Future<void> stopNetworking() async {
    try {
      await _p2pService.stopNetworking();
      _showSecurityWarning = false;
      _errorMessage = null;
      _resetDiscoveryState();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Dismiss security warning
  void dismissSecurityWarning() {
    _showSecurityWarning = false;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Select user for pairing or data transfer
  void selectUser(P2PUser user) {
    _selectedUser = user;
    notifyListeners();
  }

  /// Clear selected user
  void clearSelectedUser() {
    _selectedUser = null;
    notifyListeners();
  }

  /// Send pairing request
  Future<bool> sendPairingRequest(
      P2PUser targetUser, bool saveConnection) async {
    try {
      _errorMessage = null;
      final success =
          await _p2pService.sendPairingRequest(targetUser, saveConnection);
      if (!success) {
        _errorMessage = 'Failed to send pairing request';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Respond to pairing request
  Future<bool> respondToPairingRequest(String requestId, bool accept,
      bool trustUser, bool saveConnection) async {
    try {
      _errorMessage = null;
      final success = await _p2pService.respondToPairingRequest(
          requestId, accept, trustUser, saveConnection);
      if (!success) {
        _errorMessage = 'Failed to respond to pairing request';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Set selected file for transfer
  void setSelectedFile(String filePath) {
    _selectedFile = filePath;
    notifyListeners();
  }

  /// Send file to selected user
  Future<bool> sendDataToUser(String filePath, P2PUser targetUser) async {
    try {
      _errorMessage = null;
      final success = await _p2pService.sendData(filePath, targetUser);
      if (!success) {
        _errorMessage = 'Failed to start data transfer';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cancel data transfer
  Future<bool> cancelDataTransfer(String taskId) async {
    try {
      _errorMessage = null;
      final success = await _p2pService.cancelDataTransfer(taskId);
      if (!success) {
        _errorMessage = 'Failed to cancel data transfer';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get network status description
  String getNetworkStatusDescription() {
    if (_networkInfo == null) return 'Checking network...';

    if (_networkInfo!.isMobile) {
      return 'Connected via mobile data (secure)';
    } else if (_networkInfo!.isWiFi) {
      final securityText = _networkInfo!.isSecure ? 'secure' : 'unsecure';
      final wifiName = _networkInfo!.wifiName ?? 'Unknown WiFi';
      return 'Connected to $wifiName ($securityText)';
    } else if (_networkInfo!.securityType == 'ETHERNET') {
      return 'Connected via Ethernet (secure)';
    } else {
      return 'No network connection';
    }
  }

  /// Get connection status description
  String getConnectionStatusDescription() {
    switch (connectionStatus) {
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.discovering:
        return 'Discovering devices...';
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.pairing:
        return 'Pairing...';
      case ConnectionStatus.paired:
        return 'Paired';
    }
  }

  /// Get data transfer progress text
  String getTransferProgressText(DataTransferTask task) {
    final progress = (task.progress * 100).toStringAsFixed(1);
    final transferred = _formatBytes(task.transferredBytes);
    final total = _formatBytes(task.fileSize);
    return '$progress% ($transferred / $total)';
  }

  /// Format bytes to human readable string
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get status icon for user
  IconData getUserStatusIcon(P2PUser user) {
    if (!user.isOnline) return Icons.offline_bolt;
    if (user.isPaired && user.isTrusted) return Icons.verified_user;
    if (user.isPaired) return Icons.link;
    return Icons.person;
  }

  /// Get status color for user
  Color getUserStatusColor(P2PUser user) {
    switch (user.connectionDisplayStatus) {
      case ConnectionDisplayStatus.discovered:
        return Colors.blue; // Xanh dương - thiết bị mới phát hiện
      case ConnectionDisplayStatus.connectedOnline:
        return Colors.green; // Xanh lá - đã kết nối và online
      case ConnectionDisplayStatus.connectedOffline:
        return Colors.grey; // Xám - đã kết nối nhưng offline
    }
  }

  /// Get transfer status icon
  IconData getTransferStatusIcon(DataTransferTask task) {
    switch (task.status) {
      case DataTransferStatus.pending:
        return Icons.schedule;
      case DataTransferStatus.requesting:
        return Icons.help_outline;
      case DataTransferStatus.transferring:
        return Icons.sync;
      case DataTransferStatus.completed:
        return Icons.check_circle;
      case DataTransferStatus.failed:
        return Icons.error;
      case DataTransferStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// Get transfer status color
  Color getTransferStatusColor(DataTransferTask task) {
    switch (task.status) {
      case DataTransferStatus.pending:
        return Colors.orange;
      case DataTransferStatus.requesting:
        return Colors.blue;
      case DataTransferStatus.transferring:
        return Colors.green;
      case DataTransferStatus.completed:
        return Colors.green;
      case DataTransferStatus.failed:
        return Colors.red;
      case DataTransferStatus.cancelled:
        return Colors.grey;
    }
  }

  /// Perform initial discovery when networking starts
  Future<void> _performInitialDiscovery() async {
    if (_hasPerformedInitialDiscovery) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      await _p2pService.manualDiscovery();
      _hasPerformedInitialDiscovery = true;
    } catch (e) {
      _errorMessage = 'Initial discovery failed: $e';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Manual discovery for refresh button
  Future<void> manualDiscovery() async {
    if (_isRefreshing) return;

    try {
      _isRefreshing = true;
      notifyListeners();

      await _p2pService.manualDiscovery();
      _p2pService.lastDiscoveryTime =
          DateTime.now(); // Update time after discovery runs

      // Add a short cooldown to prevent spamming
      await Future.delayed(const Duration(seconds: 10));
    } catch (e) {
      _errorMessage = 'Discovery failed: $e';
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Quick refresh for lightweight updates
  Future<void> quickRefresh() async {
    if (!isEnabled) return;

    try {
      await _p2pService.quickRefresh();
    } catch (e) {
      _errorMessage = 'Quick refresh failed: $e';
      notifyListeners();
    }
  }

  /// Reset discovery state when networking is stopped
  void _resetDiscoveryState() {
    _hasPerformedInitialDiscovery = false;
    _isRefreshing = false;
  }

  /// Disconnect from user
  Future<bool> disconnectUser(String userId) async {
    try {
      _errorMessage = null;
      final success = await _p2pService.disconnectUser(userId);
      if (!success) {
        _errorMessage = 'Failed to disconnect user';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Send trust request
  Future<bool> sendTrustRequest(P2PUser targetUser) async {
    try {
      _errorMessage = null;
      final success = await _p2pService.sendTrustRequest(targetUser);
      if (!success) {
        _errorMessage = 'Failed to send trust request';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Remove trust from user
  Future<bool> removeTrust(String userId) async {
    try {
      _errorMessage = null;
      final success = await _p2pService.removeTrust(userId);
      if (!success) {
        _errorMessage = 'Failed to remove trust';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update file storage settings
  Future<bool> updateFileStorageSettings(
      P2PFileStorageSettings settings) async {
    try {
      _errorMessage = null;
      final success = await _p2pService.updateFileStorageSettings(settings);
      if (!success) {
        _errorMessage = 'Failed to update file storage settings';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get file storage settings
  P2PFileStorageSettings? get fileStorageSettings =>
      _p2pService.fileStorageSettings;

  /// Set callback for new pairing requests (for auto-showing dialogs)
  void setNewPairingRequestCallback(Function(PairingRequest)? callback) {
    _onNewPairingRequest = callback;
    _p2pService.setNewPairingRequestCallback(callback);
  }

  /// Clear new pairing request callback
  void clearNewPairingRequestCallback() {
    _onNewPairingRequest = null;
    _p2pService.setNewPairingRequestCallback(null);
  }

  void _onP2PServiceChanged() {
    logInfo(
        '🔄 P2PController: Service changed - discovered users: ${_p2pService.discoveredUsers.length}, connected: ${_p2pService.connectedUsers.length}');
    notifyListeners();
  }

  @override
  void dispose() {
    _p2pService.removeListener(_onP2PServiceChanged);
    clearNewPairingRequestCallback(); // Clean up callback
    super.dispose();
  }
}
