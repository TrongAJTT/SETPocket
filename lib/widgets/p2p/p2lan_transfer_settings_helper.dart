import 'package:flutter/material.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/screens/p2lan/p2lan_transfer_settings_layout.dart';
import 'package:setpocket/widgets/generic/generic_settings_dialog.dart';
import 'package:setpocket/widgets/generic/generic_settings_screen.dart';

class P2LanTransferSettingsHelper {
  /// Shows P2Lan transfer settings using the appropriate UI based on screen size and platform
  static void showSettings(
    BuildContext context, {
    required P2PDataTransferSettings? currentSettings,
    required Function(P2PDataTransferSettings) onSettingsChanged,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    if (isDesktop) {
      // Desktop: Use dialog
      _showSettingsDialog(context, currentSettings, onSettingsChanged);
    } else {
      // Mobile/Tablet: Use full screen
      _showSettingsScreen(context, currentSettings, onSettingsChanged);
    }
  }

  static void _showSettingsDialog(
    BuildContext context,
    P2PDataTransferSettings? currentSettings,
    Function(P2PDataTransferSettings) onSettingsChanged,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GenericSettingsDialog(
        title: 'P2Lan Transfer Settings',
        settingsLayout: P2LanTransferSettingsLayout(
          currentSettings: currentSettings,
          onSettingsChanged: (settings) {
            onSettingsChanged(settings);
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
          showActions: true,
          isCompact: false,
        ),
      ),
    );
  }

  static void _showSettingsScreen(
    BuildContext context,
    P2PDataTransferSettings? currentSettings,
    Function(P2PDataTransferSettings) onSettingsChanged,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GenericSettingsScreen(
          title: 'P2Lan Transfer Settings',
          settingsLayout: P2LanTransferSettingsLayout(
            currentSettings: currentSettings,
            onSettingsChanged: (settings) {
              onSettingsChanged(settings);
              Navigator.of(context).pop();
            },
            showActions: true,
            isCompact: true,
          ),
        ),
      ),
    );
  }

  /// Quick settings dialog for specific sections (useful for contextual settings)
  static void showQuickSettings(
    BuildContext context, {
    required P2PDataTransferSettings? currentSettings,
    required Function(P2PDataTransferSettings) onSettingsChanged,
    int initialTabIndex = 0,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => GenericSettingsDialog(
          title: 'Quick Settings',
          preferredSize: const Size(600, 500),
          settingsLayout: P2LanTransferSettingsLayout(
            currentSettings: currentSettings,
            onSettingsChanged: (settings) {
              onSettingsChanged(settings);
              Navigator.of(context).pop();
            },
            onCancel: () => Navigator.of(context).pop(),
            showActions: true,
            isCompact: true,
          ),
        ),
      );
    } else {
      _showSettingsScreen(context, currentSettings, onSettingsChanged);
    }
  }
}
