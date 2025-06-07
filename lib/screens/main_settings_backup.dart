import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/widgets/cache_details_dialog.dart';
import 'package:my_multi_tools/services/cache_service.dart';
import 'package:my_multi_tools/services/generation_history_service.dart';
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
  bool _historyEnabled = false;

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
    setState(() {
      _themeMode = themeIndex != null
          ? ThemeMode.values[themeIndex]
          : settingsController.themeMode;
      _language = lang ?? settingsController.locale.languageCode;
      _historyEnabled = historyEnabled;
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
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final maxWidth = isDesktop ? 720.0 : 480.0;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ListView(
          padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 32 : 24, vertical: isDesktop ? 24 : 32),
          children: [
            if (!widget.isEmbedded) _buildHeader(loc),
            _buildUserInterfaceSection(loc),
            const SizedBox(height: 32),
            _buildRandomToolsSection(loc),
            const SizedBox(height: 32),
            _buildDataSection(loc),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings_outlined,
                  size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                loc.settings,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            loc.settingsDesc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      children: [
        _buildThemeSettings(loc),
        const SizedBox(height: 20),
        _buildLanguageSettings(loc),
      ],
    );
  }

  Widget _buildRandomToolsSection(AppLocalizations loc) {
    return _buildSection(
      title: loc.random,
      icon: Icons.casino_outlined,
      children: [
        _buildHistorySettings(loc),
      ],
    );
  }

  Widget _buildDataSection(AppLocalizations loc) {
    return _buildSection(
      title: loc.cache,
      icon: Icons.storage_outlined,
      children: [
        _buildCacheInfo(loc),
        const SizedBox(height: 16),
        _buildCacheActions(loc),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _language,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(loc.english),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'vi',
                  child: Row(
                    children: [
                      const Text('🇻🇳', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Text(loc.vietnamese),
                    ],
                  ),
                ),
              ],
              onChanged: _onLanguageChanged,
            ),
          ),
        ),
      ],
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
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final clearButton = Expanded(
      child: FilledButton.icon(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: _clearing ? null : _clearCache,
      ),
    );

    final detailsButton = Expanded(
      child: OutlinedButton.icon(
        icon: const Icon(Icons.visibility_outlined),
        label: Text(loc.viewCacheDetails),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: _showCacheDetails,
      ),
    );

    return Row(
      children: [
        clearButton,
        SizedBox(width: isDesktop ? 16 : 12),
        detailsButton,
      ],
    );
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
