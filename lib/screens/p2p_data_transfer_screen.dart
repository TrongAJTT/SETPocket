import 'package:flutter/material.dart';
import 'package:setpocket/controllers/p2p_controller.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/layouts/two_panels_main_multi_tab_layout.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/utils/network_debug_utils.dart';
import 'package:setpocket/widgets/p2p/network_security_warning_dialog.dart';
import 'package:setpocket/widgets/p2p/pairing_request_dialog.dart';
import 'package:setpocket/widgets/p2p/user_pairing_dialog.dart';
import 'package:setpocket/widgets/p2p/data_transfer_progress_widget.dart';
import 'package:setpocket/widgets/p2p/permission_request_dialog.dart';
import 'package:setpocket/widgets/hold_to_confirm_dialog.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:setpocket/widgets/p2p/p2p_data_transfer_settings_dialog.dart';
import 'package:setpocket/widgets/p2p/user_info_dialog.dart';
import 'package:setpocket/widgets/p2p/multi_file_sender_dialog.dart';
import 'package:setpocket/widgets/p2p/device_info_card.dart';
import 'package:setpocket/services/network_security_service.dart';

class P2PDataTransferScreen extends StatefulWidget {
  final bool isEmbedded;

  const P2PDataTransferScreen({super.key, this.isEmbedded = false});

  @override
  State<P2PDataTransferScreen> createState() => _P2PDataTransferScreenState();
}

class _P2PDataTransferScreenState extends State<P2PDataTransferScreen> {
  late P2PController _controller;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = P2PController();
    _controller.addListener(_onControllerChanged);

    // Set up callback for auto-showing pairing request dialogs
    _controller.setNewPairingRequestCallback(_onNewPairingRequest);

