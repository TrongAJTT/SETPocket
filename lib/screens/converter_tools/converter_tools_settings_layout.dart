import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/converter_models/currency_fetch_mode.dart'
    show CurrencyFetchMode, CurrencyFetchModeExtension;
import 'package:setpocket/services/app_logger.dart' show logError;
import 'package:setpocket/services/settings_models_service.dart'
    show ExtensibleSettingsService;
import 'package:setpocket/widgets/generic/base_settings_layout.dart';
import 'package:setpocket/widgets/generic/option_item.dart' show OptionItem;
import 'package:setpocket/widgets/generic/option_list_picker.dart'
    show OptionListPicker;
import 'package:setpocket/widgets/generic/option_slider.dart'
    show SliderOption, OptionSlider, OptionSliderLayout;
import 'package:setpocket/widgets/generic/option_switch.dart'
    show OptionSwitchDecorator, OptionSwitch;

/// Layout for Converter Tools settings using the generic settings system
class ConverterToolsSettingsLayout
    extends BaseSettingsLayout<Map<String, dynamic>> {
  const ConverterToolsSettingsLayout({
    super.key,
    super.onSettingsSaved,
    super.onCancel,
    super.showActions,
  });

  @override
  State<ConverterToolsSettingsLayout> createState() =>
      _ConverterToolsSettingsLayoutState();
}

