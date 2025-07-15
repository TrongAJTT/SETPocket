import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/layouts/two_panels_layout.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';
import 'package:setpocket/widgets/mobile_appbar.dart';

void main() {
  group('TwoPanelsLayout AppBar Sync Tests', () {
    late MobileAppBarController controller;

    setUp(() {
      controller = MobileAppBarController();
      controller.clear();
    });

    tearDown(() {
      controller.clear();
    });

    testWidgets('Should sync actions to MobileAppBarController on mobile', (WidgetTester tester) async {
      // Create test actions
      final testActions = [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {},
          tooltip: 'Save',
        ),
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () {},
          tooltip: 'Copy',
        ),
      ];

      // Build TwoPanelsLayout with actions in mobile size
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)), // Mobile size
            child: TwoPanelsLayout(
              title: 'Test Title',
              mainPanel: const Text('Main Panel'),
              rightPanel: const Text('Right Panel'),
              mainPanelActions: testActions,
              isEmbedded: false, // Not embedded, so should sync
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that MobileAppBarController has the correct title and actions
      expect(controller.title, equals('Test Title'));
      expect(controller.actions.length, equals(2));
      
      // Check that actions are IconButtons with correct icons
      final actions = controller.actions;
      expect(actions[0], isA<IconButton>());
      expect(actions[1], isA<IconButton>());
      
      final firstIcon = (actions[0] as IconButton).icon as Icon;
      final secondIcon = (actions[1] as IconButton).icon as Icon;
      expect(firstIcon.icon, equals(Icons.save));
      expect(secondIcon.icon, equals(Icons.copy));
    });

    testWidgets('Should NOT sync when embedded', (WidgetTester tester) async {
      final testActions = [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {},
        ),
      ];

      // Build TwoPanelsLayout embedded
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)), // Mobile size
            child: TwoPanelsLayout(
              title: 'Test Title',
              mainPanel: const Text('Main Panel'),
              mainPanelActions: testActions,
              isEmbedded: true, // Embedded, so should NOT sync
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // MobileAppBarController should be empty
      expect(controller.title, equals(''));
      expect(controller.actions, isEmpty);
    });

    testWidgets('Should use MobileAppBar on mobile standalone', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)), // Mobile size
            child: TwoPanelsLayout(
              title: 'Test Title',
              mainPanel: const Text('Main Panel'),
              isEmbedded: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find MobileAppBar widget
      expect(find.byType(MobileAppBar), findsOneWidget);
      expect(find.byType(AppBar), findsNothing); // Should not use regular AppBar
    });

    testWidgets('Should use regular AppBar on desktop standalone', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)), // Desktop size
            child: TwoPanelsLayout(
              title: 'Test Title',
              mainPanel: const Text('Main Panel'),
              isEmbedded: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find regular AppBar widget
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(MobileAppBar), findsNothing); // Should not use MobileAppBar
    });

    testWidgets('Should clear AppBar on dispose when not embedded', (WidgetTester tester) async {
      // Set some initial state
      controller.setAppBar(title: 'Initial', actions: []);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)), // Mobile size
            child: TwoPanelsLayout(
              title: 'Test Title',
              mainPanel: const Text('Main Panel'),
              isEmbedded: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify sync happened
      expect(controller.title, equals('Test Title'));

      // Remove the widget (dispose)
      await tester.pumpWidget(const MaterialApp(home: Text('Empty')));
      await tester.pumpAndSettle();

      // AppBar should be cleared
      expect(controller.title, equals(''));
      expect(controller.actions, isEmpty);
    });
  });
}
