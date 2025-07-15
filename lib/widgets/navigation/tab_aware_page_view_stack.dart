import 'package:flutter/material.dart';
import 'package:setpocket/services/tab_page_stack_manager.dart';
import 'package:setpocket/services/tab_navigation_state_manager.dart';
import 'package:setpocket/services/app_logger.dart';

/// Tab-aware PageView Stack với state isolation hoàn toàn
class TabAwarePageViewStack extends StatefulWidget {
  final Widget initialPage;
  final String tabKey;
  final VoidCallback? onBackToRoot;

  const TabAwarePageViewStack({
    super.key,
    required this.initialPage,
    required this.tabKey,
    this.onBackToRoot,
  });

  @override
  State<TabAwarePageViewStack> createState() => _TabAwarePageViewStackState();

  /// Push page to specific tab
  static void pushPage(String tabKey, Widget page) {
    TabPageStackManager.instance.pushPage(tabKey, page);
  }

  /// Force push page to specific tab
  static void forcePushPage(String tabKey, Widget page) {
    TabPageStackManager.instance.forcePushPage(tabKey, page);
  }

  /// Pop page from specific tab
  static bool popPage(String tabKey) {
    return TabPageStackManager.instance.popPage(tabKey);
  }

  /// Reset tab to initial
  static void resetToInitial(String tabKey) {
    TabPageStackManager.instance.resetToInitial(tabKey);
  }

  /// Get stack size for tab
  static int getStackSize(String tabKey) {
    return TabPageStackManager.instance.getStackSize(tabKey);
  }

  /// Check if tab can pop
  static bool canPop(String tabKey) {
    return TabPageStackManager.instance.canPop(tabKey);
  }
}

class _TabAwarePageViewStackState extends State<TabAwarePageViewStack> with AutomaticKeepAliveClientMixin {
  late final TabPageStackManager _stackManager;
  late final TabNavigationStateManager _stateManager;

  @override
  void initState() {
    super.initState();
    _stackManager = TabPageStackManager.instance;
    _stateManager = TabNavigationStateManager.instance;

    // Set initial page for this tab
    _stackManager.setInitialPage(widget.tabKey, widget.initialPage);

    // Set current tab context
    _stateManager.setCurrentTab(widget.tabKey);

    logInfo('TabAwarePageViewStack[${widget.tabKey}]: Initialized');
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: Listenable.merge([_stateManager, _stackManager]),
      builder: (context, child) {
        final stack = _stackManager.getTabStack(widget.tabKey);

        if (stack.isEmpty) {
          // Fallback to initial page if stack is empty
          return widget.initialPage;
        }

        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (!didPop) {
              _handleWillPop();
            }
          },
          child: IndexedStack(
            index: stack.length - 1,
            children: stack,
          ),
        );
      },
    );
  }

  void _handleWillPop() {
    final canPop = _stackManager.canPop(widget.tabKey);

    if (canPop) {
      _stackManager.popPage(widget.tabKey);

      // Update navigation state
      final tabState = _stateManager.getTabState(widget.tabKey);
      tabState.popNavigation();

      logInfo('TabAwarePageViewStack[${widget.tabKey}]: Popped page');
    } else {
      // At root, call callback
      if (widget.onBackToRoot != null) {
        widget.onBackToRoot!();
      }
      logInfo(
          'TabAwarePageViewStack[${widget.tabKey}]: At root, called onBackToRoot');
    }
  }

  @override
  void dispose() {
    logInfo('TabAwarePageViewStack[${widget.tabKey}]: Disposed');
    super.dispose();
  }
}
