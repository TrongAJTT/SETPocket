import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:setpocket/controllers/date_calculator_controller.dart';
import 'package:setpocket/layouts/two_panels_main_multi_tab_layout.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/calculator_services/date_calculator_service.dart';
import 'package:setpocket/utils/localization_utils.dart';
import 'package:setpocket/widgets/generic_info_dialog.dart';
import 'package:setpocket/widgets/numeric_stepper_widget.dart';
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/utils/generic_dialog_utils.dart';
import 'package:setpocket/utils/generic_table_builder.dart' as table;
import 'dart:convert';

class DateCalculatorScreen extends StatelessWidget {
  final bool isEmbedded;
  const DateCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    final DateCalculatorController c = Get.put(DateCalculatorController());
    final l10n = AppLocalizations.of(context)!;

    // Trigger initial calculation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.activeTab.value == DateCalculationType.age &&
          c.currentAge.value.isEmpty) {
        c.calculate();
      } else if (c.activeTab.value == DateCalculationType.dateInfo &&
          c.dayOfWeek.value.isEmpty) {
        c.calculate();
      }
    });

    return Obx(() => TwoPanelsMainMultiTabLayout(
          isEmbedded: isEmbedded,
          title: l10n.dateCalculator,
          mainPanelTitle: l10n.dateCalculator,
          mainTabIndex: _getTabIndex(c.activeTab.value),
          onMainTabChanged: (index) {
            final tabType = [
              DateCalculationType.dateInfo, // Detail - index 0
              DateCalculationType.difference, // Difference - index 1
              DateCalculationType.addSubtract, // Add/Subtract - index 2
              DateCalculationType.age, // Birthday - index 3
            ][index];
            c.onTabChanged(tabType);
          },
          mainPanelActions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showClearDataDialog(context, l10n, c),
              tooltip: l10n.clearTabData,
              iconSize: 20,
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context, l10n),
              tooltip: l10n.showCalculatorInfo,
              iconSize: 20,
            ),
          ],
          secondaryPanelActions: [
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearHistoryDialog(context, l10n, c),
              tooltip: l10n.clearCalculationHistory,
            ),
          ],
          mainTabs: _buildMainTabs(c, l10n, context),
          secondaryPanel: c.historyEnabled.value
              ? _buildBookmarkPanel(c, l10n, context)
              : null,
          secondaryPanelTitle: l10n.bookmarks,
          secondaryTab: c.historyEnabled.value
              ? TabData(
                  label: l10n.bookmarks,
                  icon: Icons.bookmark,
                  content: _buildBookmarkPanel(c, l10n, context),
                )
              : null,
        ));
  }

  int _getTabIndex(DateCalculationType type) {
    return [
      DateCalculationType.dateInfo, // Detail - index 0
      DateCalculationType.difference, // Difference - index 1
      DateCalculationType.addSubtract, // Add/Subtract - index 2
      DateCalculationType.age, // Birthday - index 3
    ].indexOf(type);
  }

  List<TabData> _buildMainTabs(
      DateCalculatorController c, AppLocalizations l10n, BuildContext context) {
    return [
      TabData(
        label: "Detail", // As per screenshot
        icon: Icons.info_outline,
        content: _buildDateInfoTab(c, l10n, context),
      ),
      TabData(
        label: l10n.dateDifference,
        icon: Icons.compare_arrows,
        content: _buildDifferenceTab(c, l10n, context),
      ),
      TabData(
        label: l10n.addSubtractDate,
        icon: Icons.add_circle_outline,
        content: _buildAddSubtractTab(c, l10n, context),
      ),
      TabData(
        label: "Birthday", // As per screenshot
        icon: Icons.cake,
        content: _buildAgeCalculatorTab(c, l10n, context),
      ),
    ];
  }

  // --- Input Widgets ---
  Widget _buildDateSelector(BuildContext context,
      {required String label,
      required DateTime date,
      required Function(DateTime) onChanged,
      String? quickButtonLabel,
      DateTime? quickButtonDate}) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today_outlined),
        title: Text(label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(DateFormat.yMd().format(date),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.today),
              onPressed: () => onChanged(quickButtonDate ?? DateTime.now()),
              tooltip: quickButtonLabel ?? 'Set to today',
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
            const Icon(Icons.arrow_drop_down)
          ],
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) onChanged(picked);
        },
      ),
    );
  }

  // --- Tab Builders ---

  Widget _buildAddSubtractTab(
      DateCalculatorController c, AppLocalizations l10n, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(context,
              label: l10n.baseDate,
              date: c.startDate.value,
              onChanged: (picked) => c.startDate.value = picked),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.value,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  NumericStepper(
                    label: l10n.years,
                    min: -1000,
                    max: 1000,
                    initialValue: c.addSubtractYears.value.toDouble(),
                    onChanged: (val) => c.addSubtractYears.value = val.toInt(),
                  ),
                  const SizedBox(height: 8),
                  NumericStepper(
                    label: l10n.months,
                    min: -10000,
                    max: 10000,
                    initialValue: c.addSubtractMonths.value.toDouble(),
                    onChanged: (val) => c.addSubtractMonths.value = val.toInt(),
                  ),
                  const SizedBox(height: 8),
                  NumericStepper(
                    label: l10n.days,
                    min: -100000,
                    max: 100000,
                    initialValue: c.addSubtractDays.value.toDouble(),
                    onChanged: (val) => c.addSubtractDays.value = val.toInt(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: c.calculate,
            icon: const Icon(Icons.calculate),
            label: Text(l10n.calculate),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => c.addSubtractResultDate.value.isNotEmpty
              ? table.GenericTableBuilder.buildResultCard(
                  context,
                  title: l10n.results,
                  onSave: () => _saveToBookmark(c, l10n, context),
                  rows: [
                    table.GenericTableBuilder.createRow(
                        l10n.resultDate, c.addSubtractResultDate.value),
                    table.GenericTableBuilder.createRow(
                        l10n.dayOfWeek, c.addSubtractResultDayOfWeek.value),
                  ],
                  footer: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        c.onTabChanged(DateCalculationType.dateInfo);
                        c.selectedDate.value =
                            c.addSubtractResultDate.value.isNotEmpty
                                ? DateTime.parse(c.addSubtractResultDate.value)
                                : DateTime.now();
                      },
                      icon: const Icon(Icons.share),
                      label: Text(l10n.seeInfoForThisDate),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildDifferenceTab(
      DateCalculatorController c, AppLocalizations l10n, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(context,
              label: 'Start Date', date: c.fromDate.value, onChanged: (picked) {
            c.fromDate.value = picked;
            c.checkDateConflict();
          }),
          const SizedBox(height: 12),
          _buildDateSelector(context,
              label: 'End Date',
              date: c.toDate.value,
              quickButtonLabel: l10n.setToNextWeek,
              quickButtonDate: DateTime.now().add(const Duration(days: 7)),
              onChanged: (picked) {
            c.toDate.value = picked;
            c.checkDateConflict();
          }),
          const SizedBox(height: 16),
          Obx(() {
            if (c.isDateConflict.value) {
              return _buildWarningCard(
                  context, l10n.startDateConflixWithEndDateAlarm);
            }
            return const SizedBox.shrink();
          }),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: c.isDateConflict.value
                  ? OutlinedButton.icon(
                      onPressed: c.swapDifferenceDates,
                      icon: const Icon(Icons.swap_horiz),
                      label: Text(l10n.swap),
                      style: OutlinedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    )
                  : ElevatedButton.icon(
                      onPressed: c.calculate,
                      icon: const Icon(Icons.calculate),
                      label: Text(l10n.calculate),
                      style: OutlinedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                    )),
          Obx(() => c.diffTotalDays.value != 0
              ? table.GenericTableBuilder.buildResultCard(
                  context,
                  title: l10n.duration,
                  onSave: () => _saveToBookmark(c, l10n, context),
                  rows: [
                    table.GenericTableBuilder.createSectionHeader(
                        l10n.dateDistanceSection),
                    table.GenericTableBuilder.createRow(
                        l10n.years, '${c.diffYears.value} ${l10n.years}'),
                    table.GenericTableBuilder.createRow(
                        l10n.months, '${c.diffMonths.value} ${l10n.months}'),
                    table.GenericTableBuilder.createRow(
                        l10n.days, '${c.diffDays.value} ${l10n.days}'),
                    table.GenericTableBuilder.createSectionHeader(
                        l10n.unitConversionSection),
                    table.GenericTableBuilder.createRow(l10n.totalWeeks,
                        '${c.diffTotalWeeks.value} ${l10n.weeks}'),
                    table.GenericTableBuilder.createRow(l10n.totalDays,
                        '${c.diffTotalDays.value} ${l10n.days}'),
                  ],
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildAgeCalculatorTab(
      DateCalculatorController c, AppLocalizations l10n, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(context,
              label: l10n.birthDate,
              date: c.birthDate.value, onChanged: (picked) {
            c.birthDate.value = picked;
            c.calculate();
          }),
          const SizedBox(height: 16),
          Obx(() => c.currentAge.value.isNotEmpty
              ? table.GenericTableBuilder.buildResultCard(
                  context,
                  title: l10n.ageCalculatorResultsTitle,
                  onSave: () => _saveToBookmark(c, l10n, context),
                  rows: [
                    table.GenericTableBuilder.createRow(
                        l10n.yourCurrentAge, c.currentAge.value),
                    table.GenericTableBuilder.createRow(
                        l10n.daysLived, '${c.totalDaysLived.value} Days'),
                    table.GenericTableBuilder.createRow(l10n.daysUntilBirthday,
                        '${c.daysUntilBirthday.value} Days'),
                    table.GenericTableBuilder.createRow(
                        l10n.nextBirthday, c.nextBirthday.value),
                  ],
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildDateInfoTab(
      DateCalculatorController c, AppLocalizations l10n, BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(context,
              label: l10n.selectedDate,
              date: c.selectedDate.value, onChanged: (picked) {
            c.selectedDate.value = picked;
            c.calculate();
          }),
          const SizedBox(height: 16),
          Obx(() => c.dayOfWeek.value.isNotEmpty
              ? table.GenericTableBuilder.buildResultCard(
                  context,
                  title: l10n.dateInfoResults,
                  onSave: () => _saveToBookmark(c, l10n, context),
                  rows: [
                    table.GenericTableBuilder.createRow(
                        l10n.dayOfWeek, c.dayOfWeek.value),
                    table.GenericTableBuilder.createRow(
                        l10n.dayInMonth, '${c.dayInMonth.value}'),
                    table.GenericTableBuilder.createRow(
                        l10n.dayInYear, '${c.dayInYear.value}'),
                    table.GenericTableBuilder.createRow(
                        l10n.weekInMonth, '${c.weekInMonth.value}'),
                    table.GenericTableBuilder.createRow(
                        l10n.weekInYear, '${c.weekInYear.value}'),
                    table.GenericTableBuilder.createRow(
                        l10n.monthOfYear, c.monthOfYear.value),
                    table.GenericTableBuilder.createRow(
                        l10n.year, '${c.yearValue.value}'),
                    table.GenericTableBuilder.createRow(
                        l10n.quarterOfYear, 'Q${c.quarterOfYear.value}'),
                    table.GenericTableBuilder.createRow(
                        l10n.isLeapYear, c.isLeapYear.value ? "Yes" : "No"),
                    table.GenericTableBuilder.createRow(
                        l10n.daysInMonth, '${c.daysInMonth.value}'),
                    table.GenericTableBuilder.createRow(
                        l10n.daysInYear, '${c.daysInYear.value}'),
                  ],
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.tertiary, width: 1),
      ),
      color: theme.colorScheme.tertiaryContainer
          .withValues(alpha: 0.3), // or withValues
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: theme.colorScheme.tertiary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Result Widgets ---

  // --- History Panel ---
  Widget _buildBookmarkPanel(
      DateCalculatorController c, AppLocalizations l10n, BuildContext context) {
    return Obx(() => c.history.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noHistoryYet,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    l10n.startCalculatingCreateBookmarkHint,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: c.history.length,
            itemBuilder: (context, index) {
              final item = c.history.toList()[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      _getCalculationIcon(item.subType),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(c.getL10nNameFromTypeString(item.title!, l10n)),
                  subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.value}: ${item.displayTitle!}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        Text(
                          l10n.savedOnDate(
                              LocalizationUtils.getFormattedDateTime(
                                  context, item.timestamp,
                                  includeSeconds: true)),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                        ),
                      ]),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        await c.deleteHistoryItem(item.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete),
                            const SizedBox(width: 8),
                            Text(l10n.delete),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Load calculation into current state
                    _loadFromBookmark(context, c, item);
                  },
                ),
              );
            },
          ));
  }

  IconData _getCalculationIcon(String? subType) {
    switch (subType) {
      case 'addSubtract':
        return Icons.add_circle_outline;
      case 'difference':
        return Icons.compare_arrows;
      case 'age':
        return Icons.cake;
      case 'dateInfo':
        return Icons.info_outline;
      default:
        return Icons.calendar_today;
    }
  }

  void _loadFromBookmark(BuildContext context, DateCalculatorController c,
      UnifiedHistoryData item) {
    try {
      // Parse value field which contains the data (following Financial Calculator format)
      final data = jsonDecode(item.value.toString()) as Map<String, dynamic>?;

      if (data == null || data['inputsData'] == null) {
        SnackbarUtils.showTyped(
            context,
            'Could not load bookmark: invalid data format.',
            SnackBarType.error);
        return;
      }

      final inputsData = data['inputsData'] as Map<String, dynamic>;

      // Switch to the appropriate tab based on subType
      DateCalculationType? targetTab;
      switch (item.subType) {
        case 'addSubtract':
          targetTab = DateCalculationType.addSubtract;
          break;
        case 'difference':
          targetTab = DateCalculationType.difference;
          break;
        case 'age':
          targetTab = DateCalculationType.age;
          break;
        case 'dateInfo':
          targetTab = DateCalculationType.dateInfo;
          break;
      }

      if (targetTab != null) {
        c.onTabChanged(targetTab);

        // Load data based on tab type
        switch (targetTab) {
          case DateCalculationType.addSubtract:
            if (inputsData['startDate'] != null) {
              c.startDate.value = DateTime.parse(inputsData['startDate']);
            }
            c.addSubtractYears.value = inputsData['years'] ?? 0;
            c.addSubtractMonths.value = inputsData['months'] ?? 0;
            c.addSubtractDays.value = inputsData['days'] ?? 0;
            break;

          case DateCalculationType.difference:
            if (inputsData['fromDate'] != null) {
              c.fromDate.value = DateTime.parse(inputsData['fromDate']);
            }
            if (inputsData['toDate'] != null) {
              c.toDate.value = DateTime.parse(inputsData['toDate']);
            }
            break;

          case DateCalculationType.age:
            if (inputsData['birthDate'] != null) {
              c.birthDate.value = DateTime.parse(inputsData['birthDate']);
            }
            break;

          case DateCalculationType.dateInfo:
            if (inputsData['selectedDate'] != null) {
              c.selectedDate.value = DateTime.parse(inputsData['selectedDate']);
            }
            break;
        }

        // Trigger calculation after loading
        c.calculate();

        // Show success message
        SnackbarUtils.showTyped(
            context, 'Bookmark loaded successfully', SnackBarType.success);
      }
    } catch (e) {
      SnackbarUtils.showTyped(context,
          'Error loading bookmark: ${e.toString()}', SnackBarType.error);
    }
  }

  // --- Dialogs & Helpers ---
  void _saveToBookmark(
      DateCalculatorController c, AppLocalizations l10n, BuildContext context) {
    c.saveCurrentCalculationToHistory(l10n);
    SnackbarUtils.showTyped(context, l10n.saveToHistory, SnackBarType.success);
  }

  void _showInfoDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => const GenericInfoDialog(
        title: "Date Calculator",
        headerIcon: Icons.calendar_today,
        overview:
            "A comprehensive tool for date calculations including add/subtract operations, date differences, age calculations, and detailed date information.",
        sections: [],
      ),
    );
  }

  void _showClearDataDialog(
      BuildContext context, AppLocalizations l10n, DateCalculatorController c) {
    GenericDialogUtils.showSimpleGenericClearDialog(
      context: context,
      title: l10n.clearTabData,
      description: 'Clear data for current tab?',
      onConfirm: () {
        c.clearCurrentTabData();
        SnackbarUtils.showTyped(context, 'Tab data cleared', SnackBarType.info);
      },
    );
  }

  void _showClearHistoryDialog(
      BuildContext context, AppLocalizations l10n, DateCalculatorController c) {
    GenericDialogUtils.showSimpleHoldClearDialog(
      context: context,
      title: l10n.clearHistory,
      content: l10n.confirmClearHistory,
      duration: const Duration(seconds: 1),
      onConfirm: () {
        c.clearHistory();
        SnackbarUtils.showTyped(context, 'History cleared', SnackBarType.info);
      },
    );
  }
}