    _initializeController();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.clearNewPairingRequestCallback(); // Clear callback
    _controller.dispose();
    super.dispose();
  }

  void _initializeController() async {
    await _controller.initialize();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});

      // Show security warning dialog
      if (_controller.showSecurityWarning) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSecurityWarningDialog();
        });
      }
    }
  }

  /// Handle new pairing request - auto-show dialog if screen is visible
  void _onNewPairingRequest(PairingRequest request) {
    if (mounted) {
      logInfo(
          'Auto-showing pairing request dialog for: ${request.fromUserName}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Show dialog immediately for new requests
        _showSinglePairingRequestDialog(request);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_controller.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.p2pDataTransfer)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return TwoPanelsMainMultiTabLayout(
      isEmbedded: widget.isEmbedded,
      title: l10n.p2pDataTransfer,
      mainPanelTitle: l10n.p2pDataTransfer,
      mainTabIndex: _currentTabIndex,
      onMainTabChanged: (index) {
        setState(() {
          _currentTabIndex = index;
        });
      },
      mainPanelActions: [
        // Refresh button - show only when networking is enabled and not currently refreshing
        if (_controller.isEnabled && !_controller.isRefreshing)
          IconButton(
            icon: const Icon(Icons.wifi_tethering),
            onPressed: _manualRefresh,
            tooltip: 'Broadcast Signal',
          ),
        // Loading indicator when refreshing
        if (_controller.isRefreshing)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        if (_controller.pendingRequests.isNotEmpty)
          IconButton(
            icon: Badge(
              label: Text('${_controller.pendingRequests.length}'),
              child: const Icon(Icons.notifications),
            ),
            onPressed: _showPairingRequests,
            tooltip: l10n.pairingRequests,
          ),
        // File storage settings
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _showTransferSettings,
          tooltip: 'Transfer Settings',
        ),
      ],
      mainTabs: [
        TabData(
          label: l10n.devices,
          icon: Icons.devices,
          content: _buildDevicesTab(),
        ),
        TabData(
          label: l10n.transfers,
          icon: Icons.swap_horiz,
          content: _buildTransfersTab(),
        ),
      ],
      secondaryPanel: _buildStatusPanel(),
      secondaryPanelTitle: l10n.status,
      secondaryTab: TabData(
        label: l10n.status,
        icon: Icons.info,
        content: _buildStatusPanel(),
      ),
    );
  }

  Widget _buildDevicesTab() {
    return Column(
      children: [
        // Network status card
        _buildNetworkStatusCard(),
        const SizedBox(height: 16),

        // Devices sections
        Expanded(
          child: _controller.discoveredUsers.isEmpty
              ? _buildEmptyDevicesState()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Saved devices section
                    if (_controller.connectedUsers.isNotEmpty) ...[
                      _buildSectionHeader('Saved Devices'),
                      ..._controller.connectedUsers
                          .map((user) => _buildUserCard(user)),
                      const SizedBox(height: 16),
                    ],
                    // Available devices section
                    if (_controller.unconnectedUsers.isNotEmpty) ...[
                      _buildSectionHeader('Available Devices'),
                      ..._controller.unconnectedUsers
                          .map((user) => _buildUserCard(user)),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildTransfersTab() {
    if (_controller.activeTransfers.isEmpty) {
      return _buildEmptyTransfersState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _controller.activeTransfers.length,
      itemBuilder: (context, index) {
        final transfer = _controller.activeTransfers[index];
        return DataTransferProgressWidget(
          task: transfer,
          onCancel: () => _cancelTransfer(transfer.id),
          onClear: () => _clearTransfer(transfer.id),
        );
      },
    );
  }

  Widget _buildStatusPanel() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Connection status
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.connectionStatus,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _getConnectionStatusIcon(),
                        color: _getConnectionStatusColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:
                            Text(_controller.getConnectionStatusDescription()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Network info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.networkInfo,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      TextButton(
                        onPressed: _debugNetwork,
                        child: const Text('Debug'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_controller.getNetworkStatusDescription()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Statistics
          if (_controller.currentUser != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.statistics,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '${l10n.discoveredDevices}: ${_controller.discoveredUsers.length}'),
                    Text(
                        '${l10n.pairedDevices}: ${_controller.pairedUsers.length}'),
                    Text(
                        '${l10n.activeTransfers}: ${_controller.activeTransfers.length}'),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Current device info
          FutureBuilder<Widget>(
            future: _buildThisDeviceCard(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              } else {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'This Device',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Loading device information...'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),

          // Debug section removed - using simple native device ID now

          // Add some bottom padding for better scrolling experience
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    final toggleNetworkBtn = ElevatedButton.icon(
      onPressed: _toggleNetworking,
      icon: Icon(_controller.isEnabled ? Icons.wifi_off : Icons.wifi),
      label: Text(_controller.isEnabled
          ? (l10n.stopNetworking)
          : (l10n.startNetworking)),
      style: ElevatedButton.styleFrom(
        backgroundColor: _controller.isEnabled ? Colors.red[700] : null,
        foregroundColor: _controller.isEnabled ? Colors.white : null,
      ),
    );

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _getNetworkStatusIcon(),
                  color: _getNetworkStatusColor(),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _controller.getNetworkStatusDescription(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _controller.getConnectionStatusDescription(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (isDesktop) toggleNetworkBtn
              ],
            ),
            if (!isDesktop) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [toggleNetworkBtn],
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.9)
                  : Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildUserCard(P2PUser user) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _controller.getUserStatusColor(user),
          child: Icon(
            _controller.getUserStatusIcon(user),
            color: Colors.white,
          ),
        ),
        title: Text(user.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user.ipAddress}:${user.port}'),
            if (user.isPaired || user.isTrusted)
              Wrap(
                spacing: 6.0,
                runSpacing: 4.0,
                children: [
                  if (user.isStored)
                    const Chip(
                      label: Text('Saved'),
                      avatar: Icon(Icons.save, size: 14),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  if (user.isTrusted)
                    const Chip(
                      label: Text('Trusted'),
                      avatar: Icon(Icons.verified_user, size: 14),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                ],
              )
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(user, value),
          itemBuilder: (context) => [
            // View user info (replaced send file option)
            PopupMenuItem(
              value: 'view_info',
              child: Row(
                children: [
                  const Icon(Icons.info),
                  const SizedBox(width: 8),
                  const Text('View Info'),
                ],
              ),
            ),

            // Basic actions
            if (!user.isPaired)
              PopupMenuItem(
                value: 'pair',
                child: Row(
                  children: [
                    const Icon(Icons.link),
                    const SizedBox(width: 8),
                    Text(l10n.pair),
                  ],
                ),
              ),

            // Trust management
            if (user.isPaired && !user.isTrusted)
              const PopupMenuItem(
                value: 'request_trust',
                child: Row(
                  children: [
                    Icon(Icons.verified_user),
                    SizedBox(width: 8),
                    Text('Request Trust'),
                  ],
                ),
              ),
            if (user.isTrusted)
              const PopupMenuItem(
                value: 'remove_trust',
                child: Row(
                  children: [
                    Icon(Icons.security),
                    SizedBox(width: 8),
                    Text('Remove Trust'),
                  ],
                ),
              ),

            // Connection management
            if (user.isStored)
              const PopupMenuItem(
                value: 'unpair',
                child: Row(
                  children: [
                    Icon(Icons.link_off),
                    SizedBox(width: 8),
                    Text('Unpair'),
                  ],
                ),
              ),
          ],
        ),
        onTap: () => _selectUser(user),
      ),
    );
  }

  Widget _buildEmptyDevicesState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noDevicesFound,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _controller.isRefreshing
                ? 'Searching for devices...'
                : (_controller.isEnabled
                    ? (_controller.hasPerformedInitialDiscovery
                        ? 'No devices in range. Try refreshing.'
                        : 'Initial discovery in progress...')
                    : l10n.startNetworkingToDiscover),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Show last discovery time and refresh button when appropriate
          if (_controller.isEnabled &&
              _controller.hasPerformedInitialDiscovery) ...[
            if (_controller.lastDiscoveryTime != null)
              Text(
                'Last refresh: ${_formatDiscoveryTime(_controller.lastDiscoveryTime!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            if (!_controller.isRefreshing)
              ElevatedButton.icon(
                onPressed: _manualRefresh,
                icon: const Icon(Icons.signal_cellular_alt),
                label: const Text('Broadcast Signal'),
              ),
            if (_controller.isRefreshing)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Refreshing...'),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyTransfersState() {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noActiveTransfers,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.transfersWillAppearHere,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Event handlers

  void _toggleNetworking() {
    if (_controller.isEnabled) {
      _stopNetworking();
    } else {
      _startNetworking();
    }
  }

  void _startNetworking() async {
    // Check for location permission before starting
    final status = await Permission.locationWhenInUse.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) => PermissionRequestDialog(
            onContinue: () async {
              Navigator.of(context).pop();
              // Now, attempt to start networking, which will trigger the actual permission request
              final success = await _controller.checkAndStartNetworking();
              if (!success && _controller.errorMessage != null && mounted) {
                _showErrorSnackBar(_controller.errorMessage!);
              }
            },
            onCancel: () {
              Navigator.of(context).pop();
            },
          ),
        );
      }
    } else {
      // Permission is already granted, proceed
      final success = await _controller.checkAndStartNetworking();
      if (!success && _controller.errorMessage != null && mounted) {
        _showErrorSnackBar(_controller.errorMessage!);
      }
    }
  }

  void _stopNetworking() async {
    await _controller.stopNetworking();
  }

  void _selectUser(P2PUser user) {
    _controller.selectUser(user);
    if (!user.isPaired) {
      _showPairingDialog(user);
    } else if (user.isPaired && user.isOnline) {
      // Show multi-file sender dialog for paired and online users
      _showMultiFileSenderDialog(user);
    }
  }

  void _handleUserAction(P2PUser user, String action) {
    switch (action) {
      case 'view_info':
        _showUserInfoDialog(user);
        break;
      case 'pair':
        _showPairingDialog(user);
        break;
      case 'request_trust':
        _requestTrust(user);
        break;
      case 'remove_trust':
        _removeTrust(user);
        break;
      case 'unpair':
        _showUnpairDialog(user);
        break;
    }
  }

  void _cancelTransfer(String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.cancelTransfer),
        content: Text(AppLocalizations.of(context)!.confirmCancelTransfer),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.cancelDataTransfer(taskId);
            },
            child: Text(AppLocalizations.of(context)!.cancelTransfer),
          ),
        ],
      ),
    );
  }

  void _showPairingDialog(P2PUser user) {
    showDialog(
      context: context,
      builder: (context) => UserPairingDialog(
        user: user,
        onPair: (saveConnection) async {
          final success =
              await _controller.sendPairingRequest(user, saveConnection);
          if (!success && _controller.errorMessage != null) {
            _showErrorSnackBar(_controller.errorMessage!);
          }
        },
      ),
    );
  }

  void _showPairingRequests() {
    showDialog(
      context: context,
      builder: (context) => PairingRequestDialog(
        requests: _controller.pendingRequests,
        onRespond: (requestId, accept, trustUser, saveConnection) async {
          final success = await _controller.respondToPairingRequest(
              requestId, accept, trustUser, saveConnection);
          if (!success && _controller.errorMessage != null) {
            _showErrorSnackBar(_controller.errorMessage!);
          }
        },
      ),
    );
  }

  /// Show dialog for a single pairing request (for auto-showing new requests)
  void _showSinglePairingRequestDialog(PairingRequest request) {
    showDialog(
      context: context,
      builder: (context) => PairingRequestDialog(
        requests: [request], // Show only this specific request
        onRespond: (requestId, accept, trustUser, saveConnection) async {
          final success = await _controller.respondToPairingRequest(
              requestId, accept, trustUser, saveConnection);
          if (!success && _controller.errorMessage != null) {
            _showErrorSnackBar(_controller.errorMessage!);
          }
        },
      ),
    );
  }

  void _showSecurityWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NetworkSecurityWarningDialog(
        networkInfo: _controller.networkInfo!,
        onProceed: () async {
          Navigator.of(context).pop();
          await _controller.startNetworkingWithWarning();
        },
        onCancel: () {
          Navigator.of(context).pop();
          _controller.dismissSecurityWarning();
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper methods

  IconData _getConnectionStatusIcon() {
    switch (_controller.connectionStatus) {
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
      case ConnectionStatus.discovering:
        return Icons.search;
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.pairing:
        return Icons.link;
      case ConnectionStatus.paired:
        return Icons.check_circle;
    }
  }

  Color _getConnectionStatusColor() {
    switch (_controller.connectionStatus) {
      case ConnectionStatus.disconnected:
        return Colors.red;
      case ConnectionStatus.discovering:
        return Colors.orange;
      case ConnectionStatus.connected:
        return Colors.blue;
      case ConnectionStatus.pairing:
        return Colors.orange;
      case ConnectionStatus.paired:
        return Colors.green;
    }
  }

  IconData _getNetworkStatusIcon() {
    final networkInfo = _controller.networkInfo;
    if (networkInfo == null) return Icons.help_outline;

    if (networkInfo.isMobile) {
      return Icons.signal_cellular_4_bar;
    } else if (networkInfo.isWiFi) {
      return networkInfo.isSecure ? Icons.wifi_lock : Icons.wifi;
    } else if (networkInfo.securityType == 'ETHERNET') {
      return Icons.lan; // Ethernet cable icon
    } else {
      return Icons.wifi_off;
    }
  }

  Color _getNetworkStatusColor() {
    final networkInfo = _controller.networkInfo;
    if (networkInfo == null) return Colors.grey;

    switch (networkInfo.securityLevel) {
      case NetworkSecurityLevel.secure:
        return Colors.green;
      case NetworkSecurityLevel.unsecure:
        return Colors.orange;
      case NetworkSecurityLevel.unknown:
        return Colors.grey;
    }
  }

  void _debugNetwork() async {
    await NetworkDebugUtils.debugNetworkConnectivity();
    _showErrorSnackBar('Network debug completed. Check logs for details.');
  }

  void _manualRefresh() async {
    await _controller.manualDiscovery();
    if (mounted && _controller.errorMessage != null) {
      _showErrorSnackBar(_controller.errorMessage!);
    }
  }

  String _formatDiscoveryTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _showTransferSettings() {
    showDialog(
      context: context,
      builder: (context) => P2PDataTransferSettingsDialog(
        currentSettings: _controller.transferSettings,
        onSettingsChanged: (settings) async {
          final success = await _controller.updateTransferSettings(settings);
          if (success) {
            _showErrorSnackBar('Transfer settings updated');
          } else if (_controller.errorMessage != null) {
            _showErrorSnackBar(_controller.errorMessage!);
          }
        },
      ),
    );
  }

  void _requestTrust(P2PUser user) async {
    final success = await _controller.sendTrustRequest(user);
    if (success) {
      _showErrorSnackBar('Trust request sent to ${user.displayName}');
    } else if (_controller.errorMessage != null) {
      _showErrorSnackBar(_controller.errorMessage!);
    }
  }

  void _removeTrust(P2PUser user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Trust'),
        content: Text('Remove trust from ${user.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await _controller.removeTrust(user.id);
              if (success) {
                _showErrorSnackBar('Trust removed from ${user.displayName}');
              } else if (_controller.errorMessage != null) {
                _showErrorSnackBar(_controller.errorMessage!);
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showUnpairDialog(P2PUser user) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => HoldToConfirmDialog(
        title: 'Unpair from ${user.displayName}',
        content:
            'This will remove the pairing completely from both devices. You will need to pair again in the future.\n\nThe other device will also be notified and their connection will be removed.',
        actionText: 'Hold to Unpair',
        holdText: 'Hold to Unpair',
        processingText: 'Unpairing...',
        instructionText: 'Hold the button for 1 second to confirm unpair',
        actionIcon: Icons.link_off,
        holdDuration: const Duration(seconds: 1),
        l10n: l10n,
        onConfirmed: () async {
          Navigator.of(context).pop();

          final success = await _controller.unpairUser(user.id);
          if (success) {
            _showErrorSnackBar('Unpaired from ${user.displayName}');
          } else if (_controller.errorMessage != null) {
            _showErrorSnackBar(_controller.errorMessage!);
          }
        },
      ),
    );
  }

  void _clearTransfer(String taskId) {
    _controller.clearTransfer(taskId);
  }

  Future<Widget> _buildThisDeviceCard() async {
    // Luôn hiển thị device info, ngay cả khi networking chưa được khởi động
    try {
      // Lấy thông tin device
      final deviceName = await NetworkSecurityService.getDeviceName();
      final appInstallationId =
          await NetworkSecurityService.getAppInstallationId();

      // Tạo dummy user với thông tin hiện có
      final deviceUser = P2PUser(
        id: appInstallationId,
        displayName: deviceName,
        appInstallationId: appInstallationId,
        ipAddress: _controller.currentUser?.ipAddress ?? 'Not connected',
        port: _controller.currentUser?.port ?? 0,
        isOnline: _controller.isEnabled,
        lastSeen: DateTime.now(),
        isStored: false,
      );

      return DeviceInfoCard(
        user: deviceUser,
        title: 'This Device',
        showStatusChips: false,
        isCompact: false,
        showDeviceIdToggle: true,
      );
    } catch (e) {
      // Fallback nếu có lỗi
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Device',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Loading device information...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showUserInfoDialog(P2PUser user) {
    showDialog(
      context: context,
      builder: (context) => UserInfoDialog(user: user),
    );
  }

  void _showMultiFileSenderDialog(P2PUser user) {
    showDialog(
      context: context,
      builder: (context) => MultiFileSenderDialog(
        targetUser: user,
        onSendFiles: (filePaths) async {
          final success =
              await _controller.sendMultipleFilesToUser(filePaths, user);
          if (!success && _controller.errorMessage != null) {
            _showErrorSnackBar(_controller.errorMessage!);
          } else {
            _showErrorSnackBar(
                'Started sending ${filePaths.length} files to ${user.displayName}');
          }
        },
      ),
    );
  }

  // Debug methods removed - using simple native device ID now
}
