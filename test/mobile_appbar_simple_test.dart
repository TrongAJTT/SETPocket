import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';
import 'package:setpocket/widgets/mobile_appbar.dart';

void main() {
  group('MobileAppBar Tests', () {
    testWidgets('MobileAppBar should display title and actions from controller', 
        (WidgetTester tester) async {
      final controller = MobileAppBarController();
      
      // Set title and actions
      controller.setAppBar(
        title: 'Test Title',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const MobileAppBar(),
          ),
        ),
      );

      // Check if title is displayed
      expect(find.text('Test Title'), findsOneWidget);
      
      // Check if action is displayed
      expect(find.byIcon(Icons.settings), findsOneWidget);

      print('✅ MobileAppBar correctly displays title and actions');
    });

    testWidgets('MobileAppBar should show title when set', 
        (WidgetTester tester) async {
      final controller = MobileAppBarController();
      
      // Set title first
      controller.setAppBar(
        title: 'Test Mobile Title',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const MobileAppBar(),
          ),
        ),
      );

      // Should show the title
      expect(find.text('Test Mobile Title'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      print('✅ MobileAppBar correctly shows set title and actions');
    });

    test('MobileAppBarController should notify listeners', () {
      final controller = MobileAppBarController();
      bool notified = false;
      
      controller.addListener(() {
        notified = true;
      });

      controller.setAppBar(title: 'Test', actions: []);
      
      expect(notified, isTrue);
      expect(controller.title, equals('Test'));
      expect(controller.actions, isEmpty);

      print('✅ MobileAppBarController correctly notifies listeners');
    });
  });
}
