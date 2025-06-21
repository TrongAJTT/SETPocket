import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/bmi_models.dart';
import 'package:setpocket/services/calculator_services/bmi_service.dart';
import 'package:setpocket/services/graphing_calculator_service.dart';
import 'package:setpocket/widgets/calculator_layout.dart';
import 'package:setpocket/widgets/calculator_content/bmi_calculator_content.dart';
import 'package:setpocket/widgets/generic_info_dialog.dart';

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

    GenericInfoDialog.show(
      context: context,
      title: l10n.bmiDetailedInfo,
      overview: l10n.bmiOverview,
      headerIcon: Icons.monitor_weight,
      sections: [
        // BMI Formula
        InfoSection(
          title: l10n.bmiFormula,
          icon: Icons.calculate,
          color: Colors.indigo,
          children: [
            GenericInfoDialog.buildBmiFormula(
                theme, 'BMI = Weight (kg) / [Height (m)]²'),
          ],
        ),

        // Key Features
        InfoSection(
          title: l10n.bmiKeyFeatures,
          icon: Icons.star_outline,
          color: Colors.orange,
          children: [
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.comprehensiveBmiCalc,
                description: l10n.comprehensiveBmiCalcDesc,
                icon: Icons.calculate,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.multipleUnitSystems,
                description: l10n.multipleUnitSystemsDesc,
                icon: Icons.straighten,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.healthInsights,
                description: l10n.healthInsightsDesc,
                icon: Icons.insights,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.calculationHistory,
                description: l10n.calculationHistoryDesc,
                icon: Icons.history,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.ageGenderConsideration,
                description: l10n.ageGenderConsiderationDesc,
                icon: Icons.people,
              ),
            ),
          ],
        ),

        // How to Use
        InfoSection(
          title: l10n.bmiHowToUse,
          icon: Icons.help_outline,
          color: Colors.blue,
          children: [
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(step: l10n.step1Bmi, description: l10n.step1BmiDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(step: l10n.step2Bmi, description: l10n.step2BmiDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(step: l10n.step3Bmi, description: l10n.step3BmiDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(step: l10n.step4Bmi, description: l10n.step4BmiDesc),
            ),
          ],
        ),

        // BMI Scale
        InfoSection(
          title: l10n.bmiScale,
          icon: Icons.category,
          color: Colors.purple,
          children: [
            // Adult BMI Scale
            GenericInfoDialog.buildBmiScaleHeader(theme, l10n.bmiAdultTitle),
            ...BmiService.getBmiRangesForAge(l10n, 18)
                .map((range) => GenericInfoDialog.buildBmiRangeItem(
                      theme: theme,
                      category: range['category'],
                      range: range['range'],
                      color: range['color'],
                      description: range['description'],
                    ))
                .toList(),

            const SizedBox(height: 16),

            // Pediatric BMI Scale
            GenericInfoDialog.buildBmiScaleHeader(
                theme, l10n.bmiPediatricTitle),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                l10n.bmiPercentileNote,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            ...BmiService.getBmiRangesForAge(l10n, 16)
                .map((range) => GenericInfoDialog.buildBmiRangeItem(
                      theme: theme,
                      category: range['category'],
                      range: range['range'],
                      color: range['color'],
                      description: range['description'],
                    ))
                .toList(),

            GenericInfoDialog.buildAgeConsiderations(
              theme: theme,
              elderlyNote: l10n.bmiElderlyNote,
              youthNote: l10n.bmiYouthNote,
            ),
          ],
        ),

        // Health Tips
        InfoSection(
          title: l10n.bmiTips,
          icon: Icons.lightbulb_outline,
          color: Colors.green,
          children: [
            GenericInfoDialog.buildTipItem(theme, l10n.tip1Bmi),
            GenericInfoDialog.buildTipItem(theme, l10n.tip2Bmi),
            GenericInfoDialog.buildTipItem(theme, l10n.tip3Bmi),
            GenericInfoDialog.buildTipItem(theme, l10n.tip4Bmi),
            GenericInfoDialog.buildTipItem(theme, l10n.tip5Bmi),
          ],
        ),

        // Limitations
        InfoSection(
          title: l10n.bmiLimitations,
          icon: Icons.warning_outlined,
          color: Colors.amber,
          children: [
            GenericInfoDialog.buildBulletList(
              theme: theme,
              description: l10n.bmiLimitationsDesc,
              items: BmiService.getBmiDetailedInfo(l10n)['limitations']
                  .map<String>((limitation) => limitation.toString())
                  .toList(),
            ),
          ],
        ),

        // When to Consult Healthcare Professionals
        InfoSection(
          title: l10n.bmiPracticalApplications,
          icon: Icons.medical_services,
          color: Colors.teal,
          children: [
            GenericInfoDialog.buildBulletList(
              theme: theme,
              description: l10n.bmiPracticalApplicationsDesc,
              items: BmiService.getBmiDetailedInfo(l10n)['whenToConsult']
                  .map<String>((consultation) => consultation.toString())
                  .toList(),
            ),
          ],
        ),

        // Disclaimer
        InfoSection(
          title: 'Important Notice',
          icon: Icons.info_outline,
          color: Colors.red,
          children: [
            GenericInfoDialog.buildDisclaimer(
              theme: theme,
              text: l10n.bmiLimitationReminder,
            ),
          ],
        ),
      ],
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
