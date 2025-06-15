import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';

class BmiCalculatorScreen extends StatefulWidget {
  final bool isEmbedded;

  const BmiCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _isMetric = true;
  double? _bmi;
  String _bmiCategory = '';
  Color _categoryColor = Colors.grey;

  void _calculateBMI() {
    final heightText = _heightController.text;
    final weightText = _weightController.text;

    if (heightText.isEmpty || weightText.isEmpty) return;

    double? height = double.tryParse(heightText);
    double? weight = double.tryParse(weightText);

    if (height == null || weight == null || height <= 0 || weight <= 0) return;

    // Convert to metric if needed
    if (!_isMetric) {
      height = height * 2.54 / 100; // inches to meters
      weight = weight * 0.453592; // pounds to kg
    } else {
      height = height / 100; // cm to meters
    }

    final bmi = weight / (height * height);

    setState(() {
      _bmi = bmi;
      _setBMICategory(bmi);
    });
  }

  void _setBMICategory(double bmi) {
    final l10n = AppLocalizations.of(context)!;

    if (bmi < 18.5) {
      _bmiCategory = l10n.underweight;
      _categoryColor = Colors.blue;
    } else if (bmi < 25) {
      _bmiCategory = l10n.normalWeight;
      _categoryColor = Colors.green;
    } else if (bmi < 30) {
      _bmiCategory = l10n.overweight;
      _categoryColor = Colors.orange;
    } else {
      _bmiCategory = l10n.obese;
      _categoryColor = Colors.red;
    }
  }

  void _toggleUnit() {
    setState(() {
      _isMetric = !_isMetric;
      _heightController.clear();
      _weightController.clear();
      _bmi = null;
      _bmiCategory = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Unit toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.units,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.metric),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.imperial),
                      ),
                    ],
                    selected: {_isMetric},
                    onSelectionChanged: (Set<bool> selection) {
                      _toggleUnit();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Input fields
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.enterMeasurements,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _heightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: InputDecoration(
                      labelText: _isMetric ? l10n.heightCm : l10n.heightInches,
                      border: const OutlineInputBorder(),
                      suffixText: _isMetric ? 'cm' : 'in',
                    ),
                    onChanged: (_) => _calculateBMI(),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: InputDecoration(
                      labelText: _isMetric ? l10n.weightKg : l10n.weightPounds,
                      border: const OutlineInputBorder(),
                      suffixText: _isMetric ? 'kg' : 'lbs',
                    ),
                    onChanged: (_) => _calculateBMI(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results
          if (_bmi != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      l10n.yourBMI,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _bmi!.toStringAsFixed(1),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _categoryColor,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _categoryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _categoryColor),
                      ),
                      child: Text(
                        _bmiCategory,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: _categoryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BMI Scale
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.bmiScale,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    _buildBMIScaleItem(l10n.underweight, '< 18.5', Colors.blue),
                    _buildBMIScaleItem(
                        l10n.normalWeight, '18.5 - 24.9', Colors.green),
                    _buildBMIScaleItem(
                        l10n.overweight, '25.0 - 29.9', Colors.orange),
                    _buildBMIScaleItem(l10n.obese, '≥ 30.0', Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (widget.isEmbedded) {
      return body;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.bmiCalculator),
        ),
        body: body,
      );
    }
  }

  Widget _buildBMIScaleItem(String category, String range, Color color) {
    final isCurrentCategory = category == _bmiCategory;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentCategory ? color.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentCategory ? Border.all(color: color) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrentCategory ? FontWeight.bold : null,
                  ),
            ),
          ),
          Text(
            range,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isCurrentCategory ? FontWeight.bold : null,
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
