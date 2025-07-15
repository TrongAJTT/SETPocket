import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/calculator_models/financial_models.dart'
    hide FinancialCalculatorState;
import 'package:setpocket/models/unified_history_data.dart';
import 'package:setpocket/services/calculator_services/financial_calculator_service.dart';
import 'package:setpocket/services/calculator_services/graphing_calculator_service.dart';
import 'package:setpocket/layouts/two_panels_main_multi_tab_layout.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/widgets/generic_info_dialog.dart';
import 'package:setpocket/utils/percentage_input_utils.dart';
import 'package:setpocket/utils/generic_dialog_utils.dart';
import 'package:setpocket/utils/localization_utils.dart';

class FinancialCalculatorScreen extends StatefulWidget {
  final bool isEmbedded;

  const FinancialCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  State<FinancialCalculatorScreen> createState() =>
      _FinancialCalculatorScreenState();
}

class _FinancialCalculatorScreenState extends State<FinancialCalculatorScreen> {
  // Form controllers for each tab
  final Map<String, TextEditingController> _loanControllers = {
    'amount': TextEditingController(),
    'rate': TextEditingController(),
    'term': TextEditingController(),
  };

  final Map<String, TextEditingController> _investmentControllers = {
    'initial': TextEditingController(),
    'monthly': TextEditingController(),
    'rate': TextEditingController(),
    'term': TextEditingController(),
  };

  final Map<String, TextEditingController> _compoundControllers = {
    'principal': TextEditingController(),
    'rate': TextEditingController(),
    'time': TextEditingController(),
    'frequency': TextEditingController(),
  };

  // Form focus nodes for each tab
  final Map<String, FocusNode> _loanFocusNodes = {
    'rate': FocusNode(),
    'term': FocusNode(),
  };

  final Map<String, FocusNode> _investmentFocusNodes = {
    'monthly': FocusNode(),
    'rate': FocusNode(),
    'term': FocusNode(),
  };

  final Map<String, FocusNode> _compoundFocusNodes = {
    'rate': FocusNode(),
    'time': FocusNode(),
    'frequency': FocusNode(),
  };

  // Results
  LoanCalculationResult? _loanResult;
  InvestmentCalculationResult? _investmentResult;
  CompoundInterestCalculationResult? _compoundResult;

  // History and settings
  List<UnifiedHistoryData> _history = [];
  bool _historyEnabled = false;

  // Current main tab index for state management
  int _currentMainTabIndex = 0;

