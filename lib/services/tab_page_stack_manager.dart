import 'package:flutter/material.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';
import 'package:setpocket/services/tab_navigation_state_manager.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/variables.dart';

/// Quản lý widget stack riêng biệt cho từng tab
class TabPageStackManager extends ChangeNotifier {
  static TabPageStackManager? _instance;
  static TabPageStackManager get instance {
    _instance ??= TabPageStackManager._();
    return _instance!;
  }

  TabPageStackManager._();

  // Per-tab widget stacks
  final Map<String, List<Widget>> _tabStacks = {};
  final Map<String, Widget> _tabInitialPages = {};

  /// Get or create stack for tab
  List<Widget> getTabStack(String tabKey) {
    return _tabStacks[tabKey] ??= [];
  }

  /// Set initial page for tab
  void setInitialPage(String tabKey, Widget initialPage) {
    _tabInitialPages[tabKey] = initialPage;

    // Initialize stack with initial page if empty
    final stack = getTabStack(tabKey);
    if (stack.isEmpty) {
      stack.add(initialPage);
      logDebug('TabPageStackManager: Set initial page for $tabKey');
    }
  }

  /// Push page to tab stack
  void pushPage(String tabKey, Widget page) {
    final stack = getTabStack(tabKey);

    // Check for duplicate page types
    if (stack.isNotEmpty) {
      final currentPage = stack.last;
      if (currentPage.runtimeType == page.runtimeType) {
        logDebug(
            'TabPageStackManager: Same page type already on top for $tabKey, not pushing');
        return;
      }
    }

    stack.add(page);
    _updateTabState(tabKey);
    notifyListeners();
    logInfo(
        'TabPageStackManager: Pushed page (${page.runtimeType}) to $tabKey, stack size: ${stack.length}');
  }

  /// Force push page (ignore duplicates)
  void forcePushPage(String tabKey, Widget page) {
    final stack = getTabStack(tabKey);
    stack.add(page);
    _updateTabState(tabKey);
    notifyListeners();
    logInfo(
        'TabPageStackManager: Force pushed page to $tabKey, stack size: ${stack.length}');
  }

  /// Pop page from tab stack
  bool popPage(String tabKey) {
    final stack = getTabStack(tabKey);

    if (stack.length > 1) {
      stack.removeLast();
      _updateTabState(tabKey);
      notifyListeners();
      logInfo(
          'TabPageStackManager: Popped page from $tabKey, stack size: ${stack.length}');
      return true;
    }

    return false;
  }

  /// Reset tab to initial page
  void resetToInitial(String tabKey) {
    final initialPage = _tabInitialPages[tabKey];
    if (initialPage != null) {
      final stack = getTabStack(tabKey);
      stack.clear();
      stack.add(initialPage);
      _updateTabState(tabKey);
      notifyListeners();
      logInfo('TabPageStackManager: Reset $tabKey to initial page');
    }
  }

  /// Get current page for tab
  Widget? getCurrentPage(String tabKey) {
    final stack = getTabStack(tabKey);
    return stack.isNotEmpty ? stack.last : null;
  }

  /// Get stack size for tab
  int getStackSize(String tabKey) {
    return getTabStack(tabKey).length;
  }

  /// Check if tab can pop
  bool canPop(String tabKey) {
    return getTabStack(tabKey).length > 1;
  }

  /// Clear all tab stacks
  void clearAllStacks() {
    _tabStacks.clear();
    _tabInitialPages.clear();
    logInfo('TabPageStackManager: Cleared all stacks');
  }

  /// Clear specific tab stack
  void clearTabStack(String tabKey) {
    _tabStacks.remove(tabKey);
    _tabInitialPages.remove(tabKey);
    logInfo('TabPageStackManager: Cleared stack for $tabKey');
  }

  /// Update tab navigation state based on stack
  void _updateTabState(String tabKey) {
    final stackSize = getStackSize(tabKey);
    final stateManager = TabNavigationStateManager.instance;
    final tabState = stateManager.getTabState(tabKey);

    // Update back button state
    tabState.showBackButton = stackSize > 1;

    // Update AppBar controller for current tab
    final controller = MobileAppBarController();
    controller.setCurrentTab(tabKey);
    controller.setBackButton(stackSize > 1);

    // If at root, clear AppBar title
    if (stackSize <= 1) {
      tabState.appBarTitle = appName;
      controller.setAppBar(title: appName, showBackButton: false);
    }

    // Save state
    stateManager.saveState();

    logDebug(
        'TabPageStackManager: Updated state for $tabKey - stack: $stackSize, back: ${stackSize > 1}');
  }

  /// Get debug information
  Map<String, dynamic> getDebugInfo() {
    return {
      'tabStacks': _tabStacks.map((key, stack) => MapEntry(key, {
            'size': stack.length,
            'pages': stack.map((page) => page.runtimeType.toString()).toList(),
          })),
      'initialPages': _tabInitialPages
          .map((key, page) => MapEntry(key, page.runtimeType.toString())),
    };
  }
}
