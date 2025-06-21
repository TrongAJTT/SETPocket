import 'package:flutter/material.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/services/network_security_service.dart';
import 'package:setpocket/services/p2p_service.dart';

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
  List<P2PUser> get connectedUsers => _p2pService.connectedUsers;
  List<P2PUser> get unconnectedUsers => _p2pService.unconnectedUsers;
  List<PairingRequest> get pendingRequests => _p2pService.pendingRequests;
  List<FileTransferTask> get activeTransfers => _p2pService.activeTransfers;
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

  /// Select user for pairing or file transfer
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
  Future<bool> sendFileToUser(String filePath, P2PUser targetUser) async {
    try {
      _errorMessage = null;
      final success = await _p2pService.sendFile(filePath, targetUser);
      if (!success) {
        _errorMessage = 'Failed to start file transfer';
      }
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cancel file transfer
  Future<bool> cancelFileTransfer(String taskId) async {
    try {
      _errorMessage = null;
      final success = await _p2pService.cancelFileTransfer(taskId);
      if (!success) {
        _errorMessage = 'Failed to cancel file transfer';
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

  /// Get file transfer progress text
  String getTransferProgressText(FileTransferTask task) {
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
  IconData getTransferStatusIcon(FileTransferTask task) {
    switch (task.status) {
      case FileTransferStatus.pending:
        return Icons.schedule;
      case FileTransferStatus.requesting:
        return Icons.help_outline;
      case FileTransferStatus.transferring:
        return Icons.sync;
      case FileTransferStatus.completed:
        return Icons.check_circle;
      case FileTransferStatus.failed:
        return Icons.error;
      case FileTransferStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// Get transfer status color
  Color getTransferStatusColor(FileTransferTask task) {
    switch (task.status) {
      case FileTransferStatus.pending:
        return Colors.orange;
      case FileTransferStatus.requesting:
        return Colors.blue;
      case FileTransferStatus.transferring:
        return Colors.green;
      case FileTransferStatus.completed:
        return Colors.green;
      case FileTransferStatus.failed:
        return Colors.red;
      case FileTransferStatus.cancelled:
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
    if (!isEnabled) return;

    _isRefreshing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _p2pService.manualDiscovery();
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

  void _onP2PServiceChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _p2pService.removeListener(_onP2PServiceChanged);
    super.dispose();
  }
}
