import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/hive_service.dart';
import 'package:setpocket/services/isar_service.dart';
import 'package:setpocket/services/converter_services/converter_tools_data_service.dart';
import 'package:setpocket/services/profile_tab_service.dart';
import 'package:setpocket/services/settings_models_service.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/number_format_service.dart';
import 'package:setpocket/services/app_installation_service.dart';
import 'package:setpocket/services/quick_actions_service.dart';
import 'package:setpocket/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:setpocket/layouts/profile_mobile_layout.dart';
import 'package:setpocket/layouts/profile_desktop_layout.dart';
import 'package:flutter/services.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';
import 'package:setpocket/services/app_cleanup_service.dart';

// Global navigation key for deep linking
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// --- Workmanager Setup ---
@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // This background task is a simple keep-alive.
    // Its purpose is just to wake the app up periodically to prevent the OS
    // from completely killing the process, allowing P2P timers to continue.
    //
    // Note: We check for silentMode to ensure no notifications are shown

    try {
      final now = DateTime.now();
      final taskInfo = 'Task: $task, Input: $inputData';
      final silentMode = inputData?['silentMode'] ?? true;
      final showNotification = inputData?['showNotification'] ?? false;

      // Only log the execution - no notifications unless explicitly requested
      if (!silentMode || showNotification) {
        logInfo('📱 Background KeepAlive: $taskInfo at $now');
      }

      // Perform minimal work - just prove the app is alive
      // No network calls, no heavy processing, just a simple heartbeat

      if (!silentMode) {
        logInfo('✅ Background KeepAlive completed successfully');
      }
      return Future.value(true);
    } catch (e) {
      // Always log errors regardless of silent mode
      logInfo('❌ Background KeepAlive failed: $e');
      return Future.value(false);
    }
  });
}
// --- End Workmanager Setup ---

// Global flag to track first time setup
bool _isFirstTimeSetup = false;

class BreadcrumbData {
  final String title;
  final String toolType;
  final Widget? tool;
  final IconData? icon;

  const BreadcrumbData({
    required this.title,
    required this.toolType,
    this.tool,
    this.icon,
  });
}

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize workmanager for background tasks on mobile platforms
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode:
            false, // Always disable debug mode to prevent notifications
      );
      logInfo('WorkManager initialized successfully (notifications disabled)');
    } catch (e) {
      logError('Failed to initialize WorkManager: $e');
    }
  }

  // Setup window manager for desktop platforms
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux)) {
    await windowManager.ensureInitialized();
    // Don't prevent close - just trigger emergency save
    await windowManager.setPreventClose(false);
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Reduce accessibility tree errors on Windows debug builds
  if (kDebugMode && defaultTargetPlatform == TargetPlatform.windows) {
    // Disable semantic debugging to reduce accessibility bridge errors
    WidgetsBinding.instance.ensureSemantics();
  }

  // Initialize core databases first
  try {
    logInfo('Initializing databases...');

    // Initialize Hive database first (needed for migration)
    await HiveService.initialize();
    logInfo('Hive initialized');

    // Initialize Isar database
    await IsarService.init();
    logInfo('Isar initialized');

    // Clean up expired drafts and deleted templates
    await AppCleanupService.cleanStartUp();
    logInfo('AppCleanupService cleanStartUp completed');

    // Wait a bit to ensure Isar is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));

    // Initialize ConverterToolsDataService
    final converterDataService = ConverterToolsDataService();
    await converterDataService.initialize();
    logInfo('ConverterToolsDataService initialized');

    // Initialize App Installation Service immediately after Isar
    _isFirstTimeSetup = await AppInstallationService.instance.initialize();
    logInfo(
        'AppInstallationService initialized, first time setup: $_isFirstTimeSetup');

    // These services no longer have an init() method or are initialized elsewhere
    // await TemplateService.init();
    // await UnifiedRandomStateService.init();
  } catch (e) {
    // Log the error but don't crash the app
    logError('Error during database initialization', e);
    _isFirstTimeSetup = true; // Assume first time setup on error
  }

  // Initialize other services in background after UI starts
  _initializeServicesInBackground();

  // Đảm bảo khởi tạo tabs trước khi build UI
  await ProfileTabService.instance.initialize();

  runApp(const MainApp());
}

// Initialize non-critical services in background
void _initializeServicesInBackground() {
  Future.microtask(() async {
    try {
      logDebug('Initializing background services...');

      // Initialize settings service
      await ExtensibleSettingsService.initialize();
      logDebug('ExtensibleSettingsService initialized');

      // Initialize AppLogger service (depends on settings)
      await AppLogger.instance.initialize();
      logDebug('AppLogger initialized');

      // UnifiedRandomStateService is initialized on demand now
      // await UnifiedRandomStateService.initialize();

      // GraphingCalculatorService is no longer a separate service
      // await GraphingCalculatorService.initialize();

      // Initialize settings controller and load saved settings
      await settingsController.loadSettings();
      logDebug('Settings loaded');

      // Initialize quick actions
      await _initializeQuickActions();
      logDebug('Quick actions initialized');

      logInfo('All background services initialized successfully');
    } catch (e) {
      // Log initialization errors but continue
      logError('Error during background service initialization', e);
    }
  });
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
  // This function is no longer needed with the new profile tab system
  // Navigation is handled by ProfileTabService
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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // ...
    } else if (state == AppLifecycleState.paused) {
      // ...
    } else if (state == AppLifecycleState.detached &&
        (Platform.isAndroid || Platform.isIOS)) {
      // P2P service logic was here, now removed.
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, _) {
        // Initialize number formatting with current locale
        NumberFormatService.initialize(settingsController.locale);

        return MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blueAccent,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
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
          routes: const {
            // Routes removed - navigation handled by profile tabs
          },
          navigatorObservers: [
            NavigatorObserver(),
          ],
          builder: (context, child) {
            // Set navigation context for P2P services
            // P2PNavigationService.instance.setContext(context);
            return child!;
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    // Show first time setup snackbar if needed
    if (_isFirstTimeSetup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFirstTimeSetupSnackbar();
      });
    }
  }

  void _showFirstTimeSetupSnackbar() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.construction, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'TODO: Installation progress - Setting up your new installation...',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[700],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Log for debugging
    logInfo(
        'First time setup detected - showed installation progress snackbar');
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    // Trigger emergency save before window closes
    await _clearAllDrafts();

    // Send emergency disconnect signals
    await _sendEmergencyP2PDisconnect();

    // Allow window to close
    await windowManager.destroy();
  }

  Future<void> _sendEmergencyP2PDisconnect() async {
    // This method is no longer needed as P2PService is removed/refactored.
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is less than 600, we consider it mobile layout
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return const ProfileMobileLayout();
        } else {
          return const ProfileDesktopLayout();
        }
      },
    );
  }
}

// Old layouts removed - now using ProfileMobileLayout and ProfileDesktopLayout

Future<void> _clearAllDrafts() async {
  // Clearing drafts is no longer necessary as they are part of the main text template data
  // with a 'draft' status. This can be handled by the TemplateService if needed.
}
