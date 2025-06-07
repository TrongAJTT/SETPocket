import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/widgets/tool_card.dart';
import 'package:my_multi_tools/widgets/cache_details_dialog.dart';
import 'package:my_multi_tools/services/cache_service.dart';
import 'package:my_multi_tools/services/tool_visibility_service.dart';
import 'package:my_multi_tools/services/quick_actions_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/text_template_gen_list_screen.dart';
import 'screens/main_settings.dart';
import 'screens/random_tools_screen.dart';

// Global navigation key for deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize settings controller and load saved settings
  await settingsController.loadSettings();

  // Initialize quick actions
  await _initializeQuickActions();

  runApp(const MainApp());
}

Future<void> _initializeQuickActions() async {
  await QuickActionsService.initialize();

  // Set up quick action handler
  QuickActionsService.setQuickActionHandler((toolId) {
    // Navigate to the selected tool when quick action is triggered
    _navigateToTool(toolId);
  });
}

void _navigateToTool(String toolId) {
  final context = navigatorKey.currentContext;
  if (context == null) return;

  // Find the tool configuration
  ToolVisibilityService.getVisibleToolsInOrder().then((tools) {
    final tool = tools.firstWhere(
      (t) => t.id == toolId,
      orElse: () => tools.first, // Fallback to first tool
    );

    // Navigate to the tool
    // Use navigatorKey.currentState instead of context to avoid using BuildContext across async gaps
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => _getToolScreen(tool),
      ),
      (route) => false, // Clear all previous routes
    );
  });
}

Widget _getToolScreen(ToolConfig tool) {
  switch (tool.id) {
    case 'textTemplate':
      return const TemplateListScreen();
    case 'randomTools':
      return const RandomToolsScreen();
    default:
      return const HomePage(); // Fallback to home
  }
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
          navigatorKey: navigatorKey,
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
  final GlobalKey<_ToolSelectionScreenState> _toolSelectionKey = GlobalKey();
  void _refreshToolSelection() {
    // Refresh the tool list first
    _toolSelectionKey.currentState?.refreshTools();
    // Reset the current selection
    setState(() {
      currentTool = null;
      selectedToolType = null;
      currentToolTitle = null;
    });
  }

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
                  key: _toolSelectionKey,
                  isDesktop: true,
                  selectedToolType: selectedToolType,
                  onToolVisibilityChanged: _refreshToolSelection,
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

class ToolSelectionScreen extends StatefulWidget {
  final bool isDesktop;
  final Function(Widget, String)? onToolSelected;
  final String? selectedToolType;
  final VoidCallback? onToolVisibilityChanged;

  const ToolSelectionScreen({
    super.key,
    this.isDesktop = false,
    this.onToolSelected,
    this.selectedToolType,
    this.onToolVisibilityChanged,
  });

  @override
  State<ToolSelectionScreen> createState() => _ToolSelectionScreenState();
}

class _ToolSelectionScreenState extends State<ToolSelectionScreen> {
  List<ToolConfig> _visibleTools = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadVisibleTools();
  }

  Future<void> _loadVisibleTools() async {
    final tools = await ToolVisibilityService.getVisibleToolsInOrder();
    setState(() {
      _visibleTools = tools;
      _loading = false;
    });
  }

  // Public method to refresh tools when called from outside
  void refreshTools() {
    setState(() {
      _loading = true;
    });
    _loadVisibleTools();
  }

  Widget _getToolWidget(ToolConfig config, AppLocalizations loc) {
    switch (config.id) {
      case 'textTemplate':
        return TemplateListScreen(
          isEmbedded: widget.isDesktop,
          onToolSelected: widget.onToolSelected,
        );
      case 'randomTools':
        return RandomToolsScreen(
          isEmbedded: widget.isDesktop,
          onToolSelected: widget.onToolSelected,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'description':
        return Icons.description;
      case 'casino':
        return Icons.casino;
      default:
        return Icons.extension;
    }
  }

  Color _getIconColor(String colorName) {
    switch (colorName) {
      case 'blue800':
        return Colors.blue.shade800;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getLocalizedName(BuildContext context, String nameKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (nameKey) {
      case 'textTemplateGen':
        return l10n.textTemplateGen;
      case 'random':
        return l10n.random;
      default:
        return nameKey;
    }
  }

  String _getLocalizedDesc(BuildContext context, String descKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (descKey) {
      case 'textTemplateGenDesc':
        return l10n.textTemplateGenDesc;
      case 'randomDesc':
        return l10n.randomDesc;
      default:
        return descKey;
    }
  }

  String _getSelectedToolType(ToolConfig config) {
    switch (config.id) {
      case 'textTemplate':
        return 'TemplateListScreen';
      case 'randomTools':
        return 'RandomToolsScreen';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check if no tools are visible
    if (_visibleTools.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.visibility_off,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                loc.allToolsHidden,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                loc.allToolsHiddenDesc,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Show visible tools
        ..._visibleTools.map((config) {
          return ToolCard(
            title: _getLocalizedName(context, config.nameKey),
            description: _getLocalizedDesc(context, config.descKey),
            icon: _getIconData(config.icon),
            iconColor: _getIconColor(config.iconColor),
            isSelected: widget.selectedToolType == _getSelectedToolType(config),
            onTap: () {
              final tool = _getToolWidget(config, loc);
              if (widget.isDesktop) {
                widget.onToolSelected
                    ?.call(tool, _getLocalizedName(context, config.nameKey));
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => tool,
                  ),
                );
              }
            },
          );
        }).toList(),

        // Settings tool - always visible
        const SizedBox(height: 32),
        ToolCard(
          title: loc.settings,
          description: loc.settings,
          icon: Icons.settings,
          iconColor: Colors.grey,
          isSelected: widget.selectedToolType == 'MainSettingsScreen',
          onTap: () {
            final tool = MainSettingsScreen(
              isEmbedded: widget.isDesktop,
              onToolVisibilityChanged: widget.onToolVisibilityChanged,
            );
            if (widget.isDesktop) {
              widget.onToolSelected?.call(tool, loc.settings);
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
