import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/widgets/tool_card.dart';
import 'screens/batch_video_detail_viewer.dart';
import 'screens/text_template_gen_list_screen.dart';
import 'screens/main_settings.dart';
import 'screens/random_tools_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLocale(Locale locale) {
    _locale = locale;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.title),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          // Sidebar chiếm 1/5, main chiếm 4/5, nhưng sidebar min 250, max 350
          double sidebarWidth = (totalWidth / 4).clamp(250, 400);
          return Row(
            children: [
              SizedBox(
                width: sidebarWidth,
                child: ToolSelectionScreen(
                  isDesktop: true,
                  onToolSelected: (Widget tool) {
                    setState(() {
                      currentTool = tool;
                    });
                  },
                ),
              ),
              SizedBox(
                width: totalWidth - sidebarWidth,
                child: currentTool ??
                    Center(
                      child: Text(AppLocalizations.of(context)!.selectTool),
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
  final Function(Widget)? onToolSelected;

  const ToolSelectionScreen({
    super.key,
    this.isDesktop = false,
    this.onToolSelected,
  });
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ToolCard(
          title: loc.batchVideoDetailViewer,
          description: loc.batchVideoDetailViewerDesc,
          icon: Icons.video_library,
          iconColor: Colors.red.shade700,
          onTap: () {
            const tool = BatchVideoDetailViewer();
            if (isDesktop) {
              onToolSelected?.call(tool);
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
          title: loc.textTemplateGen,
          description: loc.textTemplateGenDesc,
          icon: Icons.description,
          iconColor: Colors.blue.shade800,
          onTap: () {
            const tool = TemplateListScreen();
            if (isDesktop) {
              onToolSelected?.call(tool);
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
          onTap: () {
            const tool = RandomToolsScreen();
            if (isDesktop) {
              onToolSelected?.call(tool);
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
          onTap: () {
            const tool = MainSettingsScreen();
            if (isDesktop) {
              onToolSelected?.call(tool);
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
          ElevatedButton.icon(
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
        ],
      ),
    );
  }
}
