import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/screens/text_template/text_template_use_screen.dart';
import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';

void main() {
  group('TemplateUseScreen Integration Tests', () {
    late MobileAppBarController controller;

    setUp(() {
      controller = MobileAppBarController();
      controller.clear();
    });

    tearDown(() {
      controller.clear();
    });

    testWidgets('Should sync Copy button to MobileAppBar on mobile', (WidgetTester tester) async {
      // Create a test template
      final template = TextTemplatesData()
        ..id = 'test'
        ..title = 'Test Template'
        ..content = 'Hello {{name}}!'
        ..status = TemplateStatus.complete
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      // Build TemplateUseScreen in mobile size
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)), // Mobile size
            child: TemplateUseScreen(
              template: template,
              isEmbedded: false, // Not embedded, so should sync
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that Copy button is in MobileAppBarController
      expect(controller.actions.length, equals(1));
      
      final action = controller.actions.first;
      expect(action, isA<IconButton>());
      final iconButton = action as IconButton;
      final icon = iconButton.icon as Icon;
      expect(icon.icon, equals(Icons.copy));
      expect(iconButton.tooltip, equals('Copy')); // Assuming 'Copy' is the localized text
    });

    testWidgets('Should have back button for proper navigation', (WidgetTester tester) async {
      final template = TextTemplatesData()
        ..id = 'test'
        ..title = 'Test Template'
        ..content = 'Hello {{name}}!'
        ..status = TemplateStatus.complete
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      // Build in a navigation context
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TemplateUseScreen(
                        template: template,
                        isEmbedded: false,
                      ),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ),
      );

      // Navigate to TemplateUseScreen
      await tester.tap(find.text('Navigate'));
      await tester.pumpAndSettle();

      // Should find a back button in the AppBar
      expect(find.byType(BackButton), findsOneWidget);
    });
  });
}
