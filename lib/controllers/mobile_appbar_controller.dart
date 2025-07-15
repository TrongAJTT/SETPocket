import 'package:flutter/material.dart';
import 'package:setpocket/variables.dart';

/// Controller to manage the mobile AppBar state
/// Singleton pattern to ensure only one instance exists
class MobileAppBarController extends ChangeNotifier {
  static final MobileAppBarController _instance =
      MobileAppBarController._internal();
  factory MobileAppBarController() => _instance;
  MobileAppBarController._internal();

  // Per-tab state storage
  final Map<String, _TabAppBarState> _tabStates = {};
  String _currentTabKey = 'tab_0'; // Default tab

  String get title => _getCurrentState().title;
  List<Widget> get actions => List.unmodifiable(_getCurrentState().actions);
  bool get showBackButton => _getCurrentState().showBackButton;

  /// Get current tab state or create default
  _TabAppBarState _getCurrentState() {
    return _tabStates[_currentTabKey] ??= _TabAppBarState();
  }

  /// Switch to a different tab context
  void setCurrentTab(String tabKey) {
    if (_currentTabKey != tabKey) {
      _currentTabKey = tabKey;
      notifyListeners();
      print('📱 MobileAppBar: Switched to tab context: $tabKey');
    }
  }

  /// Set title and actions for the current tab's AppBar
  void setAppBar({String? title, List<Widget>? actions, bool? showBackButton}) {
    final state = _getCurrentState();
    bool changed = false;

    if (title != null && title != state.title) {
      state.title = title;
      changed = true;
    }

    if (actions != null) {
      state.actions = List.from(actions);
      changed = true;
    }

    if (showBackButton != null && showBackButton != state.showBackButton) {
      state.showBackButton = showBackButton;
      changed = true;
    }

    if (changed) {
      notifyListeners();
      print(
          '📱 MobileAppBar: Set title "${state.title}" with ${state.actions.length} actions, back: ${state.showBackButton} for $_currentTabKey');
    }
  }

  /// Clear AppBar for current tab
  void clear() {
    final state = _getCurrentState();
    if (state.title == appName &&
        state.actions.isEmpty &&
        !state.showBackButton) {
      return; // No need to clear if already cleared
    }

    state.title = appName;
    state.actions = [];
    state.showBackButton = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
      print(
          '🧹 MobileAppBar: Cleared to appName for $_currentTabKey, back: false');
    });
  }

  /// Force clear AppBar for current tab
  void forceClear() {
    final state = _getCurrentState();
    state.title = appName;
    state.actions = [];
    state.showBackButton = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
      print(
          '🧹 MobileAppBar: Force cleared to appName for $_currentTabKey, back: false');
    });
  }

  /// Set only back button state for current tab
  void setBackButton(bool show) {
    final state = _getCurrentState();
    if (state.showBackButton != show) {
      state.showBackButton = show;
      notifyListeners();
      print('📱 MobileAppBar: Set back button: $show for $_currentTabKey');
    }
  }

  /// Clear all tab states (for debugging)
  void clearAllTabs() {
    _tabStates.clear();
    notifyListeners();
    print('🧹 MobileAppBar: Cleared all tab states');
  }
}

/// Per-tab AppBar state
class _TabAppBarState {
  String title = appName;
  List<Widget> actions = [];
  bool showBackButton = false;
}
