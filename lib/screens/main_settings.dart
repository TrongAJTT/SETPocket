import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:setpocket/main.dart';

// Settings modules
import 'package:setpocket/widgets/settings/user_interface_settings.dart';
import 'package:setpocket/widgets/settings/tools_management_settings.dart';
import 'package:setpocket/widgets/settings/data_management_settings.dart';
import 'package:setpocket/widgets/settings/about_settings.dart';

// Layout components
import 'package:setpocket/layouts/section_sidebar_scrolling_layout.dart';
import 'package:setpocket/widgets/generic/section_item.dart';
import 'package:setpocket/screens/settings/single_section_display_screen.dart';

class MainSettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  final VoidCallback? onToolVisibilityChanged;
  final String? initialSectionId;
  final bool forceFullLayout;

  const MainSettingsScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolVisibilityChanged,
    this.initialSectionId,
    this.forceFullLayout = false,
  });

  @override
  State<MainSettingsScreen> createState() => _MainSettingsScreenState();
}

class _MainSettingsScreenState extends State<MainSettingsScreen> {
  late ThemeMode _themeMode = settingsController.themeMode;
  late String _language = settingsController.locale.languageCode;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loading) {
      _loadSettings();
    }
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

  void _handleMobileAppbar() {
    final loc = AppLocalizations.of(context)!;
    // Removed unified MobileAppBarController logic
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;

    if (_loading) {
      return widget.isEmbedded
          ? const Center(child: CircularProgressIndicator())
          : Scaffold(
              appBar: AppBar(title: Text(loc.settings)),
              body: const Center(child: CircularProgressIndicator()),
            );
    }

    // On mobile, show section selection screen first if not embedded and not forcing full layout
    if (!isDesktop &&
        !widget.isEmbedded &&
        widget.initialSectionId == null &&
        !widget.forceFullLayout) {
      // _handleMobileAppbar();
      return MobileSectionSelectionScreen(
        title: loc.settings,
        sections: _buildSections(loc),
        onSectionSelected: (sectionId) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SingleSectionDisplayScreen(
                sectionId: sectionId,
                sections: _buildSections(loc),
              ),
            ),
          );
        },
      );
    }

    // For single section display (mobile navigation)
    if (widget.initialSectionId != null) {
      // Hiển thị AppBar trên mobile khi vào từng section
      return Scaffold(
        appBar: AppBar(title: Text(loc.settings)),
        body: SingleSectionDisplayScreen(
          sectionId: widget.initialSectionId!,
          sections: _buildSections(loc),
        ),
      );
    }

    // Full layout for desktop hoặc embedded
    if (!isDesktop && !widget.isEmbedded) {
      // Mobile: bọc layout bằng Scaffold để có AppBar
      return Scaffold(
        appBar: AppBar(title: Text(loc.settings)),
        body: SectionSidebarScrollingLayout(
          title: null,
          isEmbedded: false,
          sections: _buildSections(loc),
          showViewToggle: true,
          onSectionChanged: (sectionId) {},
        ),
      );
    }
    // Desktop hoặc embedded: giữ nguyên
    return SectionSidebarScrollingLayout(
      title: widget.isEmbedded ? null : loc.settings,
      isEmbedded: widget.isEmbedded,
      sections: _buildSections(loc),
      showViewToggle: true,
      onSectionChanged: (sectionId) {},
    );
  }

  List<SectionItem> _buildSections(AppLocalizations loc) {
    return [
      // User Interface section
      SectionItem(
        id: 'interface',
        title: loc.userInterface,
        subtitle: 'Theme, language & display preferences',
        icon: Icons.palette_outlined,
        iconColor: Colors.blue.shade600,
        content: UserInterfaceSettings(
          initialThemeMode: _themeMode,
          initialLanguage: _language,
          onThemeChanged: _onThemeChanged,
          onLanguageChanged: _onLanguageChanged,
        ),
      ),

      // Tools Management section
      SectionItem(
        id: 'tools',
        title: loc.toolsShortcuts,
        subtitle: 'Configure tools visibility & quick actions',
        icon: Icons.build_outlined,
        iconColor: Colors.orange.shade600,
        content: ToolsManagementSettings(
          onToolVisibilityChanged: widget.onToolVisibilityChanged,
        ),
      ),

      // Data Management section
      SectionItem(
        id: 'data',
        title: loc.dataAndStorage,
        subtitle: 'Cache, logs & data retention settings',
        icon: Icons.storage_outlined,
        iconColor: Colors.green.shade600,
        content: const DataManagementSettings(
          initialLogRetentionDays:
              7, // Default value, will be loaded in the widget
        ),
      ),

      // About section
      SectionItem(
        id: 'about',
        title: loc.about,
        subtitle: 'App version & information',
        icon: Icons.info_outline,
        iconColor: Colors.grey.shade600,
        content: const AboutSettings(),
      ),
    ];
  }
}
