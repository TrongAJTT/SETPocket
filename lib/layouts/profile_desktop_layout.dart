import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/profile_tab_service.dart';
import 'package:setpocket/services/profile_breadcrumb_service.dart';
import 'package:setpocket/services/profile_widget_factory.dart';
import 'package:setpocket/utils/generic_settings_utils.dart';
import 'package:setpocket/widgets/navigation/profile_section.dart';
import 'package:setpocket/widgets/navigation/profile_tool_selection_screen.dart';
import 'package:setpocket/screens/routine_screen.dart';
import 'package:setpocket/screens/main_settings.dart';

/// Màn hình desktop mới với Profile Section và loại bỏ Settings khỏi sidebar
class ProfileDesktopLayout extends StatefulWidget {
  const ProfileDesktopLayout({super.key});

  @override
  State<ProfileDesktopLayout> createState() => _ProfileDesktopLayoutState();
}

class _ProfileDesktopLayoutState extends State<ProfileDesktopLayout>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeProfileService();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeProfileService() async {
    await ProfileTabService.instance.initialize();
    if (mounted) {
      setState(() {}); // Refresh UI sau khi initialize
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedBuilder(
          animation: ProfileTabService.instance,
          builder: (context, child) {
            return _buildAppBarTitle(context);
          },
        ),
        actions: [
          // Breadcrumb trong AppBar (chỉ hiển thị khi có breadcrumb)
          if (_shouldShowBreadcrumb())
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildCompactBreadcrumb(),
              ),
            ),

