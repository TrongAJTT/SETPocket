import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/widgets/cache_details_dialog.dart';
import 'package:my_multi_tools/widgets/tool_visibility_dialog.dart';
import 'package:my_multi_tools/widgets/quick_actions_dialog.dart';
import 'package:my_multi_tools/services/cache_service.dart';
import 'package:my_multi_tools/services/generation_history_service.dart';
import 'package:my_multi_tools/services/settings_service.dart';
import 'package:my_multi_tools/services/currency_cache_service.dart';
import 'package:my_multi_tools/services/currency_state_service.dart';

import 'package:my_multi_tools/models/currency_cache_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class MainSettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onToolVisibilityChanged;

  const MainSettingsScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolVisibilityChanged,
  });

  @override
  State<MainSettingsScreen> createState() => _MainSettingsScreenState();
}

class _MainSettingsScreenState extends State<MainSettingsScreen> {
  late ThemeMode _themeMode = settingsController.themeMode;
  late String _language = settingsController.locale.languageCode;
  String _cacheInfo = 'Calculating...';
  bool _clearing = false;
  bool _loading = true;
  bool _historyEnabled = false;
  bool _featureStateSavingEnabled = true;
  CurrencyFetchMode _currencyFetchMode = CurrencyFetchMode.manual;
  int _fetchTimeoutSeconds = 10;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCacheInfo();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode');
    final lang = prefs.getString('language');
    final historyEnabled = await GenerationHistoryService.isHistoryEnabled();
    final featureStateSavingEnabled =
        await SettingsService.getFeatureStateSaving();
    final currencyFetchMode = await SettingsService.getCurrencyFetchMode();
    final fetchTimeout = await SettingsService.getFetchTimeout();
    setState(() {
      _themeMode = themeIndex != null
          ? ThemeMode.values[themeIndex]
          : settingsController.themeMode;
      _language = lang ?? settingsController.locale.languageCode;
      _historyEnabled = historyEnabled;
      _featureStateSavingEnabled = featureStateSavingEnabled;
      _currencyFetchMode = currencyFetchMode;
      _fetchTimeoutSeconds = fetchTimeout;
      _loading = false;
    });
  }

  Future<void> _loadCacheInfo() async {
    try {
      final totalSize = await CacheService.getTotalCacheSize();
      setState(() {
        _cacheInfo = CacheService.formatCacheSize(totalSize);
      });
    } catch (e) {
      setState(() {
        _cacheInfo = 'Unknown';
      });
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await _showConfirmDialog();
    if (confirmed != true) return;

    setState(() {
      _clearing = true;
    });

    try {
      await CacheService.clearAllCache();
      await _loadCacheInfo(); // Refresh cache info
      setState(() {
        _clearing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.clearCache),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _clearing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  void _onHistoryEnabledChanged(bool enabled) async {
    setState(() => _historyEnabled = enabled);
    await GenerationHistoryService.setHistoryEnabled(enabled);
  }

  void _onFeatureStateSavingChanged(bool enabled) async {
    setState(() => _featureStateSavingEnabled = enabled);
    await SettingsService.updateFeatureStateSaving(enabled);
  }

  void _onCurrencyFetchModeChanged(CurrencyFetchMode mode) async {
    setState(() => _currencyFetchMode = mode);
    await SettingsService.updateCurrencyFetchMode(mode);
  }

  void _onFetchTimeoutChanged(int timeoutSeconds) async {
    setState(() => _fetchTimeoutSeconds = timeoutSeconds);
    await SettingsService.updateFetchTimeout(timeoutSeconds);
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

  Future<bool?> _showConfirmDialog() async {
    final loc = AppLocalizations.of(context)!;
    final textController = TextEditingController();

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(loc.clearAllCache),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.confirmClearAllCache),
              const SizedBox(height: 16),
              Text(
                loc.typeConfirmToProceed,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'confirm',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.cancel),
            ),
            FilledButton(
              onPressed: textController.text.toLowerCase() == 'confirm'
                  ? () => Navigator.of(context).pop(true)
                  : null,
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(loc.clearAllCache),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    Widget body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _buildSettingsContent(loc);

    if (widget.isEmbedded) {
      // Desktop embedded view - no AppBar, just content with header
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    loc.settings,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    // Mobile view - normal Scaffold with AppBar
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
      ),
      body: body,
    );
  }

  Widget _buildSettingsContent(AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final maxWidth = isDesktop ? 1200.0 : (isTablet ? 800.0 : 480.0);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: isDesktop ? _buildDesktopLayout(loc) : _buildMobileLayout(loc),
      ),
    );
  }

  Widget _buildDesktopLayout(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isEmbedded) _buildHeader(loc),
          Expanded(
            child: SingleChildScrollView(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildUserInterfaceSection(loc),
                          const SizedBox(height: 24),
                          _buildToolsShortcutsSection(loc),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right Column
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildConverterToolsSection(loc),
                          const SizedBox(height: 24),
                          _buildRandomToolsSection(loc),
                          const SizedBox(height: 24),
                          _buildDataSection(loc),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(AppLocalizations loc) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : 20,
        vertical: isTablet ? 24 : 20,
      ),
      children: [
        if (!widget.isEmbedded) _buildHeader(loc),
        _buildUserInterfaceSection(loc),
        const SizedBox(height: 24),
        _buildToolsShortcutsSection(loc),
        const SizedBox(height: 24),
        _buildConverterToolsSection(loc),
        const SizedBox(height: 24),
        _buildRandomToolsSection(loc),
        const SizedBox(height: 24),
        _buildDataSection(loc),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Padding(
      padding: EdgeInsets.only(bottom: isDesktop ? 40 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  size: isDesktop ? 32 : 28,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.settings,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.settingsDesc,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isDesktop) ...[
            const SizedBox(height: 24),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.0),
                    Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? iconColor,
  }) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: isDesktop ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(isDesktop ? 24 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (iconColor ?? Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.05),
                  (iconColor ?? Theme.of(context).colorScheme.primary)
                      .withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isDesktop ? 20 : 16),
                topRight: Radius.circular(isDesktop ? 20 : 16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 10 : 8),
                  decoration: BoxDecoration(
                    color: (iconColor ?? Theme.of(context).colorScheme.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: isDesktop ? 24 : 22,
                    color: iconColor ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(width: isDesktop ? 16 : 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: isDesktop ? 20 : (isTablet ? 18 : 16),
                        ),
                  ),
                ),
              ],
            ),
          ),
          // Section Content
          Padding(
            padding: EdgeInsets.fromLTRB(
              isDesktop ? 24 : 20,
              isDesktop ? 8 : 4,
              isDesktop ? 24 : 20,
              isDesktop ? 24 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInterfaceSection(AppLocalizations loc) {
    return _buildSection(
      title: loc.userInterface,
      icon: Icons.palette_outlined,
      iconColor: Colors.purple.shade600,
      children: [
        _buildThemeSettings(loc),
        const SizedBox(height: 24),
        _buildLanguageSettings(loc),
      ],
    );
  }

  Widget _buildToolsShortcutsSection(AppLocalizations loc) {
    return _buildSection(
      title: loc.toolsShortcuts,
      icon: Icons.tune,
      iconColor: Colors.blue.shade600,
      children: [
        _buildToolVisibilitySettings(loc),
        const SizedBox(height: 16),
        _buildQuickActionsSettings(loc),
      ],
    );
  }

  Widget _buildConverterToolsSection(AppLocalizations loc) {
    return _buildSection(
      title: loc.converterTools,
      icon: Icons.swap_horiz,
      iconColor: Colors.green.shade600,
      children: [
        _buildCurrencyFetchModeSettings(loc),
        const SizedBox(height: 24),
        _buildFetchTimeoutSettings(loc),
      ],
    );
  }

  Widget _buildRandomToolsSection(AppLocalizations loc) {
    return _buildSection(
      title: loc.random,
      icon: Icons.casino_outlined,
      iconColor: Colors.orange.shade600,
      children: [
        _buildHistorySettings(loc),
        const SizedBox(height: 24),
        _buildFeatureStateSavingSettings(loc),
      ],
    );
  }

  Widget _buildDataSection(AppLocalizations loc) {
    return _buildSection(
      title: loc.cache,
      icon: Icons.storage_outlined,
      iconColor: Colors.red.shade600,
      children: [
        _buildCacheInfo(loc),
        const SizedBox(height: 16),
        _buildCacheActions(loc),
      ],
    );
  }

  Widget _buildThemeSettings(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.theme,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        _buildThemeOptions(loc),
      ],
    );
  }

  Widget _buildLanguageSettings(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.language,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 12),
        _buildLanguageOptions(loc),
      ],
    );
  }

  Widget _buildLanguageOptions(AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 700;

    final languageOptions = [
      _buildLanguageOption(
        'en',
        _language,
        _onLanguageChanged,
        '🇺🇸',
        Colors.blue.shade600,
        loc.english,
      ),
      _buildLanguageOption(
        'vi',
        _language,
        _onLanguageChanged,
        '🇻🇳',
        Colors.red.shade600,
        loc.vietnamese,
      ),
    ];

    if (isLargeScreen) {
      return Row(
        children: languageOptions
            .map((option) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: option,
                  ),
                ))
            .toList(),
      );
    } else {
      return Column(
        children: languageOptions
            .map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: option,
                ))
            .toList(),
      );
    }
  }

  Widget _buildLanguageOption(String value, String groupValue,
      Function(String?) onChanged, String flag, Color color, String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 700;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: isLargeScreen ? null : double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: isLargeScreen ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: isSelected ? FontWeight.w500 : null,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySettings(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.saveGenerationHistory,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.saveGenerationHistoryDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: _historyEnabled,
          onChanged: _onHistoryEnabledChanged,
        ),
      ],
    );
  }

  Widget _buildFeatureStateSavingSettings(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.saveFeatureState,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.saveFeatureStateDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: _featureStateSavingEnabled,
          onChanged: _onFeatureStateSavingChanged,
        ),
      ],
    );
  }

  Widget _buildCurrencyFetchModeSettings(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.currencyFetchMode,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.currencyFetchModeDesc,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        ...CurrencyFetchMode.values.map((mode) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _onCurrencyFetchModeChanged(mode),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _currencyFetchMode == mode
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                      width: _currencyFetchMode == mode ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _currencyFetchMode == mode
                        ? Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withValues(alpha: 0.1)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _currencyFetchMode == mode
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _currencyFetchMode == mode
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mode.displayName(loc),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: _currencyFetchMode == mode
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mode.description(loc),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildToolVisibilitySettings(AppLocalizations loc) {
    return InkWell(
      onTap: _showToolVisibilityDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.tune,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.displayArrangeTools,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.displayArrangeToolsDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSettings(AppLocalizations loc) {
    return InkWell(
      onTap: _showQuickActionsDialog,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.flash_on,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.manageQuickActions,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.manageQuickActionsDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickActionsDialog() {
    showDialog(
      context: context,
      builder: (context) => const QuickActionsDialog(),
    );
  }

  void _testCache() async {
    try {
      await CurrencyCacheService.debugCache();
      await CurrencyStateService.debugState();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debug information printed to console'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildFetchTimeoutSettings(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.fetchTimeout,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.fetchTimeoutDesc,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _fetchTimeoutSeconds.toDouble(),
                min: 10,
                max: 90,
                divisions:
                    16, // (90-10)/5 = 16 divisions for 5-second increments
                onChanged: (value) => _onFetchTimeoutChanged(value.round()),
                label: loc.fetchTimeoutSeconds(_fetchTimeoutSeconds),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                loc.fetchTimeoutSeconds(_fetchTimeoutSeconds),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCacheInfo(AppLocalizations loc) {
    return Row(
      children: [
        Icon(
          Icons.info_outline,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '${loc.cache}: $_cacheInfo',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildCacheActions(AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 600;
    final isMobile = screenWidth < 480;

    final clearButton = FilledButton.icon(
      icon: _clearing
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.delete_outline),
      label: Text(loc.clearCache),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 14 : 12,
        ),
        minimumSize:
            isMobile ? const Size(double.infinity, 44) : const Size(120, 44),
      ),
      onPressed: _clearing ? null : _clearCache,
    );

    final detailsButton = OutlinedButton.icon(
      icon: const Icon(Icons.visibility_outlined),
      label: Text(loc.viewCacheDetails),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 16,
          vertical: isDesktop ? 14 : 12,
        ),
        minimumSize:
            isMobile ? const Size(double.infinity, 44) : const Size(120, 44),
      ),
      onPressed: _showCacheDetails,
    );

    // Use Column layout on mobile, Row layout on desktop
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          clearButton,
          const SizedBox(height: 12),
          detailsButton,
        ],
      );
    } else {
      // Desktop and tablet: use Row layout with proper expansion
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: clearButton),
              SizedBox(width: isDesktop ? 16 : 12),
              Expanded(child: detailsButton),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.bug_report_outlined),
              label: Text(loc.testCache),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20 : 16,
                  vertical: isDesktop ? 14 : 12,
                ),
              ),
              onPressed: _testCache,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildThemeOptions(AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 700;

    final themeOptions = [
      _buildThemeOption(
        ThemeMode.system,
        _themeMode,
        _onThemeChanged,
        Icons.brightness_auto_outlined,
        Theme.of(context).colorScheme.primary,
        loc.system,
      ),
      _buildThemeOption(
        ThemeMode.light,
        _themeMode,
        _onThemeChanged,
        Icons.light_mode_outlined,
        Colors.amber.shade600,
        loc.light,
      ),
      _buildThemeOption(
        ThemeMode.dark,
        _themeMode,
        _onThemeChanged,
        Icons.dark_mode_outlined,
        Colors.indigo.shade600,
        loc.dark,
      ),
    ];

    if (isLargeScreen) {
      return Row(
        children: themeOptions
            .map((option) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: option,
                  ),
                ))
            .toList(),
      );
    } else {
      return Column(
        children: themeOptions
            .map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: option,
                ))
            .toList(),
      );
    }
  }

  Widget _buildThemeOption(
      ThemeMode value,
      ThemeMode groupValue,
      Function(ThemeMode?) onChanged,
      IconData icon,
      Color color,
      String label) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 700;
    final isSelected = value == groupValue;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: isLargeScreen ? null : double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: isLargeScreen ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: isSelected ? FontWeight.w500 : null,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
