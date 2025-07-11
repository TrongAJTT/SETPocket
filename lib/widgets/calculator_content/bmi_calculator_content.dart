import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/calculator_models/bmi_models.dart';
import 'package:setpocket/services/calculator_services/bmi_service.dart';
import 'package:setpocket/utils/widget_layout_render_helper.dart';
import 'package:setpocket/widgets/generic/number_stepper.dart';

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

  // Age group instead of exact age
  AgeGroup _ageGroup = AgeGroup.adult18Plus;

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
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await BmiService.getPreferences();
    final savedState = await BmiService.getCalculatorState();

    if (!mounted) return;

    setState(() {
      _unitSystem = UnitSystem.values[prefs['unitSystem'] ?? 0];
      _autoSaveToHistory = prefs['autoSaveToHistory'] ?? false;
      _rememberLastValues = prefs['rememberLastValues'] ?? true;
    });

    // Load from saved state if available and remember last values is enabled
    if (_rememberLastValues && savedState != null) {
      final height = savedState['height'];
      final weight = savedState['weight'];
      final ageGroup = savedState['ageGroup'];
      final gender = savedState['gender'];

      if (height != null) _heightController.text = height.toString();
      if (weight != null) _weightController.text = weight.toString();
      if (ageGroup != null) _ageGroup = AgeGroup.values[ageGroup];
      if (gender != null) _gender = Gender.values[gender];

      // Also load unit system and auto-calculate if we have values
      if (savedState['unitSystem'] != null) {
        _unitSystem = UnitSystem.values[savedState['unitSystem']];
      }

      // Auto-calculate if we have saved height and weight
      if (height != null && weight != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _calculateBmi();
        });
      }
    } else if (_rememberLastValues) {
      // Fallback to preferences if no saved state
      final height = prefs['lastHeight'];
      final weight = prefs['lastWeight'];
      final ageGroup = prefs['lastAgeGroup'];
      final gender = prefs['lastGender'];

      if (height != null) _heightController.text = height.toString();
      if (weight != null) _weightController.text = weight.toString();
      if (ageGroup != null) _ageGroup = AgeGroup.values[ageGroup];
      if (gender != null) _gender = Gender.values[gender];
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
        _weightController.text.isNotEmpty) {
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);
      if (height != null) prefs['lastHeight'] = height;
      if (weight != null) prefs['lastWeight'] = weight;
      prefs['lastAgeGroup'] = _ageGroup.index;
      prefs['lastGender'] = _gender.index;
    }

    await BmiService.savePreferences(prefs);
  }

  Future<void> _saveCalculatorState() async {
    try {
      final height = double.tryParse(_heightController.text);
      final weight = double.tryParse(_weightController.text);

      await BmiService.saveCalculatorState(
        height: height,
        weight: weight,
        ageGroup: _ageGroup,
        unitSystem: _unitSystem,
        gender: _gender,
        lastCalculation: _currentCalculation,
      );
    } catch (e) {
      debugPrint('Error saving calculator state: $e');
    }
  }

  void _calculateBmi() {
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty) {
      if (!mounted) return;
      setState(() {
        _currentCalculation = null;
      });
      return;
    }

    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      if (!mounted) return;
      setState(() {
        _currentCalculation = null;
      });
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final calculation = BmiService.calculateBmi(
        height, weight, _ageGroup, _gender, _unitSystem, l10n);

    if (!mounted) return;
    setState(() {
      _currentCalculation = calculation;
    });
  }

  void _onBookmarkPressed() {
    if (_currentCalculation == null) return;

    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();
    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (height == null || weight == null) return;

    final bmiData = BmiData.create(
      height: height,
      weight: weight,
      ageGroup: _ageGroup,
      unitSystem: _unitSystem,
      gender: _gender,
      calculatedAt: DateTime.now(),
    );

    widget.onSaveToHistory?.call(bmiData, _currentCalculation!);
  }

  void _onCalculatePressed() {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    _calculateBmi();

    // Save both preferences and state when the user explicitly calculates.
    _savePreferences();
    _saveCalculatorState();

    if (_currentCalculation != null) {
      widget.onCalculationChanged?.call(_currentCalculation!);

      // Auto-save to history if enabled
      if (_autoSaveToHistory) {
        final height = double.tryParse(_heightController.text);
        final weight = double.tryParse(_weightController.text);
        if (height != null && weight != null) {
          final bmiData = BmiData.create(
            height: height,
            weight: weight,
            ageGroup: _ageGroup,
            gender: _gender,
            unitSystem: _unitSystem,
            calculatedAt: DateTime.now(),
          );
          widget.onSaveToHistory?.call(bmiData, _currentCalculation!);
        }
      }
    }
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
    return BmiService.getBmiRangeTitle(l10n, _ageGroup);
  }

  String _getCurrentBmiRangeNote(AppLocalizations l10n) {
    return BmiService.getBmiRangeNote(l10n, _ageGroup);
  }

  List<Map<String, dynamic>> _getCurrentBmiRanges(AppLocalizations l10n) {
    return BmiService.getBmiRangesForAgeGroup(l10n, _ageGroup);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Unit system toggle
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: WidgetLayoutRenderHelper.twoEqualWidthInRow(
                // Left side - Units label
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.units,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                // Right side - SegmentedButton spanning full width
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<UnitSystem>(
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
                ),
                minWidth: 300,
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

                  // Gender and Age row using TwoInARow layout
                  WidgetLayoutRenderHelper.twoEqualWidthInRow(
                    // Gender section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                          },
                        ),
                      ],
                    ),
                    // Age section using SegmentedButton
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.ageGroup,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<AgeGroup>(
                          segments: [
                            ButtonSegment(
                              value: AgeGroup.under18,
                              label: Text(l10n.ageUnder18),
                            ),
                            ButtonSegment(
                              value: AgeGroup.adult18Plus,
                              label: Text(l10n.age18Plus),
                            ),
                          ],
                          selected: {_ageGroup},
                          onSelectionChanged: (Set<AgeGroup> selection) {
                            if (!mounted) return;
                            setState(() {
                              _ageGroup = selection.first;
                            });
                          },
                        ),
                      ],
                    ),
                    minWidth: 500,
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

                  // Height and Weight input
                  WidgetLayoutRenderHelper.twoEqualWidthInRow(
                    // Height input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _unitSystem == UnitSystem.metric
                              ? l10n.heightCm
                              : l10n.heightInches,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: InputDecoration(
                            hintText:
                                _unitSystem == UnitSystem.metric ? '170' : '67',
                            border: const OutlineInputBorder(),
                            suffixText:
                                _unitSystem == UnitSystem.metric ? 'cm' : 'in',
                          ),
                        ),
                      ],
                    ),
                    // Weight input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _unitSystem == UnitSystem.metric
                              ? l10n.weightKg
                              : l10n.weightPounds,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')),
                          ],
                          decoration: InputDecoration(
                            hintText:
                                _unitSystem == UnitSystem.metric ? '70' : '154',
                            border: const OutlineInputBorder(),
                            suffixText:
                                _unitSystem == UnitSystem.metric ? 'kg' : 'lbs',
                          ),
                        ),
                      ],
                    ),
                    minWidth: 500,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Calculate button
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _onCalculatePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.calculate,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
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
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, left: 12.0),
                            child: TextButton.icon(
                              icon: const Icon(Icons.bookmark_add_outlined),
                              label: Text(l10n.bookmark),
                              onPressed: _onBookmarkPressed,
                            ),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Icon(
                                Icons.fiber_manual_record,
                                size: 8,
                                color: _currentCalculation!.categoryColor,
                              ),
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
