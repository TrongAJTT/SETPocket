import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/settings_models.dart';
import 'package:setpocket/services/settings_models_service.dart';
import 'package:setpocket/widgets/generic/option_switch.dart';
import 'package:setpocket/widgets/generic/base_settings_layout.dart';

class CalculatorToolsSettingsLayout
    extends BaseSettingsLayout<CalculatorToolsSettingsData> {
  const CalculatorToolsSettingsLayout({
    super.key,
    super.onSettingsSaved,
    super.onCancel,
    super.showActions = true,
  });

  @override
  State<CalculatorToolsSettingsLayout> createState() =>
      _CalculatorToolsSettingsLayoutState();
}

class _CalculatorToolsSettingsLayoutState extends BaseSettingsLayoutState<
    CalculatorToolsSettingsLayout, CalculatorToolsSettingsData> {
  // Staging variables
  bool _rememberCalculationHistory = true;
  bool _askBeforeLoadingHistory = true;
  bool _saveCalculatorState = true;

  // Initial values for comparison
  late CalculatorToolsSettingsData _initialSettings;

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
    _initialSettings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();

    if (mounted) {
      setState(() {
        // Use the helper getter that converts bookmarkFunctionsBeforeLoading logic
        _askBeforeLoadingHistory = _initialSettings.askBeforeLoadingHistory;
        _rememberCalculationHistory = _initialSettings.rememberHistory;
        _saveCalculatorState = _initialSettings.saveFeatureState;
      });
    }
  }

  @override
  Future<CalculatorToolsSettingsData> performSave() async {
    // Convert _askBeforeLoadingHistory to bookmarkFunctionsBeforeLoading logic
    bool? bookmarkFunctionsBeforeLoading;
    if (_askBeforeLoadingHistory) {
      // If askBeforeLoadingHistory is true, set to null to enable asking
      bookmarkFunctionsBeforeLoading = null;
    } else {
      // If askBeforeLoadingHistory is false, set to false (don't bookmark before loading)
      bookmarkFunctionsBeforeLoading = false;
    }

    final newSettings = _initialSettings.copyWith(
      bookmarkFunctionsBeforeLoading: bookmarkFunctionsBeforeLoading,
      rememberHistory: _rememberCalculationHistory,
      saveFeatureState: _saveCalculatorState,
    );
    await ExtensibleSettingsService.updateCalculatorToolsSettings(newSettings);
    // Update initial values after save
    _initialSettings = newSettings;
    return newSettings;
  }

  void _checkForChanges() {
    final hasChanged = _rememberCalculationHistory !=
            _initialSettings.rememberHistory ||
        _askBeforeLoadingHistory != _initialSettings.askBeforeLoadingHistory ||
        _saveCalculatorState != _initialSettings.saveFeatureState;
    notifyHasChanges(hasChanged);
  }

  @override
  Widget buildSettingsContent(BuildContext context, AppLocalizations l10n) {
    // final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OptionSwitch(
              title: l10n.saveFeatureState,
              subtitle: l10n.saveFeatureStateDesc,
              value: _saveCalculatorState,
              onChanged: (value) {
                setState(() {
                  _saveCalculatorState = value;
                });
                _checkForChanges();
              },
              decorator: switchDecorator,
            ),
            const SizedBox(height: 16),
            OptionSwitch(
              title: l10n.rememberCalculationHistory,
              subtitle: l10n.rememberCalculationHistoryDesc,
              value: _rememberCalculationHistory,
              onChanged: (enabled) {
                setState(() {
                  _rememberCalculationHistory = enabled;
                  if (!enabled) {
                    _askBeforeLoadingHistory = false;
                  }
                });
                _checkForChanges();
              },
              decorator: switchDecorator,
            ),
            const SizedBox(height: 16),
            OptionSwitch(
              title: l10n.askBeforeLoadingHistory,
              subtitle: l10n.askBeforeLoadingHistoryDesc,
              value: _askBeforeLoadingHistory,
              onChanged: (value) {
                setState(() {
                  _askBeforeLoadingHistory = value;
                });
                _checkForChanges();
              },
              isDisabled: !_rememberCalculationHistory,
              decorator: switchDecorator,
            ),
          ],
        ),
      ],
    );
  }
}
