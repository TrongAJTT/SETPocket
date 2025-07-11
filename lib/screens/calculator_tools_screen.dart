import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/screens/calculator_tools/date_calculator_screen.dart';
import 'calculator_tools/bmi_calculator_screen.dart';
import 'calculator_tools/financial_calculator_screen.dart';
import 'calculator_tools/discount_calculator_screen.dart';
import 'calculator_tools/scientific_calculator_screen.dart';
import 'calculator_tools/graphing_calculator_screen.dart';
import 'package:setpocket/widgets/generic/section_item.dart';
import 'package:setpocket/widgets/generic/section_list_view.dart';
import 'package:setpocket/widgets/generic/section_grid_view.dart';
import 'package:setpocket/utils/generic_settings_utils.dart';

class CalculatorToolsScreen extends StatelessWidget {
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory, IconData? icon})?
      onToolSelected;

  const CalculatorToolsScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolSelected,
  });

  List<SectionItem> _buildSections(AppLocalizations loc) {
    return [
      SectionItem(
        id: 'scientific_calculator',
        title: loc.scientificCalculator,
        subtitle: loc.scientificCalculatorDesc,
        icon: Icons.calculate,
        iconColor: Colors.teal,
        content: ScientificCalculatorScreen(isEmbedded: isEmbedded),
      ),
      SectionItem(
        id: 'graphing_calculator',
        title: loc.graphingCalculator,
        subtitle: loc.graphingCalculatorDesc,
        icon: Icons.show_chart,
        iconColor: Colors.indigo,
        content: GraphingCalculatorScreen(isEmbedded: isEmbedded),
      ),
      SectionItem(
        id: 'bmi_calculator',
        title: loc.bmiCalculator,
        subtitle: loc.bmiCalculatorDesc,
        icon: Icons.monitor_weight,
        iconColor: Colors.blue,
        content: BmiCalculatorScreen(isEmbedded: isEmbedded),
      ),
      SectionItem(
        id: 'financial_calculator',
        title: loc.financialCalculator,
        subtitle: loc.financialCalculatorDesc,
        icon: Icons.attach_money,
        iconColor: Colors.green,
        content: FinancialCalculatorScreen(isEmbedded: isEmbedded),
      ),
      SectionItem(
        id: 'date_calculator',
        title: loc.dateCalculator,
        subtitle: loc.dateCalculatorDesc,
        icon: Icons.calendar_today,
        iconColor: Colors.orange,
        content: DateCalculatorScreen(isEmbedded: isEmbedded),
      ),
      SectionItem(
        id: 'discount_calculator',
        title: loc.discountCalculator,
        subtitle: loc.discountCalculatorDesc,
        icon: Icons.local_offer,
        iconColor: Colors.purple,
        content: DiscountCalculatorScreen(isEmbedded: isEmbedded),
      ),
    ];
  }

  void _onSectionSelected(
      String sectionId, AppLocalizations loc, BuildContext context) {
    final sections = _buildSections(loc);
    final section = sections.firstWhere((s) => s.id == sectionId);

    if (isEmbedded && onToolSelected != null) {
      onToolSelected!(section.content, section.title,
          parentCategory: 'CalculatorToolsScreen', icon: section.icon);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => section.content,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    final sections = _buildSections(loc);

    Widget content;
    if (isDesktop) {
      // Desktop: Use AutoScaleSectionGridView
      content = AutoScaleSectionGridView(
        sections: sections,
        onSectionSelected: (sectionId) =>
            _onSectionSelected(sectionId, loc, context),
        minCellWidth: 400,
        fixedCellHeight: 110,
        decorator: const SectionGridDecorator(
          padding: EdgeInsets.all(16),
        ),
      );
    } else {
      // Mobile: Use SectionListView
      content = SectionListView(
        sections: sections,
        onSectionSelected: (sectionId) =>
            _onSectionSelected(sectionId, loc, context),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      );
    }

    if (isEmbedded) {
      return Stack(
        children: [
          content,
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'calculator_tools_settings',
              onPressed: () {
                GenericSettingsUtils.quickOpenCalculatorToolsSettings(context);
              },
              tooltip: loc.settings,
              child: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.calculatorTools),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                GenericSettingsUtils.quickOpenCalculatorToolsSettings(context);
              },
              tooltip: loc.settings,
            ),
          ],
        ),
        body: content,
      );
    }
  }
}
