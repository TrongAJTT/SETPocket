import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class MainSettingsScreen extends StatefulWidget {
  const MainSettingsScreen({super.key});

  @override
  State<MainSettingsScreen> createState() => _MainSettingsScreenState();
}

class _MainSettingsScreenState extends State<MainSettingsScreen> {
  late ThemeMode _themeMode;
  late String _language;
  String _cacheInfo = 'Calculating...';
  bool _clearing = false;

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
    setState(() {
      _themeMode = themeIndex != null
          ? ThemeMode.values[themeIndex]
          : settingsController.themeMode;
      _language = lang ?? settingsController.locale.languageCode;
    });
  }

  Future<void> _loadCacheInfo() async {
    setState(() {
      _cacheInfo = 'Approx. 0 MB';
    });
  }

  Future<void> _clearCache() async {
    setState(() {
      _clearing = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _cacheInfo = 'Approx. 0 MB';
      _clearing = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.clearCache)),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.settings,
                            size: 32,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 12),
                        Text(
                          loc.settings,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      loc.settingsDesc,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.theme,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          buildRadioOption<ThemeMode>(
                            ThemeMode.system,
                            _themeMode,
                            _onThemeChanged,
                            Icons.brightness_auto,
                            Colors.blueGrey,
                            loc.system,
                          ),
                          const SizedBox(width: 16),
                          buildRadioOption<ThemeMode>(
                            ThemeMode.light,
                            _themeMode,
                            _onThemeChanged,
                            Icons.light_mode,
                            Colors.amber,
                            loc.light,
                          ),
                          const SizedBox(width: 16),
                          buildRadioOption<ThemeMode>(
                            ThemeMode.dark,
                            _themeMode,
                            _onThemeChanged,
                            Icons.dark_mode,
                            Colors.deepPurple,
                            loc.dark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.language,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _language,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'en',
                            child: Row(
                              children: [
                                const Text('🇺🇸',
                                    style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(loc.english),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'vi',
                            child: Row(
                              children: [
                                const Text('🇻🇳',
                                    style: TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(loc.vietnamese),
                              ],
                            ),
                          ),
                        ],
                        onChanged: _onLanguageChanged,
                        isExpanded: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.storage,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(loc.cache,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('${loc.cache}: $_cacheInfo',
                          style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        icon: _clearing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete),
                        label: Text(loc.clearCache),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: _clearing ? null : _clearCache,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRadioOption<T>(T value, T groupValue, Function(T?) onChanged,
      IconData icon, Color color, String label) {
    return Row(
      children: [
        Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
        ),
        Icon(icon, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
