import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/widgets/cache_details_dialog.dart';
import 'package:setpocket/widgets/tool_visibility_dialog.dart';
import 'package:setpocket/widgets/quick_actions_dialog.dart';
import 'package:setpocket/widgets/hold_to_confirm_dialog.dart';
import 'package:setpocket/services/cache_service.dart';
import 'package:setpocket/services/generation_history_service.dart';
import 'package:setpocket/services/settings_service.dart';
import 'package:setpocket/services/converter_services/currency_cache_service.dart';
import 'package:setpocket/services/converter_services/currency_state_service.dart';
import 'package:setpocket/services/converter_services/length_state_service.dart';
import 'package:setpocket/services/converter_services/time_state_service.dart';
import 'package:setpocket/services/graphing_calculator_service.dart';
import 'package:setpocket/screens/log_viewer_screen.dart';

import 'package:setpocket/models/converter_models/currency_cache_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setpocket/main.dart';
import 'package:hive/hive.dart';
import 'package:setpocket/services/hive_service.dart';

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
  String _cacheInfo = '';
  bool _clearing = false;
  bool _loading = true;
  bool _historyEnabled = false;
  bool _rememberCalculationHistory = true;
  bool _featureStateSavingEnabled = true;
  bool _askBeforeLoadingHistory = true;

  CurrencyFetchMode _currencyFetchMode = CurrencyFetchMode.manual;
  int _fetchTimeoutSeconds = 10;
  int _fetchRetryTimes = 1;

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
    if (_loading) {
      _loadCacheInfo();
      _loadLogInfo();
    }
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
    final fetchRetryTimes = await SettingsService.getFetchRetryTimes();
    final logRetentionDays = await SettingsService.getLogRetentionDays();
    final askBeforeLoadingHistory =
        await GraphingCalculatorService.getAskBeforeLoading();
    final rememberCalculationHistory =
        await GraphingCalculatorService.getRememberHistory();

    setState(() {
      _themeMode = themeIndex != null
          ? ThemeMode.values[themeIndex]
          : settingsController.themeMode;
      _language = lang ?? settingsController.locale.languageCode;
      _historyEnabled = historyEnabled;
      _rememberCalculationHistory = rememberCalculationHistory;
      _featureStateSavingEnabled = featureStateSavingEnabled;
      _currencyFetchMode = currencyFetchMode;
      _fetchTimeoutSeconds = fetchTimeout;
      _fetchRetryTimes = fetchRetryTimes;
      _logRetentionDays = logRetentionDays;
      _askBeforeLoadingHistory = askBeforeLoadingHistory;

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
      final totalSize = await CacheService.getTotalCacheSize();
      if (mounted) {
        setState(() {
          _cacheInfo = CacheService.formatCacheSize(totalSize);
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

    await showDialog(
      context: context,
      builder: (context) => HoldToConfirmDialog(
        title: l10n.clearAllCache,
        content: l10n.confirmClearAllCache,
        actionText: l10n.clearCache,
        holdText: l10n.holdToClearCache,
        processingText: l10n.clearingCache,
        instructionText: l10n.holdToClearCacheInstruction,
        onConfirmed: () async {
          Navigator.of(context).pop();
          await _performClearCache();
        },
        holdDuration: const Duration(seconds: 10),
        actionIcon: Icons.delete_forever,
        l10n: l10n,
      ),
    );
  }

  Future<void> _performClearCache() async {
    setState(() {
      _clearing = true;
    });

    try {
      await CacheService.clearAllCache();

      // Reset "Hỏi trước khi tải lịch sử" khi clear Calculator Tools cache
      await GraphingCalculatorService.setAskBeforeLoading(true);
      await GraphingCalculatorService.setSaveDialogPreference(null);

      await _loadCacheInfo(); // Refresh cache info
      await _loadSettings(); // Refresh settings để cập nhật UI

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

  void _onFetchRetryTimesChanged(int retryTimes) async {
    setState(() => _fetchRetryTimes = retryTimes);
    await SettingsService.updateFetchRetryTimes(retryTimes);
  }

  void _onRememberCalculationHistoryChanged(bool enabled) async {
    setState(() {
      _rememberCalculationHistory = enabled;
    });

    await GraphingCalculatorService.setRememberHistory(enabled);
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column
                  Expanded(
                    child: Column(
                      children: [
                        _buildUserInterfaceSection(loc),
                        const SizedBox(height: 24),
                        _buildToolsShortcutsSection(loc),
                        const SizedBox(height: 24),
                        _buildRandomToolsSection(loc),
                        const SizedBox(height: 24),
                        _buildCalculatorToolsSection(loc),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right Column
                  Expanded(
                    child: Column(
                      children: [
                        _buildConverterToolsSection(loc),
                        const SizedBox(height: 24),
                        _buildDataSection(loc),
                        const SizedBox(height: 32), // Extra padding at bottom
                      ],
                    ),
                  ),
                ],
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
        _buildRandomToolsSection(loc),
        const SizedBox(height: 24),
        _buildCalculatorToolsSection(loc),
        const SizedBox(height: 24),
        _buildConverterToolsSection(loc),
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
              isDesktop ? 10 : 10,
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
        const SizedBox(height: 16),
        _buildFeatureStateSavingSettings(loc),
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
        const SizedBox(height: 24),
        _buildFetchRetrySettings(loc),
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
      ],
    );
  }

  Widget _buildCalculatorToolsSection(AppLocalizations loc) {
    return _buildSection(
      title: loc.calculatorTools,
      icon: Icons.calculate_outlined,
      iconColor: Colors.teal.shade600,
      children: [
        _buildRememberCalculationHistorySettings(loc),
        const SizedBox(height: 24),
        _buildAskBeforeLoadingHistorySettings(loc),
      ],
    );
  }

  Widget _buildDataSection(AppLocalizations loc) {
    return _buildSection(
      title: loc.dataAndStorage,
      icon: Icons.storage_outlined,
      iconColor: Colors.red.shade600,
      children: [
        _buildCacheInfo(loc),
        const SizedBox(height: 16),
        _buildCacheActions(loc),
        const SizedBox(height: 24),
        _buildExpandableLogSection(loc),
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
                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
        padding: EdgeInsets.symmetric(
            vertical: 12, horizontal: isLargeScreen ? 6 : 12),
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
          children: [
            Text(
              flag,
              style: TextStyle(fontSize: isLargeScreen ? 16 : 20),
            ),
            SizedBox(width: isLargeScreen ? 4 : 8),
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

  Widget _buildRememberCalculationHistorySettings(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.rememberCalculationHistory,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                loc.rememberCalculationHistoryDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        Switch(
          value: _rememberCalculationHistory,
          onChanged: _onRememberCalculationHistoryChanged,
        ),
      ],
    );
  }

  Widget _buildAskBeforeLoadingHistorySettings(AppLocalizations loc) {
    // Chỉ làm mờ khi "Ghi nhớ lịch sử tính toán" bị tắt hoặc khi đã được bật
    final isDisabled = !_rememberCalculationHistory || _askBeforeLoadingHistory;

    return Padding(
      padding: EdgeInsets.zero,
      child: SwitchListTile(
        title: Text(loc.askBeforeLoadingHistory),
        subtitle: Text(loc.askBeforeLoadingHistoryDesc),
        value: _askBeforeLoadingHistory,
        onChanged: isDisabled
            ? null
            : (bool value) async {
                // Chỉ cho phép bật từ tắt khi "Ghi nhớ lịch sử tính toán" được bật
                if (!_askBeforeLoadingHistory &&
                    value &&
                    _rememberCalculationHistory) {
                  setState(() {
                    _askBeforeLoadingHistory = value;
                  });
                  await GraphingCalculatorService.setAskBeforeLoading(value);

                  // Reset dialog preference khi bật lại
                  await GraphingCalculatorService.setSaveDialogPreference(null);
                }
              },
      ),
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
                min: 5,
                max: 20,
                divisions:
                    15, // (20-5)/1 = 15 divisions for 1-second increments
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
                    .withValues(alpha: 0.3),
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

  Widget _buildFetchRetrySettings(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.fetchRetryIncomplete,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          loc.fetchRetryIncompleteDesc,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _fetchRetryTimes.toDouble(),
                min: 0,
                max: 3,
                divisions: 3,
                onChanged: (value) => _onFetchRetryTimesChanged(value.round()),
                label: loc.fetchRetryTimes(_fetchRetryTimes),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                loc.fetchRetryTimes(_fetchRetryTimes),
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

    late final Widget debugButton;

    // Only show debug button in debug mode
    if (kDebugMode) {
      debugButton = OutlinedButton.icon(
        icon: const Icon(Icons.bug_report_outlined),
        label: const Text('Debug Cache'),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 16,
            vertical: isDesktop ? 14 : 12,
          ),
          minimumSize:
              isMobile ? const Size(double.infinity, 44) : const Size(120, 44),
        ),
        onPressed: _debugMobileCache,
      );
    }

    // Use Column layout on mobile, Row layout on desktop
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          clearButton,
          const SizedBox(height: 12),
          detailsButton,
          // Only show debug button in debug mode
          if (kDebugMode) ...[
            const SizedBox(height: 12),
            debugButton,
          ],
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
          // Only show debug button in debug mode
          if (kDebugMode) ...[
            Row(
              children: [
                Expanded(child: debugButton),
              ],
            ),
          ],
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
                    padding: const EdgeInsets.symmetric(horizontal: 2),
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
        padding: EdgeInsets.symmetric(
            vertical: 12, horizontal: isLargeScreen ? 6 : 12),
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
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : color,
              size: isLargeScreen ? 16 : 20,
            ),
            SizedBox(width: isLargeScreen ? 4 : 8),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      fontWeight: isSelected ? FontWeight.w500 : null,
                      fontSize: isLargeScreen ? 12 : null,
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

  Widget _buildExpandableLogSection(AppLocalizations loc) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _logSectionExpanded = !_logSectionExpanded;
              });
              if (_logSectionExpanded) {
                _loadLogInfo();
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: _logSectionExpanded
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.1)
                    : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.logRetention,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.logsManagement,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _logSectionExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          // Expanded content
          if (_logSectionExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLogRetentionSettings(loc),
                  const SizedBox(height: 16),
                  _buildLogViewer(loc),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogRetentionSettings(AppLocalizations loc) {
    // Map retention days to slider index
    int getSliderIndex(int retentionDays) {
      if (retentionDays == -1) return 6; // Forever
      switch (retentionDays) {
        case 5:
          return 0;
        case 10:
          return 1;
        case 15:
          return 2;
        case 20:
          return 3;
        case 25:
          return 4;
        case 30:
          return 5;
        default:
          return 0; // Default to 5 days
      }
    }

    // Map slider index to retention days
    int getRetentionDays(int index) {
      switch (index) {
        case 0:
          return 5;
        case 1:
          return 10;
        case 2:
          return 15;
        case 3:
          return 20;
        case 4:
          return 25;
        case 5:
          return 30;
        case 6:
          return -1; // Forever
        default:
          return 5;
      }
    }

    String getDisplayText(int retentionDays) {
      if (retentionDays == -1) {
        return loc.logRetentionForever;
      }
      return loc.logRetentionDays(retentionDays);
    }

    final currentSliderIndex = getSliderIndex(_logRetentionDays);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        loc.logRetention,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      const SizedBox(height: 4),
      Text(
        loc.logRetentionDescDetail,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: Slider(
              value: currentSliderIndex.toDouble(),
              min: 0,
              max: 6,
              divisions: 6,
              onChanged: (value) {
                final index = value.round();
                final days = getRetentionDays(index);
                setState(() {
                  _logRetentionDays = days;
                });
              },
              onChangeEnd: (value) async {
                final index = value.round();
                final days = getRetentionDays(index);
                await _updateLogRetention(days);
              },
              label: getDisplayText(_logRetentionDays),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              getDisplayText(_logRetentionDays),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
    ]);
  }

  Widget _buildLogViewer(AppLocalizations loc) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.visibility_outlined),
      label: Text(loc.viewLogs),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onPressed: _showLogViewer,
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
    await SettingsService.updateLogRetentionDays(days);
  }

  // Debug function for mobile cache issues
  Future<void> _debugMobileCache() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Mobile Cache Debug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Running cache diagnostics...'),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );

    try {
      // Run diagnostics
      final isReliable = await CurrencyCacheService.isCacheReliable();
      final settings = await SettingsService.getSettings();
      final hasCache = await CurrencyCacheService.hasCachedData();

      // Test state loading with error handling
      String currencyStateResult = '✗ Error';
      String lengthStateResult = '✗ Error';
      String timeStateResult = '✗ Error';

      try {
        await CurrencyStateService.loadState();
        currencyStateResult = '✓ Saved';
      } catch (e) {
        logError('Currency state load error: $e');
        currencyStateResult =
            '✗ Default (Error: ${e.toString().substring(0, 30)}...)';
      }

      try {
        await LengthStateService.loadState();
        lengthStateResult = '✓ Saved';
      } catch (e) {
        logError('Length state load error: $e');
        lengthStateResult =
            '✗ Default (Error: ${e.toString().substring(0, 30)}...)';
      }

      try {
        await TimeStateService.loadState();
        timeStateResult = '✓ Saved';
      } catch (e) {
        logError('Time state load error: $e');
        timeStateResult =
            '✗ Default (Error: ${e.toString().substring(0, 30)}...)';
      }

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show results
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cache Diagnostics Results'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Cache Status:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '• Reliability: ${isReliable ? "✓ Reliable" : "✗ Unreliable"}'),
                  Text('• Has Cache: ${hasCache ? "✓ Yes" : "✗ No"}'),
                  const SizedBox(height: 12),
                  const Text('Settings:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '• Feature State Saving: ${settings.featureStateSavingEnabled ? "✓ Enabled" : "✗ Disabled"}'),
                  const SizedBox(height: 12),
                  const Text('State Persistence:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('• Currency State: $currencyStateResult'),
                  Text('• Length State: $lengthStateResult'),
                  Text('• Time State: $timeStateResult'),
                  if (currencyStateResult.contains('Error') ||
                      lengthStateResult.contains('Error') ||
                      timeStateResult.contains('Error')) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('⚠️ State Loading Issues Detected',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text(
                              'This usually happens after app updates that change data structure.'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                              await _clearAllStateData();
                            },
                            child: const Text('Clear All State Data'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to run diagnostics: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _clearAllStateData() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Clearing State Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Clearing all converter state data...'),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );

    try {
      // Clear Hive boxes to fix compatibility issues
      await Hive.deleteFromDisk();

      // Re-initialize Hive with new adapters
      await HiveService.initialize();

      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text(
                'All state data has been cleared. The app will restart to complete the process.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Restart app
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to clear state data: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }
}
