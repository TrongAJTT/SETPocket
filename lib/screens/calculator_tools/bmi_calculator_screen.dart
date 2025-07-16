import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/layouts/two_panels_layout.dart';
import 'package:setpocket/models/calculator_models/bmi_models.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/services/calculator_services/bmi_service.dart';
import 'package:setpocket/services/function_info_service.dart';
import 'package:setpocket/services/settings_models_service.dart';
import 'package:setpocket/widgets/calculator_content/bmi_calculator_content.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/utils/generic_dialog_utils.dart';
import 'dart:convert'; // Added for jsonDecode

class BmiCalculatorScreen extends StatefulWidget {
  final bool isEmbedded;

  const BmiCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  State<BmiCalculatorScreen> createState() => _BmiCalculatorScreenState();
}

class _BmiCalculatorScreenState extends State<BmiCalculatorScreen> {
  bool _historyEnabled = false;
  int _bookmarkCount = 0;
  final GlobalKey<_BmiHistoryWidgetState> _historyWidgetKey =
      GlobalKey<_BmiHistoryWidgetState>();

  @override
  void initState() {
    super.initState();
    _loadHistorySettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Build actions cho main panel (clear history button)
  List<Widget> _buildRightPanelActions() {
    final actions = <Widget>[];

    // Chỉ add clear history action nếu có bookmark
    if (_bookmarkCount > 1) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.delete_sweep_outlined),
          tooltip: AppLocalizations.of(context)!.clearAllBookmarks,
          onPressed: () => _showClearAllConfirmation(context),
        ),
      );
    }

    return actions;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload history when returning to this screen (e.g., from settings)
    _loadHistorySettings();
  }

  Future<void> _loadHistorySettings() async {
    final settings =
        await ExtensibleSettingsService.getCalculatorToolsSettings();
    final history = await BmiService.getHistory();
    if (mounted) {
      setState(() {
        _historyEnabled = settings.rememberHistory;
        _bookmarkCount = history.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEmbedded = widget.isEmbedded;

    return TwoPanelsLayout(
      title: l10n.bmiCalculator,
      isEmbedded: isEmbedded,
      mainPanel: _buildBmiCalculator(l10n),
      rightPanel: _historyEnabled
          ? _BmiHistoryWidget(key: _historyWidgetKey, showHeader: false)
          : null,
      mainPanelTitle: l10n.bmiCalculator,
      rightPanelTitle: l10n.bookmark,
      mainPanelActions: _buildMainPanelActions(),
      rightPanelActions: _buildRightPanelActions(), // Unified actions!
      // onShowInfo: () => _showBmiInfo(context),
    );
  }

  void _showClearAllConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await GenericDialogUtils.showClearAllBookmarksDialog(
      context: context,
      onConfirm: () async {
        await BmiService.clearHistory();
        _historyWidgetKey.currentState?.refreshHistory();
        setState(() {
          _bookmarkCount = 0;
        });
      },
    );

    if (confirmed == true && mounted) {
      SnackbarUtils.showTyped(
        // ignore: use_build_context_synchronously
        context,
        l10n.clearAllBookmarksSuccess,
        SnackBarType.success,
      );
    }
  }

  Widget _buildBmiCalculator(AppLocalizations l10n) {
    return BmiCalculatorContent(
      onSaveToHistory: (bmiData, calculation) async {
        if (!_historyEnabled) return;
        try {
          // Save to BMI history
          final historyEntry = BmiHistoryEntry.create(
            data: bmiData,
            calculationData: BmiCalculationData.create(
              bmi: calculation.bmi,
              category: calculation.category,
              interpretation: calculation.interpretation,
              recommendations: calculation.recommendations,
            ),
          );

          await BmiService.saveToHistory(historyEntry);

          // Refresh history widget directly
          _historyWidgetKey.currentState?.refreshHistory();
          // Update history data flag
          _loadHistorySettings();
          setState(() {
            _bookmarkCount++;
          });

          if (context.mounted) {
            SnackbarUtils.showTyped(
              // ignore: use_build_context_synchronously
              context,
              l10n.saved,
              SnackBarType.success,
            );
          }
        } catch (e) {
          if (context.mounted) {
            SnackbarUtils.showTyped(
              // ignore: use_build_context_synchronously
              context,
              'Error: $e',
              SnackBarType.error,
            );
          }
        }
      },
    );
  }

  List<Widget> _buildMainPanelActions() {
    return [
      IconButton(
        icon: const Icon(Icons.info),
        tooltip: AppLocalizations.of(context)!.info,
        onPressed: () {
          // Show BMI info dialog
          _showBmiInfo(context);
        },
      ),
    ];
  }

  void _showBmiInfo(BuildContext context) {
    FunctionInfo.show(context, FunctionInfoKeys.bmiCalculator);
  }
}

class _BmiHistoryWidget extends StatefulWidget {
  final bool showHeader;

  const _BmiHistoryWidget({super.key, this.showHeader = true});

  @override
  State<_BmiHistoryWidget> createState() => _BmiHistoryWidgetState();
}

class _BmiHistoryWidgetState extends State<_BmiHistoryWidget> {
  List<UnifiedHistoryData> _history = [];

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
      AppLocalizations l10n, UnifiedHistoryData item) {
    final dateFormat = DateFormat('dd/MM HH:mm');

    // Parse the data from UnifiedHistoryData following the unified format
    Map<String, dynamic> valueData = {};
    try {
      valueData = jsonDecode(item.value) as Map<String, dynamic>;
    } catch (e) {
      // Handle legacy format or parsing errors
      valueData = {'inputsData': {}, 'resultsData': {}};
    }

    final resultsData =
        Map<String, dynamic>.from(valueData['resultsData'] ?? {});
    final inputsData = Map<String, dynamic>.from(valueData['inputsData'] ?? {});

    // Extract BMI data with null safety
    final bmi = (resultsData['bmi'] as num?)?.toDouble() ?? 0.0;
    final categoryName = resultsData['category'] as String? ?? 'normalWeight';

    // Parse category from string
    BmiCategory category = BmiCategory.normalWeight;
    try {
      category = BmiCategory.values.firstWhere(
        (e) => e.name == categoryName,
        orElse: () => BmiCategory.normalWeight,
      );
    } catch (e) {
      category = BmiCategory.normalWeight;
    }

    final height = (inputsData['height'] as num?)?.toDouble() ?? 0.0;
    final weight = (inputsData['weight'] as num?)?.toDouble() ?? 0.0;
    final ageGroupName = inputsData['ageGroup'] as String? ?? 'adult18Plus';
    final unitSystemName = inputsData['unitSystem'] as String? ?? 'metric';

    // Parse enums from strings
    AgeGroup ageGroup = AgeGroup.adult18Plus;
    try {
      ageGroup = AgeGroup.values.firstWhere(
        (e) => e.name == ageGroupName,
        orElse: () => AgeGroup.adult18Plus,
      );
    } catch (e) {
      ageGroup = AgeGroup.adult18Plus;
    }

    UnitSystem unitSystem = UnitSystem.metric;
    try {
      unitSystem = UnitSystem.values.firstWhere(
        (e) => e.name == unitSystemName,
        orElse: () => UnitSystem.metric,
      );
    } catch (e) {
      unitSystem = UnitSystem.metric;
    }

    // Get color from helper method
    final categoryColor = _getCategoryColor(category);

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
                          color: categoryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: categoryColor),
                        ),
                        child: Text(
                          bmi.toStringAsFixed(1),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: categoryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getCategoryName(category, l10n),
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
                    final description =
                        '${l10n.confirmDelete} BMI ${bmi.toStringAsFixed(1)} (${_getCategoryName(category, l10n)})?';

                    final confirmed =
                        await GenericDialogUtils.showSimpleGenericClearDialog(
                      context: context,
                      title: l10n.delete,
                      description: description,
                      onConfirm: () async {
                        // The dialog handles the async action
                      },
                    );

                    if (confirmed == true) {
                      try {
                        await BmiService.removeFromHistory(item.id.toString());
                        await _loadHistory();
                        if (context.mounted) {
                          SnackbarUtils.showTyped(
                            // ignore: use_build_context_synchronously
                            context,
                            l10n.historyItemDeleted,
                            SnackBarType.success,
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          SnackbarUtils.showTyped(
                            // ignore: use_build_context_synchronously
                            context,
                            'Error: $e',
                            SnackBarType.error,
                          );
                        }
                      }
                    }
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
              '${BmiService.formatHeight(height, unitSystem)} • ${BmiService.formatWeight(weight, unitSystem)} • ${ageGroup == AgeGroup.under18 ? l10n.ageUnder18 : l10n.age18Plus}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(item.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get category color
  Color _getCategoryColor(BmiCategory category) {
    switch (category) {
      case BmiCategory.underweight:
        return Colors.blue;
      case BmiCategory.normalWeight:
        return Colors.green;
      case BmiCategory.overweightI:
        return Colors.orange;
      case BmiCategory.overweightII:
        return Colors.orange.shade700;
      case BmiCategory.obeseI:
        return Colors.red;
      case BmiCategory.obeseII:
        return Colors.red.shade700;
      case BmiCategory.obeseIII:
        return Colors.red.shade900;
    }
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
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return _buildCompactHistoryItem(l10n, item);
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
