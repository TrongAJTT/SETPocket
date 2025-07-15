import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/layouts/profile_mobile_layout.dart';
import 'package:setpocket/services/profile_tab_service.dart';

void main() {
  group('Mobile Layout Integration Tests', () {
    setUp(() async {
      // Đảm bảo services được initialize
      await ProfileTabService.instance.initialize();
    });

    testWidgets('Mobile layout shows correct AppBar title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileMobileLayout(),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Verify AppBar exists
      expect(find.byType(AppBar), findsOneWidget);

      // Verify default title is shown (tool selection)
      expect(find.text('Chọn công cụ'), findsOneWidget);
    });

    testWidgets('Mobile layout navigation works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfileMobileLayout(),
        ),
      );

      await tester.pumpAndSettle();

      // Should start with tool selection
      expect(find.text('Chọn công cụ'), findsOneWidget);

      // Navigate to routine screen
      ProfileTabService.instance.switchToRoutine();
      await tester.pumpAndSettle();

      expect(find.text('Thói quen'), findsOneWidget);

      // Navigate to settings screen
      ProfileTabService.instance.switchToSettings();
      await tester.pumpAndSettle();

      expect(find.text('Cài đặt'), findsOneWidget);

      // Navigate back to profile
      ProfileTabService.instance.setCurrentTab(0);
      await tester.pumpAndSettle();

      expect(find.text('Chọn công cụ'), findsOneWidget);
    });

    testWidgets('AppBar back button works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfileMobileLayout(),
        ),
      );

      await tester.pumpAndSettle();

      // Start from tool selection - no back button
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // Navigate to routine - should show back button
      ProfileTabService.instance.switchToRoutine();
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.text('Thói quen'), findsOneWidget);

      // Tap back button - should return to tool selection
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Chọn công cụ'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('Mobile layout shows only necessary AppBar elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfileMobileLayout(),
        ),
      );

      await tester.pumpAndSettle();

      final appBar = tester.widget<AppBar>(find.byType(AppBar));

      // Verify AppBar has the expected structure for mobile
      expect(appBar.title, isNotNull);

      // On tool selection screen, no back button should be shown
      expect(find.byIcon(Icons.arrow_back), findsNothing);

      // AppBar should always be visible on mobile
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Bottom navigation bar exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProfileMobileLayout(),
        ),
      );

      await tester.pumpAndSettle();

      // Bottom navigation should exist
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
