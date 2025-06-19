import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/bmi_models.dart';
import 'package:setpocket/services/bmi_service.dart';

/// BMI Calculator content widget - separated from main screen for better organization
class BmiCalculatorContent extends StatefulWidget {
  final Function(BmiCalculation)? onCalculationChanged;
  final Function(BmiData, BmiCalculation)? onSaveToHistory;

  const BmiCalculatorContent({
    super.key,
    this.onCalculationChanged,
    this.onSaveToHistory,
  });

  @override
  State<BmiCalculatorContent> createState() => _BmiCalculatorContentState();
}

class _BmiCalculatorContentState extends State<BmiCalculatorContent> {
  // Form controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // State variables
  UnitSystem _unitSystem = UnitSystem.metric;
  Gender _gender = Gender.male;
  BmiCalculation? _currentCalculation;
  bool _autoSaveToHistory = false;
  bool _rememberLastValues = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await BmiService.getPreferences();
    if (!mounted) return;

    setState(() {
      _unitSystem = UnitSystem.values[prefs['unitSystem'] ?? 0];
      _autoSaveToHistory = prefs['autoSaveToHistory'] ?? true;
      _rememberLastValues = prefs['rememberLastValues'] ?? true;
    });

    if (_rememberLastValues) {
      final height = prefs['lastHeight'];
      final weight = prefs['lastWeight'];
      final age = prefs['lastAge'];
      final gender = prefs['lastGender'];

      if (height != null) _heightController.text = height.toString();
      if (weight != null) _weightController.text = weight.toString();
      if (age != null) _ageController.text = age.toString();
      if (gender != null) _gender = Gender.values[gender];

      if (height != null && weight != null && age != null) {
        _calculateBmi();
      }
    }
  }

  Future<void> _savePreferences() async {
    final prefs = {
      'unitSystem': _unitSystem.index,
      'autoSaveToHistory': _autoSaveToHistory,
      'rememberLastValues': _rememberLastValues,
    };

    if (_rememberLastValues &&
        _heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _ageController.text.isNotEmpty) {
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);
      final age = int.tryParse(_ageController.text);
      if (height != null) prefs['lastHeight'] = height;
      if (weight != null) prefs['lastWeight'] = weight;
      if (age != null) prefs['lastAge'] = age;
      prefs['lastGender'] = _gender.index;
    }

    await BmiService.savePreferences(prefs);
  }

  void _calculateBmi() {
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();
    final ageText = _ageController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty || ageText.isEmpty) {
      if (!mounted) return;
      setState(() {
        _currentCalculation = null;
      });
      widget.onCalculationChanged?.call(_currentCalculation!);
      return;
    }

    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);
    final age = int.tryParse(ageText);

    if (height == null ||
        weight == null ||
        age == null ||
        height <= 0 ||
        weight <= 0 ||
        age <= 0 ||
        age > 150) {
      if (!mounted) return;
      setState(() {
        _currentCalculation = null;
      });
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final calculation = BmiService.calculateBmi(
        height, weight, age, _gender, _unitSystem, l10n);

    if (!mounted) return;
    setState(() {
      _currentCalculation = calculation;
    });

    widget.onCalculationChanged?.call(calculation);
    _savePreferences();

    // // Auto-save to history if enabled
    // if (_autoSaveToHistory && widget.onSaveToHistory != null) {
    //   widget.onSaveToHistory!(
    //     BmiData(
    //       height: height,
    //       weight: weight,
    //       age: age,
    //       gender: _gender,
    //       unitSystem: _unitSystem,
    //       calculatedAt: DateTime.now(),
    //     ),
    //     calculation,
    //   );
    // }
  }

  void _toggleUnitSystem() {
    if (!mounted) return;
    setState(() {
      if (_unitSystem == UnitSystem.metric) {
        if (_heightController.text.isNotEmpty) {
          final height = double.tryParse(_heightController.text);
          if (height != null) {
            final converted = BmiService.convertHeight(
                height, UnitSystem.metric, UnitSystem.imperial);
            _heightController.text = converted.toStringAsFixed(1);
          }
        }
        if (_weightController.text.isNotEmpty) {
          final weight = double.tryParse(_weightController.text);
          if (weight != null) {
            final converted = BmiService.convertWeight(
                weight, UnitSystem.metric, UnitSystem.imperial);
            _weightController.text = converted.toStringAsFixed(1);
          }
        }
        _unitSystem = UnitSystem.imperial;
      } else {
        if (_heightController.text.isNotEmpty) {
          final height = double.tryParse(_heightController.text);
          if (height != null) {
            final converted = BmiService.convertHeight(
                height, UnitSystem.imperial, UnitSystem.metric);
            _heightController.text = converted.toStringAsFixed(0);
          }
        }
        if (_weightController.text.isNotEmpty) {
          final weight = double.tryParse(_weightController.text);
          if (weight != null) {
            final converted = BmiService.convertWeight(
                weight, UnitSystem.imperial, UnitSystem.metric);
            _weightController.text = converted.toStringAsFixed(1);
          }
        }
        _unitSystem = UnitSystem.metric;
      }
    });
    _calculateBmi();
  }

  String _getCategoryName(BmiCategory category, AppLocalizations l10n) {
    switch (category) {
      case BmiCategory.underweight:
        return l10n.underweight;
      case BmiCategory.normalWeight:
        return l10n.normalWeight;
      case BmiCategory.overweightI:
        return l10n.overweightI;
      case BmiCategory.overweightII:
        return l10n.overweightII;
      case BmiCategory.obeseI:
        return l10n.obeseI;
      case BmiCategory.obeseII:
        return l10n.obeseII;
      case BmiCategory.obeseIII:
        return l10n.obeseIII;
    }
  }

  String _getCurrentBmiRangeTitle(AppLocalizations l10n) {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) return l10n.bmiAdultTitle;

    final age = int.tryParse(ageText) ?? 18;
    return BmiService.getBmiRangeTitle(l10n, age);
  }

  String _getCurrentBmiRangeNote(AppLocalizations l10n) {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) return BmiService.getBmiRangeNote(l10n, 18);

    final age = int.tryParse(ageText) ?? 18;
    return BmiService.getBmiRangeNote(l10n, age);
  }

  List<Map<String, dynamic>> _getCurrentBmiRanges(AppLocalizations l10n) {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) return BmiService.getBmiRanges(l10n);

    final age = int.tryParse(ageText) ?? 18;
    return BmiService.getBmiRangesForAge(l10n, age);
  }

  Widget _buildBMIScaleItem(String category, String range, Color color) {
    final isCurrentCategory = _currentCalculation != null &&
        category ==
            _getCategoryName(
                _currentCalculation!.category, AppLocalizations.of(context)!);

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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Unit system toggle
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
                  SegmentedButton<UnitSystem>(
                    segments: [
                      ButtonSegment(
                        value: UnitSystem.metric,
                        label: Text(l10n.metric),
                      ),
                      ButtonSegment(
                        value: UnitSystem.imperial,
                        label: Text(l10n.imperial),
                      ),
                    ],
                    selected: {_unitSystem},
                    onSelectionChanged: (Set<UnitSystem> selection) {
                      _toggleUnitSystem();
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Personal information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.personalInfo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Gender and Age row - responsive layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWideScreen = constraints.maxWidth > 300;

                      if (isWideScreen) {
                        return Row(
                          children: [
                            // Gender section (fixed width)
                            SizedBox(
                              width: 200,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.gender,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  SegmentedButton<Gender>(
                                    segments: [
                                      ButtonSegment(
                                        value: Gender.male,
                                        label: Text(l10n.male),
                                        icon: const Icon(Icons.male),
                                      ),
                                      ButtonSegment(
                                        value: Gender.female,
                                        label: Text(l10n.female),
                                        icon: const Icon(Icons.female),
                                      ),
                                    ],
                                    selected: {_gender},
                                    onSelectionChanged:
                                        (Set<Gender> selection) {
                                      if (!mounted) return;
                                      setState(() {
                                        _gender = selection.first;
                                      });
                                      _calculateBmi();
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Age section (expanded)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.ageYears,
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _ageController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(3),
                                    ],
                                    decoration: InputDecoration(
                                      border: const OutlineInputBorder(),
                                      suffixText: l10n.age.toLowerCase(),
                                    ),
                                    onChanged: (_) => _calculateBmi(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Narrow screen - stack vertically
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gender selection
                            Text(
                              l10n.gender,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            SegmentedButton<Gender>(
                              segments: [
                                ButtonSegment(
                                  value: Gender.male,
                                  label: Text(l10n.male),
                                  icon: const Icon(Icons.male),
                                ),
                                ButtonSegment(
                                  value: Gender.female,
                                  label: Text(l10n.female),
                                  icon: const Icon(Icons.female),
                                ),
                              ],
                              selected: {_gender},
                              onSelectionChanged: (Set<Gender> selection) {
                                if (!mounted) return;
                                setState(() {
                                  _gender = selection.first;
                                });
                                _calculateBmi();
                              },
                            ),

                            const SizedBox(height: 16),

                            // Age field
                            TextField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              decoration: InputDecoration(
                                labelText: l10n.ageYears,
                                border: const OutlineInputBorder(),
                                suffixText: l10n.age.toLowerCase(),
                              ),
                              onChanged: (_) => _calculateBmi(),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Measurements
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.measurements,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Height and Weight row - responsive layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWideScreen = constraints.maxWidth > 300;

                      if (isWideScreen) {
                        return Row(
                          children: [
                            // Height field (1:1 ratio)
                            Expanded(
                              child: TextField(
                                controller: _heightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]')),
                                ],
                                decoration: InputDecoration(
                                  labelText: _unitSystem == UnitSystem.metric
                                      ? l10n.heightCm
                                      : l10n.heightInches,
                                  border: const OutlineInputBorder(),
                                  suffixText: _unitSystem == UnitSystem.metric
                                      ? 'cm'
                                      : 'in',
                                ),
                                onChanged: (_) => _calculateBmi(),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Weight field (1:1 ratio)
                            Expanded(
                              child: TextField(
                                controller: _weightController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.]')),
                                ],
                                decoration: InputDecoration(
                                  labelText: _unitSystem == UnitSystem.metric
                                      ? l10n.weightKg
                                      : l10n.weightPounds,
                                  border: const OutlineInputBorder(),
                                  suffixText: _unitSystem == UnitSystem.metric
                                      ? 'kg'
                                      : 'lbs',
                                ),
                                onChanged: (_) => _calculateBmi(),
                              ),
                            ),
                          ],
                        );
                      } else {
                        // Narrow screen - stack vertically
                        return Column(
                          children: [
                            TextField(
                              controller: _heightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              decoration: InputDecoration(
                                labelText: _unitSystem == UnitSystem.metric
                                    ? l10n.heightCm
                                    : l10n.heightInches,
                                border: const OutlineInputBorder(),
                                suffixText: _unitSystem == UnitSystem.metric
                                    ? 'cm'
                                    : 'in',
                              ),
                              onChanged: (_) => _calculateBmi(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _weightController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]')),
                              ],
                              decoration: InputDecoration(
                                labelText: _unitSystem == UnitSystem.metric
                                    ? l10n.weightKg
                                    : l10n.weightPounds,
                                border: const OutlineInputBorder(),
                                suffixText: _unitSystem == UnitSystem.metric
                                    ? 'kg'
                                    : 'lbs',
                              ),
                              onChanged: (_) => _calculateBmi(),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Results
          if (_currentCalculation != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.bmiResults,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        // Manual save button
                        if (widget.onSaveToHistory != null)
                          IconButton(
                            onPressed: () {
                              final height =
                                  double.tryParse(_heightController.text);
                              final weight =
                                  double.tryParse(_weightController.text);
                              final age = int.tryParse(_ageController.text);

                              if (height != null &&
                                  weight != null &&
                                  age != null) {
                                widget.onSaveToHistory!(
                                  BmiData(
                                    height: height,
                                    weight: weight,
                                    age: age,
                                    gender: _gender,
                                    unitSystem: _unitSystem,
                                    calculatedAt: DateTime.now(),
                                  ),
                                  _currentCalculation!,
                                );
                              }
                            },
                            icon: const Icon(Icons.add),
                            tooltip: l10n.saveToHistory,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentCalculation!.bmi.toStringAsFixed(1),
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _currentCalculation!.categoryColor,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentCalculation!.categoryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _currentCalculation!.categoryColor),
                      ),
                      child: Text(
                        _getCategoryName(_currentCalculation!.category, l10n),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: _currentCalculation!.categoryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _currentCalculation!.interpretation,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recommendations
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recommendations,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ..._currentCalculation!.recommendations.map(
                      (rec) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.fiber_manual_record,
                              size: 8,
                              color: _currentCalculation!.categoryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                rec,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // BMI Scale reference
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
                    const SizedBox(height: 8),
                    // Dynamic title and note based on age
                    Text(
                      _getCurrentBmiRangeTitle(l10n),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCurrentBmiRangeNote(l10n),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Dynamic BMI ranges based on age
                    ..._getCurrentBmiRanges(l10n).map(
                      (range) => _buildBMIScaleItem(
                        range['category'],
                        range['range'],
                        range['color'],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
