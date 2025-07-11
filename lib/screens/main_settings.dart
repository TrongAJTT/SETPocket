import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/utils/widget_layout_decor_utils.dart';
import 'package:setpocket/widgets/cache_details_dialog.dart';
import 'package:setpocket/widgets/settings/tool_visibility_dialog.dart';
import 'package:setpocket/widgets/settings/quick_actions_dialog.dart';
import 'package:setpocket/services/cache_service.dart';
import 'package:setpocket/services/settings_models_service.dart';

import 'package:setpocket/screens/log_viewer_screen.dart';
import 'package:setpocket/layouts/section_sidebar_scrolling_layout.dart';
import 'package:setpocket/widgets/generic/section_item.dart';
import 'package:setpocket/widgets/generic/option_item.dart';
import 'package:setpocket/widgets/generic/option_slider.dart';
import 'package:setpocket/widgets/generic/option_switch.dart';
import 'package:setpocket/widgets/generic/option_card.dart';
import 'package:setpocket/widgets/generic/option_grid_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setpocket/main.dart';
import 'package:setpocket/utils/generic_settings_utils.dart';
import 'package:setpocket/utils/function_type_utils.dart';
import 'package:setpocket/services/p2p_settings_adapter.dart';

class MainSettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onToolVisibilityChanged;
  final String? initialSectionId;

  const MainSettingsScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolVisibilityChanged,
    this.initialSectionId,
  });

  @override
  State<MainSettingsScreen> createState() => _MainSettingsScreenState();
}

class _MainSettingsScreenState extends State<MainSettingsScreen> {
  late ThemeMode _themeMode = settingsController.themeMode;
  late String _language = settingsController.locale.languageCode;
  String _cacheInfo = '';
  bool _loading = true;
  bool _rememberCalculationHistory = true;
  bool _featureStateSavingEnabled = true;
  bool _askBeforeLoadingHistory = true;

  // Static decorator for settings
  late final OptionSwitchDecorator switchDecorator;
  bool _isDecoratorInitialized = false;

