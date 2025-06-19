import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/bmi_models.dart';
import 'package:setpocket/services/bmi_service.dart';
import 'package:setpocket/services/graphing_calculator_service.dart';
import 'package:setpocket/widgets/calculator_layout.dart';
import 'package:setpocket/widgets/calculator_content/bmi_calculator_content.dart';

class BmiCalculatorScreen extends StatefulWidget {
  final bool isEmbedded;

  const BmiCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  bool _historyEnabled = false;
  bool _hasHistoryData = false;
  final GlobalKey<_BmiHistoryWidgetState> _historyWidgetKey =
      GlobalKey<_BmiHistoryWidgetState>();

  @override
  void initState() {
    super.initState();
    _loadHistorySettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload history when returning to this screen (e.g., from settings)
    _loadHistorySettings();
  }

  Future<void> _loadHistorySettings() async {
    final enabled = await GraphingCalculatorService.getRememberHistory();
    final history = await BmiService.getHistory();
    if (mounted) {
      setState(() {
        _historyEnabled = enabled;
        _hasHistoryData = history.isNotEmpty;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final calculatorLayout = NewCalculatorLayout(
      calculatorContent: BmiCalculatorContent(
        onSaveToHistory: (bmiData, calculation) async {
          try {
            // Save to BMI history
            final historyEntry = BmiHistoryEntry(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              data: bmiData,
              calculation: calculation,
            );

            await BmiService.saveToHistory(historyEntry);

            // Refresh history widget directly
            _historyWidgetKey.currentState?.refreshHistory();
            // Update history data flag
            _loadHistorySettings();

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.saved)),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
      ),
      historyWidget: _historyEnabled
          ? _BmiHistoryWidget(key: _historyWidgetKey, showHeader: false)
          : null,
      historyEnabled: _historyEnabled,
      hasHistory: _historyEnabled,
      isEmbedded: widget.isEmbedded,
      title: l10n.bmiCalculator,
      onShowInfo: () => _showBmiInfo(context),
      onClearHistory: () async {
        await BmiService.clearHistory();
        _historyWidgetKey.currentState?.refreshHistory();
        _loadHistorySettings();
      },
      hasHistoryData: _hasHistoryData,
      clearHistoryMessage: l10n.confirmClearHistory, // BMI-specific message
      historyClearedMessage:
          l10n.historyCleared, // BMI-specific success message
    );

    // Return the calculator layout directly - NewCalculatorLayout handles Scaffold internally
    return calculatorLayout;
  }

  void _showBmiInfo(BuildContext context) {
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
                                  'BMI = Weight (kg) / [Height (m)]²',
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
            'Age Considerations:',
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
}

class _BmiHistoryWidget extends StatefulWidget {
  final bool showHeader;

  const _BmiHistoryWidget({super.key, this.showHeader = true});

  @override
  State<_BmiHistoryWidget> createState() => _BmiHistoryWidgetState();
}

class _BmiHistoryWidgetState extends State<_BmiHistoryWidget> {
  List<BmiHistoryEntry> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
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
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: entry.calculation.categoryColor
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: entry.calculation.categoryColor),
                        ),
                        child: Text(
                          entry.calculation.bmi.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: entry.calculation.categoryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getCategoryName(entry.calculation.category, l10n),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
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
            Text(
              '${BmiService.formatHeight(entry.data.height, entry.data.unitSystem)} • ${BmiService.formatWeight(entry.data.weight, entry.data.unitSystem)} • ${entry.data.age} ${l10n.age.toLowerCase()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(entry.data.calculatedAt),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // History header with consistent styling
        if (widget.showHeader)
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

  Future<void> _loadHistory() async {
    final history = await BmiService.getHistory();
    setState(() {
      _history = history;
    });
  }

  void refreshHistory() {
    _loadHistory();
  }
}
