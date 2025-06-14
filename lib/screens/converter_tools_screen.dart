import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/screens/converters/unit_converter_screen.dart';
import 'package:setpocket/screens/converters/currency_converter_screen.dart';
import 'package:setpocket/screens/converters/length_converter_screen.dart';
import 'package:setpocket/screens/converters/mass_converter_screen.dart';
import 'package:setpocket/screens/converters/weight_converter_screen.dart';
import 'package:setpocket/screens/converters/area_converter_screen.dart';

class ConverterToolsScreen extends StatelessWidget {
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory, IconData? icon})?
      onToolSelected;

  const ConverterToolsScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    int crossAxisCount;
    if (width < 1035) {
      crossAxisCount = 1;
    } else if (width < 1480) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 3;
    }

    final gridView = GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 100,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: 11, // Number of converter tools (increased by 1)
      itemBuilder: (context, index) {
        Widget screen;
        String title;
        IconData icon;
        Color iconColor;
        switch (index) {
          case 0:
            screen = const CurrencyConverterScreen();
            title = loc.currencyConverter;
            icon = Icons.attach_money;
            iconColor = Colors.green;
            break;
          case 1:
            screen = const LengthConverterNewScreen();
            title = loc.lengthConverter;
            icon = Icons.straighten;
            iconColor = Colors.blue;
            break;
          case 2:
            screen = const MassConverterNewScreen();
            title = loc.massConverter;
            icon = Icons.balance;
            iconColor = Colors.orange;
            break;
          case 3:
            screen = const WeightConverterScreen();
            title = loc.weightConverter;
            icon = Icons.fitness_center;
            iconColor = Colors.deepPurple;
            break;
          case 4:
            screen = const AreaConverterScreen();
            title = loc.areaConverter;
            icon = Icons.crop_free;
            iconColor = Colors.purple;
            break;
          case 5:
            screen = UnitConverterScreen(
                categoryId: 'time', categoryName: loc.timeConverter);
            title = loc.timeConverter;
            icon = Icons.schedule;
            iconColor = Colors.red;
            break;
          case 6:
            screen = UnitConverterScreen(
                categoryId: 'volume', categoryName: loc.volumeConverter);
            title = loc.volumeConverter;
            icon = Icons.local_drink;
            iconColor = Colors.cyan;
            break;
          case 7:
            screen = UnitConverterScreen(
                categoryId: 'number_systems',
                categoryName: loc.numberSystemConverter);
            title = loc.numberSystemConverter;
            icon = Icons.calculate;
            iconColor = Colors.indigo;
            break;
          case 8:
            screen = UnitConverterScreen(
                categoryId: 'speed', categoryName: loc.speedConverter);
            title = loc.speedConverter;
            icon = Icons.speed;
            iconColor = Colors.teal;
            break;
          case 9:
            screen = UnitConverterScreen(
                categoryId: 'temperature',
                categoryName: loc.temperatureConverter);
            title = loc.temperatureConverter;
            icon = Icons.thermostat;
            iconColor = Colors.amber;
            break;
          case 10:
            screen = UnitConverterScreen(
                categoryId: 'data_storage', categoryName: loc.dataConverter);
            title = loc.dataConverter;
            icon = Icons.storage;
            iconColor = Colors.deepOrange;
            break;
          default:
            screen = const SizedBox();
            title = "";
            icon = Icons.error;
            iconColor = Colors.grey;
        }

        return Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              if (isEmbedded && onToolSelected != null) {
                onToolSelected!(screen, title,
                    parentCategory: 'ConverterToolsScreen', icon: icon);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => screen),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getDescription(index, loc),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (isEmbedded) {
      return gridView;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.converterTools),
        ),
        body: gridView,
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
        return loc.massConverterDesc;
      case 3:
        return loc.weightConverterDesc;
      case 4:
        return loc.areaConverterDesc;
      case 5:
        return loc.timeConverterDesc;
      case 6:
        return loc.volumeConverterDesc;
      case 7:
        return loc.numberSystemConverterDesc;
      case 8:
        return loc.speedConverterDesc;
      case 9:
        return loc.temperatureConverterDesc;
      case 10:
        return loc.dataConverterDesc;
      default:
        return "";
    }
  }
}