  // Add state variables for log section
  bool _logSectionExpanded = false;
  int _logRetentionDays = 7;
  String _logInfo = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDecoratorInitialized) {
      switchDecorator = OptionSwitchDecorator.compact(context);
      _isDecoratorInitialized = true;
    }
    if (_loading) {
      _loadCacheInfo();
      _loadLogInfo();
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode');
    final lang = prefs.getString('language');
    final globalSettings = await ExtensibleSettingsService.getGlobalSettings();
    final calculatorSettings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();

    setState(() {
      _themeMode = themeIndex != null
          ? ThemeMode.values[themeIndex]
          : settingsController.themeMode;
      _language = lang ?? settingsController.locale.languageCode;
      _featureStateSavingEnabled = globalSettings.featureStateSavingEnabled;
      _logRetentionDays = globalSettings.logRetentionDays;
      _rememberCalculationHistory = calculatorSettings.rememberHistory;
      _askBeforeLoadingHistory = calculatorSettings.askBeforeLoadingHistory;

      _loading = false;
    });
  }

  Future<void> _loadCacheInfo() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    if (mounted) {
      setState(() {
        _cacheInfo = l10n.calculating;
      });
    }

    try {
      final totalCacheSize = await CacheService.getTotalCacheSize();
      final totalLogSize = await CacheService.getTotalLogSize();

      if (mounted) {
        setState(() {
          final cacheFormated = CacheService.formatCacheSize(totalCacheSize);
          final logFormated = CacheService.formatCacheSize(totalLogSize);
          _cacheInfo = l10n.cacheWithLogSize(cacheFormated, logFormated);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cacheInfo = l10n.unknown;
        });
      }
    }
  }

  Future<void> _clearCache() async {
    final l10n = AppLocalizations.of(context)!;
    await CacheService.confirmAndClearAllCache(context, l10n: l10n);
    // Refresh info after dialog closes
    await _loadCacheInfo();
    await _loadSettings();
  }

  Future<void> _showCacheDetails() async {
    await showDialog(
      context: context,
      builder: (context) => const CacheDetailsDialog(),
    );
    // Refresh cache info after dialog closes
    await _loadCacheInfo();
  }

  void _onThemeChanged(ThemeMode? mode) async {
    if (mode != null) {
      setState(() => _themeMode = mode);
      settingsController.setThemeMode(mode);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', mode.index);
    }
  }

  void _onLanguageChanged(String? lang) async {
    if (lang != null) {
      setState(() => _language = lang);
      settingsController.setLocale(Locale(lang));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', lang);
    }
  }

  void _onFeatureStateSavingChanged(bool enabled) async {
    setState(() => _featureStateSavingEnabled = enabled);

    // Update global settings
    final currentSettings = await ExtensibleSettingsService.getGlobalSettings();
    final updatedSettings = currentSettings.copyWith(
      featureStateSavingEnabled: enabled,
    );
    await ExtensibleSettingsService.updateGlobalSettings(updatedSettings);
  }

  void _onRememberCalculationHistoryChanged(bool enabled) async {
    setState(() {
      _rememberCalculationHistory = enabled;
      if (!enabled) {
        _askBeforeLoadingHistory = false;
      }
    });

    // Save the setting change
    final currentSettings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    final updatedSettings = currentSettings.copyWith(
      rememberHistory: enabled,
      bookmarkFunctionsBeforeLoading:
          enabled ? (_askBeforeLoadingHistory ? null : false) : false,
    );
    await ExtensibleSettingsService.updateCalculatorToolsSettings(
        updatedSettings);
  }

  void _showToolVisibilityDialog() async {
    await showDialog(
      context: context,
      builder: (context) => ToolVisibilityDialog(
        onChanged: () {
          // Refresh parent if needed
          if (widget.isEmbedded && widget.onToolVisibilityChanged != null) {
            widget.onToolVisibilityChanged!();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;

    if (_loading) {
      return widget.isEmbedded
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              appBar: AppBar(title: Text(loc.settings)),
              body: const Center(child: CircularProgressIndicator()),
            );
    }

    // On mobile, show section selection screen first if not embedded
    if (!isDesktop && !widget.isEmbedded && widget.initialSectionId == null) {
      return MobileSectionSelectionScreen(
        title: loc.settings,
        sections: _buildSections(loc),
        onSectionSelected: (sectionId) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainSettingsScreen(
                isEmbedded: false,
                onToolVisibilityChanged: widget.onToolVisibilityChanged,
                initialSectionId: sectionId,
              ),
            ),
          );
        },
      );
    }

    return SectionSidebarScrollingLayout(
      title: loc.settings,
      sections: _buildSections(loc),
      isEmbedded: widget.isEmbedded,
      selectedSectionId: widget.initialSectionId ?? 'user_interface',
    );
  }

  List<SectionItem> _buildSections(AppLocalizations loc) {
    return [
      SectionItem(
        id: 'user_interface',
        title: loc.userInterface,
        subtitle: 'Theme and language settings',
        icon: Icons.palette,
        iconColor: Colors.blue,
        content: _buildUserInterfaceSection(loc),
      ),
      SectionItem(
        id: 'tools_shortcuts',
        title: 'Tools & Shortcuts',
        subtitle: 'Quick actions and tool management',
        icon: Icons.dashboard,
        iconColor: Colors.orange,
        content: _buildToolsShortcutsSection(loc),
      ),
      SectionItem(
        id: 'tools_settings',
        title: 'Tools Settings',
        subtitle: 'Random tools and state management',
        icon: Icons.casino,
        iconColor: Colors.purple,
        content: _buildToolsSettingsSection(loc),
      ),
      SectionItem(
        id: 'data_management',
        title: 'Data Management',
        subtitle: 'Cache, logs, and storage',
        icon: Icons.storage,
        iconColor: Colors.red,
        content: _buildDataSection(loc),
      ),
    ];
  }

  Widget _buildUserInterfaceSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThemeSettings(loc),
        const SizedBox(height: 16),
        _buildLanguageSettings(loc),
      ],
    );
  }

  Widget _buildToolsShortcutsSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildToolVisibilitySettings(loc),
        const SizedBox(height: 16),
        _buildQuickActionsSettings(loc),
      ],
    );
  }

  Widget _buildToolsSettingsSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRandomToolsSettingsCard(loc),
        const SizedBox(height: 16),
        _buildConverterToolsSettingsCard(loc),
        const SizedBox(height: 16),
        _buildCalculatorToolsSettingsCard(loc),
        const SizedBox(height: 16),
        _buildP2PTransferSettingsCard(loc),
      ],
    );
  }

  Widget _buildRandomToolsSettingsCard(AppLocalizations loc) {
    return OptionCard(
      onTap: _showRandomToolsSettings,
      option: OptionItem.withIcon(
        value: null,
        label: 'Random Tools Settings',
        subtitle: 'Configure generation history and state saving',
        iconData: Icons.casino,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  Widget _buildConverterToolsSettingsCard(AppLocalizations loc) {
    return OptionCard(
      onTap: _showConverterToolsSettings,
      option: OptionItem.withIcon(
        value: null,
        label: 'Converter Tools Settings',
        subtitle: 'Configure currency fetching and state saving',
        iconData: Icons.transform,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  Widget _buildCalculatorToolsSettingsCard(AppLocalizations loc) {
    return OptionCard(
      onTap: _showCalculatorToolsSettings,
      option: OptionItem.withIcon(
        value: null,
        label: loc.calculatorTools,
        subtitle: 'History and computation settings',
        iconData: Icons.calculate,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  Widget _buildP2PTransferSettingsCard(AppLocalizations loc) {
    return OptionCard(
      onTap: _showP2PTransferSettings,
      option: OptionItem.withIcon(
        value: null,
        label: 'P2P Transfer Settings',
        subtitle: 'File transfer and network configuration',
        iconData: Icons.share,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  void _showRandomToolsSettings() {
    GenericSettingsUtils.quickOpenRandomToolsSettings(
      context,
      showSuccessMessage: false, // No need for success message in main settings
    );
  }

  void _showConverterToolsSettings() {
    GenericSettingsUtils.quickOpenConverterToolsSettings(
      context,
      showSuccessMessage: false, // No need for success message in main settings
    );
  }

  void _showCalculatorToolsSettings() {
    GenericSettingsUtils.quickOpenCalculatorToolsSettings(context);
  }

  void _showP2PTransferSettings() {
    GenericSettingsUtils.quickOpenP2PTransferSettings(context);
  }

  Widget _buildDataSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCacheManagement(loc),
        const SizedBox(height: 24),
        _buildExpandableLogSection(loc),
      ],
    );
  }

  Widget _buildThemeSettings(AppLocalizations loc) {
    return AutoScaleOptionGridPicker<ThemeMode>(
      title: loc.theme,
      options: [
        OptionItem.withIcon(
          value: ThemeMode.system,
          label: loc.system,
          iconData: Icons.brightness_auto_outlined,
          iconColor: Theme.of(context).colorScheme.primary,
        ),
        OptionItem.withIcon(
          value: ThemeMode.light,
          label: loc.light,
          iconData: Icons.light_mode_outlined,
          iconColor: Colors.amber.shade600,
        ),
        OptionItem.withIcon(
          value: ThemeMode.dark,
          label: loc.dark,
          iconData: Icons.dark_mode_outlined,
          iconColor: Colors.indigo.shade600,
        ),
      ],
      selectedValue: _themeMode,
      onSelectionChanged: (value) => _onThemeChanged(value),
      minCellWidth: 200,
      maxCellWidth: 300,
      fixedCellHeight: 50,
      decorator: const OptionGridDecorator(
        iconAlign: IconAlign.leftOfTitle,
        iconSpacing: 12,
        labelAlign: LabelAlign.left,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildLanguageSettings(AppLocalizations loc) {
    return AutoScaleOptionGridPicker<String>(
      title: loc.language,
      options: [
        OptionItem.withEmoji(
          value: 'en',
          label: loc.english,
          emoji: '🇺🇸',
        ),
        OptionItem.withEmoji(
          value: 'vi',
          label: loc.vietnamese,
          emoji: '🇻🇳',
        ),
      ],
      selectedValue: _language,
      onSelectionChanged: (value) => _onLanguageChanged(value),
      minCellWidth: 200,
      maxCellWidth: 300,
      fixedCellHeight: 50,
      decorator: const OptionGridDecorator(
        iconAlign: IconAlign.leftOfTitle,
        iconSpacing: 12,
        labelAlign: LabelAlign.left,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildRememberCalculationHistory(AppLocalizations loc) {
    return OptionSwitch(
      title: loc.rememberCalculationHistory,
      subtitle: loc.rememberCalculationHistoryDesc,
      value: _rememberCalculationHistory,
      onChanged: _onRememberCalculationHistoryChanged,
      decorator: switchDecorator,
    );
  }

  Widget _buildAskToLoadGraphingHistory(AppLocalizations loc) {
    return OptionSwitch(
      title: loc.askBeforeLoadingHistory,
      subtitle: loc.askBeforeLoadingHistoryDesc,
      value: _askBeforeLoadingHistory,
      onChanged: (value) async {
        setState(() {
          _askBeforeLoadingHistory = value;
        });

        // Save the setting change
        final currentSettings =
            await ExtensibleSettingsService.getCalculatorToolsSettings();
        final updatedSettings = currentSettings.copyWith(
          bookmarkFunctionsBeforeLoading: value ? null : false,
        );
        await ExtensibleSettingsService.updateCalculatorToolsSettings(
            updatedSettings);
      },
      isDisabled: !_rememberCalculationHistory,
      decorator: switchDecorator,
    );
  }

  Widget _buildCacheManagement(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.dataAndStorage,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          _cacheInfo,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showCacheDetails,
                icon: const Icon(Icons.info_outline),
                label: Text(loc.viewCacheDetails),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _clearCache,
                icon: const Icon(Icons.delete_forever),
                label: Text(loc.clearCache),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildToolVisibilitySettings(AppLocalizations loc) {
    return OptionCard(
      onTap: _showToolVisibilityDialog,
      option: OptionItem.withIcon(
        value: null,
        label: loc.displayArrangeTools,
        subtitle: loc.displayArrangeToolsDesc,
        iconData: Icons.tune,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      decorator: const CardDecorator(),
    );
  }

  Widget _buildQuickActionsSettings(AppLocalizations loc) {
    return OptionCard(
      onTap: _showQuickActionsDialog,
      option: OptionItem.withIcon(
        value: null,
        label: loc.manageQuickActions,
        subtitle: loc.manageQuickActionsDesc,
        iconData: Icons.flash_on,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showQuickActionsDialog() {
    showDialog(
      context: context,
      builder: (context) => const QuickActionsDialog(),
    );
  }

  Widget _buildExpandableLogSection(AppLocalizations loc) {
    return ExpandableOptionCard(
      initialExpanded: _logSectionExpanded,
      onExpansionChanged: (isExpanded) {
        setState(() => _logSectionExpanded = isExpanded);
        if (isExpanded) {
          _loadLogInfo();
        }
      },
      option: OptionItem.withIcon(
        value: null,
        label: loc.logApplication,
        subtitle: loc.logsManagement,
        iconData: Icons.description_outlined,
        iconSize: 20,
        iconColor: Theme.of(context).colorScheme.primary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Log info
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                loc.statusInfo(_logInfo),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLogRetentionSettings(loc),
          const SizedBox(height: 16),
          _buildLogManagementButtons(loc),
        ],
      ),
    );
  }

  Widget _buildLogRetentionSettings(AppLocalizations loc) {
    // Map retention days to slider index
    final List<SliderOption<int>> logOptions = [
      SliderOption(value: 5, label: loc.logRetentionDays(5)),
      SliderOption(value: 10, label: loc.logRetentionDays(10)),
      SliderOption(value: 15, label: loc.logRetentionDays(15)),
      SliderOption(value: 20, label: loc.logRetentionDays(20)),
      SliderOption(value: 25, label: loc.logRetentionDays(25)),
      SliderOption(value: 30, label: loc.logRetentionDays(30)),
      SliderOption(value: -1, label: loc.logRetentionForever),
    ];

    return OptionSlider<int>(
      label: loc.logRetention,
      subtitle: loc.logRetentionDescDetail,
      icon: Icons.history,
      currentValue: _logRetentionDays,
      options: logOptions,
      onChanged: (days) async {
        setState(() => _logRetentionDays = days);
        await _updateLogRetention(days);
      },
      layout: OptionSliderLayout.none,
    );
  }

  Widget _buildLogManagementButtons(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.visibility_outlined),
            label: Text(loc.viewLogs),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: _showLogViewer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.delete_sweep_outlined),
            label: Text(loc.clearLogs),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: _forceCleanupLogs,
          ),
        ),
      ],
    );
  }

  void _showLogViewer() async {
    final screenWidth = MediaQuery.of(context).size.width;

    if (widget.isEmbedded && screenWidth >= 900) {
      // If embedded in desktop view, show as dialog
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            child: const LogViewerScreen(isEmbedded: true),
          ),
        ),
      );
    } else {
      // Mobile or standalone - navigate to full screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const LogViewerScreen(),
        ),
      );
    }
  }

  Future<void> _loadLogInfo() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    if (mounted) {
      setState(() {
        _logInfo = l10n.calculating;
      });
    }

    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 500));

    // This would load actual log information
    // For now, just set some placeholder data
    if (mounted) {
      setState(() {
        _logInfo = l10n.logsAvailable;
      });
    }
  }

  Future<void> _updateLogRetention(int days) async {
    setState(() {
      _logRetentionDays = days;
    });

    // Update global settings
    final currentSettings = await ExtensibleSettingsService.getGlobalSettings();
    final updatedSettings = currentSettings.copyWith(
      logRetentionDays: days,
    );
    await ExtensibleSettingsService.updateGlobalSettings(updatedSettings);
  }

  Future<void> _forceCleanupLogs() async {
    final l10n = AppLocalizations.of(context)!;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Expanded(child: Text(l10n.deletingOldLogs)),
            ],
          ),
        ),
      );

      // Force cleanup
      final deletedCount = await AppLogger.instance.forceCleanupNow();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Pre-compute message
      final message = deletedCount > 0
          ? l10n.deletedOldLogFiles(deletedCount)
          : l10n.noOldLogFilesToDelete;

      // Show result
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingLogs(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
