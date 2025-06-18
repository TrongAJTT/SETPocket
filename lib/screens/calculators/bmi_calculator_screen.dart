import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/bmi_models.dart';
import '../../services/bmi_service.dart';
import '../../widgets/calculator_layout.dart';

class BmiCalculatorScreen extends StatefulWidget {
  final bool isEmbedded;

  const BmiCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen>
    with TickerProviderStateMixin {
  // Form controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  // State variables
  UnitSystem _unitSystem = UnitSystem.metric;
  Gender _gender = Gender.male;
  BmiCalculation? _currentCalculation;
  List<BmiHistoryEntry> _history = [];
  bool _autoSaveToHistory = false;
  bool _rememberLastValues = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadHistory();
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

  Future<void> _loadHistory() async {
    final history = await BmiService.getHistory();
    setState(() {
      _history = history;
    });
  }

  void _calculateBmi() {
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();
    final ageText = _ageController.text.trim();

    if (heightText.isEmpty || weightText.isEmpty || ageText.isEmpty) {
      setState(() {
        _currentCalculation = null;
      });
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
      setState(() {
        _currentCalculation = null;
      });
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final calculation = BmiService.calculateBmi(
        height, weight, age, _gender, _unitSystem, l10n);

    setState(() {
      _currentCalculation = calculation;
    });

    // Removed auto-save functionality completely
    _savePreferences();
  }

  Future<void> _saveCalculationToHistory(BmiCalculation calculation) async {
    final height = double.parse(_heightController.text);
    final weight = double.parse(_weightController.text);
    final age = int.parse(_ageController.text);

    final data = BmiData(
      height: height,
      weight: weight,
      age: age,
      gender: _gender,
      unitSystem: _unitSystem,
      calculatedAt: DateTime.now(),
    );

    final entry = BmiHistoryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      data: data,
      calculation: calculation,
    );

    await BmiService.saveToHistory(entry);
    await _loadHistory();
  }

  void _toggleUnitSystem() {
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

  void _showBmiInfo() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: isDesktop ? 700 : screenWidth * 0.9,
          height: isDesktop ? 800 : MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.monitor_weight,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.bmiDetailedInfo,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.bmiOverview,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onPrimary
                                  .withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BMI Formula
                      _buildInfoSection(
                        theme,
                        l10n.bmiFormula,
                        Icons.calculate,
                        Colors.indigo,
                        [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        Colors.indigo.withValues(alpha: 0.3)),
                              ),
                              child: Center(
                                child: Text(
                                  'BMI = Cân nặng (kg) / [Chiều cao (m)]²',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Key Features
                      _buildInfoSection(
                        theme,
                        l10n.bmiKeyFeatures,
                        Icons.star_outline,
                        Colors.orange,
                        [
                          _buildFeatureItem(theme, l10n.comprehensiveBmiCalc,
                              l10n.comprehensiveBmiCalcDesc, Icons.calculate),
                          _buildFeatureItem(theme, l10n.multipleUnitSystems,
                              l10n.multipleUnitSystemsDesc, Icons.straighten),
                          _buildFeatureItem(theme, l10n.healthInsights,
                              l10n.healthInsightsDesc, Icons.insights),
                          _buildFeatureItem(theme, l10n.calculationHistory,
                              l10n.calculationHistoryDesc, Icons.history),
                          _buildFeatureItem(theme, l10n.ageGenderConsideration,
                              l10n.ageGenderConsiderationDesc, Icons.people),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // How to Use
                      _buildInfoSection(
                        theme,
                        l10n.bmiHowToUse,
                        Icons.help_outline,
                        Colors.blue,
                        [
                          _buildStepItem(
                              theme, l10n.step1Bmi, l10n.step1BmiDesc),
                          _buildStepItem(
                              theme, l10n.step2Bmi, l10n.step2BmiDesc),
                          _buildStepItem(
                              theme, l10n.step3Bmi, l10n.step3BmiDesc),
                          _buildStepItem(
                              theme, l10n.step4Bmi, l10n.step4BmiDesc),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // BMI Scale with enhanced information
                      _buildInfoSection(
                        theme,
                        l10n.bmiScale,
                        Icons.category,
                        Colors.purple,
                        [
                          // Adult BMI Scale
                          _buildBmiScaleHeader(theme, l10n.bmiAdultTitle),
                          ...BmiService.getBmiRangesForAge(l10n, 18)
                              .map((range) => _buildBmiRangeItem(
                                    theme,
                                    range['category'],
                                    range['range'],
                                    range['color'],
                                    range['description'],
                                  ))
                              .toList(),

                          const SizedBox(height: 16),

                          // Pediatric BMI Scale
                          _buildBmiScaleHeader(theme, l10n.bmiPediatricTitle),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            child: Text(
                              l10n.bmiPercentileNote,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          ...BmiService.getBmiRangesForAge(l10n, 16)
                              .map((range) => _buildBmiRangeItem(
                                    theme,
                                    range['category'],
                                    range['range'],
                                    range['color'],
                                    range['description'],
                                  ))
                              .toList(),

                          _buildAgeConsiderations(theme, l10n),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Health Tips
                      _buildInfoSection(
                        theme,
                        l10n.bmiTips,
                        Icons.lightbulb_outline,
                        Colors.green,
                        [
                          _buildTipItem(theme, l10n.tip1Bmi),
                          _buildTipItem(theme, l10n.tip2Bmi),
                          _buildTipItem(theme, l10n.tip3Bmi),
                          _buildTipItem(theme, l10n.tip4Bmi),
                          _buildTipItem(theme, l10n.tip5Bmi),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Limitations with detailed information
                      _buildInfoSection(
                        theme,
                        l10n.bmiLimitations,
                        Icons.warning_outlined,
                        Colors.amber,
                        [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.bmiLimitationsDesc,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                ...BmiService.getBmiDetailedInfo(
                                        l10n)['limitations']
                                    .map<Widget>((limitation) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          child: Text(
                                            "• $limitation",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // When to Consult Healthcare Professionals
                      _buildInfoSection(
                        theme,
                        l10n.bmiPracticalApplications,
                        Icons.medical_services,
                        Colors.teal,
                        [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.bmiPracticalApplicationsDesc,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 12),
                                ...BmiService.getBmiDetailedInfo(
                                        l10n)['whenToConsult']
                                    .map<Widget>((consultation) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          child: Text(
                                            "• $consultation",
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Disclaimer
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                theme.colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.bmiLimitationReminder,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  border: Border(
                    top: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.close),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
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

  Widget _buildInfoSection(ThemeData theme, String title, IconData icon,
      Color color, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      ThemeData theme, String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(ThemeData theme, String step, String description) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step.substring(5, 6), // Extract step number
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(ThemeData theme, String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Text(
        "• $tip",
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildBmiRangeItem(ThemeData theme, String category, String range,
      Color color, String description) {
    return Padding(
      padding: const EdgeInsets.all(8),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      range,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiScaleHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAgeConsiderations(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Lưu ý theo độ tuổi:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.bmiElderlyNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.bmiYouthNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // For Desktop: Pure calculator content without tabs
    final desktopCalculatorContent = _buildCalculatorTab(l10n);

    // For Mobile: Just return calculator content, no tabs needed since CalculatorLayout handles it
    final mobileContent =
        _buildCalculatorTab(l10n); // No more tab layout on mobile

    // History widget for desktop side panel
    final historyWidget = _buildHistoryWidget(l10n);

    return CalculatorLayout(
      calculatorContent: desktopCalculatorContent,
      mobileContent: mobileContent, // Mobile gets same content as desktop
      historyWidget: historyWidget,
      historyEnabled: true,
      hasHistory: _history.isNotEmpty,
      isEmbedded: widget.isEmbedded,
      title: l10n.bmiCalculator,
      onShowInfo: _showBmiInfo,
    );
  }

  Widget _buildHistoryWidget(AppLocalizations l10n) {
    return Column(
      children: [
        // History header with consistent styling
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.bmiHistoryTab,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (_history.isNotEmpty)
                IconButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.clearBmiHistory),
                        content: Text(l10n.confirmClearHistory),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(l10n.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(l10n.delete),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await BmiService.clearHistory();
                      await _loadHistory();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.historyCleared)),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  tooltip: l10n.clearBmiHistory,
                ),
            ],
          ),
        ),

        // History content
        Expanded(
          child: _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noHistoryYet,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          l10n.noHistoryMessage,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final entry = _history[index];
                    return _buildCompactHistoryItem(l10n, entry);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompactHistoryItem(
      AppLocalizations l10n, BmiHistoryEntry entry) {
    final dateFormat = DateFormat('dd/MM HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(entry.data.calculatedAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await BmiService.removeFromHistory(entry.id);
                    await _loadHistory();
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  tooltip: l10n.delete,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        entry.calculation.categoryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: entry.calculation.categoryColor),
                  ),
                  child: Text(
                    entry.calculation.bmi.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: entry.calculation.categoryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getCategoryName(entry.calculation.category, l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${BmiService.formatHeight(entry.data.height, entry.data.unitSystem)} • ${BmiService.formatWeight(entry.data.weight, entry.data.unitSystem)} • ${entry.data.age} ${l10n.age.toLowerCase()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorTab(AppLocalizations l10n) {
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
                                      labelText: l10n.ageYears,
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
                        IconButton(
                          onPressed: () async {
                            if (_currentCalculation != null) {
                              // Check if this calculation is already in history
                              final isDuplicate = await _isCalculationDuplicate(
                                  _currentCalculation!);
                              if (!isDuplicate) {
                                await _saveCalculationToHistory(
                                    _currentCalculation!);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l10n.saved)),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Kết quả này đã có trong lịch sử')),
                                  );
                                }
                              }
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

  String _getGenderName(Gender gender, AppLocalizations l10n) {
    switch (gender) {
      case Gender.male:
        return l10n.male;
      case Gender.female:
        return l10n.female;
      case Gender.other:
        return l10n.other;
    }
  }

  String _getCurrentBmiRangeTitle(AppLocalizations l10n) {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty) return l10n.bmiAdultTitle; // Default to adult

    final age = int.tryParse(ageText) ?? 18;
    return BmiService.getBmiRangeTitle(l10n, age);
  }

  String _getCurrentBmiRangeNote(AppLocalizations l10n) {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty)
      return BmiService.getBmiRangeNote(l10n, 18); // Default to adult

    final age = int.tryParse(ageText) ?? 18;
    return BmiService.getBmiRangeNote(l10n, age);
  }

  List<Map<String, dynamic>> _getCurrentBmiRanges(AppLocalizations l10n) {
    final ageText = _ageController.text.trim();
    if (ageText.isEmpty)
      return BmiService.getBmiRanges(l10n); // Default to adult

    final age = int.tryParse(ageText) ?? 18;
    return BmiService.getBmiRangesForAge(l10n, age);
  }

  Future<bool> _isCalculationDuplicate(BmiCalculation calculation) async {
    final history = await BmiService.getHistory();
    return history.any((entry) =>
        entry.calculation.bmi == calculation.bmi &&
        entry.calculation.category == calculation.category);
  }
}