  // Flag to track if data was manually cleared
  bool _wasDataCleared = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadState();
  }

  void _initializeDefaults() {
    // Only set default frequency value if this is a fresh start (no state loaded)
    // and data was not manually cleared
    final allCompoundEmpty = _compoundControllers.values
        .every((controller) => controller.text.isEmpty);

    if (!_wasDataCleared &&
        allCompoundEmpty &&
        _compoundControllers['frequency']!.text.isEmpty) {
      _compoundControllers['frequency']!.text = '12';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
    _checkAndReloadState();
  }

  Future<void> _checkAndReloadState() async {
    // Check if state exists in database but controller has old values
    final stateData = await FinancialCalculatorService.getCurrentState();

    // If no state exists but we have data in controllers, it means cache was cleared
    // but widget wasn't reloaded - need to clear all data
    if (stateData == null) {
      final hasAnyData =
          _loanControllers.values.any((c) => c.text.isNotEmpty) ||
              _investmentControllers.values.any((c) => c.text.isNotEmpty) ||
              _compoundControllers.values.any((c) => c.text.isNotEmpty) ||
              _loanResult != null ||
              _investmentResult != null ||
              _compoundResult != null;

      if (hasAnyData) {
        // Clear all controllers to reflect the cleared cache state
        setState(() {
          for (final controller in _loanControllers.values) {
            controller.clear();
          }
          for (final controller in _investmentControllers.values) {
            controller.clear();
          }
          for (final controller in _compoundControllers.values) {
            controller.clear();
          }

          // Clear results
          _loanResult = null;
          _investmentResult = null;
          _compoundResult = null;

          // Reset to default tab
          _currentMainTabIndex = 0;

          // Mark as cleared
          _wasDataCleared = true;
        });
      }
    }
  }

  @override
  void dispose() {
    // Save state before disposing (while context is still valid)
    // Use unawaited since dispose should not be async
    if (mounted) {
      _saveState().catchError((error) {
        // Ignore save errors during dispose
      });
    }

    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final controller in _loanControllers.values) {
      controller.dispose();
    }
    for (final controller in _investmentControllers.values) {
      controller.dispose();
    }
    for (final controller in _compoundControllers.values) {
      controller.dispose();
    }
  }

  Future<void> _loadSettings() async {
    final enabled = await GraphingCalculatorService.getRememberHistory();
    final history = await FinancialCalculatorService.getHistory();
    if (mounted) {
      setState(() {
        _historyEnabled = enabled;
        _history = history;
      });
    }
  }

  Future<void> _loadState() async {
    final stateData = await FinancialCalculatorService.getCurrentState();
    final state = FinancialCalculatorService.mapToState(stateData);

    if (state != null && mounted) {
      setState(() {
        // Restore main tab index
        final activeTab = state['activeTabIndex'] as int? ?? 0;
        if (activeTab < 3) {
          _currentMainTabIndex = activeTab;
        }

        // Load inputs
        final loanInputs = state['loanInputs'] as Map<String, String>? ?? {};
        loanInputs.forEach((key, value) {
          if (_loanControllers.containsKey(key)) {
            _loanControllers[key]!.text = value;
          }
        });

        final investmentInputs =
            state['investmentInputs'] as Map<String, String>? ?? {};
        investmentInputs.forEach((key, value) {
          if (_investmentControllers.containsKey(key)) {
            _investmentControllers[key]!.text = value;
          }
        });

        final compoundInputs =
            state['compoundInputs'] as Map<String, String>? ?? {};
        compoundInputs.forEach((key, value) {
          if (_compoundControllers.containsKey(key)) {
            _compoundControllers[key]!.text = value;
          }
        });

        // Load results
        final loanResults = state['loanResults'] as Map<String, dynamic>?;
        if (loanResults != null) {
          _loanResult = LoanCalculationResult.fromMap(loanResults);
        }

        final investmentResults =
            state['investmentResults'] as Map<String, dynamic>?;
        if (investmentResults != null) {
          _investmentResult =
              InvestmentCalculationResult.fromMap(investmentResults);
        }

        final compoundResults =
            state['compoundResults'] as Map<String, dynamic>?;
        if (compoundResults != null) {
          _compoundResult =
              CompoundInterestCalculationResult.fromMap(compoundResults);
        }
      });
    }

    // Initialize defaults after trying to load state
    _initializeDefaults();
  }

  Future<void> _saveState() async {
    try {
      // Check if context is still valid before accessing MediaQuery
      if (!mounted) return;

      final stateData = FinancialCalculatorService.stateToMap(
        activeTabIndex: _currentMainTabIndex,
        loanInputs: _loanControllers
            .map((key, controller) => MapEntry(key, controller.text)),
        investmentInputs: _investmentControllers
            .map((key, controller) => MapEntry(key, controller.text)),
        compoundInputs: _compoundControllers
            .map((key, controller) => MapEntry(key, controller.text)),
        loanResults: _loanResult?.toMap(),
        investmentResults: _investmentResult?.toMap(),
        compoundResults: _compoundResult?.toMap(),
      );

      await FinancialCalculatorService.saveCurrentState(stateData);
    } catch (e) {
      // Ignore errors during dispose phase
      // Context might not be available when widget is being disposed
    }
  }

  Future<void> _saveLoanToHistory() async {
    if (_loanResult == null) return;

    final l10n = AppLocalizations.of(context)!;
    final inputs = _loanControllers
        .map((key, controller) => MapEntry(key, controller.text));

    final historyItem = {
      'title': 'Loan Calculation',
      'value': jsonEncode({
        // Embed inputs and results inside the 'value' field
        'inputsData': inputs,
        'resultsData': _loanResult!.toMap(),
      }),
      'timestamp': DateTime.now().toIso8601String(),
      'subType': 'loan',
      'displayTitle':
          '${l10n.loanTab}: \$${inputs['amount']} - ${inputs['rate']}% - ${inputs['term']} ${l10n.years}',
    };

    await FinancialCalculatorService.saveToHistory(historyItem);
    await _loadSettings();

    if (mounted) {
      SnackbarUtils.showTyped(
        context,
        l10n.bookmarkSaved,
        SnackBarType.info,
      );
    }
  }

  Future<void> _saveInvestmentToHistory() async {
    if (_investmentResult == null) return;

    final l10n = AppLocalizations.of(context)!;
    final inputs = _investmentControllers
        .map((key, controller) => MapEntry(key, controller.text));

    final historyItem = {
      'title': 'Investment Calculation',
      'value': jsonEncode({
        // Embed inputs and results inside the 'value' field
        'inputsData': inputs,
        'resultsData': _investmentResult!.toMap(),
      }),
      'timestamp': DateTime.now().toIso8601String(),
      'subType': 'investment',
      'displayTitle':
          '${l10n.investmentTab}: \$${inputs['initial']} + \$${inputs['monthly']}/${l10n.months} - ${inputs['rate']}%',
    };

    await FinancialCalculatorService.saveToHistory(historyItem);
    await _loadSettings();

    if (mounted) {
      SnackbarUtils.showTyped(
        context,
        l10n.bookmarkSaved,
        SnackBarType.info,
      );
    }
  }

  Future<void> _saveCompoundToHistory() async {
    if (_compoundResult == null) return;

    final l10n = AppLocalizations.of(context)!;
    final inputs = _compoundControllers
        .map((key, controller) => MapEntry(key, controller.text));

    final historyItem = {
      'title': 'Compound Interest Calculation',
      'value': jsonEncode({
        // Embed inputs and results inside the 'value' field
        'inputsData': inputs,
        'resultsData': _compoundResult!.toMap(),
      }),
      'timestamp': DateTime.now().toIso8601String(),
      'subType': 'compound',
      'displayTitle':
          '${l10n.compoundTab}: \$${inputs['principal']} - ${inputs['rate']}% - ${inputs['time']} ${l10n.years}',
    };

    await FinancialCalculatorService.saveToHistory(historyItem);
    await _loadSettings();

    if (mounted) {
      SnackbarUtils.showTyped(
        context,
        l10n.bookmarkSaved,
        SnackBarType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TwoPanelsMainMultiTabLayout(
      isEmbedded: widget.isEmbedded,
      title: l10n.financialCalculator,
      mainPanelTitle: l10n.financialCalculator,
      mainPanelActions: [
        IconButton(
          onPressed: () => _showClearDataDialog(l10n),
          icon: const Icon(Icons.delete),
          tooltip: l10n.clearTabData,
          iconSize: 20,
        ),
        IconButton(
          onPressed: () => _showFinancialCalculatorInfo(context),
          icon: const Icon(Icons.info_outline),
          tooltip: l10n.info,
          iconSize: 20,
        ),
      ],
      initialMainTabIndex: _currentMainTabIndex,
      mainTabIndex: _currentMainTabIndex, // Add this to sync current tab
      onMainTabChanged: (index) {
        // Only update if the index actually changed to prevent loops
        if (_currentMainTabIndex != index) {
          setState(() {
            _currentMainTabIndex = index;
          });
          // Delay save to avoid conflicts during tab switches
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _saveState();
            }
          });
        }
      },
      mainTabs: [
        TabData(
          label: l10n.loanTab,
          icon: Icons.home,
          content: _buildLoanCalculator(l10n),
        ),
        TabData(
          label: l10n.investmentTab,
          icon: Icons.trending_up,
          content: _buildInvestmentCalculator(l10n),
        ),
        TabData(
          label: l10n.compoundTab,
          icon: Icons.savings,
          content: _buildCompoundInterestCalculator(l10n),
        ),
      ],
      secondaryPanel: _historyEnabled ? _buildHistoryWidget() : null,
      secondaryPanelTitle: l10n.bookmarks,
      secondaryPanelActions: _history.isNotEmpty
          ? [
              IconButton(
                onPressed: () => _showClearHistoryDialog(l10n),
                icon: const Icon(Icons.clear_all),
                tooltip: l10n.clearAll,
                iconSize: 20,
              ),
            ]
          : null,
      secondaryTab: _historyEnabled
          ? TabData(
              label: l10n.history,
              icon: Icons.history,
              content: _buildHistoryWidget(),
            )
          : null,
      secondaryEnabled: _historyEnabled,
    );
  }

  Widget _buildLoanCalculator(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.loanCalculator,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _loanControllers['amount']!,
            nextFocusNode: _loanFocusNodes['rate'],
            label: l10n.loanAmount,
            hint: l10n.loanAmountHint,
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _loanControllers['rate']!,
            focusNode: _loanFocusNodes['rate']!,
            nextFocusNode: _loanFocusNodes['term'],
            label: l10n.annualInterestRate,
            hint: l10n.annualInterestRateHint,
            icon: Icons.percent,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _loanControllers['term']!,
            focusNode: _loanFocusNodes['term']!,
            label: l10n.loanTerm,
            hint: l10n.loanTermHint,
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateLoan,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                Text(l10n.calculateLoan, style: const TextStyle(fontSize: 16)),
          ),
          if (_loanResult != null) ...[
            const SizedBox(height: 24),
            _buildResultCard(
                l10n,
                [
                  _buildResultRow(l10n, l10n.monthlyPayment,
                      '\$${_loanResult!.monthlyPayment.toStringAsFixed(2)}'),
                  _buildResultRow(l10n, l10n.totalPayment,
                      '\$${_loanResult!.totalPayment.toStringAsFixed(2)}'),
                  _buildResultRow(l10n, l10n.totalInterest,
                      '\$${_loanResult!.totalInterest.toStringAsFixed(2)}'),
                ],
                onBookmark: _saveLoanToHistory),
          ],
        ],
      ),
    );
  }

  Widget _buildInvestmentCalculator(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.investmentCalculator,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _investmentControllers['initial']!,
            nextFocusNode: _investmentFocusNodes['monthly'],
            label: l10n.initialInvestment,
            hint: l10n.initialInvestmentHint,
            icon: Icons.savings,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _investmentControllers['monthly']!,
            focusNode: _investmentFocusNodes['monthly']!,
            nextFocusNode: _investmentFocusNodes['rate'],
            label: l10n.monthlyContribution,
            hint: l10n.monthlyContributionHint,
            icon: Icons.calendar_month,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _investmentControllers['rate']!,
            focusNode: _investmentFocusNodes['rate']!,
            nextFocusNode: _investmentFocusNodes['term'],
            label: l10n.annualReturn,
            hint: l10n.annualReturnHint,
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _investmentControllers['term']!,
            focusNode: _investmentFocusNodes['term']!,
            label: l10n.investmentPeriod,
            hint: l10n.investmentPeriodHint,
            icon: Icons.timeline,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateInvestment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.calculateInvestment,
                style: const TextStyle(fontSize: 16)),
          ),
          if (_investmentResult != null) ...[
            const SizedBox(height: 24),
            _buildResultCard(
                l10n,
                [
                  _buildResultRow(l10n, l10n.futureValue,
                      '\$${_investmentResult!.futureValue.toStringAsFixed(2)}'),
                  _buildResultRow(l10n, l10n.totalContributions,
                      '\$${_investmentResult!.totalContributions.toStringAsFixed(2)}'),
                  _buildResultRow(l10n, l10n.totalEarnings,
                      '\$${_investmentResult!.totalEarnings.toStringAsFixed(2)}'),
                ],
                onBookmark: _saveInvestmentToHistory),
          ],
        ],
      ),
    );
  }

  Widget _buildCompoundInterestCalculator(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.compoundInterestCalculator,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _compoundControllers['principal']!,
            nextFocusNode: _compoundFocusNodes['rate'],
            label: l10n.principalAmount,
            hint: l10n.principalAmountHint,
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _compoundControllers['rate']!,
            focusNode: _compoundFocusNodes['rate']!,
            nextFocusNode: _compoundFocusNodes['time'],
            label: l10n.annualInterestRate,
            hint: l10n.annualInterestRateHint,
            icon: Icons.percent,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _compoundControllers['time']!,
            focusNode: _compoundFocusNodes['time']!,
            nextFocusNode: _compoundFocusNodes['frequency'],
            label: l10n.timePeriod,
            hint: l10n.timePeriodHint,
            icon: Icons.schedule,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _compoundControllers['frequency']!,
            focusNode: _compoundFocusNodes['frequency']!,
            label: l10n.compoundingFrequency,
            hint: l10n.compoundingFrequencyHint,
            icon: Icons.repeat,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateCompoundInterest,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.calculateCompoundInterest,
                style: const TextStyle(fontSize: 16)),
          ),
          if (_compoundResult != null) ...[
            const SizedBox(height: 24),
            _buildResultCard(
                l10n,
                [
                  _buildResultRow(l10n, l10n.finalAmount,
                      '\$${_compoundResult!.compoundAmount.toStringAsFixed(2)}'),
                  _buildResultRow(l10n, l10n.interestEarned,
                      '\$${_compoundResult!.compoundInterestEarned.toStringAsFixed(2)}'),
                ],
                onBookmark: _saveCompoundToHistory),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
  }) {
    // Check if this is a percentage field
    final isPercentageField = label.contains('(%)') || hint.contains('%');

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        if (isPercentageField)
          const PercentageInputFormatter()
        else
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      onChanged: isPercentageField
          ? PercentageInputUtils.createPercentageOnChanged(controller)
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
      ),
      textInputAction:
          nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
      onSubmitted: (value) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
    );
  }

  Widget _buildResultCard(
    AppLocalizations l10n,
    List<Widget> children, {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.results,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (onBookmark != null)
                  IconButton(
                    onPressed: onBookmark,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    tooltip: 'Lưu vào lịch sử',
                    iconSize: 20,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
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

  Widget _buildResultRow(AppLocalizations l10n, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _calculateLoan({bool skipValidation = false}) {
    final amount = double.tryParse(_loanControllers['amount']!.text);
    final rate = double.tryParse(_loanControllers['rate']!.text);
    final term = double.tryParse(_loanControllers['term']!.text);

    if (!skipValidation &&
        (amount == null ||
            rate == null ||
            term == null ||
            amount <= 0 ||
            rate < 0 ||
            term <= 0)) {
      _showErrorDialog(AppLocalizations.of(context)!.pleaseEnterValidNumbers);
      return;
    }

    // If we get here with skipValidation=true, use 0 as fallback for nulls
    final safeAmount = amount ?? 0;
    final safeRate = rate ?? 0;
    final safeTerm = term ?? 0;

    setState(() {
      _loanResult = FinancialCalculatorService.calculateLoan(
        amount: safeAmount,
        rate: safeRate,
        term: safeTerm,
      );
    });
    _saveState();
  }

  void _calculateInvestment({bool skipValidation = false}) {
    final initial =
        double.tryParse(_investmentControllers['initial']!.text) ?? 0;
    final monthly =
        double.tryParse(_investmentControllers['monthly']!.text) ?? 0;
    final rate = double.tryParse(_investmentControllers['rate']!.text);
    final term = double.tryParse(_investmentControllers['term']!.text);

    if (!skipValidation &&
        (rate == null || term == null || rate < 0 || term <= 0)) {
      _showErrorDialog(
          AppLocalizations.of(context)!.pleaseEnterValidReturnAndTerm);
      return;
    }

    // Use safe fallbacks when skipValidation is true
    final safeRate = rate ?? 0;
    final safeTerm = term ?? 0;

    setState(() {
      _investmentResult = FinancialCalculatorService.calculateInvestment(
        initial: initial,
        monthly: monthly,
        rate: safeRate,
        term: safeTerm,
      );
    });
    _saveState();
  }

  void _calculateCompoundInterest({bool skipValidation = false}) {
    final principal = double.tryParse(_compoundControllers['principal']!.text);
    final rate = double.tryParse(_compoundControllers['rate']!.text);
    final time = double.tryParse(_compoundControllers['time']!.text);
    final frequency = double.tryParse(_compoundControllers['frequency']!.text);

    if (!skipValidation &&
        (principal == null ||
            rate == null ||
            time == null ||
            frequency == null ||
            principal <= 0 ||
            rate < 0 ||
            time <= 0 ||
            frequency <= 0)) {
      _showErrorDialog(AppLocalizations.of(context)!.pleaseEnterValidNumbers);
      return;
    }

    // Use safe fallbacks when skipValidation is true
    final safePrincipal = principal ?? 0;
    final safeRate = rate ?? 0;
    final safeTime = time ?? 0;
    final safeFrequency = frequency ?? 0;

    setState(() {
      _compoundResult = FinancialCalculatorService.calculateCompoundInterest(
        principal: safePrincipal,
        rate: safeRate,
        time: safeTime,
        frequency: safeFrequency,
      );
    });
    _saveState();
  }

  Widget _buildHistoryWidget() {
    final l10n = AppLocalizations.of(context)!;

    return _buildHistoryPanel(l10n);
  }

  Future<void> _showClearDataDialog(AppLocalizations l10n) async {
    final tabNames = [l10n.loanTab, l10n.investmentTab, l10n.compoundTab];
    final currentTabName = tabNames[_currentMainTabIndex];

    await GenericDialogUtils.showSimpleGenericClearDialog(
      context: context,
      title: l10n.clearTabData,
      description: '${l10n.clearTabData}: $currentTabName?',
      onConfirm: () {
        _clearCurrentTabData();
        if (mounted) {
          SnackbarUtils.showTyped(
            context,
            '${l10n.tabDataCleared}: $currentTabName',
            SnackBarType.info,
          );
        }
      },
    );
  }

  void _clearCurrentTabData() {
    setState(() {
      _wasDataCleared = true; // Mark that data was manually cleared
      switch (_currentMainTabIndex) {
        case 0: // Loan tab
          _loanControllers['amount']!.clear();
          _loanControllers['rate']!.clear();
          _loanControllers['term']!.clear();
          _loanResult = null;
          break;
        case 1: // Investment tab
          _investmentControllers['initial']!.clear();
          _investmentControllers['monthly']!.clear();
          _investmentControllers['rate']!.clear();
          _investmentControllers['term']!.clear();
          _investmentResult = null;
          break;
        case 2: // Compound Interest tab
          _compoundControllers['principal']!.clear();
          _compoundControllers['rate']!.clear();
          _compoundControllers['time']!.clear();
          _compoundControllers['frequency']!.clear();
          _compoundResult = null;
          break;
      }
    });
    _saveState();
  }

  Future<void> _showClearHistoryDialog(AppLocalizations l10n) async {
    await GenericDialogUtils.showSimpleHoldClearDialog(
      context: context,
      title: l10n.clearAll,
      content: l10n.confirmClearFinancialHistory,
      duration: const Duration(seconds: 1),
      onConfirm: () async {
        await FinancialCalculatorService.clearHistory();
        await _loadSettings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.financialHistoryCleared)),
          );
        }
      },
    );
  }

  IconData _getCalculationIcon(String? subType) {
    switch (subType) {
      case 'loan':
        return Icons.home;
      case 'investment':
        return Icons.trending_up;
      case 'compound':
        return Icons.savings;
      default:
        return Icons.calculate;
    }
  }

  void _loadFromHistory(UnifiedHistoryData item) {
    // The 'value' field is a JSON string, decode it first.
    final data = jsonDecode(item.value.toString()) as Map<String, dynamic>?;

    if (data == null || data['inputsData'] == null) {
      // Handle legacy data or error
      SnackbarUtils.showTyped(context,
          'Could not load bookmark: invalid data format.', SnackBarType.error);
      return;
    }

    final inputsData = data['inputsData'] as Map<String, dynamic>;

    setState(() {
      switch (item.subType) {
        case 'loan':
          _currentMainTabIndex = 0;
          inputsData.forEach((key, value) {
            if (_loanControllers.containsKey(key)) {
              _loanControllers[key]!.text = value.toString();
            }
          });
          // Trigger calculation after loading data
          _calculateLoan(skipValidation: true);
          break;
        case 'investment':
          _currentMainTabIndex = 1;
          inputsData.forEach((key, value) {
            if (_investmentControllers.containsKey(key)) {
              _investmentControllers[key]!.text = value.toString();
            }
          });
          // Trigger calculation after loading data
          _calculateInvestment(skipValidation: true);
          break;
        case 'compound':
          _currentMainTabIndex = 2;
          inputsData.forEach((key, value) {
            if (_compoundControllers.containsKey(key)) {
              _compoundControllers[key]!.text = value.toString();
            }
          });
          // Trigger calculation after loading data
          _calculateCompoundInterest(skipValidation: true);
          break;
      }
    });
    _saveState();
  }

  void _showFinancialCalculatorInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    GenericInfoDialog.show(
      context: context,
      title: l10n.financialCalculatorDetailedInfo,
      overview: l10n.financialCalculatorOverview,
      headerIcon: Icons.calculate,
      sections: [
        // Key Features
        InfoSection(
          title: l10n.financialKeyFeatures,
          icon: Icons.star_outline,
          color: Colors.indigo,
          children: [
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.comprehensiveFinancialCalc,
                description: l10n.comprehensiveFinancialCalcDesc,
                icon: Icons.calculate,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.multipleCalculationTypes,
                description: l10n.multipleCalculationTypesDesc,
                icon: Icons.category,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.realTimeResults,
                description: l10n.realTimeResultsDesc,
                icon: Icons.speed,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.historySaving,
                description: l10n.historySavingDesc,
                icon: Icons.history,
              ),
            ),
          ],
        ),

        // How to Use
        InfoSection(
          title: l10n.financialHowToUse,
          icon: Icons.help_outline,
          color: Colors.blue,
          children: [
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                  step: l10n.step1Financial,
                  description: l10n.step1FinancialDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                  step: l10n.step2Financial,
                  description: l10n.step2FinancialDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                  step: l10n.step3Financial,
                  description: l10n.step3FinancialDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                  step: l10n.step4Financial,
                  description: l10n.step4FinancialDesc),
            ),
          ],
        ), // Financial Formulas
        InfoSection(
          title: l10n.financialFormulas,
          icon: Icons.functions,
          color: Colors.purple,
          children: [
            // Loan Formula
            _buildFormulaCard(
              theme: theme,
              title: l10n.loanFormula,
              formula: l10n.loanFormulaText,
              description: l10n.loanFormulaDesc,
            ),
            const SizedBox(height: 12),

            // Investment Formula
            _buildFormulaCard(
              theme: theme,
              title: l10n.investmentFormula,
              formula: l10n.investmentFormulaText,
              description: l10n.investmentFormulaDesc,
            ),
            const SizedBox(height: 12),

            // Compound Interest Formula
            _buildFormulaCard(
              theme: theme,
              title: l10n.compoundInterestFormula,
              formula: l10n.compoundInterestFormulaText,
              description: l10n.compoundInterestFormulaDesc,
            ),
          ],
        ),

        // Calculation Types
        InfoSection(
          title: l10n.financialCalculationTypes,
          icon: Icons.category,
          color: Colors.orange,
          children: [
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.loanCalculator,
                description: l10n.loanCalculationDesc,
                icon: Icons.home,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.investmentCalculator,
                description: l10n.investmentCalculationDesc,
                icon: Icons.trending_up,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.compoundInterestCalculator,
                description: l10n.compoundInterestDesc,
                icon: Icons.savings,
              ),
            ),
          ],
        ),

        // Practical Applications
        InfoSection(
          title: l10n.practicalFinancialApplications,
          icon: Icons.business_center,
          color: Colors.teal,
          children: [
            GenericInfoDialog.buildBulletList(
              theme: theme,
              description: l10n.financialApplicationsDesc,
              items: [
                'Thế chấp và vay mua nhà',
                'Vay mua xe và tài sản',
                'Kế hoạch tiết kiệm hưu trí',
                'Quỹ giáo dục con em',
                'Đầu tư kinh doanh',
                'Lập kế hoạch tài chính cá nhân',
              ],
            ),
          ],
        ),

        // Financial Tips
        InfoSection(
          title: l10n.financialTips,
          icon: Icons.lightbulb_outline,
          color: Colors.green,
          children: [
            GenericInfoDialog.buildTipItem(theme, l10n.financialTip1),
            GenericInfoDialog.buildTipItem(theme, l10n.financialTip2),
            GenericInfoDialog.buildTipItem(theme, l10n.financialTip3),
            GenericInfoDialog.buildTipItem(theme, l10n.financialTip4),
            GenericInfoDialog.buildTipItem(theme, l10n.financialTip5),
          ],
        ),

        // Limitations
        InfoSection(
          title: l10n.financialLimitations,
          icon: Icons.warning_outlined,
          color: Colors.amber,
          children: [
            GenericInfoDialog.buildBulletList(
              theme: theme,
              description: l10n.financialLimitationsDesc,
              items: [
                l10n.financialLimitation1,
                l10n.financialLimitation2,
                l10n.financialLimitation3,
                l10n.financialLimitation4,
                l10n.financialLimitation5,
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
              text: l10n.financialDisclaimer,
            ),
          ],
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.inputError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaCard({
    required ThemeData theme,
    required String title,
    required String formula,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              formula,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPanel(AppLocalizations l10n) {
    if (_history.isEmpty) {
      return Center(
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
                'Start calculating and save results to create bookmarks',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _getCalculationIcon(item.subType),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(_getL10nNameFromSubType(item.subType, l10n)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.value}: ${item.displayTitle ?? item.title ?? 'Financial Calculation'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  l10n.savedOnDate(LocalizationUtils.getFormattedDateTime(
                      context, item.timestamp,
                      includeSeconds: true)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  await FinancialCalculatorService.removeFromHistory(
                      item.id.toString());
                  await _loadSettings();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete),
                      const SizedBox(width: 8),
                      Text(l10n.removeFromFinancialHistory),
                    ],
                  ),
                ),
              ],
            ),
            onTap: () {
              // Load calculation into current state
              _loadFromHistory(item);
            },
          ),
        );
      },
    );
  }

  String _getL10nNameFromSubType(String? subType, AppLocalizations l10n) {
    switch (subType) {
      case 'loan':
        return l10n.loanTab;
      case 'investment':
        return l10n.investmentTab;
      case 'compound':
        return l10n.compoundTab;
      default:
        return l10n.financialCalculator;
    }
  }
}
