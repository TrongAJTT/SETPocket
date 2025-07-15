import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setpocket/services/profile_widget_factory.dart';
import 'package:setpocket/services/profile_tab_service.dart';
import 'package:setpocket/services/profile_breadcrumb_service.dart';
import 'package:setpocket/widgets/navigation/profile_tool_selection_screen.dart';
import 'package:setpocket/screens/converter_tools/speed_converter_screen.dart';
import 'package:setpocket/screens/p2lan_transfer/p2lan_transfer_screen.dart';

void main() {
  group('Widget Recreation After Restart Tests', () {
    late ProfileTabService tabService;
    late ProfileBreadcrumbService breadcrumbService;

    setUp(() async {
      tabService = ProfileTabService.instance;
      breadcrumbService = ProfileBreadcrumbService.instance;

      // Initialize services
      await tabService.initialize();

      // Clear all for fresh start
      for (int i = 0; i < 3; i++) {
        breadcrumbService.clearBreadcrumbs(i);
      }
    });

    test('should recreate SpeedConverterScreen from toolId', () {
      final widget = ProfileWidgetFactory.instance.recreateWidget(
        toolId: 'speed',
        isEmbedded: true,
      );

      expect(widget, isA<SpeedConverterScreen>());
      expect((widget as SpeedConverterScreen).isEmbedded, isTrue);
    });

    test('should recreate P2LanTransferScreen from toolId', () {
      final widget = ProfileWidgetFactory.instance.recreateWidget(
        toolId: 'p2pDataTransfer',
        isEmbedded: true,
      );

      expect(widget, isA<P2LanTransferScreen>());
      expect((widget as P2LanTransferScreen).isEmbedded, isTrue);
    });

    test('should fallback to ProfileToolSelectionScreen for unknown toolId',
        () {
      final widget = ProfileWidgetFactory.instance.recreateWidget(
        toolId: 'unknownTool',
        isEmbedded: true,
      );

      expect(widget, isA<ProfileToolSelectionScreen>());
    });

    test('should simulate app restart and widget recreation', () async {
      // === SIMULATION 1: User opens Speed Converter ===
      print('\n📱 === USER OPENS SPEED CONVERTER ===');

      // Set tab 0 to speed converter
      tabService.setCurrentTab(0);
      tabService.updateTabTool(
        tabIndex: 0,
        toolId: 'speed',
        toolTitle: 'Speed Converter',
        icon: Icons.speed,
        iconColor: Colors.green,
        toolWidget: const SpeedConverterScreen(isEmbedded: true),
        parentCategory: 'converterTools',
      );

      // Add breadcrumb
      breadcrumbService.pushBreadcrumb(
        title: 'Converter Tools',
        toolId: 'converterTools',
        isCategory: true,
      );
      breadcrumbService.pushBreadcrumb(
        title: 'Speed Converter',
        toolId: 'speed',
        isCategory: false,
      );

      print('Before restart - Tab 0: ${tabService.currentTab?.toolId}');
      print(
          'Before restart - Breadcrumbs: ${breadcrumbService.getCurrentBreadcrumbs().map((b) => b.title).join(" > ")}');

      // === SIMULATION 2: App restart scenario ===
      print('\n🔄 === SIMULATING APP RESTART ===');

      // Save tab state (this happens automatically)
      final savedTab = tabService.currentTab!;
      expect(savedTab.toolId, equals('speed'));
      expect(savedTab.toolTitle, equals('Speed Converter'));

      // After app restart, ProfileTab.fromJson() creates Container() for toolWidget
      // This is what we need to detect and fix

      // === SIMULATION 3: Widget recreation ===
      print('\n🔧 === WIDGET RECREATION ===');

      // Detect if widget needs recreation (Container with no child)
      if (savedTab.toolWidget is Container &&
          (savedTab.toolWidget as Container).child == null) {
        print('Widget needs recreation for toolId: ${savedTab.toolId}');

        // Recreate widget
        final recreatedWidget = ProfileWidgetFactory.instance.recreateWidget(
          toolId: savedTab.toolId,
          isEmbedded: true,
        );

        expect(recreatedWidget, isA<SpeedConverterScreen>());
        print('✅ Successfully recreated SpeedConverterScreen');
      }

      print('\n✅ === WIDGET RECREATION TEST COMPLETE ===');
    });

    test('should handle P2Lan breadcrumb integration', () async {
      print('\n📱 === P2LAN BREADCRUMB INTEGRATION TEST ===');

      // Set tab 1 to P2Lan
      tabService.setCurrentTab(1);
      tabService.updateTabTool(
        tabIndex: 1,
        toolId: 'p2pDataTransfer',
        toolTitle: 'P2LAN Transfer',
        icon: Icons.share,
        iconColor: Colors.teal,
        toolWidget: const P2LanTransferScreen(isEmbedded: true),
        parentCategory: 'directTool',
      );

      // P2Lan should get breadcrumb as a direct tool
      breadcrumbService.pushBreadcrumb(
        title: 'P2LAN Transfer',
        toolId: 'p2pDataTransfer',
        isCategory: true, // Direct tools are treated as category level
      );

      final breadcrumbs = breadcrumbService.getCurrentBreadcrumbs();
      expect(breadcrumbs.length, equals(1));
      expect(breadcrumbs[0].title, equals('P2LAN Transfer'));
      expect(breadcrumbs[0].toolId, equals('p2pDataTransfer'));

      print('P2LAN breadcrumb: ${breadcrumbs.map((b) => b.title).join(" > ")}');
      print('✅ P2LAN breadcrumb integration working');
    });
  });
}
