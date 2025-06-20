import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/layouts/two_panels_main_multi_tab_layout.dart';
import 'package:setpocket/controllers/date_calculator_controller.dart';
import 'package:setpocket/models/date_calculator_models.dart';
import 'package:setpocket/services/date_calculator_service.dart';
import 'package:setpocket/utils/localization_utils.dart';
import 'package:setpocket/widgets/numeric_stepper_widget.dart';
import 'package:setpocket/widgets/generic_info_dialog.dart';

class DateCalculatorScreen extends StatefulWidget {
  final bool isEmbedded;

  const DateCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen> {
  late DateCalculatorController _controller;

  @override
  void initState() {
    super.initState();
    final dateCalculatorService = DateCalculatorService();
    _controller =
        DateCalculatorController(dateCalculatorService: dateCalculatorService);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildMainContent(l10n);
  }

  Widget _buildMainContent(AppLocalizations l10n) {
    return TwoPanelsMainMultiTabLayout(
      isEmbedded: widget.isEmbedded,
      title: l10n.dateCalculator,
      mainPanelTitle: l10n.dateCalculator,
      mainTabIndex: _getTabIndex(_controller.activeTab),
      onMainTabChanged: (index) {
        final tabType = [
          DateCalculationType.dateInfo,
          DateCalculationType.dateDifference,
          DateCalculationType.addSubtract,
          DateCalculationType.age,
        ][index];
        _controller.setActiveTab(tabType);
      },
      mainPanelActions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInfoDialog(context, l10n),
          tooltip: l10n.showCalculatorInfo,
        ),
        IconButton(
          icon: const Icon(Icons.clear_all),
          onPressed: () => _showClearDataDialog(context, l10n),
          tooltip: l10n.clearTabData,
        ),
      ],
      secondaryPanelActions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showClearHistoryDialog(context, l10n),
          tooltip: l10n.clearCalculationHistory,
        ),
      ],
      mainTabs: _buildMainTabs(l10n),
      secondaryPanel: _buildHistoryPanel(),
      secondaryPanelTitle: l10n.dateCalculatorHistory,
      secondaryTab: TabData(
        label: l10n.history,
        icon: Icons.history,
        content: _buildHistoryPanel(),
      ),
    );
  }

  int _getTabIndex(DateCalculationType type) {
    return [
      DateCalculationType.dateInfo,
      DateCalculationType.dateDifference,
      DateCalculationType.addSubtract,
      DateCalculationType.age,
    ].indexOf(type);
  }

  List<TabData> _buildMainTabs(AppLocalizations l10n) {
    return [
      TabData(
        label: l10n.dateInfo,
        icon: Icons.info_outline,
        content: _buildDateInfoTab(),
      ),
      TabData(
        label: l10n.dateDifference,
        icon: Icons.date_range,
        content: _buildDateDifferenceTab(),
      ),
      TabData(
        label: l10n.addSubtractDate,
        icon: Icons.add_circle,
        content: _buildAddSubtractTab(),
      ),
      TabData(
        label: l10n.ageCalculator,
        icon: Icons.cake,
        content: _buildAgeCalculatorTab(),
      ),
    ];
  }

  Widget _buildDateInfoTab() {
    final l10n = AppLocalizations.of(context)!;
    final dateInfoState = _controller.dateInfoState;
    final result = _controller.currentResult;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(
            label: l10n.selectedDate,
            date: dateInfoState.selectedDate,
            icon: Icons.info_outline,
            onChanged: (selectedDate) {
              _controller.updateDateInfo(selectedDate);
            },
          ),
          const SizedBox(height: 24),
          if (result != null && !result.containsKey('error')) ...[
            _buildDateInfoResultsTable(l10n, result),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.selectDateToView,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateDifferenceTab() {
    final l10n = AppLocalizations.of(context)!;
    final state = _controller.dateDifferenceState;
    final result = _controller.currentResult;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(
            label: l10n.startDate,
            date: state.startDate,
            icon: Icons.start,
            onChanged: (date) {
              _controller.updateDateDifferenceState(startDate: date);
            },
          ),
          const SizedBox(height: 16),
          _buildDateSelector(
            label: l10n.endDate,
            date: state.endDate,
            icon: Icons.event,
            quickOptionDate: DateTime.now().add(const Duration(days: 7)),
            quickOptionTooltip: '+1 week',
            onChanged: (date) {
              _controller.updateDateDifferenceState(endDate: date);
            },
          ),
          const SizedBox(height: 24),
          if (result != null && !result.containsKey('error')) ...[
            _buildDateDifferenceResultsTable(l10n, result),
          ],
        ],
      ),
    );
  }

  Widget _buildAddSubtractTab() {
    final l10n = AppLocalizations.of(context)!;
    final state = _controller.addSubtractState;
    final result = _controller.currentResult;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(
            label: l10n.baseDate,
            date: state.baseDate,
            icon: Icons.calendar_today,
            onChanged: (date) {
              _controller.updateAddSubtractState(baseDate: date);
            },
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.addSubtractValues,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.link),
                        style: _controller.isDataConstraintEnabled
                            ? IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.12),
                              )
                            : null,
                        color: _controller.isDataConstraintEnabled
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        onPressed: () {
                          _controller.setDataConstraint(
                              !_controller.isDataConstraintEnabled);
                        },
                        tooltip: _controller.isDataConstraintEnabled
                            ? 'Disable data constraints'
                            : 'Enable data constraints',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  NumericStepper(
                    min: 0,
                    max: _controller.isDataConstraintEnabled
                        ? double.infinity
                        : 100,
                    initialValue: state.years.toDouble(),
                    label: l10n.years,
                    icon: Icons.calendar_today,
                    onChanged: (value) {
                      _controller.updateAddSubtractState(years: value.toInt());
                    },
                  ),
                  const SizedBox(height: 12),
                  NumericStepper(
                    min: 0,
                    max: _controller.isDataConstraintEnabled ? 11 : 120,
                    initialValue: state.months.toDouble(),
                    label: l10n.months,
                    icon: Icons.calendar_view_month,
                    onWrapAroundMin: _controller.isDataConstraintEnabled
                        ? () => _controller.updateAddSubtractState(
                            months: state.months - 1)
                        : null,
                    onWrapAroundMax: _controller.isDataConstraintEnabled
                        ? () => _controller.updateAddSubtractState(
                            months: state.months + 1)
                        : null,
                    onChanged: (value) {
                      _controller.updateAddSubtractState(months: value.toInt());
                    },
                  ),
                  const SizedBox(height: 12),
                  NumericStepper(
                    min: 0,
                    max: _controller.isDataConstraintEnabled ? 30 : 36525,
                    initialValue: state.days.toDouble(),
                    label: l10n.days,
                    icon: Icons.calendar_view_day,
                    onWrapAroundMin: _controller.isDataConstraintEnabled
                        ? () => _controller.updateAddSubtractState(
                            days: state.days - 1)
                        : null,
                    onWrapAroundMax: _controller.isDataConstraintEnabled
                        ? () => _controller.updateAddSubtractState(
                            days: state.days + 1)
                        : null,
                    onChanged: (value) {
                      _controller.updateAddSubtractState(days: value.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (result != null && !result.containsKey('error')) ...[
            _buildAddSubtractResultsTable(l10n, result, state),
          ],
        ],
      ),
    );
  }

  Widget _buildAgeCalculatorTab() {
    final l10n = AppLocalizations.of(context)!;
    final state = _controller.ageState;
    final result = _controller.currentResult;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDateSelector(
            label: l10n.birthDate,
            date: state.birthDate,
            icon: Icons.cake,
            onChanged: (date) {
              _controller.updateAgeState(birthDate: date);
            },
          ),
          const SizedBox(height: 24),
          if (_controller.isCalculating)
            const Center(child: CircularProgressIndicator())
          else if (result != null && !result.containsKey('error'))
            _buildAgeCalculatorResultsTable(l10n, result)
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    l10n.selectDateToView,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAgeCalculatorResultsTable(
      AppLocalizations l10n, Map<String, dynamic> result) {
    return _buildResultCard(
      title: l10n.ageCalculatorResultsTitle,
      onBookmark: () {
        _controller.saveToHistory();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.resultBookmarked)),
        );
      },
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: Table(
            columnWidths: const {
              0: MaxColumnWidth(FixedColumnWidth(180), FlexColumnWidth(2)),
              1: FlexColumnWidth(3),
            },
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
              verticalInside: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
            children: [
              _buildTableRow(
                l10n.age,
                '${result['years'] ?? 0} ${l10n.years}, ${result['months'] ?? 0} ${l10n.months}, ${result['days'] ?? 0} ${l10n.days}',
              ),
              _buildTableRow(
                l10n.daysLived,
                '${result['totalDays'] ?? 0} ${l10n.days}',
              ),
              _buildTableRow(
                l10n.daysUntilBirthday,
                '${result['daysUntilBirthday'] ?? 0} ${l10n.days}',
              ),
              _buildTableRow(
                l10n.nextBirthday,
                result['nextBirthday'] != null
                    ? LocalizationUtils.formatDate(
                        context, DateTime.parse(result['nextBirthday']))
                    : '',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryPanel() {
    final l10n = AppLocalizations.of(context)!;
    final history = _controller.history;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noHistoryYet,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.performCalculation,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _getTabIcon(item.type),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(item.displayTitle,
                maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              LocalizationUtils.formatDateTime(context, item.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  await _controller.removeFromHistory(item.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.historyItemDeleted)),
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete),
                      const SizedBox(width: 8),
                      Text(l10n.deleteFromHistory),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              _controller.loadFromHistory(item);
            },
          ),
        );
      },
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required IconData icon,
    required Function(DateTime) onChanged,
    DateTime? quickOptionDate,
    String? quickOptionTooltip,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
          ),
          child: IconButton(
            icon: Icon(
              Icons.today,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 20,
            ),
            onPressed: () => onChanged(quickOptionDate ?? DateTime.now()),
            tooltip: quickOptionTooltip ?? 'Today',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: const EdgeInsets.all(4),
          ),
        ),
        title: Text(label),
        subtitle: Text(LocalizationUtils.formatDate(context, date)),
        trailing: const Icon(Icons.calendar_month),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onChanged(picked);
          }
        },
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required List<Widget> children,
    VoidCallback? onBookmark,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (onBookmark != null)
                  IconButton(
                    icon: const Icon(Icons.bookmark_border),
                    onPressed: onBookmark,
                    tooltip: AppLocalizations.of(context)!.bookmarkResult,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfoResultsTable(
      AppLocalizations l10n, Map<String, dynamic> result) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.dateInfoResults,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    _controller.saveToHistory();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.resultBookmarked)),
                    );
                  },
                  tooltip: l10n.bookmarkResult,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Table(
                columnWidths: const {
                  0: MaxColumnWidth(FixedColumnWidth(180), FlexColumnWidth(2)),
                  1: FlexColumnWidth(3),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                  verticalInside: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
                children: [
                  _buildTableRow(
                    l10n.weekdayName,
                    LocalizationUtils.getLocalizedWeekdayName(
                        result['weekday'], l10n),
                  ),
                  _buildTableRow(
                    l10n.dayInMonth,
                    result['dayInMonth']?.toString() ?? '0',
                  ),
                  _buildTableRow(
                    l10n.dayInYear,
                    result['dayInYear']?.toString() ?? '0',
                  ),
                  _buildTableRow(
                    l10n.weekInMonth,
                    result['weekInMonth']?.toString() ?? '0',
                  ),
                  _buildTableRow(
                    l10n.weekInYear,
                    result['weekInYear']?.toString() ?? '0',
                  ),
                  _buildTableRow(
                    l10n.monthOfYear,
                    LocalizationUtils.getLocalizedMonthName(
                        result['month'], l10n),
                  ),
                  _buildTableRow(
                    l10n.yearValue,
                    result['year']?.toString() ?? '0',
                  ),
                  _buildTableRow(
                    l10n.quarterOfYear,
                    'Q${result['quarter']?.toString() ?? '0'}',
                  ),
                  _buildTableRow(
                    l10n.isLeapYear,
                    (result['isLeapYear'] == true) ? l10n.yes : l10n.no,
                  ),
                  _buildTableRow(
                    l10n.daysInMonth,
                    result['daysInMonth']?.toString() ?? '0',
                  ),
                  _buildTableRow(
                    l10n.daysInYear,
                    result['daysInYear']?.toString() ?? '0',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateDifferenceResultsTable(
      AppLocalizations l10n, Map<String, dynamic> result) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.duration,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    _controller.saveToHistory();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.resultBookmarked)),
                    );
                  },
                  tooltip: l10n.bookmarkResult,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildSectionHeader(l10n.dateDistanceSection),
                  Table(
                    columnWidths: const {
                      0: MaxColumnWidth(
                          FixedColumnWidth(180), FlexColumnWidth(2)),
                      1: FlexColumnWidth(3),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                      verticalInside: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                    children: [
                      _buildTableRow(
                        l10n.years,
                        '${result['simplifiedYears'] ?? 0} ${l10n.years}',
                      ),
                      _buildTableRow(
                        l10n.months,
                        '${result['simplifiedMonths'] ?? 0} ${l10n.months}',
                      ),
                      _buildTableRow(
                        l10n.days,
                        '${result['simplifiedDays'] ?? 0} ${l10n.days}',
                      ),
                    ],
                  ),
                  _buildSectionHeader(l10n.unitConversionSection),
                  Table(
                    columnWidths: const {
                      0: MaxColumnWidth(
                          FixedColumnWidth(180), FlexColumnWidth(2)),
                      1: FlexColumnWidth(3),
                    },
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                      verticalInside: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 0.5,
                      ),
                    ),
                    children: [
                      _buildTableRow(
                        l10n.totalMonths,
                        '${result['totalMonths'] ?? 0} ${l10n.months}',
                      ),
                      _buildTableRow(
                        l10n.totalWeeks,
                        '${result['totalWeeks'] ?? 0} ${l10n.weeks}',
                      ),
                      _buildTableRow(
                        l10n.totalDays,
                        '${result['totalDays'] ?? 0} ${l10n.days}',
                      ),
                      _buildTableRow(
                        l10n.totalHours,
                        '${result['totalHours'] ?? 0} ${l10n.hours}',
                      ),
                      _buildTableRow(
                        l10n.totalMinutes,
                        '${result['totalMinutes'] ?? 0} ${l10n.minutes}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSubtractResultsTable(
      AppLocalizations l10n, Map<String, dynamic> result, dynamic state) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.addSubtractResultsTitle,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    _controller.saveToHistory();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.resultBookmarked)),
                    );
                  },
                  tooltip: l10n.bookmarkResult,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: Table(
                columnWidths: const {
                  0: MaxColumnWidth(FixedColumnWidth(180), FlexColumnWidth(2)),
                  1: FlexColumnWidth(3),
                },
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                  verticalInside: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
                children: [
                  _buildTableRow(
                    l10n.resultDate,
                    result['resultDate'] != null
                        ? LocalizationUtils.formatDate(
                            context, DateTime.parse(result['resultDate']))
                        : '',
                  ),
                  _buildTableRow(
                    l10n.dayOfWeek,
                    LocalizationUtils.getLocalizedWeekdayName(
                        result['weekday'], l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primaryContainer.withAlpha(50),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        TableCell(
          // verticalAlignment: TableCellVerticalAlignment.fill,
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String sectionTitle) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Text(
        sectionTitle,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  IconData _getTabIcon(DateCalculationType type) {
    switch (type) {
      case DateCalculationType.dateInfo:
        return Icons.info_outline;
      case DateCalculationType.dateDifference:
        return Icons.date_range;
      case DateCalculationType.addSubtract:
        return Icons.add_circle;
      case DateCalculationType.age:
        return Icons.cake;
      case DateCalculationType.workingDays:
        return Icons.work;
      case DateCalculationType.timezone:
        return Icons.public;
      case DateCalculationType.recurring:
        return Icons.repeat;
      case DateCalculationType.countdown:
        return Icons.timer;
      case DateCalculationType.timeUnit:
        return Icons.schedule;
      case DateCalculationType.nthWeekday:
        return Icons.event_note;
    }
  }

  void _showInfoDialog(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    GenericInfoDialog.show(
      context: context,
      title: l10n.dateCalculatorDetailedInfo,
      overview: l10n.dateCalculatorOverview,
      headerIcon: Icons.date_range,
      sections: [
        // Key Features
        InfoSection(
          title: l10n.dateKeyFeatures,
          icon: Icons.star_outline,
          color: Colors.indigo,
          children: [
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.comprehensiveDateCalc,
                description: l10n.comprehensiveDateCalcDesc,
                icon: Icons.date_range,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.multipleCalculationModes,
                description: l10n.multipleCalculationModesDesc,
                icon: Icons.tab,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.detailedDateInfo,
                description: l10n.detailedDateInfoDesc,
                icon: Icons.info_outline,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.flexibleDateInput,
                description: l10n.flexibleDateInputDesc,
                icon: Icons.input,
              ),
            ),
          ],
        ),

        // How to Use
        InfoSection(
          title: l10n.dateHowToUse,
          icon: Icons.help_outline,
          color: Colors.blue,
          children: [
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(step: l10n.step1Date, description: l10n.step1DateDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(step: l10n.step2Date, description: l10n.step2DateDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(step: l10n.step3Date, description: l10n.step3DateDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(step: l10n.step4Date, description: l10n.step4DateDesc),
            ),
          ],
        ),

        // Calculation Modes
        InfoSection(
          title: l10n.dateCalculationModes,
          icon: Icons.category,
          color: Colors.orange,
          children: [
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.dateInfoMode,
                description: l10n.dateInfoModeDesc,
                icon: Icons.info_outline,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.dateDifferenceMode,
                description: l10n.dateDifferenceModeDesc,
                icon: Icons.compare_arrows,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.addSubtractMode,
                description: l10n.addSubtractModeDesc,
                icon: Icons.add_circle_outline,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.ageCalculatorMode,
                description: l10n.ageCalculatorModeDesc,
                icon: Icons.cake_outlined,
              ),
            ),
          ],
        ),

        // Usage Tips
        InfoSection(
          title: l10n.dateTips,
          icon: Icons.lightbulb_outline,
          color: Colors.green,
          children: [
            GenericInfoDialog.buildTipItem(theme, l10n.dateTip1),
            GenericInfoDialog.buildTipItem(theme, l10n.dateTip2),
            GenericInfoDialog.buildTipItem(theme, l10n.dateTip3),
            GenericInfoDialog.buildTipItem(theme, l10n.dateTip4),
            GenericInfoDialog.buildTipItem(theme, l10n.dateTip5),
          ],
        ),

        // Limitations
        InfoSection(
          title: l10n.dateLimitations,
          icon: Icons.warning_outlined,
          color: Colors.amber,
          children: [
            GenericInfoDialog.buildBulletList(
              theme: theme,
              description: l10n.dateLimitationsDesc,
              items: [
                l10n.dateLimitation1,
                l10n.dateLimitation2,
                l10n.dateLimitation3,
                l10n.dateLimitation4,
                l10n.dateLimitation5,
              ],
            ),
          ],
        ),

        // Disclaimer
        InfoSection(
          title: 'Lưu ý quan trọng',
          icon: Icons.info_outline,
          color: Colors.red,
          children: [
            GenericInfoDialog.buildDisclaimer(
              theme: theme,
              text: l10n.dateDisclaimer,
            ),
          ],
        ),
      ],
    );
  }

  void _showClearDataDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearTabData),
        content: Text(l10n.confirmClearTabData),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              _controller.clearCurrentTabData();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.tabDataCleared)),
              );
            },
            child: Text(l10n.clearTabData),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCalculationHistory),
        content: Text(l10n.confirmClearHistory),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              _controller.clearHistory();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.historyCleared)),
              );
            },
            child: Text(l10n.clearCalculationHistory),
          ),
        ],
      ),
    );
  }
}
