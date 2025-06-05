import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/widgets/tool_card.dart';
import 'package:my_multi_tools/widgets/cache_details_dialog.dart';
import 'package:my_multi_tools/services/cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/text_template_gen_list_screen.dart';
import 'screens/main_settings.dart';
import 'screens/random_tools_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize settings controller and load saved settings
  await settingsController.loadSettings();
  runApp(const MainApp());
}

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    // Load language
    final languageCode = prefs.getString('language') ?? 'en';
    _locale = Locale(languageCode);

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}

final SettingsController settingsController = SettingsController();

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Multi Tools',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settingsController.themeMode,
          locale: settingsController.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is less than 600, we consider it mobile layout
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return const MobileLayout();
        } else {
          return const DesktopLayout();
        }
      },
    );
  }
}

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.title)),
      body: const ToolSelectionScreen(),
    );
  }
}

class DesktopLayout extends StatefulWidget {
  const DesktopLayout({super.key});

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  Widget? currentTool;
  String? selectedToolType;
  String? currentToolTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentToolTitle ?? AppLocalizations.of(context)!.title),
        leading: currentTool != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    currentTool = null;
                    selectedToolType = null;
                    currentToolTitle = null;
                  });
                },
              )
            : null,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          // Sidebar chiếm 1/4, main chiếm 3/4, nhưng sidebar min 280, max 380
          double sidebarWidth = (totalWidth / 4).clamp(280, 380);

          return Row(
            children: [
              // Sidebar với danh sách tools
              SizedBox(
                width: sidebarWidth,
                child: ToolSelectionScreen(
                  isDesktop: true,
                  selectedToolType: selectedToolType,
                  onToolSelected: (Widget tool, String title) {
                    setState(() {
                      currentTool = tool;
                      selectedToolType = tool.runtimeType.toString();
                      currentToolTitle = title;
                    });
                  },
                ),
              ),
              // Main content area
              Expanded(
                child: currentTool != null
                    ? ClipRect(
                        child: currentTool!,
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context)!.selectTool,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!.selectToolDesc,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ToolSelectionScreen extends StatelessWidget {
  final bool isDesktop;
  final Function(Widget, String)? onToolSelected;
  final String? selectedToolType;

  const ToolSelectionScreen({
    super.key,
    this.isDesktop = false,
    this.onToolSelected,
    this.selectedToolType,
  });
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ToolCard(
          title: loc.textTemplateGen,
          description: loc.textTemplateGenDesc,
          icon: Icons.description,
          iconColor: Colors.blue.shade800,
          isSelected: selectedToolType == 'TemplateListScreen',
          onTap: () {
            final tool = TemplateListScreen(
              isEmbedded: isDesktop,
              onToolSelected:
                  onToolSelected, // Truyền callback để xử lý sub-navigation
            );
            if (isDesktop) {
              onToolSelected?.call(tool, loc.textTemplateGen);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => tool,
                ),
              );
            }
          },
        ),
        ToolCard(
          title: loc.random,
          description: loc.randomDesc,
          icon: Icons.casino,
          iconColor: Colors.purple,
          isSelected: selectedToolType == 'RandomToolsScreen',
          onTap: () {
            final tool = RandomToolsScreen(
              isEmbedded: isDesktop,
              onToolSelected:
                  onToolSelected, // Truyền callback để xử lý sub-navigation
            );
            if (isDesktop) {
              onToolSelected?.call(tool, loc.random);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => tool,
                ),
              );
            }
          },
        ),
        const SizedBox(height: 32),
        ToolCard(
          title: loc.settings,
          description: loc.settings,
          icon: Icons.settings,
          iconColor: Colors.grey,
          isSelected: selectedToolType == 'MainSettingsScreen',
          onTap: () {
            final tool = MainSettingsScreen(isEmbedded: isDesktop);
            if (isDesktop) {
              onToolSelected?.call(tool, loc.settings);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => tool,
                ),
              );
            }
          },
          showActions: false,
        ),
      ],
    );
  }
}

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.settings),
      content: const SettingsScreen(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _themeMode;
  late String _language;
  String _cacheInfo = 'Calculating...';
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    _themeMode = settingsController.themeMode;
    _language = settingsController.locale.languageCode;
    _loadCacheInfo();
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

  void _onThemeChanged(ThemeMode? mode) {
    if (mode != null) {
      setState(() => _themeMode = mode);
      settingsController.setThemeMode(mode);
    }
  }

  void _onLanguageChanged(String? lang) {
    if (lang != null) {
      setState(() => _language = lang);
      settingsController.setLocale(Locale(lang));
    }
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
    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(loc.theme, style: const TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: Text(loc.system),
            leading: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: _themeMode,
              onChanged: _onThemeChanged,
            ),
          ),
          ListTile(
            title: Text(loc.light),
            leading: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: _themeMode,
              onChanged: _onThemeChanged,
            ),
          ),
          ListTile(
            title: Text(loc.dark),
            leading: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: _themeMode,
              onChanged: _onThemeChanged,
            ),
          ),
          const SizedBox(height: 24),
          Text(loc.language,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          ListTile(
            title: Text(loc.english),
            leading: Radio<String>(
              value: 'en',
              groupValue: _language,
              onChanged: _onLanguageChanged,
            ),
          ),
          ListTile(
            title: Text(loc.vietnamese),
            leading: Radio<String>(
              value: 'vi',
              groupValue: _language,
              onChanged: _onLanguageChanged,
            ),
          ),
          const SizedBox(height: 24),
          Text('${loc.cache}: $_cacheInfo'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: _clearing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete),
                  label: Text(loc.clearCache),
                  onPressed: _clearing ? null : _clearCache,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.info_outline),
                  label: Text(loc.viewCacheDetails),
                  onPressed: _showCacheDetails,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