          // Tool-specific actions
          ..._buildToolActions(context),

          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
            tooltip: l10n.about,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: ProfileTabService.instance,
        builder: (context, child) {
          if (!ProfileTabService.instance.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildDesktopLayout();
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // Sidebar chiếm 1/4, main chiếm 3/4, nhưng sidebar min 280, max 380
        double sidebarWidth = (totalWidth / 4).clamp(280, 380);

        return Row(
          children: [
            // Sidebar với tool selection và profile section
            SizedBox(
              width: sidebarWidth,
              child: Column(
                children: [
                  // Tool selection area
                  Expanded(
                    child: ProfileToolSelectionScreen(
                      isEmbedded: true,
                      forTabIndex: ProfileTabService.instance.currentTabIndex,
                      onToolSelected: _handleToolSelected,
                    ),
                  ),

                  // Profile Section ở dưới cùng sidebar
                  ProfileSection(
                    onToolSelected: _handleToolSelected,
                    onRoutinePressed: _handleRoutinePressed,
                    onSettingsPressed: _handleSettingsPressed,
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMainContent() {
    final profileService = ProfileTabService.instance;

    // Xử lý các view khác nhau
    switch (profileService.currentView) {
      case ProfileView.routine:
        return const RoutineScreen();
      case ProfileView.settings:
        return const MainSettingsScreen();
      case ProfileView.profile:
        final currentTab = profileService.currentTab;

        if (currentTab == null) {
          return _buildWelcomeScreen();
        }

        // Nếu tab đang ở tool selection
        if (currentTab.toolId == 'tool_selection') {
          return _buildWelcomeScreen();
        }

        // Nếu tool widget của tab đang là Container() (tức là sau restart),
        // tái tạo widget từ toolId
        if (currentTab.toolWidget is Container &&
            (currentTab.toolWidget as Container).child == null) {
          final recreatedWidget = ProfileWidgetFactory.instance.recreateWidget(
            toolId: currentTab.toolId,
            isEmbedded: true,
            onToolSelected: _handleToolSelected,
            forTabIndex: profileService.currentTabIndex,
          );

          // Cập nhật tab với widget mới được tái tạo sau khi build hoàn thành
          WidgetsBinding.instance.addPostFrameCallback((_) {
            profileService.updateTabTool(
              tabIndex: profileService.currentTabIndex,
              toolId: currentTab.toolId,
              toolTitle: currentTab.toolTitle,
              icon: currentTab.icon,
              iconColor: currentTab.iconColor,
              toolWidget: recreatedWidget,
              parentCategory: currentTab.parentCategory,
            );
          });

          return ClipRect(child: recreatedWidget);
        }

        // Hiển thị tool widget của tab hiện tại
        return ClipRect(child: currentTab.toolWidget);
    }
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.selectTool,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.selectToolDesc,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  'Profile Tab ${ProfileTabService.instance.currentTabIndex + 1}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  'Select a tool from the sidebar to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleToolSelected(
    Widget tool,
    String title, {
    String? parentCategory,
    IconData? icon,
  }) {
    // Tool đã được cập nhật vào tab thông qua ProfileToolSelectionScreen
    // Chỉ cần trigger refresh UI
    setState(() {});
  }

  void _handleRoutinePressed() {
    // Hiển thị Routine screen trong main area
    ProfileTabService.instance.switchToRoutine();
    ProfileTabService.instance.updateTabTool(
      tabIndex: ProfileTabService.instance.routineTabIndex,
      toolId: 'routine',
      toolTitle: 'Routine Hub',
      icon: Icons.auto_awesome,
      iconColor: Colors.purple,
      toolWidget: const RoutineScreen(isEmbedded: true),
    );
  }

  void _handleSettingsPressed() {
    // Hiển thị Settings screen trong main area
    ProfileTabService.instance.switchToSettings();
    ProfileTabService.instance.updateTabTool(
      tabIndex: ProfileTabService.instance.settingsTabIndex,
      toolId: 'settings',
      toolTitle: 'Settings',
      icon: Icons.settings,
      iconColor: Colors.grey,
      toolWidget: MainSettingsScreen(
        isEmbedded: true,
        onToolVisibilityChanged: () {
          // Refresh tool selection khi visibility thay đổi
          setState(() {});
        },
      ),
    );
  }

  /// Build AppBar title với icon cho desktop
  Widget _buildAppBarTitle(BuildContext context) {
    final profileService = ProfileTabService.instance;
    final currentTab = profileService.currentTab;

    String title;
    IconData icon;
    Color iconColor;

    if (currentTab == null || currentTab.toolId == 'tool_selection') {
      title = AppLocalizations.of(context)!.title;
      icon = Icons.apps;
      iconColor = Colors.blue;
    } else {
      title = currentTab.toolTitle;
      icon = currentTab.icon;
      iconColor = currentTab.iconColor;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showAbout(BuildContext context) {
    GenericSettingsUtils.navigateAbout(context);
  }

  /// Build tool-specific actions
  List<Widget> _buildToolActions(BuildContext context) {
    // DISABLED: Không extract actions từ widgets nữa để tránh nút Save bị leak
    return [];
  }

  /// Kiểm tra xem có nên hiển thị breadcrumb không
  bool _shouldShowBreadcrumb() {
    final currentTab = ProfileTabService.instance.currentTab;
    return ProfileTabService.instance.currentView == ProfileView.profile &&
        currentTab != null &&
        (currentTab.toolId != 'tool_selection' ||
            ProfileBreadcrumbService.instance
                .getCurrentBreadcrumbs()
                .isNotEmpty);
  }

  /// Tạo compact breadcrumb cho AppBar
  Widget _buildCompactBreadcrumb() {
    return AnimatedBuilder(
      animation: ProfileBreadcrumbService.instance,
      builder: (context, child) {
        final breadcrumbs =
            ProfileBreadcrumbService.instance.getCurrentBreadcrumbs();

        if (breadcrumbs.isEmpty) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Back button
            if (ProfileBreadcrumbService.instance.canGoBack())
              IconButton(
                onPressed: () =>
                    ProfileBreadcrumbService.instance.popBreadcrumb(),
                icon: const Icon(Icons.arrow_back),
                iconSize: 18,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Back',
              ),

            // Breadcrumb path (chỉ hiển thị mục cuối cùng để tiết kiệm không gian)
            if (breadcrumbs.isNotEmpty)
              Flexible(
                child: Text(
                  breadcrumbs.length > 1
                      ? '${breadcrumbs[breadcrumbs.length - 2].title} > ${breadcrumbs.last.title}'
                      : breadcrumbs.last.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        );
      },
    );
  }
}
