import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/widgets/generic/option_item.dart';
import 'package:setpocket/widgets/generic/option_grid_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setpocket/main.dart';

/// User Interface Settings Module
/// Handles theme and language settings
class UserInterfaceSettings extends StatefulWidget {
  final ThemeMode initialThemeMode;
  final String initialLanguage;
  final Function(ThemeMode)? onThemeChanged;
  final Function(String)? onLanguageChanged;

  const UserInterfaceSettings({
    super.key,
    required this.initialThemeMode,
    required this.initialLanguage,
    this.onThemeChanged,
    this.onLanguageChanged,
  });

  @override
  State<UserInterfaceSettings> createState() => _UserInterfaceSettingsState();
}

class _UserInterfaceSettingsState extends State<UserInterfaceSettings> {
  late ThemeMode _currentThemeMode;
  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    _currentThemeMode = widget.initialThemeMode;
    _currentLanguage = widget.initialLanguage;
  }

  void _onThemeChanged(ThemeMode? mode) async {
    if (mode != null) {
      setState(() => _currentThemeMode = mode);

      // Update global settings controller
      settingsController.setThemeMode(mode);

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('themeMode', mode.index);

      // Notify parent
      widget.onThemeChanged?.call(mode);
    }
  }

  void _onLanguageChanged(String? lang) async {
    if (lang != null) {
      setState(() => _currentLanguage = lang);

      // Update global settings controller
      settingsController.setLocale(Locale(lang));

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', lang);

      // Notify parent
      widget.onLanguageChanged?.call(lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThemeSettings(loc),
        const SizedBox(height: 16),
        _buildLanguageSettings(loc),
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
      selectedValue: _currentThemeMode,
      onSelectionChanged: _onThemeChanged,
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
      selectedValue: _currentLanguage,
      onSelectionChanged: _onLanguageChanged,
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
}
