import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/screens/converters/currency_converter_screen.dart';
import 'package:setpocket/screens/converters/length_converter_screen.dart';
import 'package:setpocket/screens/converters/mass_converter_screen.dart';
import 'package:setpocket/screens/converters/weight_converter_screen.dart';
import 'package:setpocket/screens/converters/area_converter_screen.dart';
import 'package:setpocket/screens/converters/volume_converter_screen.dart';
import 'package:setpocket/screens/converters/number_system_converter_screen.dart';
import 'package:setpocket/screens/converters/speed_converter_screen.dart';
import 'package:setpocket/screens/converters/temperature_converter_screen.dart';
import 'package:setpocket/screens/converters/data_converter_screen.dart';
import 'converters/time_converter_screen.dart';
import 'package:setpocket/widgets/generic/section_item.dart';
import 'package:setpocket/widgets/generic/section_list_view.dart';
import 'package:setpocket/widgets/generic/section_grid_view.dart';

class ConverterToolsScreen extends StatelessWidget {
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory, IconData? icon})?
      onToolSelected;

  const ConverterToolsScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolSelected,
  });

  List<SectionItem> _buildSections(AppLocalizations loc) {
    return [
      SectionItem(
        id: 'currency_converter',
        title: loc.currencyConverter,
        subtitle: _getDescription(0, loc),
        icon: Icons.attach_money,
        iconColor: Colors.green,
        content: const CurrencyConverterScreen(),
      ),
      SectionItem(
        id: 'length_converter',
        title: loc.lengthConverter,
        subtitle: _getDescription(1, loc),
        icon: Icons.straighten,
        iconColor: Colors.blue,
        content: const LengthConverterNewScreen(),
      ),
      SectionItem(
        id: 'temperature_converter',
        title: loc.temperatureConverter,
        subtitle: _getDescription(2, loc),
        icon: Icons.thermostat,
        iconColor: Colors.amber,
        content: const TemperatureConverterScreen(),
      ),
      SectionItem(
        id: 'mass_converter',
        title: loc.massConverter,
        subtitle: _getDescription(3, loc),
        icon: Icons.balance,
        iconColor: Colors.orange,
        content: const MassConverterNewScreen(),
      ),
      SectionItem(
        id: 'time_converter',
        title: loc.timeConverter,
        subtitle: _getDescription(4, loc),
        icon: Icons.schedule,
        iconColor: Colors.red,
        content: const TimeConverterScreen(),
      ),
      SectionItem(
        id: 'data_converter',
        title: loc.dataConverter,
        subtitle: _getDescription(5, loc),
        icon: Icons.storage,
        iconColor: Colors.deepOrange,
        content: const DataConverterScreen(),
      ),
      SectionItem(
        id: 'volume_converter',
        title: loc.volumeConverter,
        subtitle: _getDescription(6, loc),
        icon: Icons.local_drink,
        iconColor: Colors.cyan,
        content: const VolumeConverterScreen(),
      ),
      SectionItem(
        id: 'speed_converter',
        title: loc.speedConverter,
        subtitle: _getDescription(7, loc),
        icon: Icons.speed,
        iconColor: Colors.teal,
        content: const SpeedConverterScreen(),
      ),
      SectionItem(
        id: 'area_converter',
        title: loc.areaConverter,
        subtitle: _getDescription(8, loc),
        icon: Icons.crop_free,
        iconColor: Colors.purple,
        content: const AreaConverterScreen(),
      ),
      SectionItem(
        id: 'weight_converter',
        title: loc.weightConverter,
        subtitle: _getDescription(9, loc),
        icon: Icons.fitness_center,
        iconColor: Colors.deepPurple,
        content: const WeightConverterScreen(),
      ),
      SectionItem(
        id: 'number_system_converter',
        title: loc.numberSystemConverter,
        subtitle: _getDescription(10, loc),
        icon: Icons.code,
        iconColor: Colors.indigo,
        content: const NumberSystemConverterScreen(),
      ),
    ];
  }

  void _onSectionSelected(
      String sectionId, AppLocalizations loc, BuildContext context) {
    final sections = _buildSections(loc);
    final section = sections.firstWhere((s) => s.id == sectionId);

    if (isEmbedded && onToolSelected != null) {
      onToolSelected!(section.content, section.title,
          parentCategory: 'ConverterToolsScreen', icon: section.icon);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => section.content),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    final sections = _buildSections(loc);

    Widget content;
    if (isDesktop) {
      // Desktop: Use AutoScaleSectionGridView
      content = AutoScaleSectionGridView(
        sections: sections,
        onSectionSelected: (sectionId) =>
            _onSectionSelected(sectionId, loc, context),
        minCellWidth: 400,
        fixedCellHeight: 100,
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
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.converterTools),
        ),
        body: content,
      );
    }
  }

  String _getDescription(int index, AppLocalizations loc) {
    switch (index) {
      case 0:
        return loc.currencyConverterDesc;
      case 1:
        return loc.lengthConverterDesc;
      case 2:
        return loc.temperatureConverterDesc;
      case 3:
        return loc.massConverterDesc;
      case 4:
        return loc.timeConverterDesc;
      case 5:
        return loc.dataConverterDesc;
      case 6:
        return loc.volumeConverterDesc;
      case 7:
        return loc.speedConverterDesc;
      case 8:
        return loc.areaConverterDesc;
      case 9:
        return loc.weightConverterDesc;
      case 10:
        return loc.numberSystemConverterDesc;
      default:
        return "";
    }
  }
}
