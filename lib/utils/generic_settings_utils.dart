import 'package:flutter/material.dart';
import 'package:setpocket/utils/function_type_utils.dart';
import 'package:setpocket/widgets/generic/generic_settings_helper.dart';
import 'package:setpocket/models/p2p_models.dart';
import 'package:setpocket/screens/p2lan_transfer/p2lan_transfer_settings_layout.dart';
import 'package:setpocket/screens/random_tools/random_tools_settings_layout.dart';
import 'package:setpocket/screens/converter_tools/converter_tools_settings_layout.dart';
import 'package:setpocket/screens/calculator_tools/calculator_tools_settings_layout.dart';
import 'package:setpocket/services/p2p_settings_adapter.dart';
import 'package:setpocket/utils/snackbar_utils.dart';

/// Generic settings utilities for different function types.
///
/// This utility class provides factory methods to navigate to settings based on
/// function types using the generic settings system. It acts as a bridge between
/// specific function types and the generic settings navigation methods.
///
/// **Three Navigation Approaches:**
///
/// 1. **navigateSettings()** - Adaptive platform-specific navigation
/// 2. **navigateQuickSettings()** - Optimized for rapid access and frequent use
/// 3. **navigateBottomSheetSettings()** - Mobile-first modal interface
///
/// Each method automatically creates the appropriate configuration for the given
/// function type and delegates to the corresponding GenericSettingsHelper method.
class GenericSettingsUtils {
  /// Factory method to navigate to settings based on function type using
  /// platform-adaptive behavior.
  ///
  /// **Behavior:**
  /// - Desktop: Opens dialog window
  /// - Mobile/Tablet: Full-screen navigation
  ///
  /// **Use Cases:**
  /// - Main settings access from menus or dedicated settings buttons
  /// - When you want automatic platform-appropriate presentation
  /// - For comprehensive settings that may need more space
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [functionType]: Type of settings to show (see FunctionType enum)
  /// - [currentSettings]: Current settings object (type depends on functionType)
  /// - [onSettingsChanged]: Callback when settings are modified
  /// - [onCancel]: Optional callback when cancel is pressed
  /// - [showActions]: Whether to show action buttons (Save/Cancel)
  /// - [isCompact]: Whether to use compact layout
  /// - [preferredSize]: Preferred dialog size (desktop only)
  /// - [barrierDismissible]: Whether clicking outside dismisses dialog
  static void navigateSettings(
    BuildContext context,
    FunctionType functionType, {
    dynamic currentSettings,
    required Function(dynamic) onSettingsChanged,
    VoidCallback? onCancel,
    bool showActions = true,
    bool isCompact = false,
    Size? preferredSize,
    bool barrierDismissible = false,
  }) {
    final config = _createSettingsConfig(
      context,
      functionType,
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: showActions,
      isCompact: isCompact,
      preferredSize: preferredSize,
      barrierDismissible: barrierDismissible,
    );

    if (config != null) {
      GenericSettingsHelper.showSettings(context, config);
    }
  }

  /// Factory method for quick settings navigation optimized for rapid access.
  ///
  /// **Behavior:**
  /// - Desktop: Smaller, focused dialog (600x500 by default)
  /// - Mobile: Falls back to full-screen navigation
  ///
  /// **Use Cases:**
  /// - Frequently accessed settings that need quick modification
  /// - Settings accessed from toolbar buttons, context menus, or shortcuts
  /// - When you need settings access but want to minimize disruption
  /// - Power-user features or expert mode toggles
  ///
  /// **Design Philosophy:**
  /// This method prioritizes speed and efficiency. Settings are presented in
  /// a way that allows quick changes without losing context of the main task.
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [functionType]: Type of settings to show (see FunctionType enum)
  /// - [currentSettings]: Current settings object (type depends on functionType)
  /// - [onSettingsChanged]: Callback when settings are modified
  /// - [onCancel]: Optional callback when cancel is pressed
  /// - [quickSize]: Custom dialog size (desktop only, overrides default 600x500)
  /// - [barrierDismissible]: Whether clicking outside dismisses dialog (default: true)
  static void navigateQuickSettings(
    BuildContext context,
    FunctionType functionType, {
    dynamic currentSettings,
    required Function(dynamic) onSettingsChanged,
    VoidCallback? onCancel,
    Size? quickSize,
    bool barrierDismissible = true,
  }) {
    final config = _createSettingsConfig(
      context,
      functionType,
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: true,
      isCompact: true,
      barrierDismissible: barrierDismissible,
    );

    if (config != null) {
      GenericSettingsHelper.showQuickSettings(
        context,
        config,
        quickSize: quickSize,
      );
    }
  }

