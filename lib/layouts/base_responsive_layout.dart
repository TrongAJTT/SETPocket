import 'package:flutter/material.dart';

mixin BaseResponsiveLayout {
  /// Default false
  bool hasInitialized = false;

  /// Syncs the mobile app bar with the current state
  void syncMobileAppBar();

  /// Call this in didChangeDependencies
  void refreshMobileAppBarIfNotInitialized() {
    if (!hasInitialized) {
      hasInitialized = true;
      refreshMobileAppBar();
    }
  }

  /// Use this in initState and didUpdateWidget
  void refreshMobileAppBar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncMobileAppBar();
    });
  }
}
