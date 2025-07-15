import 'package:flutter/material.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';
import 'package:setpocket/variables.dart';

/// Service quản lý navigation chung cho cả desktop và mobile
/// Đồng bộ breadcrumb navigation trên desktop với TabPageViewStack trên mobile
class NavigationSyncService extends ChangeNotifier {
  static final NavigationSyncService _instance =
      NavigationSyncService._internal();
  factory NavigationSyncService() => _instance;
  NavigationSyncService._internal();

  /// Navigation stack cho mỗi tab
  final Map<String, List<NavigationItem>> _navigationStacks = {};

  /// Get current navigation stack cho tab
  List<NavigationItem> getNavigationStack(String tabKey) {
    return _navigationStacks[tabKey] ?? [];
  }

  /// Push navigation item vào stack
  void pushNavigation(String tabKey, NavigationItem item) {
    if (!_navigationStacks.containsKey(tabKey)) {
      _navigationStacks[tabKey] = [];
    }

    final stack = _navigationStacks[tabKey]!;

    // Kiểm tra duplicate
    if (stack.isNotEmpty && stack.last.id == item.id) {
      debugPrint(
          '🔄 NavigationSync[$tabKey]: Duplicate navigation item, skipping');
      return;
    }

    stack.add(item);
    _syncWithServices(tabKey);

    debugPrint(
        '🔄 NavigationSync[$tabKey]: Pushed "${item.title}", stack size: ${stack.length}');
    notifyListeners();
  }

  /// Pop navigation item khỏi stack
  bool popNavigation(String tabKey) {
    final stack = _navigationStacks[tabKey];
    if (stack == null || stack.length <= 1) {
      return false;
    }

    stack.removeLast();
    _syncWithServices(tabKey);

    debugPrint(
        '🔄 NavigationSync[$tabKey]: Popped navigation, stack size: ${stack.length}');
    notifyListeners();
    return true;
  }

  /// Reset navigation về root
  void resetNavigation(String tabKey) {
    final stack = _navigationStacks[tabKey];
    if (stack == null || stack.length <= 1) {
      return;
    }

    // Giữ lại item đầu tiên (root)
    final rootItem = stack.first;
    stack.clear();
    stack.add(rootItem);

    _syncWithServices(tabKey);

    debugPrint('🔄 NavigationSync[$tabKey]: Reset to root');
    notifyListeners();
  }

  /// Đồng bộ với các services khác
  void _syncWithServices(String tabKey) {
    final stack = _navigationStacks[tabKey];
    if (stack == null || stack.isEmpty) return;

    final currentItem = stack.last;
    final canBack = stack.length > 1;

    // Sync với MobileAppBarController
    final mobileController = MobileAppBarController();
    if (stack.length == 1) {
      // Ở root, dùng appName và không có back button
      mobileController.setAppBar(
        title: appName,
        actions: [],
        showBackButton: false,
      );
    } else {
      // Có tool, dùng title của tool và hiển thị back button
      mobileController.setAppBar(
        title: currentItem.title,
        actions: currentItem.actions,
        showBackButton: canBack,
      );
    }

    // Sync với ProfileTabService để update breadcrumb
    _updateBreadcrumb(tabKey, stack);
  }

  /// Update breadcrumb cho desktop
  void _updateBreadcrumb(String tabKey, List<NavigationItem> stack) {
    // TODO: Implement breadcrumb update với ProfileTabService
    // Hiện tại chỉ log để debug
    if (stack.length >= 2) {
      final currentItem = stack.last;
      final parentItem = stack[stack.length - 2];

      debugPrint(
          '🍞 NavigationSync: Breadcrumb ${parentItem.title} > ${currentItem.title}');
    }
  }

  /// Get current navigation item
  NavigationItem? getCurrentItem(String tabKey) {
    final stack = _navigationStacks[tabKey];
    return stack != null && stack.isNotEmpty ? stack.last : null;
  }

  /// Check if có thể back được
  bool canPop(String tabKey) {
    final stack = _navigationStacks[tabKey];
    return stack != null && stack.length > 1;
  }

  /// Initialize navigation stack với root item
  void initializeNavigation(
    String tabKey, {
    String rootTitle = '',
    String rootId = 'root',
  }) {
    final rootItem = NavigationItem(
      id: rootId,
      title: rootTitle.isNotEmpty ? rootTitle : appName,
      actions: [],
      isSubTool: false,
    );

    _navigationStacks[tabKey] = [rootItem];

    // Clear MobileAppBar khi initialize
    final mobileController = MobileAppBarController();
    mobileController.forceClear();

    debugPrint(
        '🔄 NavigationSync[$tabKey]: Initialized with root "$rootTitle"');
  }

  /// Clear toàn bộ navigation cho tab
  void clearNavigation(String tabKey) {
    _navigationStacks.remove(tabKey);

    // Clear MobileAppBar
    final mobileController = MobileAppBarController();
    mobileController.forceClear();

    debugPrint('🔄 NavigationSync[$tabKey]: Cleared navigation');
  }
}

/// Navigation item cho stack
class NavigationItem {
  final String id;
  final String title;
  final List<Widget> actions;
  final bool isSubTool;

  const NavigationItem({
    required this.id,
    required this.title,
    required this.actions,
    this.isSubTool = false,
  });

  @override
  String toString() =>
      'NavigationItem(id: $id, title: $title, isSubTool: $isSubTool)';
}
