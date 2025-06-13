import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'calculators/bmi_calculator_screen.dart';
import 'calculators/financial_calculator_screen.dart';
import 'calculators/date_calculator_screen.dart';
import 'calculators/discount_calculator_screen.dart';
import 'calculators/scientific_calculator_screen.dart';
import 'calculators/graphing_calculator_screen.dart';

class CalculatorToolsScreen extends StatelessWidget {
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory})? onToolSelected;

  const CalculatorToolsScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth < 600) {
      // Mobile: 1 column
      crossAxisCount = 1;
    } else if (screenWidth < 900) {
      // Tablet: 2 columns
      crossAxisCount = 2;
    } else {
      // Desktop: 3 columns
      crossAxisCount = 3;
    }

    final calculators = [
      {
        'title': localizations.scientificCalculator,
        'description': localizations.scientificCalculatorDesc,
        'icon': Icons.calculate,
        'color': Colors.teal,
        'screen': const ScientificCalculatorScreen(),
      },
      {
        'title': localizations.graphingCalculator,
        'description': localizations.graphingCalculatorDesc,
        'icon': Icons.show_chart,
        'color': Colors.indigo,
        'screen': const GraphingCalculatorScreen(),
      },
      {
        'title': localizations.bmiCalculator,
        'description': localizations.bmiCalculatorDesc,
        'icon': Icons.monitor_weight,
        'color': Colors.blue,
        'screen': const BmiCalculatorScreen(),
      },
      {
        'title': "Financial Calculator",
        'description': "Calculate loans, investments, and compound interest",
        'icon': Icons.attach_money,
        'color': Colors.green,
        'screen': const FinancialCalculatorScreen(),
      },
      {
        'title': "Date Calculator",
        'description': "Calculate date differences and add/subtract dates",
        'icon': Icons.calendar_today,
        'color': Colors.orange,
        'screen': const DateCalculatorScreen(),
      },
      {
        'title': "Discount Calculator",
        'description': "Calculate discounts, tips, and tax",
        'icon': Icons.local_offer,
        'color': Colors.purple,
        'screen': const DiscountCalculatorScreen(),
      },
    ];

    final gridView = GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: 120,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: calculators.length,
      itemBuilder: (context, index) {
        final calculator = calculators[index];
        return _buildCalculatorTile(
          context,
          title: calculator['title'] as String,
          description: calculator['description'] as String,
          icon: calculator['icon'] as IconData,
          color: calculator['color'] as Color,
          calculator: calculator,
        );
      },
    );

    if (isEmbedded) {
      return gridView;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.calculatorTools),
        ),
        body: gridView,
      );
    }
  }

  Widget _buildCalculatorTile(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Map<String, dynamic> calculator,
  }) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          final screen = calculator['screen'] as Widget;
          if (isEmbedded && onToolSelected != null) {
            onToolSelected!(screen, title,
                parentCategory: 'CalculatorToolsScreen');
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => screen,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.7),
                        fontSize: 14,
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
  }
}
