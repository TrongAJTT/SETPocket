import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/settings_models_service.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/widgets/generic/option_switch.dart';
import 'package:setpocket/widgets/generic/base_settings_layout.dart';

/// Layout for Random Tools settings using the generic settings system
class RandomToolsSettingsLayout
    extends BaseSettingsLayout<Map<String, dynamic>> {
  const RandomToolsSettingsLayout({
    super.key,
    super.onSettingsSaved,
    super.onCancel,
    super.showActions,
  });

  @override
  State<RandomToolsSettingsLayout> createState() =>
      _RandomToolsSettingsLayoutState();
}

class _RandomToolsSettingsLayoutState extends BaseSettingsLayoutState<
    RandomToolsSettingsLayout, Map<String, dynamic>> {
  bool _saveGenerationHistory = true;
  bool _saveRandomToolsState = true;

  // Initial values to track changes
  bool _initialSaveGenerationHistory = true;
  bool _initialSaveRandomToolsState = true;

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
    final randomSettings =
        await ExtensibleSettingsService.getRandomToolsSettings();

    if (mounted) {
      setState(() {
        _saveGenerationHistory = randomSettings.saveGenerationHistory;
        _saveRandomToolsState = randomSettings.saveRandomToolsState;

        // Store initial values to track changes
        _initialSaveGenerationHistory = randomSettings.saveGenerationHistory;
        _initialSaveRandomToolsState = randomSettings.saveRandomToolsState;
      });
    }
  }

  @override
  Future<Map<String, dynamic>> performSave() async {
    try {
      // Update random tools settings
      final currentSettings =
          await ExtensibleSettingsService.getRandomToolsSettings();
      final updatedSettings = currentSettings.copyWith(
        saveGenerationHistory: _saveGenerationHistory,
        saveRandomToolsState: _saveRandomToolsState,
      );
      await ExtensibleSettingsService.updateRandomToolsSettings(
          updatedSettings);

      // Update initial values after saving
      _initialSaveGenerationHistory = _saveGenerationHistory;
      _initialSaveRandomToolsState = _saveRandomToolsState;

      return {
        'saveGenerationHistory': _saveGenerationHistory,
        'saveRandomToolsState': _saveRandomToolsState,
      };
    } catch (e) {
      logError('RandomToolsSettingsLayout: Error saving settings: $e');
      rethrow;
    }
  }

  void _checkForChanges() {
    final hasChanges =
        _saveGenerationHistory != _initialSaveGenerationHistory ||
            _saveRandomToolsState != _initialSaveRandomToolsState;
    notifyHasChanges(hasChanges);
  }

  void _onSaveGenerationHistoryChanged(bool enabled) {
    setState(() {
      _saveGenerationHistory = enabled;
    });
    _checkForChanges();
  }

  void _onSaveRandomToolsStateChanged(bool enabled) {
    setState(() {
      _saveRandomToolsState = enabled;
    });
    _checkForChanges();
  }

  Widget _buildHistorySettings(AppLocalizations loc) {
    return OptionSwitch(
      title: loc.saveGenerationHistory,
      subtitle: loc.saveGenerationHistoryDesc,
      value: _saveGenerationHistory,
      onChanged: _onSaveGenerationHistoryChanged,
      decorator: switchDecorator,
    );
  }

  Widget _buildSaveRandomToolsStateSettings(AppLocalizations loc) {
    return OptionSwitch(
      title: loc.saveRandomToolsState,
      subtitle: loc.saveRandomToolsStateDesc,
      value: _saveRandomToolsState,
      onChanged: _onSaveRandomToolsStateChanged,
      decorator: switchDecorator,
    );
  }

  @override
  Widget buildSettingsContent(BuildContext context, AppLocalizations loc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Generation History Settings
          _buildHistorySettings(loc),

          const SizedBox(height: 8),

          // State Saving Settings
          _buildSaveRandomToolsStateSettings(loc),
        ],
      ),
    );
  }
}
