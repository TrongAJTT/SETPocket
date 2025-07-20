import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:setpocket/controllers/p2p_controller.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/layouts/two_panels_main_multi_tab_layout.dart';
import 'package:setpocket/models/p2p/p2p_models.dart';
import 'package:setpocket/screens/p2lan_transfer/p2lan_chat_screen.dart';
import 'package:setpocket/services/function_info_service.dart';
import 'package:setpocket/utils/generic_dialog_utils.dart';
import 'package:setpocket/utils/network_debug_utils.dart';
import 'package:setpocket/widgets/p2p/network_security_warning_dialog.dart';
import 'package:setpocket/widgets/p2p/pairing_request_dialog.dart';
import 'package:setpocket/widgets/p2p/file_transfer_request_dialog.dart';
import 'package:setpocket/widgets/p2p/user_pairing_dialog.dart';

import 'package:setpocket/widgets/hold_to_confirm_dialog.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/utils/permission_utils.dart';
import 'package:setpocket/utils/generic_settings_utils.dart';
import 'package:setpocket/widgets/p2p/user_info_dialog.dart';
import 'package:setpocket/widgets/p2p/multi_file_sender_dialog.dart';
import 'package:setpocket/widgets/p2p/device_info_card.dart';
import 'package:setpocket/widgets/p2p/transfer_batch_widget.dart';
import 'package:setpocket/screens/p2lan_transfer/p2lan_local_files_screen.dart';
import 'package:setpocket/services/network_security_service.dart';
import 'package:setpocket/services/p2p_services/p2p_navigation_service.dart';
import 'package:setpocket/services/p2p_services/p2p_notification_service.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:path_provider/path_provider.dart';

class P2LanTransferScreen extends StatefulWidget {
  final bool isEmbedded;

  const P2LanTransferScreen({super.key, this.isEmbedded = false});

  @override
  State<P2LanTransferScreen> createState() => _P2LanTransferScreenState();
}

class _P2LanTransferScreenState extends State<P2LanTransferScreen> {
  late P2PController _controller;
  int _currentTabIndex = 0;
  final GlobalKey<NavigatorState> _chatNavigatorKey =
      GlobalKey<NavigatorState>();
  bool _isControllerInitialized = false;
  final ScrollController _transfersScrollController = ScrollController();

  // Cache management state
  bool _isCalculatingCacheSize = false;
  String _cachedFileCacheSize = 'Unknown';

  // Batch expand state management
  final Map<String?, bool> _batchExpandStates = {};

