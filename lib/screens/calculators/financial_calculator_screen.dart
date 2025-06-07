import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class FinancialCalculatorScreen extends StatefulWidget {
  const FinancialCalculatorScreen({super.key});

  @override
  State<FinancialCalculatorScreen> createState() =>
      _FinancialCalculatorScreenState();
}

class _FinancialCalculatorScreenState extends State<FinancialCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Loan Calculator
  final _loanAmountController = TextEditingController();
  final _loanInterestController = TextEditingController();
  final _loanTermController = TextEditingController();
  double? _monthlyPayment;
  double? _totalPayment;
  double? _totalInterest;

  // Investment Calculator
  final _initialInvestmentController = TextEditingController();
  final _monthlyContributionController = TextEditingController();
  final _investmentInterestController = TextEditingController();
  final _investmentTermController = TextEditingController();
  double? _futureValue;
  double? _totalContributions;
  double? _totalEarnings;

  // Compound Interest Calculator
  final _principalController = TextEditingController();
  final _compoundInterestController = TextEditingController();
  final _compoundTermController = TextEditingController();
  final _compoundFrequencyController = TextEditingController(text: '12');
  double? _compoundAmount;
  double? _compoundInterestEarned;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loanAmountController.dispose();
    _loanInterestController.dispose();
    _loanTermController.dispose();
    _initialInvestmentController.dispose();
    _monthlyContributionController.dispose();
    _investmentInterestController.dispose();
    _investmentTermController.dispose();
    _principalController.dispose();
    _compoundInterestController.dispose();
    _compoundTermController.dispose();
    _compoundFrequencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Calculator'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Loan', icon: Icon(Icons.home)),
            Tab(text: 'Investment', icon: Icon(Icons.trending_up)),
            Tab(text: 'Compound', icon: Icon(Icons.savings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLoanCalculator(),
          _buildInvestmentCalculator(),
          _buildCompoundInterestCalculator(),
        ],
      ),
    );
  }

  Widget _buildLoanCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Loan Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _loanAmountController,
            label: 'Loan Amount (\$)',
            hint: 'Enter loan amount',
            icon: Icons.attach_money,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _loanInterestController,
            label: 'Annual Interest Rate (%)',
            hint: 'Enter interest rate',
            icon: Icons.percent,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _loanTermController,
            label: 'Loan Term (years)',
            hint: 'Enter loan term',
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateLoan,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Calculate Loan', style: TextStyle(fontSize: 16)),
          ),
          if (_monthlyPayment != null) ...[
            const SizedBox(height: 24),
            _buildResultCard([
              _buildResultRow('Monthly Payment',
                  '\$${_monthlyPayment!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'Total Payment', '\$${_totalPayment!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'Total Interest', '\$${_totalInterest!.toStringAsFixed(2)}'),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildInvestmentCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Investment Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _initialInvestmentController,
            label: 'Initial Investment (\$)',
            hint: 'Enter initial amount',
            icon: Icons.savings,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _monthlyContributionController,
            label: 'Monthly Contribution (\$)',
            hint: 'Enter monthly contribution',
            icon: Icons.calendar_month,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _investmentInterestController,
            label: 'Annual Return (%)',
            hint: 'Enter expected return',
            icon: Icons.trending_up,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _investmentTermController,
            label: 'Investment Period (years)',
            hint: 'Enter investment period',
            icon: Icons.timeline,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateInvestment,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Calculate Investment',
                style: TextStyle(fontSize: 16)),
          ),
          if (_futureValue != null) ...[
            const SizedBox(height: 24),
            _buildResultCard([
              _buildResultRow(
                  'Future Value', '\$${_futureValue!.toStringAsFixed(2)}'),
              _buildResultRow('Total Contributions',
                  '\$${_totalContributions!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'Total Earnings', '\$${_totalEarnings!.toStringAsFixed(2)}'),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildCompoundInterestCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Compound Interest Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _principalController,
            label: 'Principal Amount (\$)',
            hint: 'Enter principal amount',
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _compoundInterestController,
            label: 'Annual Interest Rate (%)',
            hint: 'Enter interest rate',
            icon: Icons.percent,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _compoundTermController,
            label: 'Time Period (years)',
            hint: 'Enter time period',
            icon: Icons.schedule,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _compoundFrequencyController,
            label: 'Compounding Frequency (per year)',
            hint: 'Enter frequency (12 for monthly)',
            icon: Icons.repeat,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateCompoundInterest,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Calculate Compound Interest',
                style: TextStyle(fontSize: 16)),
          ),
          if (_compoundAmount != null) ...[
            const SizedBox(height: 24),
            _buildResultCard([
              _buildResultRow(
                  'Final Amount', '\$${_compoundAmount!.toStringAsFixed(2)}'),
              _buildResultRow('Interest Earned',
                  '\$${_compoundInterestEarned!.toStringAsFixed(2)}'),
            ]),
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildResultCard(List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Results',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
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

  void _calculateLoan() {
    final amount = double.tryParse(_loanAmountController.text);
    final rate = double.tryParse(_loanInterestController.text);
    final term = double.tryParse(_loanTermController.text);

    if (amount == null ||
        rate == null ||
        term == null ||
        amount <= 0 ||
        rate < 0 ||
        term <= 0) {
      _showErrorDialog('Please enter valid positive numbers for all fields.');
      return;
    }

    final monthlyRate = rate / 100 / 12;
    final numberOfPayments = term * 12;

    if (rate == 0) {
      _monthlyPayment = amount / numberOfPayments;
    } else {
      _monthlyPayment = amount *
          (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
          (pow(1 + monthlyRate, numberOfPayments) - 1);
    }

    _totalPayment = _monthlyPayment! * numberOfPayments;
    _totalInterest = _totalPayment! - amount;

    setState(() {});
  }

  void _calculateInvestment() {
    final initial = double.tryParse(_initialInvestmentController.text) ?? 0;
    final monthly = double.tryParse(_monthlyContributionController.text) ?? 0;
    final rate = double.tryParse(_investmentInterestController.text);
    final term = double.tryParse(_investmentTermController.text);

    if (rate == null || term == null || rate < 0 || term <= 0) {
      _showErrorDialog(
          'Please enter valid positive numbers for return rate and term.');
      return;
    }

    final monthlyRate = rate / 100 / 12;
    final numberOfMonths = term * 12;

    // Future value of initial investment
    final futureValueInitial = initial * pow(1 + monthlyRate, numberOfMonths);

    // Future value of monthly contributions (annuity)
    final futureValueAnnuity =
        monthly * ((pow(1 + monthlyRate, numberOfMonths) - 1) / monthlyRate);

    _futureValue = futureValueInitial + futureValueAnnuity;
    _totalContributions = initial + (monthly * numberOfMonths);
    _totalEarnings = _futureValue! - _totalContributions!;

    setState(() {});
  }

  void _calculateCompoundInterest() {
    final principal = double.tryParse(_principalController.text);
    final rate = double.tryParse(_compoundInterestController.text);
    final time = double.tryParse(_compoundTermController.text);
    final frequency = double.tryParse(_compoundFrequencyController.text);

    if (principal == null ||
        rate == null ||
        time == null ||
        frequency == null ||
        principal <= 0 ||
        rate < 0 ||
        time <= 0 ||
        frequency <= 0) {
      _showErrorDialog('Please enter valid positive numbers for all fields.');
      return;
    }

    final rateDecimal = rate / 100;
    _compoundAmount =
        principal * pow(1 + rateDecimal / frequency, frequency * time);
    _compoundInterestEarned = _compoundAmount! - principal;

    setState(() {});
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Input Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
