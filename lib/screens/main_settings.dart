import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/widgets/cache_details_dialog.dart';
import 'package:my_multi_tools/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class MainSettingsScreen extends StatefulWidget {
  final bool isEmbedded;

  const MainSettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<MainSettingsScreen> createState() => _MainSettingsScreenState();
}

class _MainSettingsScreenState extends State<MainSettingsScreen> {
  late ThemeMode _themeMode = settingsController.themeMode;
  late String _language = settingsController.locale.languageCode;
  String _cacheInfo = 'Calculating...';
  bool _clearing = false;
  bool _loading = true;

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
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final maxWidth = isDesktop ? 680.0 : 480.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 24, vertical: isDesktop ? 24 : 32),
          children: [
            if (!widget.isEmbedded) _buildHeader(loc),
            _buildThemeCard(loc),
            const SizedBox(height: 24),
            _buildLanguageCard(loc),
            const SizedBox(height: 24),
            _buildCacheSection(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings,
                  size: 32, color: Theme.of(context).colorScheme.primary),
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
    );
  }

  Widget _buildThemeCard(AppLocalizations loc) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contrast,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(loc.theme,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _buildThemeOptions(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(AppLocalizations loc) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.language,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(loc.language,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _language,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(loc.english),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'vi',
                  child: Row(
                    children: [
                      const Text('🇻🇳', style: TextStyle(fontSize: 20)),
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
    );
  }

  Widget _buildThemeOptions(AppLocalizations loc) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen =
        screenWidth >= 800; // Increased threshold for horizontal layout

    final themeOptions = [
      _buildThemeOption(
        ThemeMode.system,
        _themeMode,
        _onThemeChanged,
        Icons.brightness_auto,
        Colors.blueGrey,
        loc.system,
      ),
      _buildThemeOption(
        ThemeMode.light,
        _themeMode,
        _onThemeChanged,
        Icons.light_mode,
        Colors.amber,
        loc.light,
      ),
      _buildThemeOption(
        ThemeMode.dark,
        _themeMode,
        _onThemeChanged,
        Icons.dark_mode,
        Colors.deepPurple,
        loc.dark,
      ),
    ];

    if (isLargeScreen) {
      // Large screens: Arrange horizontally with proper spacing
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
      // Smaller screens: Arrange vertically
      return Column(
        children: themeOptions
            .map((option) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
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
    final isLargeScreen = screenWidth >= 800;

    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: isLargeScreen ? null : double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          mainAxisSize: isLargeScreen ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Radio<ThemeMode>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
            ),
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheSection(AppLocalizations loc) {
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            _buildCacheButtons(loc, isDesktop),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheButtons(AppLocalizations loc, bool isDesktop) {
    final clearButton = Expanded(
      child: ElevatedButton.icon(
        icon: _clearing
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.delete),
        label: Text(loc.clearCache),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: _clearing ? null : _clearCache,
      ),
    );

    final detailsButton = Expanded(
      child: OutlinedButton.icon(
        icon: const Icon(Icons.info_outline),
        label: Text(loc.viewCacheDetails),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: _showCacheDetails,
      ),
    );

    if (isDesktop) {
      // On desktop, use more spacing between buttons
      return Row(
        children: [
          clearButton,
          const SizedBox(width: 16),
          detailsButton,
        ],
      );
    } else {
      // On mobile, use smaller spacing
      return Row(
        children: [
          clearButton,
          const SizedBox(width: 8),
          detailsButton,
        ],
      );
    }
  }
}
