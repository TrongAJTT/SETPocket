import 'package:flutter/material.dart';

/// Đơn giản navigation service cho mobile screens
/// Mỗi profile tab có stack riêng của nó
class MobileScreenNavigator {
  static final MobileScreenNavigator _instance = MobileScreenNavigator._();
  static MobileScreenNavigator get instance => _instance;
  MobileScreenNavigator._();

  // Navigation stacks cho 3 profile tabs
  final Map<int, List<Widget>> _tabStacks = {
    0: [],
    1: [],
    2: [],
  };

  // Current titles cho mỗi tab
  final Map<int, String> _tabTitles = {
    0: '',
    1: '',
    2: '',
  };

  // Callbacks để update UI
  VoidCallback? _onStackChanged;

  void registerUpdateCallback(VoidCallback callback) {
    _onStackChanged = callback;
  }

  void unregisterUpdateCallback() {
    _onStackChanged = null;
  }

  /// Push screen lên stack của tab hiện tại
  void pushScreen(int tabIndex, Widget screen, String title) {
    if (tabIndex < 0 || tabIndex > 2) return;

    _tabStacks[tabIndex]!.add(screen);
    _tabTitles[tabIndex] = title;
    print(
        '📱 MobileNavigator: Pushed "$title" to tab $tabIndex (stack: ${_tabStacks[tabIndex]!.length})');
    _onStackChanged?.call();
  }

  /// Pop screen từ stack của tab hiện tại
  bool popScreen(int tabIndex) {
    if (tabIndex < 0 || tabIndex > 2) return false;

    final stack = _tabStacks[tabIndex]!;
    if (stack.isEmpty) return false;

    stack.removeLast();

    // Update title
    if (stack.isEmpty) {
      _tabTitles[tabIndex] = '';
    } else {
      // Title sẽ được update bởi screen mới
    }

    print(
        '📱 MobileNavigator: Popped from tab $tabIndex (stack: ${stack.length})');
    _onStackChanged?.call();
    return true;
  }

  /// Clear stack của tab
  void clearTab(int tabIndex) {
    if (tabIndex < 0 || tabIndex > 2) return;

    _tabStacks[tabIndex]!.clear();
    _tabTitles[tabIndex] = '';
    print('📱 MobileNavigator: Cleared tab $tabIndex');
    _onStackChanged?.call();
  }

  /// Get current screen của tab
  Widget? getCurrentScreen(int tabIndex) {
    if (tabIndex < 0 || tabIndex > 2) return null;

    final stack = _tabStacks[tabIndex]!;
    return stack.isEmpty ? null : stack.last;
  }

  /// Get current title của tab
  String getCurrentTitle(int tabIndex) {
    if (tabIndex < 0 || tabIndex > 2) return '';
    return _tabTitles[tabIndex] ?? '';
  }

  /// Check if có thể back
  bool canPop(int tabIndex) {
    if (tabIndex < 0 || tabIndex > 2) return false;
    return _tabStacks[tabIndex]!.isNotEmpty;
  }

  /// Get stack depth
  int getStackDepth(int tabIndex) {
    if (tabIndex < 0 || tabIndex > 2) return 0;
    return _tabStacks[tabIndex]!.length;
  }
}
