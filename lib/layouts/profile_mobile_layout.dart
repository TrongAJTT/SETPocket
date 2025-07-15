import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/profile_tab_service.dart';
import 'package:setpocket/services/profile_widget_factory.dart';
import 'package:setpocket/utils/generic_settings_utils.dart';
import 'package:setpocket/widgets/navigation/profile_bottom_nav_bar.dart';
import 'package:setpocket/widgets/navigation/profile_tool_selection_screen.dart';
import 'package:setpocket/widgets/navigation/tab_aware_page_view_stack.dart';
import 'package:setpocket/screens/routine_screen.dart';
import 'package:setpocket/screens/main_settings.dart';
import 'package:setpocket/widgets/mobile_appbar.dart';
import 'package:setpocket/variables.dart';
import 'package:setpocket/services/navigation_sync_service.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';
import 'package:setpocket/services/tab_navigation_state_manager.dart';
import 'package:setpocket/services/tab_page_stack_manager.dart';

/// Layout mobile với bottom navigation và profile tabs
class ProfileMobileLayout extends StatefulWidget {
  const ProfileMobileLayout({super.key});

  @override
  State<ProfileMobileLayout> createState() => _ProfileMobileLayoutState();
}

class _ProfileMobileLayoutState extends State<ProfileMobileLayout>
    with WidgetsBindingObserver {
  late final TabNavigationStateManager _tabStateManager;
  late final TabPageStackManager _stackManager;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabStateManager = TabNavigationStateManager.instance;
    _stackManager = TabPageStackManager.instance;

    _initializeServices();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeServices() async {
    // Load tab navigation states
    await _tabStateManager.loadState();

    // Initialize profile service
    await ProfileTabService.instance.initialize();

    // Initialize NavigationSyncService cho 3 profile tabs
    final navSync = NavigationSyncService();
    for (int i = 0; i < 3; i++) {
      final tabKey = 'tab_$i';
      navSync.initializeNavigation(tabKey, rootTitle: appName);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MobileAppBar(
        fallbackTitle: _getCurrentTitle(),
        // fallbackActions: ,
        onBackPressed: _handleBackNavigation, // Luôn provide callback
      ),
      body: AnimatedBuilder(
        animation: ProfileTabService.instance,
        builder: (context, child) {
          if (!ProfileTabService.instance.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildCurrentTabContent();
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: ProfileTabService.instance,
        builder: (context, child) {
          if (!ProfileTabService.instance.isInitialized) {
            return const SizedBox.shrink();
          }
          return ProfileBottomNavBar(
            currentIndex: ProfileTabService.instance.currentTabIndex,
            onTabChanged: _handleTabChanged,
            onRoutinePressed: _handleRoutinePressed,
            onSettingsPressed: _handleSettingsPressed,
          );
        },
      ),
    );
  }

  String _getCurrentTitle() {
    final profileService = ProfileTabService.instance;
    final currentTab = profileService.currentTab;

    if (currentTab == null || currentTab.toolId == 'tool_selection') {
      return appName;
    }

    return currentTab.toolTitle.isNotEmpty ? currentTab.toolTitle : appName;
  }

  List<Widget> _buildFallbackActions() {
    final l10n = AppLocalizations.of(context)!;

    return [
      IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () => GenericSettingsUtils.navigateAbout(context),
        tooltip: l10n.about,
      ),
    ];
  }

  void _handleBackNavigation() {
    final profileService = ProfileTabService.instance;
    final controller = MobileAppBarController();

    switch (profileService.currentView) {
      case ProfileView.routine:
      case ProfileView.settings:
        // Reset back button và quay về profile
        controller.setBackButton(false);
        profileService.setCurrentTab(profileService.currentTabIndex);
        break;
      case ProfileView.profile:
        final tabKey = 'tab_${profileService.currentTabIndex}';

        // Sync với NavigationSyncService
        final navSync = NavigationSyncService();
        final canNavPop = navSync.canPop(tabKey);

        final canPop = _stackManager.canPop(tabKey);

        if (canPop) {
          if (canNavPop) {
            navSync.popNavigation(tabKey);
          }
          _stackManager.popPage(tabKey);
        } else {
          profileService.resetTab(profileService.currentTabIndex);
          navSync.resetNavigation(tabKey);
          _tabStateManager.resetTab(tabKey);
          // controller.setAppBar(
          //     title: appName,
          //     showBackButton: false,
          //     actions: _buildFallbackActions());
        }
        break;
    }
  }

  Widget _buildCurrentTabContent() {
    final profileService = ProfileTabService.instance;

    switch (profileService.currentView) {
      case ProfileView.routine:
        return const RoutineScreen(isEmbedded: true);
      case ProfileView.settings:
        return const MainSettingsScreen(isEmbedded: false);
      case ProfileView.profile:
        return _buildProfileTabContent();
    }
  }

  Widget _buildProfileTabContent() {
    final profileService = ProfileTabService.instance;
    final currentTab = profileService.currentTab;

    if (currentTab == null) {
      return const Center(child: Text('Loading...'));
    }

    final tabKey = 'tab_${profileService.currentTabIndex}';
    debugPrint(
        '📱 ProfileMobileLayout: Building tab content for $tabKey, toolId=${currentTab.toolId}, title=${currentTab.toolTitle}');

    final toolSelectionScreen = ProfileToolSelectionScreen(
      isEmbedded: true, // Revert: Should be true for proper callback navigation
      forTabIndex: profileService.currentTabIndex,
      onToolSelected: _handleToolSelected,
    );

    if (currentTab.toolId == 'tool_selection') {
      debugPrint('📱 ProfileMobileLayout: Tab $tabKey at tool selection');
      return TabAwarePageViewStack(
        tabKey: tabKey,
        initialPage: toolSelectionScreen,
        onBackToRoot: () {
          debugPrint('📚 Already at root (tool selection)');
        },
      );
    }

    Widget toolWidget = currentTab.toolWidget;
    debugPrint(
        '📱 ProfileMobileLayout: Tab $tabKey has tool widget: ${toolWidget.runtimeType}');

    // Tái tạo widget nếu cần thiết
    if (currentTab.toolWidget is Container &&
        (currentTab.toolWidget as Container).child == null) {
      final recreatedWidget = ProfileWidgetFactory.instance.recreateWidget(
        toolId: currentTab.toolId,
        isEmbedded: true,
        onToolSelected: _handleToolSelected,
        forTabIndex: profileService.currentTabIndex,
      );

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

      toolWidget = recreatedWidget;
    }

    final tabPageViewStack = TabAwarePageViewStack(
      tabKey: tabKey,
      initialPage: toolSelectionScreen,
      onBackToRoot: () {
        profileService.resetTab(profileService.currentTabIndex);
      },
    );

    if (currentTab.toolId != 'tool_selection') {
      debugPrint(
          '📱 ProfileMobileLayout: Tab $tabKey - pushing tool widget to stack');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stackManager.pushPage(tabKey, toolWidget);
      });
    }

    return tabPageViewStack;
  }

  void _handleTabChanged(int index) {
    debugPrint('📱 ProfileMobileLayout: Tab changed to $index');

    // Switch to new tab and restore its state
    final tabKey = 'tab_$index';

    // Update tab navigation state manager
    _tabStateManager.setCurrentTab(tabKey);

    // Switch AppBar controller context to new tab
    final controller = MobileAppBarController();
    controller.setCurrentTab(tabKey);

    // Update ProfileTabService
    ProfileTabService.instance.setCurrentTab(index);

    // Restore tab state from TabNavigationStateManager
    final tabState = _tabStateManager.getTabState(tabKey);

    // Debug: Log current tab state after switch
    final currentTab = ProfileTabService.instance.currentTab;
    debugPrint(
        '📱 ProfileMobileLayout: After switch - Tab $index state: toolId=${currentTab?.toolId}, title=${currentTab?.toolTitle}');
    debugPrint('📱 TabNavigationState: $tabState');

    // Sync back button and AppBar state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncTabState(tabKey);
    });
  }

  void _syncTabState(String tabKey) {
    final stackSize = _stackManager.getStackSize(tabKey);
    final controller = MobileAppBarController();
    final tabState = _tabStateManager.getTabState(tabKey);

    // Update AppBar from saved state
    if (tabState.appBarTitle != appName) {
      controller.setAppBar(
        title: tabState.appBarTitle,
        showBackButton: tabState.showBackButton,
      );
    } else {
      controller.setBackButton(stackSize > 1);
    }

    debugPrint(
        '📱 ProfileMobileLayout: Synced tab state for $tabKey - stack: $stackSize, title: "${tabState.appBarTitle}", back: ${tabState.showBackButton}');
  }

  void _handleToolSelected(
    Widget tool,
    String title, {
    String? parentCategory,
    IconData? icon,
  }) {
    final profileService = ProfileTabService.instance;
    final tabKey = 'tab_${profileService.currentTabIndex}';

    // Sync với NavigationSyncService
    final navSync = NavigationSyncService();
    navSync.pushNavigation(
      tabKey,
      NavigationItem(
        id: 'tool_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        actions: [],
        isSubTool: parentCategory != null,
      ),
    );

    // Kiểm tra stack size trước khi push
    final currentStackSize = _stackManager.getStackSize(tabKey);
    debugPrint(
        '📚 ProfileMobileLayout: Before push - Stack size: $currentStackSize');

    // Chỉ push nếu stack size hợp lý (< 5)
    if (currentStackSize < 5) {
      _stackManager.pushPage(tabKey, tool);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        profileService.updateTabTool(
          tabIndex: profileService.currentTabIndex,
          toolId: 'custom_tool',
          toolTitle: title,
          icon: icon ?? Icons.build,
          iconColor: Colors.blue,
          toolWidget: tool,
          parentCategory: parentCategory,
        );
      });
    } else {
      debugPrint(
          '📚 ProfileMobileLayout: Stack size too large ($currentStackSize), resetting');
      // Reset stack về initial page và push lại
      _stackManager.resetToInitial(tabKey);
      navSync.resetNavigation(tabKey);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _stackManager.pushPage(tabKey, tool);
        navSync.pushNavigation(
          tabKey,
          NavigationItem(
            id: 'tool_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            actions: [],
            isSubTool: parentCategory != null,
          ),
        );
        profileService.updateTabTool(
          tabIndex: profileService.currentTabIndex,
          toolId: 'custom_tool',
          toolTitle: title,
          icon: icon ?? Icons.build,
          iconColor: Colors.blue,
          toolWidget: tool,
          parentCategory: parentCategory,
        );
      });
    }
  }

  void _handleRoutinePressed() {
    final controller = MobileAppBarController();
    controller.setBackButton(true);
    ProfileTabService.instance.switchToRoutine();
  }

  void _handleSettingsPressed() {
    final l10n = AppLocalizations.of(context)!;
    final controller = MobileAppBarController();
    controller.setBackButton(false);
    controller.setAppBar(title: l10n.settings, showBackButton: false);
    ProfileTabService.instance.switchToSettings();
  }
}
