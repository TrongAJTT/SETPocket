import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiscountCalculatorScreen extends StatefulWidget {
  const DiscountCalculatorScreen({super.key});

  @override
  State<DiscountCalculatorScreen> createState() =>
      _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Discount Calculator
  final _originalPriceController = TextEditingController();
  final _discountPercentController = TextEditingController();
  double? _discountAmount;
  double? _finalPrice;
  double? _savedAmount;

  // Tip Calculator
  final _billAmountController = TextEditingController();
  final _tipPercentController = TextEditingController(text: '15');
  final _numberOfPeopleController = TextEditingController(text: '1');
  double? _tipAmount;
  double? _totalBill;
  double? _perPersonAmount;

  // Tax Calculator
  final _priceBeforeTaxController = TextEditingController();
  final _taxRateController = TextEditingController();
  double? _taxAmount;
  double? _priceAfterTax;

  // Markup Calculator
  final _costPriceController = TextEditingController();
  final _markupPercentController = TextEditingController();
  double? _markupAmount;
  double? _sellingPrice;
  double? _profitMargin;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _originalPriceController.dispose();
    _discountPercentController.dispose();
    _billAmountController.dispose();
    _tipPercentController.dispose();
    _numberOfPeopleController.dispose();
    _priceBeforeTaxController.dispose();
    _taxRateController.dispose();
    _costPriceController.dispose();
    _markupPercentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discount Calculator'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Discount', icon: Icon(Icons.local_offer)),
            Tab(text: 'Tip', icon: Icon(Icons.restaurant)),
            Tab(text: 'Tax', icon: Icon(Icons.receipt)),
            Tab(text: 'Markup', icon: Icon(Icons.trending_up)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscountCalculator(),
          _buildTipCalculator(),
          _buildTaxCalculator(),
          _buildMarkupCalculator(),
        ],
      ),
    );
  }

  Widget _buildDiscountCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Discount Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _originalPriceController,
            label: 'Original Price (\$)',
            hint: 'Enter original price',
            icon: Icons.attach_money,
            onChanged: (_) => _calculateDiscount(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _discountPercentController,
            label: 'Discount Percentage (%)',
            hint: 'Enter discount percentage',
            icon: Icons.percent,
            onChanged: (_) => _calculateDiscount(),
          ),
          const SizedBox(height: 24),
          if (_finalPrice != null) ...[
            _buildResultCard([
              _buildResultRow('Discount Amount',
                  '\$${_discountAmount!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'Final Price', '\$${_finalPrice!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'You Save', '\$${_savedAmount!.toStringAsFixed(2)}'),
            ]),
            const SizedBox(height: 16),
            _buildVisualIndicator(
              'Savings: ${((_discountAmount! / (_originalPriceController.text.isEmpty ? 1 : double.parse(_originalPriceController.text))) * 100).toStringAsFixed(1)}%',
              _discountAmount! /
                  (double.tryParse(_originalPriceController.text) ?? 1),
              Colors.green,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTipCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tip Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _billAmountController,
            label: 'Bill Amount (\$)',
            hint: 'Enter bill amount',
            icon: Icons.receipt_long,
            onChanged: (_) => _calculateTip(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _tipPercentController,
            label: 'Tip Percentage (%)',
            hint: 'Enter tip percentage',
            icon: Icons.percent,
            onChanged: (_) => _calculateTip(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _numberOfPeopleController,
            label: 'Number of People',
            hint: 'Enter number of people',
            icon: Icons.people,
            onChanged: (_) => _calculateTip(),
          ),
          const SizedBox(height: 16),
          _buildTipPercentageButtons(),
          const SizedBox(height: 24),
          if (_totalBill != null) ...[
            _buildResultCard([
              _buildResultRow(
                  'Tip Amount', '\$${_tipAmount!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'Total Bill', '\$${_totalBill!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'Per Person', '\$${_perPersonAmount!.toStringAsFixed(2)}'),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildTaxCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tax Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _priceBeforeTaxController,
            label: 'Price Before Tax (\$)',
            hint: 'Enter price before tax',
            icon: Icons.shopping_cart,
            onChanged: (_) => _calculateTax(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _taxRateController,
            label: 'Tax Rate (%)',
            hint: 'Enter tax rate',
            icon: Icons.percent,
            onChanged: (_) => _calculateTax(),
          ),
          const SizedBox(height: 24),
          if (_priceAfterTax != null) ...[
            _buildResultCard([
              _buildResultRow(
                  'Tax Amount', '\$${_taxAmount!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'Price After Tax', '\$${_priceAfterTax!.toStringAsFixed(2)}'),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildMarkupCalculator() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Markup Calculator',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInputField(
            controller: _costPriceController,
            label: 'Cost Price (\$)',
            hint: 'Enter cost price',
            icon: Icons.shopping_bag,
            onChanged: (_) => _calculateMarkup(),
          ),
          const SizedBox(height: 16),
          _buildInputField(
            controller: _markupPercentController,
            label: 'Markup Percentage (%)',
            hint: 'Enter markup percentage',
            icon: Icons.trending_up,
            onChanged: (_) => _calculateMarkup(),
          ),
          const SizedBox(height: 24),
          if (_sellingPrice != null) ...[
            _buildResultCard([
              _buildResultRow(
                  'Markup Amount', '\$${_markupAmount!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'Selling Price', '\$${_sellingPrice!.toStringAsFixed(2)}'),
              _buildResultRow(
                  'Profit Margin', '${_profitMargin!.toStringAsFixed(1)}%'),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildTipPercentageButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Tip Percentages:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [10, 15, 18, 20, 25].map((percent) {
            return ElevatedButton(
              onPressed: () {
                _tipPercentController.text = percent.toString();
                _calculateTip();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text('$percent%'),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      onChanged: onChanged,
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

  Widget _buildVisualIndicator(String label, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  void _calculateDiscount() {
    final originalPrice = double.tryParse(_originalPriceController.text);
    final discountPercent = double.tryParse(_discountPercentController.text);

    if (originalPrice != null &&
        discountPercent != null &&
        originalPrice > 0 &&
        discountPercent >= 0) {
      _discountAmount = originalPrice * (discountPercent / 100);
      _finalPrice = originalPrice - _discountAmount!;
      _savedAmount = _discountAmount;
      setState(() {});
    } else {
      _discountAmount = null;
      _finalPrice = null;
      _savedAmount = null;
      setState(() {});
    }
  }

  void _calculateTip() {
    final billAmount = double.tryParse(_billAmountController.text);
    final tipPercent = double.tryParse(_tipPercentController.text);
    final numberOfPeople = int.tryParse(_numberOfPeopleController.text);

    if (billAmount != null &&
        tipPercent != null &&
        numberOfPeople != null &&
        billAmount > 0 &&
        tipPercent >= 0 &&
        numberOfPeople > 0) {
      _tipAmount = billAmount * (tipPercent / 100);
      _totalBill = billAmount + _tipAmount!;
      _perPersonAmount = _totalBill! / numberOfPeople;
      setState(() {});
    } else {
      _tipAmount = null;
      _totalBill = null;
      _perPersonAmount = null;
      setState(() {});
    }
  }

  void _calculateTax() {
    final priceBeforeTax = double.tryParse(_priceBeforeTaxController.text);
    final taxRate = double.tryParse(_taxRateController.text);

    if (priceBeforeTax != null &&
        taxRate != null &&
        priceBeforeTax > 0 &&
        taxRate >= 0) {
      _taxAmount = priceBeforeTax * (taxRate / 100);
      _priceAfterTax = priceBeforeTax + _taxAmount!;
      setState(() {});
    } else {
      _taxAmount = null;
      _priceAfterTax = null;
      setState(() {});
    }
  }

  void _calculateMarkup() {
    final costPrice = double.tryParse(_costPriceController.text);
    final markupPercent = double.tryParse(_markupPercentController.text);

    if (costPrice != null &&
        markupPercent != null &&
        costPrice > 0 &&
        markupPercent >= 0) {
      _markupAmount = costPrice * (markupPercent / 100);
      _sellingPrice = costPrice + _markupAmount!;
      _profitMargin = (_markupAmount! / _sellingPrice!) * 100;
      setState(() {});
    } else {
      _markupAmount = null;
      _sellingPrice = null;
      _profitMargin = null;
      setState(() {});
    }
  }
}