  @override
  void initState() {
    super.initState();
    _controller = P2PController();
    _controller.addListener(_onControllerChanged);

    // Set up callback for auto-showing pairing request dialogs
    _controller.setNewPairingRequestCallback(_onNewPairingRequest);

    // Set up callback for auto-showing file transfer request dialogs
    _controller.setNewFileTransferRequestCallback(_onNewFileTransferRequest);

    // Set up navigation callbacks for P2P
    P2PNavigationService.instance.setP2LanCallbacks(
      switchTabCallback: _switchToTab,
      showDialogCallback: _showDialogFromNotification,
      getCurrentTabCallback: () => _currentTabIndex,
    );

    // Set up notification callbacks (only if service is available)
    final notificationService = P2PNotificationService.instanceOrNull;
    if (notificationService != null) {
      notificationService.setCallbacks(
        onNotificationTapped: _handleNotificationTapped,
        onActionPressed: _handleNotificationAction,
      );
    }

    // Initialize cache size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadCacheSize();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isControllerInitialized) {
      _initializeController();
      _isControllerInitialized = true;
    }
  }

  @override
  void didUpdateWidget(P2LanTransferScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Process pending file transfer requests when user returns to this screen
    if (_isControllerInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.processPendingFileTransferRequests();
        // Also reload settings in case they changed externally
        _controller.reloadTransferSettings();
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.clearNewPairingRequestCallback(); // Clear callback
    _controller
        .clearNewFileTransferRequestCallback(); // Clear file transfer callback

    // Clear navigation callbacks
    P2PNavigationService.instance.clearP2LanCallbacks();

    // Clear notification callbacks (only if service is available)
    final notificationService = P2PNotificationService.instanceOrNull;
    if (notificationService != null) {
      notificationService.clearCallbacks();
    }

    // 🔥 CLEANUP: Trigger memory cleanup when leaving P2Lan screen
    _performMemoryCleanup();

    _controller.dispose();
    _transfersScrollController.dispose();
    super.dispose();
  }

  /// 🔥 NEW: Perform memory cleanup when leaving screen
  void _performMemoryCleanup() {
    try {
      // Use Future.microtask to avoid blocking dispose
      Future.microtask(() async {
        try {
          // 🔥 SAFE: Let periodic cleanup handle it safely
          // The P2P service will handle cleanup automatically via its periodic timer
          logInfo(
              'P2LanTransferScreen: Screen disposed - periodic cleanup will handle file picker cache');
        } catch (e) {
          logWarning('P2LanTransferScreen: Error in cleanup logging: $e');
        }
      });
    } catch (e) {
      logWarning('P2LanTransferScreen: Error scheduling memory cleanup: $e');
    }
  }

  void _initializeController() async {
    await _controller.initialize();

    // Process any pending file transfer requests after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.processPendingFileTransferRequests();
    });
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

  /// Handle new file transfer request - auto-show dialog if screen is visible
  void _onNewFileTransferRequest(FileTransferRequest request) {
    if (mounted) {
      logInfo(
          'Auto-showing file transfer request dialog from: ${request.fromUserName}');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFileTransferRequestDialog(request);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!_controller.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.p2lanTransfer)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return TwoPanelsMainMultiTabLayout(
      isEmbedded: widget.isEmbedded,
      title: l10n.p2lanTransfer,
      mainPanelTitle: l10n.p2lanTransfer,
      mainTabIndex: _currentTabIndex,
      onMainTabChanged: (index) {
        setState(() {
          _currentTabIndex = index;
        });
      },
      mainPanelActions: [
        // ...existing code...
        if (Platform.isAndroid)
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: _openLocalFiles,
            tooltip: 'Local Files',
          ),
        if (_controller.isEnabled && !_controller.isRefreshing)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _manualRefresh,
            tooltip: 'Manual Discovery',
          ),
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
        TabData(
          label: l10n.chat,
          icon: Icons.chat,
          content: _buildChatTab(),
        ),
      ],
      secondaryPanel: _buildStatusPanel(),
      secondaryPanelTitle: l10n.status,
      secondaryTab: TabData(
        label: l10n.status,
        icon: Icons.info,
        content: _buildStatusPanel(),
      ),
      secondaryPanelActions: [
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () =>
              FunctionInfo.show(context, FunctionInfoKeys.p2lanDataTransfer),
          tooltip: l10n.info,
        ),
      ],
    );
  }

  Widget _buildChatTab() {
    return ChatTabNavigator(
        controller: _controller, navigatorKey: _chatNavigatorKey);
  }

  Widget _buildDevicesTab() {
    return Column(
      children: [
        // Network status card
        _buildNetworkStatusCard(),
        const SizedBox(height: 16),

        // Devices sections with new categorization
        Expanded(
          child: _buildDevicesSections(),
        ),
      ],
    );
  }

  Widget _buildDevicesSections() {
    // Check if we have any devices at all
    if (_controller.discoveredUsers.isEmpty) {
      return _buildEmptyDevicesState();
    }

    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Online devices section (green - saved devices that are online)
        if (_controller.hasOnlineDevices) ...[
          _buildSectionHeader(
              '🟢 ${l10n.onlineDevices} (${_controller.onlineDevices.length})',
              subtitle: l10n.savedDevicesCurrentlyAvailable),
          ..._controller.onlineDevices
              .map((user) => _buildUserCard(user, isOnline: true)),
          const SizedBox(height: 24),
        ],

        // New devices section (blue - newly discovered devices)
        if (_controller.hasNewDevices) ...[
          _buildSectionHeader(
              '🔵 ${l10n.newDevices} (${_controller.newDevices.length})',
              subtitle: l10n.recentlyDiscoveredDevices),
          ..._controller.newDevices
              .map((user) => _buildUserCard(user, isNew: true)),
          const SizedBox(height: 24),
        ],

        // Saved devices section (gray - saved but offline devices)
        if (_controller.hasSavedDevices) ...[
          _buildSectionHeader(
              '⚫ ${l10n.savedDevices} (${_controller.savedDevices.length})',
              subtitle: l10n.previouslyPairedOffline),
          ..._controller.savedDevices
              .map((user) => _buildUserCard(user, isSaved: true)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserCard(P2PUser user,
      {bool isOnline = false, bool isNew = false, bool isSaved = false}) {
    final l10n = AppLocalizations.of(context)!;
    final brightness = Theme.of(context).brightness;

    // Determine card background color based on category and theme
    Color? cardColor;
    if (isOnline) {
      cardColor = brightness == Brightness.dark
          ? Colors.green.withValues(alpha: 0.1)
          : Colors.green.withValues(alpha: 0.05);
    } else if (isNew) {
      cardColor = brightness == Brightness.dark
          ? Colors.blue.withValues(alpha: 0.1)
          : Colors.blue.withValues(alpha: 0.05);
    } else if (isSaved) {
      cardColor = brightness == Brightness.dark
          ? Colors.grey.withValues(alpha: 0.1)
          : Colors.grey.withValues(alpha: 0.03);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: cardColor,
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
                  Text(l10n.viewInfo),
                ],
              ),
            ),

            // Add to chat list, only show when user is online
            if (isOnline)
              PopupMenuItem(
                value: 'add_to_chat',
                child: Row(
                  children: [
                    const Icon(Icons.chat),
                    const SizedBox(width: 8),
                    Text(l10n.chatWith(user.displayName)),
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
              PopupMenuItem(
                value: 'add_trust',
                child: Row(
                  children: [
                    const Icon(Icons.verified_user),
                    const SizedBox(width: 8),
                    Text(l10n.addTrust),
                  ],
                ),
              ),
            if (user.isTrusted)
              PopupMenuItem(
                value: 'remove_trust',
                child: Row(
                  children: [
                    const Icon(Icons.security),
                    const SizedBox(width: 8),
                    Text(l10n.removeTrust),
                  ],
                ),
              ),

            // Connection management
            if (user.isStored)
              PopupMenuItem(
                value: 'unpair',
                child: Row(
                  children: [
                    const Icon(Icons.link_off),
                    const SizedBox(width: 8),
                    Text(l10n.unpair),
                  ],
                ),
              ),
          ],
        ),
        onTap: () => _selectUser(user),
      ),
    );
  }

  Widget _buildTransfersTab() {
    if (_controller.activeTransfers.isEmpty) {
      return _buildEmptyTransfersState();
    }

    // Group transfers by batch ID
    final groupedTransfers = <String?, List<DataTransferTask>>{};
    for (final transfer in _controller.activeTransfers) {
      final batchId = transfer.batchId;
      groupedTransfers.putIfAbsent(batchId, () => []);
      groupedTransfers[batchId]!.add(transfer);
    }

    // Convert to list of batch widgets
    final batchWidgets = <Widget>[];
    final settings = _controller.transferSettings;
    final rememberBatchState = settings?.rememberBatchExpandState == true;

    // If setting is disabled, clear any saved states
    if (!rememberBatchState && _batchExpandStates.isNotEmpty) {
      _batchExpandStates.clear();
    }

    for (final entry in groupedTransfers.entries) {
      final batchId = entry.key;

      bool isExpanded;
      if (rememberBatchState) {
        // If setting is enabled, use saved state or default to false (collapsed)
        // This preserves current widget state when setting is first enabled
        isExpanded = _batchExpandStates[batchId] ?? false;
        // Only save the state if it doesn't exist yet
        if (!_batchExpandStates.containsKey(batchId)) {
          _batchExpandStates[batchId] = false;
        }
      } else {
        // If setting is disabled, default to false (collapsed) for performance
        isExpanded = false;
      }

      batchWidgets.add(
        TransferBatchWidget(
          batchId: batchId,
          tasks: entry.value,
          initialExpanded: isExpanded,
          onCancel: _cancelTransfer,
          onClear: _clearTransfer,
          onClearWithFile: _clearTransferWithFile,
          onExpandChanged: _onBatchExpandChanged,
          onClearBatch: _onClearBatch,
          onClearBatchWithFiles: _onClearBatchWithFiles,
        ),
      );
    }

    return ListView(
      controller: _transfersScrollController,
      padding: const EdgeInsets.all(16),
      children: batchWidgets,
    );
  }

  Widget _buildStatusPanel() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File Cache card (Show only on Android)
          if (Platform.isAndroid) ...[
            _buildFileCacheCard(),
            const SizedBox(height: 16),
          ],

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
                          l10n.thisDevice,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.loadingDeviceInfo),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 16),

          // Connection status with Network Info merged
          _buildConnectionStatusCard(),
          const SizedBox(height: 16),

          // Statistics (Full-width like other cards)
          if (_controller.currentUser != null)
            SizedBox(
              width: double.infinity,
              child: Card(
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
            ),

          // Add some bottom padding for better scrolling experience
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 800;

    final toggleNetworkBtn = ElevatedButton.icon(
      onPressed: _controller.isTemporarilyDisabled ? null : _toggleNetworking,
      icon: Icon(_controller.isTemporarilyDisabled
          ? Icons.pause_circle_outline
          : (_controller.isEnabled ? Icons.wifi_off : Icons.wifi)),
      label: Text(_controller.isTemporarilyDisabled
          ? 'Paused (No Internet)'
          : (_controller.isEnabled
              ? (l10n.stopNetworking)
              : (l10n.startNetworking))),
      style: ElevatedButton.styleFrom(
        backgroundColor: _controller.isTemporarilyDisabled
            ? Colors.orange[700]
            : (_controller.isEnabled ? Colors.red[700] : null),
        foregroundColor:
            (_controller.isTemporarilyDisabled || _controller.isEnabled)
                ? Colors.white
                : null,
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
                        _controller.getNetworkStatusDescription(l10n),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _controller.getConnectionStatusDescription(l10n),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (isDesktop) ...[
                  const SizedBox(width: 8),
                  toggleNetworkBtn,
                ]
              ],
            ),
            if (!isDesktop) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  toggleNetworkBtn,
                ],
              )
            ]
          ],
        ),
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
            _controller.isTemporarilyDisabled
                ? l10n.p2pNetworkingPaused
                : (_controller.isRefreshing
                    ? l10n.searchingForDevices
                    : (_controller.isEnabled
                        ? (_controller.hasPerformedInitialDiscovery
                            ? l10n.noDevicesInRange
                            : l10n.initialDiscoveryInProgress)
                        : l10n.startNetworkingToDiscover)),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Show last discovery time and refresh button when appropriate
          if (_controller.isEnabled &&
              _controller.hasPerformedInitialDiscovery &&
              !_controller.isTemporarilyDisabled) ...[
            if (_controller.lastDiscoveryTime != null)
              Text(
                l10n.lastRefresh(
                    _formatDiscoveryTime(_controller.lastDiscoveryTime!)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            if (!_controller.isRefreshing)
              ElevatedButton.icon(
                onPressed: _manualRefresh,
                icon: const Icon(Icons.search),
                label: Text(l10n.manualDiscovery),
              ),
            if (_controller.isRefreshing)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.refreshing),
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
    try {
      // Use the utility to request all P2P permissions with proper UI flow
      final permissionsGranted =
          await PermissionUtils.requestAllP2PPermissions(context);

      if (!permissionsGranted) {
        // User cancelled or denied permissions
        if (mounted) {
          _showErrorSnackBar(
              'Permissions are required to start P2P networking');
        }
        return;
      }

      // All permissions granted, proceed with starting networking
      final success = await _controller.checkAndStartNetworking();
      if (!success && _controller.errorMessage != null && mounted) {
        _showErrorSnackBar(_controller.errorMessage!);
      }
    } catch (e) {
      logError('Error in _startNetworking: $e');
      if (mounted) {
        // Show more specific error message
        final errorMessage = e.toString().replaceFirst('Exception: ', '');
        _showErrorSnackBar(errorMessage);
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
      case 'add_to_chat':
        _addUserToChatAndOpen(user);
        break;
      case 'pair':
        _showPairingDialog(user);
        break;
      case 'add_trust':
        _addTrust(user);
        break;
      case 'remove_trust':
        _removeTrust(user);
        break;
      case 'unpair':
        _showUnpairDialog(user);
        break;
    }
  }

  /// Add user to chat and switch to Chat tab
  void _addUserToChatAndOpen(P2PUser user) async {
    final chatService = _controller.p2pChatService;
    final currentUserId = _controller.currentUser?.id;
    if (currentUserId == null) {
      _showErrorSnackBar('Current user not available');
      return;
    }
    // Find chat (API expects userId)
    final chat = await chatService.findChatByUsers(user.id);
    String chatId;
    if (chat != null) {
      chatId = chat.id.toString();
    } else {
      final newChat = await chatService.addChat(user.id);
      chatId = newChat.id.toString();
    }
    setState(() {
      _currentTabIndex = 2;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatNavigatorKey.currentState
          ?.pushNamed('/chatDetail', arguments: chatId);
    });
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
        onPair: (saveConnection, trustUser) async {
          final success = await _controller.sendPairingRequest(
              user, saveConnection, trustUser);
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

  /// Show dialog for file transfer request
  void _showFileTransferRequestDialog(FileTransferRequest request,
      {int? initialCountdown}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => FileTransferRequestDialog(
        request: request,
        initialCountdown: initialCountdown,
        onResponse: (accept, rejectMessage) async {
          final success = await _controller.respondToFileTransferRequest(
              request.requestId, accept, rejectMessage);
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
    if (mounted) {
      SnackbarUtils.showTyped(context, message, SnackBarType.error);
    }
  }

  /// Build file cache card showing cache size and clear button
  Widget _buildFileCacheCard() {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.fileCache,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: _reloadCacheSize,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.reload),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: _clearFileCache,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: Text(l10n.clear),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${l10n.cacheSize}: ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_isCalculatingCacheSize)
                  Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(l10n.calculating),
                    ],
                  )
                else
                  Text(
                    _cachedFileCacheSize,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.tempFilesDescription,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build connection status card with network info merged
  Widget _buildConnectionStatusCard() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.connectionStatus,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (kDebugMode) ...[
                  TextButton(
                    onPressed: _debugNetwork,
                    child: Text(l10n.debug),
                  ),
                ]
              ],
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
                  child: Text(_controller.getConnectionStatusDescription(l10n)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Network Info section merged here
            Row(
              children: [
                Icon(
                  _getNetworkStatusIcon(),
                  color: _getNetworkStatusColor(),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _controller.getNetworkStatusDescription(l10n),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Reload cache size manually
  void _reloadCacheSize() async {
    if (_isCalculatingCacheSize) return; // Prevent multiple calls

    setState(() {
      _isCalculatingCacheSize = true;
    });

    try {
      final cacheSize = await _getP2LanFileCacheSize();
      if (mounted) {
        setState(() {
          _cachedFileCacheSize = cacheSize;
          _isCalculatingCacheSize = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cachedFileCacheSize = 'Error: $e';
          _isCalculatingCacheSize = false;
        });
      }
    }
  }

  /// Get P2Lan specific file cache size
  Future<String> _getP2LanFileCacheSize() async {
    // This feature is only relevant on Android where file_picker creates temp files.
    if (!Platform.isAndroid) {
      return '0 B';
    }

    try {
      final tempDir = await getTemporaryDirectory();
      // The directory used by file_picker for temporary files.
      final filePickerCacheDir = Directory('${tempDir.path}/file_picker');

      int totalSize = 0;
      if (await filePickerCacheDir.exists()) {
        totalSize = await _calculateDirectorySize(filePickerCacheDir);
        logInfo(
            'P2Lan file_picker cache found in ${filePickerCacheDir.path}: ${_formatBytes(totalSize)}');
      } else {
        logInfo(
            'P2Lan file_picker cache directory not found at ${filePickerCacheDir.path}');
      }

      return _formatBytes(totalSize);
    } catch (e) {
      logError('Error calculating P2Lan cache size: $e');
      return 'Unknown';
    }
  }

  /// Calculate directory size recursively
  Future<int> _calculateDirectorySize(Directory directory) async {
    int totalSize = 0;
    try {
      await for (final entity in directory.list(recursive: true)) {
        if (entity is File) {
          try {
            final stat = await entity.stat();
            totalSize += stat.size;
          } catch (e) {
            // Skip files we can't read
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
    return totalSize;
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

  /// Clear file cache
  void _clearFileCache() async {
    // final l10n = AppLocalizations.of(context)!;
    try {
      final l10n = AppLocalizations.of(context)!;
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear File Cache'),
          content: const Text(
            'This will clear temporary files from P2Lan transfers. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange[700],
              ),
              child: Text(l10n.clear),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Call the P2P service to clean up file picker cache
        await _controller.p2pService.cleanupFilePickerCacheIfSafe();

        if (mounted) {
          SnackbarUtils.showTyped(
              context, 'File cache cleared successfully', SnackBarType.success);

          // Reload cache size to show updated value
          _reloadCacheSize();
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
            context, 'Failed to clear cache: $e', SnackBarType.error);
      }
    }
  }

  // Helper methods - keep existing ones

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
    if (_controller.isTemporarilyDisabled) {
      return Icons.pause_circle_outline;
    }

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
    if (_controller.isTemporarilyDisabled) {
      return Colors.orange;
    }

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
    final l10n = AppLocalizations.of(context)!;
    await NetworkDebugUtils.debugNetworkConnectivity();
    if (mounted) {
      SnackbarUtils.showTyped(
        context,
        l10n.networkDebugCompleted,
        SnackBarType.info,
      );
    }
  }

  void _manualRefresh() async {
    await _controller.manualDiscovery();
    if (mounted && _controller.errorMessage != null) {
      _showErrorSnackBar(_controller.errorMessage!);
    }
  }

  String _formatDiscoveryTime(DateTime time) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return l10n.daysAgo(difference.inDays);
    }
  }

  void _showTransferSettings() async {
    // Wait for initialization to complete
    try {
      await _controller.initializationComplete;

      if (mounted) {
        // Show settings dialog with immediate reload callback
        GenericSettingsUtils.quickOpenP2PTransferSettings(
          context,
          showSuccessMessage: true,
          onDialogClosed: () async {
            if (mounted) {
              await _controller.reloadTransferSettings();
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          'Failed to load settings: $e',
          SnackBarType.error,
        );
      }
    }
  }

  void _addTrust(P2PUser user) async {
    final success = await _controller.addTrust(user.id);
    if (success) {
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          'Trusted ${user.displayName}',
          SnackBarType.success,
        );
      }
    } else if (_controller.errorMessage != null) {
      _showErrorSnackBar(_controller.errorMessage!);
    }
  }

  void _removeTrust(P2PUser user) {
    final l10n = AppLocalizations.of(context)!;
    GenericDialogUtils.showSimpleGenericClearDialog(
      context: context,
      onConfirm: () async {
        Navigator.of(context).pop();
        final success = await _controller.removeTrust(user.id);
        if (success && mounted) {
          SnackbarUtils.showTyped(
            context,
            l10n.removeTrustFrom(user.displayName),
            SnackBarType.info,
          );
        } else if (_controller.errorMessage != null) {
          _showErrorSnackBar(_controller.errorMessage!);
        }
      },
      title: l10n.removeTrust,
      description: l10n.removeTrustFrom(user.displayName),
    );
  }

  void _showUnpairDialog(P2PUser user) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => HoldToConfirmDialog(
        title: l10n.unpairFrom(user.displayName),
        content: l10n.unpairDescription,
        cancelText: l10n.holdToUnpair,
        holdText: l10n.holdToUnpair,
        processingText: l10n.unpairing,
        instructionText: l10n.holdButtonToConfirmUnpair,
        actionIcon: Icons.link_off,
        holdDuration: const Duration(seconds: 1),
        l10n: l10n,
        onConfirmed: () async {
          Navigator.of(context).pop();

          final success = await _controller.unpairUser(user.id);
          if (success && context.mounted) {
            SnackbarUtils.showTyped(
              context,
              l10n.unpairFrom(user.displayName),
              SnackBarType.info,
            );
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

  void _clearTransferWithFile(String taskId, bool deleteFile) async {
    final success = await _controller.clearTransferWithFile(taskId, deleteFile);
    if (!success && _controller.errorMessage != null) {
      _showErrorSnackBar(_controller.errorMessage!);
    } else if (success && deleteFile) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        SnackbarUtils.showTyped(
            context, l10n.taskAndFileDeletedSuccessfully, SnackBarType.success);
      }
    } else if (success) {
      if (mounted) {
        SnackbarUtils.showTyped(context, 'Task cleared', SnackBarType.info);
      }
    }
  }

  Future<Widget> _buildThisDeviceCard() async {
    final l10n = AppLocalizations.of(context)!;
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
        profileId: appInstallationId,
        ipAddress: _controller.currentUser?.ipAddress ?? 'Not connected',
        port: _controller.currentUser?.port ?? 0,
        isOnline: _controller.isEnabled,
        lastSeen: DateTime.now(),
        isStored: false,
      );

      return DeviceInfoCard(
        user: deviceUser,
        title: l10n.thisDevice,
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
                l10n.thisDevice,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Text(
                '-----',
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
    // Capture the context before the async gap.
    final scaffoldContext = context;

    showDialog(
      context: context,
      builder: (context) => MultiFileSenderDialog(
        targetUser: user,
        onSendFiles: (filePaths) async {
          // The dialog's context is no longer valid here, so we use the captured scaffoldContext.
          final success =
              await _controller.sendMultipleFilesToUser(filePaths, user);
          if (!scaffoldContext.mounted) return;

          if (!success && _controller.errorMessage != null) {
            SnackbarUtils.showTyped(
                scaffoldContext, _controller.errorMessage!, SnackBarType.error);
          } else {
            final l10n = AppLocalizations.of(scaffoldContext)!;
            SnackbarUtils.showTyped(
              scaffoldContext,
              l10n.startedSending(filePaths.length, user.displayName),
              SnackBarType.info,
            );
            // Auto-switch to Transfers tab and scroll to bottom
            _switchToTransfersAndScroll();
          }
        },
      ),
    );
  }

  void _openLocalFiles() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const P2LanLocalFilesScreen(),
      ),
    );
  }

  /// Switch to Transfers tab and scroll to bottom to show new transfers
  void _switchToTransfersAndScroll() {
    // Switch to Transfers tab (index 1)
    setState(() {
      _currentTabIndex = 1;
    });

    // Wait for the tab switch to complete, then scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_transfersScrollController.hasClients) {
        _transfersScrollController.animateTo(
          _transfersScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Navigation and notification handler methods

  /// Switch to specific tab (called from navigation service)
  void _switchToTab(int tabIndex) {
    if (mounted && tabIndex >= 0 && tabIndex < 2) {
      setState(() {
        _currentTabIndex = tabIndex;
      });
    }
  }

  /// Show dialog from notification (called from navigation service)
  void _showDialogFromNotification(
      String dialogType, Map<String, dynamic> dialogData) {
    if (!mounted) return;

    switch (dialogType) {
      case 'pairing_request':
        final requestId = dialogData['requestId'] as String?;
        if (requestId != null) {
          final request = _controller.pendingRequests.firstWhere(
            (r) => r.id == requestId,
            orElse: () => throw StateError('Request not found'),
          );
          _showSinglePairingRequestDialog(request);
        }
        break;
      case 'file_transfer_request':
        final requestId = dialogData['requestId'] as String?;
        if (requestId != null) {
          final request = _controller.pendingFileTransferRequests.firstWhere(
            (r) => r.requestId == requestId,
            orElse: () => throw StateError('Request not found'),
          );
          _showFileTransferRequestDialog(request);
        }
        break;
    }
  }

  /// Handle notification tap
  void _handleNotificationTapped(P2PNotificationPayload payload) {
    if (!mounted) return;

    switch (payload.type) {
      case P2PNotificationType.fileTransferRequest:
        // Navigate to main tab and show dialog
        setState(() {
          _currentTabIndex = 0; // Devices tab
        });
        if (payload.requestId != null) {
          _showDialogFromNotification('file_transfer_request', {
            'requestId': payload.requestId,
          });
        }
        break;
      case P2PNotificationType.fileTransferProgress:
      case P2PNotificationType.fileTransferCompleted:
      case P2PNotificationType.fileTransferStatus:
        // Navigate to transfers tab
        setState(() {
          _currentTabIndex = 1; // Transfers tab
        });
        break;
      case P2PNotificationType.pairingRequest:
        // Navigate to main tab and show dialog
        setState(() {
          _currentTabIndex = 0; // Devices tab
        });
        if (payload.requestId != null) {
          _showDialogFromNotification('pairing_request', {
            'requestId': payload.requestId,
          });
        }
        break;
      case P2PNotificationType.p2lanStatus:
        // P2LAN status notification tapped - ensure we're on P2LAN screen
        // If already on P2LAN screen, no action needed
        // If not, this will be handled by the navigation service
        break;
      default:
        // Navigate to main tab for other notifications
        setState(() {
          _currentTabIndex = 0; // Devices tab
        });
        break;
    }
  }

  /// Handle notification action button press
  void _handleNotificationAction(
      P2PNotificationAction action, P2PNotificationPayload payload) {
    if (!mounted) return;

    switch (action) {
      case P2PNotificationAction.approveTransfer:
        if (payload.requestId != null) {
          _controller.respondToFileTransferRequest(
              payload.requestId!, true, null);
        }
        break;
      case P2PNotificationAction.rejectTransfer:
        if (payload.requestId != null) {
          _controller.respondToFileTransferRequest(
              payload.requestId!, false, 'Rejected from notification');
        }
        break;
      case P2PNotificationAction.acceptPairing:
        if (payload.requestId != null) {
          _controller.respondToPairingRequest(
              payload.requestId!, true, false, true);
        }
        break;
      case P2PNotificationAction.rejectPairing:
        if (payload.requestId != null) {
          _controller.respondToPairingRequest(
              payload.requestId!, false, false, false);
        }
        break;
      case P2PNotificationAction.openP2Lan:
        // Already on P2LAN screen, just switch to appropriate tab
        _handleNotificationTapped(payload);
        break;
    }
  }

  // Batch management methods

  void _onBatchExpandChanged(String? batchId, bool expanded) {
    // Only persist expand state if the setting is enabled
    final settings = _controller.transferSettings;
    if (settings?.rememberBatchExpandState == true) {
      setState(() {
        _batchExpandStates[batchId] = expanded;
      });
    }
    // If setting is disabled, still trigger setState to reflect UI changes immediately
    // but don't save to _batchExpandStates
    else {
      setState(() {});
    }
  }

  void _onClearBatch(String? batchId) {
    if (batchId == null) return;

    // Clear all tasks in the batch
    final tasksInBatch = _controller.activeTransfers
        .where((task) => task.batchId == batchId)
        .toList();

    for (final task in tasksInBatch) {
      _controller.clearTransfer(task.id);
    }

    // Remove from expand states
    _batchExpandStates.remove(batchId);
  }

  void _onClearBatchWithFiles(String? batchId) {
    if (batchId == null) return;

    // Clear all tasks in the batch with files
    final tasksInBatch = _controller.activeTransfers
        .where((task) => task.batchId == batchId)
        .toList();

    for (final task in tasksInBatch) {
      _controller.clearTransferWithFile(task.id, true);
    }

    // Remove from expand states
    _batchExpandStates.remove(batchId);
  }

  // Debug methods removed - using simple native device ID now
}
