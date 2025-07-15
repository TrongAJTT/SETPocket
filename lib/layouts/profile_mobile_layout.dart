import 'package:flutter/material.dart';
import 'package:setpocket/services/profile_tab_service.dart';
import 'package:setpocket/services/profile_widget_factory.dart';
import 'package:setpocket/widgets/navigation/profile_bottom_nav_bar.dart';
import 'package:setpocket/widgets/navigation/profile_tool_selection_screen.dart';
import 'package:setpocket/screens/routine_screen.dart';
import 'package:setpocket/screens/main_settings.dart';

/// Layout mobile với bottom navigation và profile tabs
class ProfileMobileLayout extends StatefulWidget {
  const ProfileMobileLayout({super.key});

  @override
  State<ProfileMobileLayout> createState() => _ProfileMobileLayoutState();
}

class _ProfileMobileLayoutState extends State<ProfileMobileLayout>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Timeout: nếu sau 5s tabs vẫn chưa đủ thì báo lỗi
    // Error fallback for tab loading is now handled in the UI (IndexedStack).
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Nested Navigator keys for each tab (5 tabs for mobile)
  final List<GlobalKey<NavigatorState>> _tabNavigatorKeys =
      List.generate(5, (_) => GlobalKey<NavigatorState>());

  Widget _buildTabNavigator(int tabIndex) {
    final profileService = ProfileTabService.instance;
    final currentTab = profileService.tabs[tabIndex];
    return Navigator(
      key: _tabNavigatorKeys[tabIndex],
      onGenerateRoute: (settings) {
        // Root route: tool selection hoặc tool hiện tại
        if (currentTab.toolId == 'tool_selection') {
          return MaterialPageRoute(
            builder: (context) => ProfileToolSelectionScreen(
              isEmbedded: false,
              forTabIndex: tabIndex,
              onToolSelected: (tool, title, {parentCategory, icon}) {
                _handleTabPush(tabIndex, tool, title,
                    parentCategory: parentCategory, icon: icon);
              },
            ),
          );
        } else {
          Widget toolWidget = currentTab.toolWidget;
          if (toolWidget is Container && toolWidget.child == null) {
            toolWidget = ProfileWidgetFactory.instance.recreateWidget(
              toolId: currentTab.toolId,
              isEmbedded: false,
              onToolSelected: (tool, title, {parentCategory, icon}) {
                _handleTabPush(tabIndex, tool, title,
                    parentCategory: parentCategory, icon: icon);
              },
              forTabIndex: tabIndex,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                profileService.updateTabTool(
                  tabIndex: tabIndex,
                  toolId: currentTab.toolId,
                  toolTitle: currentTab.toolTitle,
                  icon: currentTab.icon,
                  iconColor: currentTab.iconColor,
                  toolWidget: toolWidget,
                  parentCategory: currentTab.parentCategory,
                );
              }
            });
          }
          return MaterialPageRoute(builder: (context) => toolWidget);
        }
      },
    );
  }

  void _handleTabPush(int tabIndex, Widget tool, String title,
      {String? parentCategory, IconData? icon}) {
    _tabNavigatorKeys[tabIndex].currentState?.push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              // appBar: AppBar(title: Text(title)),
              body: tool,
            ),
          ),
        );
  }

  // _handleToolSelected is now unused and removed. Tool selection is handled per tab via _handleTabPush.

  void _handleRoutinePressed() {
    ProfileTabService.instance.switchToRoutine();
    setState(() {});
  }

  void _handleSettingsPressed() {
    ProfileTabService.instance.switchToSettings();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profileService = ProfileTabService.instance;
    return Scaffold(
      body: IndexedStack(
        index: profileService.currentView == ProfileView.profile
            ? profileService.currentTabIndex
            : profileService.currentView == ProfileView.routine
                ? 3
                : 4,
        children: List.generate(5, (tabIndex) {
          if (tabIndex < profileService.tabs.length) {
            return _buildTabNavigator(tabIndex);
          } else if (tabIndex == 3) {
            return const RoutineScreen();
          } else if (tabIndex == 4) {
            return const MainSettingsScreen();
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }),
      ),
      bottomNavigationBar: ProfileBottomNavBar(
        currentIndex: profileService.currentView == ProfileView.profile
            ? profileService.currentTabIndex
            : profileService.currentView == ProfileView.routine
                ? 3
                : 4,
        onTabChanged: (index) {
          if (index == 3) {
            _handleRoutinePressed();
          } else if (index == 4) {
            _handleSettingsPressed();
          } else {
            profileService.setCurrentTab(index);
            setState(() {});
          }
        },
        onRoutinePressed: _handleRoutinePressed,
        onSettingsPressed: _handleSettingsPressed,
      ),
    );
  }
}
