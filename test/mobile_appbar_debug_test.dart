import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/layouts/profile_mobile_layout.dart';
import 'package:setpocket/services/profile_tab_service.dart';
import 'package:setpocket/screens/text_template/text_template_edit_screen.dart';
import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/l10n/app_localizations.dart';

void main() {
  group('Mobile AppBar Debug Tests', () {
    testWidgets('Debug mobile AppBar actions with real ProfileTabService',
        (WidgetTester tester) async {
      // Create a sample template
      final template = TextTemplatesData()
        ..id = 'test-id'
        ..title = 'Test Template'
        ..content = 'Test content'
        ..status = TemplateStatus.draft
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      // Initialize ProfileTabService
      await ProfileTabService.instance.initialize();

      // Create the mobile layout with localization
      final app = MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        supportedLocales: [const Locale('vi'), const Locale('en')],
        home: ProfileMobileLayout(),
      );

      await tester.pumpWidget(app);
      await tester.pump(); // Single pump to avoid timeout

      // Simulate selecting Text Template Edit tool - similar to real app
      final profileService = ProfileTabService.instance;

      final templateEditWidget = TemplateEditScreen(
        template: template,
        isEmbedded: true,
      );

      // Update the current tab with the template edit tool
      profileService.updateTabTool(
        tabIndex: 0,
        toolId: 'text_template_edit',
        toolTitle: 'Create Template',
        icon: Icons.edit,
        iconColor: Colors.blue,
        toolWidget: templateEditWidget,
      );

      // Trigger UI refresh
      await tester.pump();

      // Check what's in the AppBar
      final appBarFinder = find.byType(AppBar);
      if (appBarFinder.evaluate().isNotEmpty) {
        print('📱 Found AppBar in mobile layout');

        // Look for Save icon in AppBar actions
        final saveIconFinder = find.descendant(
          of: appBarFinder,
          matching: find.byIcon(Icons.save),
        );

        // Look for About icon in AppBar actions
        final aboutIconFinder = find.descendant(
          of: appBarFinder,
          matching: find.byIcon(Icons.info_outline),
        );

        print('📱 Save buttons found: ${saveIconFinder.evaluate().length}');
        print('📱 About buttons found: ${aboutIconFinder.evaluate().length}');

        // The Save button should be present and About should not
        if (saveIconFinder.evaluate().isNotEmpty) {
          print('✅ SUCCESS: Save button found in mobile AppBar');
        } else {
          print('❌ ISSUE: Save button NOT found in mobile AppBar');
        }

        if (aboutIconFinder.evaluate().isNotEmpty) {
          print(
              '❌ ISSUE: About button still present (should be replaced by Save)');
        } else {
          print(
              '✅ SUCCESS: About button correctly hidden when tool actions present');
        }
      } else {
        print('❌ No AppBar found');
      }
    });

    testWidgets('Debug extraction directly from TemplateEditScreen',
        (WidgetTester tester) async {
      final template = TextTemplatesData()
        ..id = 'test-id'
        ..title = 'Test Template'
        ..content = 'Test content'
        ..status = TemplateStatus.draft
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      final templateEditWidget = TemplateEditScreen(
        template: template,
        isEmbedded: true,
      );

      // Create a test app with just the template edit screen
      final app = MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
        ],
        supportedLocales: [const Locale('vi'), const Locale('en')],
        home: Scaffold(body: templateEditWidget),
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      print(
          '🔍 TemplateEditScreen widget type: ${templateEditWidget.runtimeType}');

      // Check if we can find the Save button inside the TemplateEditScreen
      final saveButtonFinder = find.byIcon(Icons.save);
      print(
          '🔍 Save buttons in TemplateEditScreen: ${saveButtonFinder.evaluate().length}');

      if (saveButtonFinder.evaluate().isNotEmpty) {
        print('✅ Save button exists in TemplateEditScreen');
      } else {
        print('❌ Save button NOT found in TemplateEditScreen');
      }
    });
  });
}
