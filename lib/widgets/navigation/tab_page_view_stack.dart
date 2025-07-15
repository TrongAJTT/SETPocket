import 'package:flutter/material.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';
import 'package:setpocket/services/profile_tab_service.dart';

/// Stack-based navigation cho từng profile tab
/// Cho phép navigate trong tab mà không ảnh hưởng đến tab khác
class TabPageViewStack extends StatefulWidget {
  final Widget initialPage;
  final String tabKey; // Unique key cho mỗi tab
  final VoidCallback? onBackToRoot; // Callback khi back về root

  const TabPageViewStack({
    super.key,
    required this.initialPage,
    required this.tabKey,
    this.onBackToRoot,
  });

  @override
  State<TabPageViewStack> createState() => _TabPageViewStackState();

  /// Push page vào stack của tab này (chỉ push nếu khác page hiện tại)
  static void pushPage(BuildContext context, Widget page, String tabKey) {
    final stackState = _findStackState(context, tabKey);
    if (stackState != null) {
      // Kiểm tra xem page mới có giống page hiện tại không
      if (stackState._pageStack.isNotEmpty) {
        final currentPage = stackState._pageStack.last;
        // So sánh runtime type để tránh push duplicate cùng loại page
        if (currentPage.runtimeType == page.runtimeType) {
          debugPrint(
              '📚 TabPageViewStack[$tabKey]: Same page type already on top, not pushing');
          return;
        }
      }

      stackState._pushPage(page);
      debugPrint(
          '📚 TabPageViewStack[$tabKey]: Pushed page (${page.runtimeType}), stack size: ${stackState._pageStack.length}');
    }
  }

  /// Push page mà không kiểm tra duplicate (force push)
  static void forcePushPage(BuildContext context, Widget page, String tabKey) {
    final stackState = _findStackState(context, tabKey);
    if (stackState != null) {
      stackState._pushPage(page);
      debugPrint(
          '📚 TabPageViewStack[$tabKey]: Force pushed page, stack size: ${stackState._pageStack.length}');
    }
  }

  /// Pop page khỏi stack của tab này
  static bool popPage(BuildContext context, String tabKey) {
    final stackState = _findStackState(context, tabKey);
    if (stackState != null) {
      final popped = stackState._popPage();
      debugPrint(
          '📚 TabPageViewStack[$tabKey]: Pop page, success: $popped, stack size: ${stackState._pageStack.length}');
      return popped;
    }
    return false;
  }

  /// Reset về initial page
  static void resetToInitial(BuildContext context, String tabKey) {
    final stackState = _findStackState(context, tabKey);
    if (stackState != null) {
      stackState._resetToInitial();
      debugPrint('📚 TabPageViewStack[$tabKey]: Reset to initial page');
    }
  }

  /// Get current stack size
  static int getStackSize(BuildContext context, String tabKey) {
    final stackState = _findStackState(context, tabKey);
    return stackState?._pageStack.length ?? 0;
  }

  /// Check if có thể back được
  static bool canPop(BuildContext context, String tabKey) {
    final stackState = _findStackState(context, tabKey);
    return (stackState?._pageStack.length ?? 0) > 1;
  }

  /// Tìm stack state theo tabKey - simplified version
  static _TabPageViewStackState? _findStackState(
      BuildContext context, String tabKey) {
    _TabPageViewStackState? result;

    void visitor(Element element) {
      if (result != null) return; // Early exit khi đã tìm thấy

      if (element.widget is TabPageViewStack) {
        final stack = element.widget as TabPageViewStack;
        if (stack.tabKey == tabKey && element is StatefulElement) {
          final state = element.state;
          if (state is _TabPageViewStackState) {
            result = state;
            return;
          }
        }
      }
      element.visitChildren(visitor);
    }

    // Tìm từ current context thay vì root để tránh traverse quá nhiều
    try {
      context.visitChildElements(visitor);
    } catch (e) {
      debugPrint('📚 TabPageViewStack: Error finding stack state: $e');
    }

    return result;
  }
}

class _TabPageViewStackState extends State<TabPageViewStack> {
  final List<Widget> _pageStack = [];

  @override
  void initState() {
    super.initState();
    _pageStack.add(widget.initialPage);

    // Initial state - hide back button since we're at root
    final controller = MobileAppBarController();
    controller.setBackButton(false);
    debugPrint(
        '📚 TabPageViewStack[${widget.tabKey}]: Initialized with initial page, back button: false');
  }

  void _pushPage(Widget page) {
    if (mounted) {
      setState(() {
        _pageStack.add(page);
      });

      // Update back button state - show back button if stack > 1
      final controller = MobileAppBarController();
      controller.setBackButton(_pageStack.length > 1);
      debugPrint(
          '📚 TabPageViewStack[${widget.tabKey}]: Pushed page, stack size: ${_pageStack.length}, back button: ${_pageStack.length > 1}');
    }
  }

  bool _popPage() {
    if (_pageStack.length > 1) {
      if (mounted) {
        setState(() {
          _pageStack.removeLast();
        });

        // Update back button state after pop
        final controller = MobileAppBarController();
        controller.setBackButton(_pageStack.length > 1);

        // Reset title về appName khi stack về 1 (chỉ còn initial page)
        if (_pageStack.length == 1) {
          controller.clear();
          debugPrint(
              '📚 TabPageViewStack[${widget.tabKey}]: Reset to root, cleared MobileAppBar');
        } else {
          debugPrint(
              '📚 TabPageViewStack[${widget.tabKey}]: Popped page, stack size: ${_pageStack.length}, back button: ${_pageStack.length > 1}');
        }
      }
      return true;
    }
    return false;
  }

  void _resetToInitial() {
    if (mounted) {
      setState(() {
        _pageStack.clear();
        _pageStack.add(widget.initialPage);
      });

      // Reset back button state - hide when at root
      final controller = MobileAppBarController();
      controller.setBackButton(false);
      controller.clear();
      debugPrint(
          '📚 TabPageViewStack[${widget.tabKey}]: Reset to initial, cleared MobileAppBar');
    }
  }

  void _onWillPop() {
    // Nếu có nhiều hơn 1 page trong stack, pop page
    if (_pageStack.length > 1) {
      _popPage();
      return;
    }

    // Nếu chỉ có 1 page (root), gọi callback
    if (widget.onBackToRoot != null) {
      widget.onBackToRoot!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: IndexedStack(
        index: _pageStack.length - 1,
        children: _pageStack,
      ),
    );
  }
}