  /// Factory method for bottom sheet settings navigation with mobile-first design.
  ///
  /// **Behavior:**
  /// - All platforms: Modal bottom sheet that slides up from bottom
  /// - Includes drag handle and swipe-to-dismiss gestures
  /// - Takes 80% of screen height by default
  ///
  /// **Use Cases:**
  /// - Mobile-optimized settings that complement the main content
  /// - Contextual settings related to the current screen or task
  /// - Temporary settings that don't require full navigation commitment
  /// - Settings that benefit from gesture-based interaction
  ///
  /// **Design Philosophy:**
  /// This method provides a modern, mobile-native experience that keeps users
  /// in context. It's ideal for settings that are:
  /// - Supplementary to the main workflow
  /// - Frequently toggled or adjusted
  /// - Context-dependent or screen-specific
  ///
  /// **Interaction Design:**
  /// - Drag handle at top for visual affordance
  /// - Swipe down or tap outside to dismiss (if enabled)
  /// - Close button for explicit dismissal
  /// - Smooth slide-up animation for polished feel
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [functionType]: Type of settings to show (see FunctionType enum)
  /// - [currentSettings]: Current settings object (type depends on functionType)
  /// - [onSettingsChanged]: Callback when settings are modified
  /// - [onCancel]: Optional callback when cancel is pressed
  /// - [height]: Custom height (default: 80% of screen height)
  /// - [isDismissible]: Whether tapping outside dismisses the sheet (default: true)
  /// - [enableDrag]: Whether drag gestures can dismiss the sheet (default: true)
  static void navigateBottomSheetSettings(
    BuildContext context,
    FunctionType functionType, {
    dynamic currentSettings,
    required Function(dynamic) onSettingsChanged,
    VoidCallback? onCancel,
    double? height,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final config = _createSettingsConfig(
      context,
      functionType,
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: true,
      isCompact: true,
    );

    if (config != null) {
      GenericSettingsHelper.showBottomSheetSettings(
        context,
        config,
        height: height,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
      );
    }
  }

  /// Creates settings configuration based on function type.
  ///
  /// This internal method acts as a factory to create the appropriate
  /// GenericSettingsConfig for the given function type. It handles the
  /// type-specific logic for creating settings layouts and configurations.
  ///
  /// **Current Support:**
  /// - P2Lan Transfer: Fully implemented with P2LanTransferSettingsLayout
  /// - Other types: Placeholders for future implementation
  ///
  /// **Parameters:**
  /// - [context]: Build context for widget creation
  /// - [functionType]: The type of settings to create configuration for
  /// - [currentSettings]: Current settings object (type varies by function type)
  /// - [onSettingsChanged]: Callback when settings are modified
  /// - [onCancel]: Optional callback when cancel action is performed
  /// - [showActions]: Whether to display action buttons (Save/Cancel)
  /// - [isCompact]: Whether to use compact layout variant
  /// - [preferredSize]: Preferred size for dialog presentation
  /// - [barrierDismissible]: Whether dialog can be dismissed by clicking outside
  ///
  /// **Returns:**
  /// GenericSettingsConfig for the function type, or null if not implemented
  static GenericSettingsConfig? _createSettingsConfig(
    BuildContext context,
    FunctionType functionType, {
    dynamic currentSettings,
    required Function(dynamic) onSettingsChanged,
    VoidCallback? onCancel,
    bool showActions = true,
    bool isCompact = false,
    Size? preferredSize,
    bool barrierDismissible = false,
  }) {
    switch (functionType) {
      case FunctionType.p2lanTransfer:
        return _createP2LanTransferConfig(
          context,
          currentSettings: currentSettings as P2PDataTransferSettings?,
          onSettingsChanged:
              onSettingsChanged as Function(P2PDataTransferSettings),
          onCancel: onCancel,
          showActions: showActions,
          isCompact: isCompact,
          preferredSize: preferredSize,
          barrierDismissible: barrierDismissible,
        );

      // TODO: Add other function types as needed
      case FunctionType.textTemplate:
      case FunctionType.randomTools:
        return _createRandomToolsConfig(
          context,
          currentSettings: currentSettings as Map<String, dynamic>?,
          onSettingsChanged:
              onSettingsChanged as Function(Map<String, dynamic>),
          onCancel: onCancel,
          showActions: showActions,
          isCompact: isCompact,
          preferredSize: preferredSize,
          barrierDismissible: barrierDismissible,
        );
      case FunctionType.converterTools:
        return _createConverterToolsConfig(
          context,
          currentSettings: currentSettings as Map<String, dynamic>?,
          onSettingsChanged:
              onSettingsChanged as Function(Map<String, dynamic>),
          onCancel: onCancel,
          showActions: showActions,
          isCompact: isCompact,
          preferredSize: preferredSize,
          barrierDismissible: barrierDismissible,
        );
      case FunctionType.calculatorTools:
        return _createCalculatorToolsConfig(
          context,
          onSettingsChanged: onSettingsChanged as Function(dynamic),
          onCancel: onCancel,
          showActions: showActions,
          isCompact: isCompact,
          preferredSize: preferredSize,
          barrierDismissible: barrierDismissible,
        );
      case FunctionType.appSettings:
      case FunctionType.storageManagement:
      case FunctionType.userInterface:
      case FunctionType.networkSettings:
      case FunctionType.securitySettings:
      case FunctionType.notificationSettings:
      case FunctionType.fileManagement:
        // Not implemented yet
        return null;
    }
  }

  /// Create P2Lan transfer settings configuration
  static GenericSettingsConfig<P2PDataTransferSettings>
      _createP2LanTransferConfig(
    BuildContext context, {
    P2PDataTransferSettings? currentSettings,
    required Function(P2PDataTransferSettings) onSettingsChanged,
    VoidCallback? onCancel,
    bool showActions = true,
    bool isCompact = false,
    Size? preferredSize,
    bool barrierDismissible = false,
  }) {
    return GenericSettingsConfig<P2PDataTransferSettings>(
      title: FunctionType.p2lanTransfer.displayName,
      settingsLayout: P2LanTransferSettingsLayout(
        currentSettings: currentSettings,
        onSettingsChanged: (settings) {
          onSettingsChanged(settings);
          Navigator.of(context).pop();
        },
        onCancel: onCancel ?? () => Navigator.of(context).pop(),
        showActions: showActions,
        isCompact: isCompact,
      ),
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: showActions,
      isCompact: isCompact,
      preferredSize: preferredSize,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Create Random Tools settings configuration
  static GenericSettingsConfig<Map<String, dynamic>> _createRandomToolsConfig(
    BuildContext context, {
    Map<String, dynamic>? currentSettings,
    required Function(Map<String, dynamic>) onSettingsChanged,
    VoidCallback? onCancel,
    bool showActions = true,
    bool isCompact = false,
    Size? preferredSize,
    bool barrierDismissible = false,
  }) {
    return GenericSettingsConfig<Map<String, dynamic>>(
      title: FunctionType.randomTools.displayName,
      settingsLayout: RandomToolsSettingsLayout(
        onSettingsSaved: (result) {
          if (result.success && result.data != null) {
            onSettingsChanged(result.data!);
            Navigator.of(context).pop();
          }
          // Error cases are handled by BaseSettingsLayout (no navigation)
        },
        onCancel: onCancel ?? () => Navigator.of(context).pop(),
        showActions: showActions,
      ),
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: showActions,
      isCompact: isCompact,
      preferredSize: preferredSize,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Create Converter Tools settings configuration
  static GenericSettingsConfig<Map<String, dynamic>>
      _createConverterToolsConfig(
    BuildContext context, {
    Map<String, dynamic>? currentSettings,
    required Function(Map<String, dynamic>) onSettingsChanged,
    VoidCallback? onCancel,
    bool showActions = true,
    bool isCompact = false,
    Size? preferredSize,
    bool barrierDismissible = false,
  }) {
    return GenericSettingsConfig<Map<String, dynamic>>(
      title: FunctionType.converterTools.displayName,
      settingsLayout: ConverterToolsSettingsLayout(
        onSettingsSaved: (result) {
          if (result.success && result.data != null) {
            onSettingsChanged(result.data!);
            Navigator.of(context).pop();
          }
          // Error cases are handled by BaseSettingsLayout (no navigation)
        },
        onCancel: onCancel ?? () => Navigator.of(context).pop(),
        showActions: showActions,
      ),
      currentSettings: currentSettings,
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: showActions,
      isCompact: isCompact,
      preferredSize: preferredSize,
      barrierDismissible: barrierDismissible,
    );
  }

  static GenericSettingsConfig _createCalculatorToolsConfig(
    BuildContext context, {
    required Function(dynamic) onSettingsChanged,
    VoidCallback? onCancel,
    bool showActions = true,
    bool isCompact = false,
    Size? preferredSize,
    bool barrierDismissible = false,
  }) {
    return GenericSettingsConfig(
      title: 'Calculator Tools',
      settingsLayout: CalculatorToolsSettingsLayout(
        onSettingsSaved: (result) {
          if (result.success) {
            onSettingsChanged(null);
            Navigator.of(context).pop();
          }
        },
        onCancel: onCancel ?? () => Navigator.of(context).pop(),
        showActions: showActions,
      ),
      onSettingsChanged: onSettingsChanged,
      onCancel: onCancel,
      showActions: showActions,
      isCompact: isCompact,
      preferredSize: preferredSize,
      barrierDismissible: barrierDismissible,
    );
  }

  /// Convenience method to quickly open Random Tools settings.
  ///
  /// This is a specialized wrapper around navigateSettings() for Random Tools
  /// to eliminate code duplication and provide a consistent entry point.
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [onSettingsChanged]: Optional callback when settings are changed
  /// - [useQuickMode]: Whether to use quick dialog (default: false for full settings)
  /// - [showSuccessMessage]: Whether to show success snackbar (default: true)
  static void quickOpenRandomToolsSettings(
    BuildContext context, {
    Function(Map<String, dynamic>)? onSettingsChanged,
    bool useQuickMode = false,
    bool showSuccessMessage = true,
  }) {
    if (useQuickMode) {
      navigateQuickSettings(
        context,
        FunctionType.randomTools,
        currentSettings: null,
        onSettingsChanged: (dynamic settings) {
          if (onSettingsChanged != null) {
            onSettingsChanged(settings as Map<String, dynamic>);
          }
        },
      );
    } else {
      navigateSettings(
        context,
        FunctionType.randomTools,
        currentSettings: null,
        onSettingsChanged: (dynamic settings) {
          if (onSettingsChanged != null) {
            onSettingsChanged(settings as Map<String, dynamic>);
          }
        },
        showActions: true,
        isCompact: false,
        barrierDismissible: false,
      );
    }
  }

  /// Convenience method to quickly open Converter Tools settings.
  ///
  /// This is a specialized wrapper around navigateSettings() for Converter Tools
  /// to eliminate code duplication and provide a consistent entry point.
  ///
  /// **Parameters:**
  /// - [context]: Build context for navigation
  /// - [onSettingsChanged]: Optional callback when settings are changed
  /// - [useQuickMode]: Whether to use quick dialog (default: false for full settings)
  /// - [showSuccessMessage]: Whether to show success snackbar (default: true)
  static void quickOpenConverterToolsSettings(
    BuildContext context, {
    Function(Map<String, dynamic>)? onSettingsChanged,
    bool useQuickMode = false,
    bool showSuccessMessage = true,
  }) {
    if (useQuickMode) {
      navigateQuickSettings(
        context,
        FunctionType.converterTools,
        currentSettings: null,
        onSettingsChanged: (dynamic settings) {
          if (onSettingsChanged != null) {
            onSettingsChanged(settings as Map<String, dynamic>);
          }
        },
      );
    } else {
      navigateSettings(
        context,
        FunctionType.converterTools,
        currentSettings: null,
        onSettingsChanged: (dynamic settings) {
          if (onSettingsChanged != null) {
            onSettingsChanged(settings as Map<String, dynamic>);
          }
        },
        showActions: true,
        isCompact: false,
        barrierDismissible: false,
      );
    }
  }

  /// Convenience method to quickly open Calculator Tools settings.
  static void quickOpenCalculatorToolsSettings(
    BuildContext context, {
    bool useQuickMode = false,
  }) {
    if (useQuickMode) {
      navigateQuickSettings(
        context,
        FunctionType.calculatorTools,
        onSettingsChanged: (dynamic settings) {},
      );
    } else {
      navigateSettings(
        context,
        FunctionType.calculatorTools,
        onSettingsChanged: (dynamic settings) {},
        showActions: true,
        isCompact: false,
        barrierDismissible: false,
      );
    }
  }

  /// Convenience method to quickly open P2P Transfer settings.
  static void quickOpenP2PTransferSettings(
    BuildContext context, {
    bool showSuccessMessage = true,
  }) async {
    try {
      // Fetch settings asynchronously first
      final settings = await P2PSettingsAdapter.getSettings();

      // Ensure the context is still mounted before showing the dialog
      if (!context.mounted) return;

      // Use the generic settings helper for a consistent look and feel
      navigateQuickSettings(
        context,
        FunctionType.p2lanTransfer,
        currentSettings: settings,
        onSettingsChanged: (dynamic newSettings) async {
          try {
            await P2PSettingsAdapter.updateSettings(
                newSettings as P2PDataTransferSettings);

            // Pop the dialog on successful save
            if (context.mounted) {
              Navigator.of(context).pop();
            }

            if (showSuccessMessage && context.mounted) {
              SnackbarUtils.showTyped(
                context,
                'P2P Transfer settings saved successfully',
                SnackBarType.success,
              );
            }
          } catch (e) {
            if (context.mounted) {
              SnackbarUtils.showTyped(
                context,
                'Failed to save P2P settings: $e',
                SnackBarType.error,
              );
            }
          }
        },
        onCancel: (context.mounted) ? () => Navigator.of(context).pop() : null,
        barrierDismissible: true,
      );
    } catch (e) {
      if (context.mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error loading P2P settings: $e',
          SnackBarType.error,
        );
      }
    }
  }
}