class _ConverterToolsSettingsLayoutState extends BaseSettingsLayoutState<
    ConverterToolsSettingsLayout, Map<String, dynamic>> {
  // Current values (with safe defaults within supported ranges)
  CurrencyFetchMode _currencyFetchMode = CurrencyFetchMode.autoDaily;
  int _fetchTimeoutSeconds = 10; // Safe default within 5-20 range
  int _fetchRetryTimes = 1; // Safe default within 0-2 range
  bool _saveConverterToolsState = true;

  // Initial values to track changes
  CurrencyFetchMode _initialCurrencyFetchMode = CurrencyFetchMode.autoDaily;
  int _initialFetchTimeoutSeconds = 10;
  int _initialFetchRetryTimes = 1;
  bool _initialSaveConverterToolsState = true;

  // Static decorator for settings
  late final OptionSwitchDecorator switchDecorator;
  bool _isDecoratorInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDecoratorInitialized) {
      switchDecorator = OptionSwitchDecorator.compact(context);
      _isDecoratorInitialized = true;
    }
  }

  @override
  Future<void> loadSettings() async {
    try {
      final settings =
          await ExtensibleSettingsService.getConverterToolsSettings();

      if (mounted) {
        setState(() {
          _currencyFetchMode = settings.currencyFetchMode;
          // Validate and clamp timeout to supported range (5-20 seconds)
          _fetchTimeoutSeconds = settings.fetchTimeoutSeconds.clamp(5, 20);
          // Validate and clamp retry times to supported range (0-2)
          _fetchRetryTimes = settings.fetchRetryTimes.clamp(0, 2);
          _saveConverterToolsState = settings.saveConverterToolsState;

          // Store initial values to track changes
          _initialCurrencyFetchMode = settings.currencyFetchMode;
          _initialFetchTimeoutSeconds = _fetchTimeoutSeconds;
          _initialFetchRetryTimes = _fetchRetryTimes;
          _initialSaveConverterToolsState = settings.saveConverterToolsState;
        });
      }
    } catch (e) {
      logError('ConverterToolsSettingsLayout: Error loading settings: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> performSave() async {
    try {
      // Get current settings and update with new values
      final currentSettings =
          await ExtensibleSettingsService.getConverterToolsSettings();
      final updatedSettings = currentSettings.copyWith(
        currencyFetchMode: _currencyFetchMode,
        fetchTimeoutSeconds: _fetchTimeoutSeconds,
        fetchRetryTimes: _fetchRetryTimes,
        saveConverterToolsState: _saveConverterToolsState,
      );
      await ExtensibleSettingsService.updateConverterToolsSettings(
          updatedSettings);

      // Update initial values after saving
      _initialCurrencyFetchMode = _currencyFetchMode;
      _initialFetchTimeoutSeconds = _fetchTimeoutSeconds;
      _initialFetchRetryTimes = _fetchRetryTimes;
      _initialSaveConverterToolsState = _saveConverterToolsState;

      return {
        'currencyFetchMode': _currencyFetchMode,
        'fetchTimeoutSeconds': _fetchTimeoutSeconds,
        'fetchRetryTimes': _fetchRetryTimes,
        'saveConverterToolsState': _saveConverterToolsState,
      };
    } catch (e) {
      logError('ConverterToolsSettingsLayout: Error saving settings: $e');
      rethrow;
    }
  }

  void _checkForChanges() {
    final hasChanges = _currencyFetchMode != _initialCurrencyFetchMode ||
        _fetchTimeoutSeconds != _initialFetchTimeoutSeconds ||
        _fetchRetryTimes != _initialFetchRetryTimes ||
        _saveConverterToolsState != _initialSaveConverterToolsState;
    notifyHasChanges(hasChanges);
  }

  void _onCurrencyFetchModeChanged(CurrencyFetchMode? mode) {
    if (mode != null) {
      setState(() {
        _currencyFetchMode = mode;
      });
      _checkForChanges();
    }
  }

  void _onFetchTimeoutChanged(int timeout) {
    setState(() {
      // Clamp to supported range (5-20 seconds)
      _fetchTimeoutSeconds = timeout.clamp(5, 20);
    });
    _checkForChanges();
  }

  void _onFetchRetryTimesChanged(int retryTimes) {
    setState(() {
      // Clamp to supported range (0-2 retries)
      _fetchRetryTimes = retryTimes.clamp(0, 2);
    });
    _checkForChanges();
  }

  void _onSaveConverterToolsStateChanged(bool enabled) {
    setState(() {
      _saveConverterToolsState = enabled;
    });
    _checkForChanges();
  }

  @override
  Widget buildSettingsContent(BuildContext context, AppLocalizations loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Currency Settings
          ListTile(
            leading: Icon(Icons.currency_exchange,
                size: 20, color: Theme.of(context).colorScheme.primary),
            title: Text(
              loc.currencyFetchMode,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            subtitle: Text(
              loc.currencyFetchModeDesc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          OptionListPicker<CurrencyFetchMode>(
            options: CurrencyFetchMode.values
                .map((mode) => OptionItem(
                      value: mode,
                      label: mode.displayNameLocalized(loc),
                      subtitle: mode.description,
                    ))
                .toList(),
            selectedValue: _currencyFetchMode,
            onChanged: (value) =>
                _onCurrencyFetchModeChanged(value as CurrencyFetchMode?),
            isCompact: true,
            showSelectionControl: false,
          ),

          const SizedBox(height: 8),

          // Fetch Timeout
          OptionSlider<int>(
            label: loc.fetchTimeout,
            subtitle: loc.fetchTimeoutDesc,
            icon: Icons.timer_outlined,
            currentValue: _fetchTimeoutSeconds,
            options: List.generate(
              16, // Support 5-20 seconds
              (i) => SliderOption(
                value: i + 5,
                label: loc.fetchTimeoutSeconds(i + 5),
              ),
            ),
            onChanged: _onFetchTimeoutChanged,
            layout: OptionSliderLayout.none,
          ),

          // Fetch Retry Times
          OptionSlider<int>(
            label: loc.fetchRetryIncomplete,
            subtitle: loc.fetchRetryIncompleteDesc,
            icon: Icons.replay_outlined,
            currentValue: _fetchRetryTimes,
            options: List.generate(
              3, // Support 0-2 retries
              (i) => SliderOption(
                value: i,
                label: loc.fetchRetryTimes(i),
              ),
            ),
            onChanged: _onFetchRetryTimesChanged,
            layout: OptionSliderLayout.none,
          ),

          const SizedBox(height: 8),

          // State Saving
          OptionSwitch(
            title: loc.saveConverterToolsState,
            subtitle: loc.saveConverterToolsStateDesc,
            value: _saveConverterToolsState,
            onChanged: _onSaveConverterToolsStateChanged,
            decorator: switchDecorator,
          ),
        ],
      ),
    );
  }
}
