import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/layouts/two_panels_main_multi_tab_layout.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/widgets/generic_info_dialog.dart';
import 'package:setpocket/utils/percentage_input_utils.dart';
import 'package:setpocket/controllers/discount_calculator_controller.dart';
import 'package:setpocket/models/discount_calculator_models.dart';
import 'package:setpocket/utils/localization_utils.dart';

class DiscountCalculatorScreen extends StatefulWidget {
  final bool isEmbedded;

  const DiscountCalculatorScreen({super.key, this.isEmbedded = false});

  @override
  State<DiscountCalculatorScreen> createState() =>
      _DiscountCalculatorScreenState();
}

class _DiscountCalculatorScreenState extends State<DiscountCalculatorScreen> {
  late DiscountCalculatorController _controller;
  bool _hasRestoredFormState = false;

  // Form controllers for each tab
  final Map<String, TextEditingController> _discountControllers = {
    'originalPrice': TextEditingController(),
    'discountPercent': TextEditingController(),
  };

  final Map<String, TextEditingController> _tipControllers = {
    'billAmount': TextEditingController(),
    'tipPercent': TextEditingController(),
    'numberOfPeople': TextEditingController(),
  };

  final Map<String, TextEditingController> _taxControllers = {
    'priceBeforeTax': TextEditingController(),
    'taxRate': TextEditingController(),
  };

  final Map<String, TextEditingController> _markupControllers = {
    'costPrice': TextEditingController(),
    'markupPercent': TextEditingController(),
  };
  @override
  void initState() {
    super.initState();
    _controller = DiscountCalculatorController();
    _controller.addListener(_onControllerChanged);
    _setupFormStateListeners();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    // Dispose all controllers
    for (final controller in _discountControllers.values) {
      controller.dispose();
    }
    for (final controller in _tipControllers.values) {
      controller.dispose();
    }
    for (final controller in _taxControllers.values) {
      controller.dispose();
    }
    for (final controller in _markupControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      // Restore form state when it becomes available
      if (_controller.isFormStateLoaded && !_hasRestoredFormState) {
        _restoreFormState();
        _hasRestoredFormState = true;
      }
    }
  }

  void _setupFormStateListeners() {
    // Setup listeners for discount controllers
    _discountControllers.forEach((key, controller) {
      controller.addListener(() {
        _controller.saveFormField('discount_$key', controller.text);
      });
    });

    // Setup listeners for tip controllers
    _tipControllers.forEach((key, controller) {
      controller.addListener(() {
        _controller.saveFormField('tip_$key', controller.text);
      });
    });

    // Setup listeners for tax controllers
    _taxControllers.forEach((key, controller) {
      controller.addListener(() {
        _controller.saveFormField('tax_$key', controller.text);
      });
    });

    // Setup listeners for markup controllers
    _markupControllers.forEach((key, controller) {
      controller.addListener(() {
        _controller.saveFormField('markup_$key', controller.text);
      });
    });
  }

  void _restoreFormState() {
    // Restore discount form state
    _discountControllers.forEach((key, controller) {
      final value = _controller.getFormField('discount_$key');
      if (value.isNotEmpty) {
        controller.text = value;
      }
    });

    // Restore tip form state
    _tipControllers.forEach((key, controller) {
      final value = _controller.getFormField('tip_$key');
      if (value.isNotEmpty) {
        controller.text = value;
      }
    });

    // Restore tax form state
    _taxControllers.forEach((key, controller) {
      final value = _controller.getFormField('tax_$key');
      if (value.isNotEmpty) {
        controller.text = value;
      }
    });

    // Restore markup form state
    _markupControllers.forEach((key, controller) {
      final value = _controller.getFormField('markup_$key');
      if (value.isNotEmpty) {
        controller.text = value;
      }
    });

    // Auto-calculate results if sufficient data is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoCalculateFromRestoredState();
    });
  }

  void _autoCalculateFromRestoredState() {
    switch (_controller.activeTab) {
      case DiscountCalculationType.discount:
        final originalPrice =
            double.tryParse(_discountControllers['originalPrice']!.text);
        final discountPercent =
            double.tryParse(_discountControllers['discountPercent']!.text);
        if (originalPrice != null &&
            discountPercent != null &&
            originalPrice > 0 &&
            discountPercent >= 0 &&
            discountPercent <= 100) {
          _calculateDiscount();
        }
        break;
      case DiscountCalculationType.tip:
        final billAmount = double.tryParse(_tipControllers['billAmount']!.text);
        final tipPercent = double.tryParse(_tipControllers['tipPercent']!.text);
        final numberOfPeople =
            int.tryParse(_tipControllers['numberOfPeople']!.text);
        if (billAmount != null &&
            tipPercent != null &&
            numberOfPeople != null &&
            billAmount > 0 &&
            tipPercent >= 0 &&
            numberOfPeople > 0) {
          _calculateTip();
        }
        break;
      case DiscountCalculationType.tax:
        final priceBeforeTax =
            double.tryParse(_taxControllers['priceBeforeTax']!.text);
        final taxRate = double.tryParse(_taxControllers['taxRate']!.text);
        if (priceBeforeTax != null &&
            taxRate != null &&
            priceBeforeTax > 0 &&
            taxRate >= 0) {
          _calculateTax();
        }
        break;
      case DiscountCalculationType.markup:
        final costPrice =
            double.tryParse(_markupControllers['costPrice']!.text);
        final markupPercent =
            double.tryParse(_markupControllers['markupPercent']!.text);
        if (costPrice != null &&
            markupPercent != null &&
            costPrice > 0 &&
            markupPercent >= 0) {
          _calculateMarkup();
        }
        break;
    }
  }

  void _loadFromHistory(DiscountCalculationHistory historyItem) {
    // Switch to the corresponding tab
    _controller.setActiveTab(historyItem.type);

    // Clear current results
    _controller.clearTabData();

    // Load input data based on calculation type
    switch (historyItem.type) {
      case DiscountCalculationType.discount:
        _discountControllers['originalPrice']!.text =
            historyItem.inputs['originalPrice'] ?? '';
        _discountControllers['discountPercent']!.text =
            historyItem.inputs['discountPercent'] ?? '';
        break;
      case DiscountCalculationType.tip:
        _tipControllers['billAmount']!.text =
            historyItem.inputs['billAmount'] ?? '';
        _tipControllers['tipPercent']!.text =
            historyItem.inputs['tipPercent'] ?? '';
        _tipControllers['numberOfPeople']!.text =
            historyItem.inputs['numberOfPeople'] ?? '';
        break;
      case DiscountCalculationType.tax:
        _taxControllers['priceBeforeTax']!.text =
            historyItem.inputs['priceBeforeTax'] ?? '';
        _taxControllers['taxRate']!.text = historyItem.inputs['taxRate'] ?? '';
        break;
      case DiscountCalculationType.markup:
        _markupControllers['costPrice']!.text =
            historyItem.inputs['costPrice'] ?? '';
        _markupControllers['markupPercent']!.text =
            historyItem.inputs['markupPercent'] ?? '';
        break;
    }

    // Auto-calculate after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoCalculateFromRestoredState();
    });
  }

  void _clearAllFormData() {
    // Clear all form controllers
    for (var controller in _discountControllers.values) {
      controller.clear();
    }
    for (var controller in _tipControllers.values) {
      controller.clear();
    }
    for (var controller in _taxControllers.values) {
      controller.clear();
    }
    for (var controller in _markupControllers.values) {
      controller.clear();
    }

    // Reset tip and people defaults
    _tipControllers['tipPercent']?.text = '15';
    _tipControllers['numberOfPeople']?.text = '1';

    // Clear form state in controller
    _controller.clearFormState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TwoPanelsMainMultiTabLayout(
      isEmbedded: widget.isEmbedded,
      title: l10n.discountCalculator,
      mainPanelTitle: l10n.discountCalculator,
      mainTabIndex: _getTabIndex(_controller.activeTab),
      onMainTabChanged: (index) {
        final tabType = [
          DiscountCalculationType.discount,
          DiscountCalculationType.tip,
          DiscountCalculationType.tax,
          DiscountCalculationType.markup,
        ][index];
        _controller.setActiveTab(tabType);
      },
      mainPanelActions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showInfoDialog(l10n),
          tooltip: l10n.showCalculatorInfo,
        ),
        IconButton(
          icon: const Icon(Icons.clear_all),
          onPressed: () => _showClearDataDialog(l10n),
          tooltip: l10n.clearTabData,
        ),
      ],
      secondaryPanelActions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showClearHistoryDialog(l10n),
          tooltip: l10n.clearCalculationHistory,
        ),
      ],
      mainTabs: [
        TabData(
          label: l10n.discountTab,
          icon: Icons.local_offer,
          content: _buildDiscountTab(),
        ),
        TabData(
          label: l10n.tipTab,
          icon: Icons.restaurant,
          content: _buildTipTab(),
        ),
        TabData(
          label: l10n.taxTab,
          icon: Icons.receipt,
          content: _buildTaxTab(),
        ),
        TabData(
          label: l10n.markupTab,
          icon: Icons.trending_up,
          content: _buildMarkupTab(),
        ),
      ],
      secondaryPanel: _buildHistoryPanel(),
      secondaryPanelTitle: 'History', // l10n.discountCalculatorHistory,
      secondaryTab: TabData(
        label: l10n.history,
        icon: Icons.history,
        content: _buildHistoryPanel(),
      ),
    );
  }

  int _getTabIndex(DiscountCalculationType type) {
    return [
      DiscountCalculationType.discount,
      DiscountCalculationType.tip,
      DiscountCalculationType.tax,
      DiscountCalculationType.markup,
    ].indexOf(type);
  }

  Widget _buildDiscountTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.discountCalculator,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.originalPrice,
            hint: l10n.enterOriginalPrice,
            controller: _discountControllers['originalPrice']!,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.discountPercent,
            hint: l10n.enterDiscountPercent,
            controller: _discountControllers['discountPercent']!,
            keyboardType: TextInputType.number,
            isPercentage: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateDiscount,
            child: Text(l10n.calculateDiscount),
          ),
          if (_controller.discountResult != null) ...[
            const SizedBox(height: 24),
            _buildDiscountResultTable(l10n, _controller.discountResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildTipTab() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.tipTab,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.billAmount,
            hint: l10n.enterBillAmount,
            controller: _tipControllers['billAmount']!,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.tipPercent,
            hint: l10n.enterTipPercent,
            controller: _tipControllers['tipPercent']!,
            keyboardType: TextInputType.number,
            isPercentage: true,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.numberOfPeople,
            hint: l10n.enterNumberOfPeople,
            controller: _tipControllers['numberOfPeople']!,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateTip,
            child: Text(l10n.calculateTip),
          ),
          if (_controller.tipResult != null) ...[
            const SizedBox(height: 24),
            _buildTipResultTable(l10n, _controller.tipResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildTaxTab() {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.taxTab,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.priceBeforeTax,
            hint: l10n.enterPriceBeforeTax,
            controller: _taxControllers['priceBeforeTax']!,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.taxRate,
            hint: l10n.enterTaxRate,
            controller: _taxControllers['taxRate']!,
            keyboardType: TextInputType.number,
            isPercentage: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateTax,
            child: Text(l10n.calculateTax),
          ),
          if (_controller.taxResult != null) ...[
            const SizedBox(height: 24),
            _buildTaxResultTable(l10n, _controller.taxResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildMarkupTab() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.markupTab,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.costPrice,
            hint: l10n.enterCostPrice,
            controller: _markupControllers['costPrice']!,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.markupPercent,
            hint: l10n.enterMarkupPercent,
            controller: _markupControllers['markupPercent']!,
            keyboardType: TextInputType.number,
            isPercentage: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateMarkup,
            child: Text(l10n.calculateMarkup),
          ),
          if (_controller.markupResult != null) ...[
            const SizedBox(height: 24),
            _buildMarkupResultTable(l10n, _controller.markupResult!),
          ],
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required TextInputType keyboardType,
    bool isPercentage = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        if (isPercentage) const PercentageInputFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        suffixText: isPercentage ? '%' : null,
      ),
    );
  }

  // Calculation methods
  void _calculateDiscount() async {
    final originalPrice =
        double.tryParse(_discountControllers['originalPrice']!.text);
    final discountPercent =
        double.tryParse(_discountControllers['discountPercent']!.text);

    if (originalPrice == null ||
        discountPercent == null ||
        originalPrice <= 0 ||
        discountPercent < 0 ||
        discountPercent > 100) {
      _showErrorDialog('Please enter valid numbers');
      return;
    }

    try {
      await _controller.calculateDiscount(
        originalPrice: originalPrice,
        discountPercent: discountPercent,
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _calculateTip() async {
    final billAmount = double.tryParse(_tipControllers['billAmount']!.text);
    final tipPercent = double.tryParse(_tipControllers['tipPercent']!.text);
    final numberOfPeople =
        int.tryParse(_tipControllers['numberOfPeople']!.text);

    if (billAmount == null ||
        tipPercent == null ||
        numberOfPeople == null ||
        billAmount <= 0 ||
        tipPercent < 0 ||
        numberOfPeople <= 0) {
      _showErrorDialog('Please enter valid numbers');
      return;
    }

    try {
      await _controller.calculateTip(
        billAmount: billAmount,
        tipPercent: tipPercent,
        numberOfPeople: numberOfPeople,
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _calculateTax() async {
    final priceBeforeTax =
        double.tryParse(_taxControllers['priceBeforeTax']!.text);
    final taxRate = double.tryParse(_taxControllers['taxRate']!.text);

    if (priceBeforeTax == null ||
        taxRate == null ||
        priceBeforeTax <= 0 ||
        taxRate < 0) {
      _showErrorDialog('Please enter valid numbers');
      return;
    }

    try {
      await _controller.calculateTax(
        priceBeforeTax: priceBeforeTax,
        taxRate: taxRate,
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _calculateMarkup() async {
    final costPrice = double.tryParse(_markupControllers['costPrice']!.text);
    final markupPercent =
        double.tryParse(_markupControllers['markupPercent']!.text);

    if (costPrice == null ||
        markupPercent == null ||
        costPrice <= 0 ||
        markupPercent < 0) {
      _showErrorDialog('Please enter valid numbers');
      return;
    }

    try {
      await _controller.calculateMarkup(
        costPrice: costPrice,
        markupPercent: markupPercent,
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  void _showInfoDialog(AppLocalizations l10n) {
    final theme = Theme.of(context);

    GenericInfoDialog.show(
      context: context,
      title: l10n.discountCalculatorDetailedInfo,
      overview: l10n.discountCalculatorOverview,
      headerIcon: Icons.local_offer,
      sections: [
        // Key Features
        InfoSection(
          title: l10n.discountKeyFeatures,
          icon: Icons.star_outline,
          color: Colors.blue,
          children: [
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.comprehensiveDiscountCalc,
                description: l10n.comprehensiveDiscountCalcDesc,
                icon: Icons.calculate,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.multipleDiscountModes,
                description: l10n.multipleDiscountModesDesc,
                icon: Icons.tab,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.realTimeDiscountResults,
                description: l10n.realTimeDiscountResultsDesc,
                icon: Icons.flash_on,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.discountHistorySaving,
                description: l10n.discountHistorySavingDesc,
                icon: Icons.history,
              ),
            ),
          ],
        ),

        // How to Use
        InfoSection(
          title: l10n.discountHowToUse,
          icon: Icons.help_outline,
          color: Colors.green,
          children: [
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                  step: l10n.step1Discount,
                  description: l10n.step1DiscountDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                  step: l10n.step2Discount,
                  description: l10n.step2DiscountDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                  step: l10n.step3Discount,
                  description: l10n.step3DiscountDesc),
            ),
            GenericInfoDialog.buildStepItem(
              theme,
              StepItem(
                  step: l10n.step4Discount,
                  description: l10n.step4DiscountDesc),
            ),
          ],
        ),

        // Calculation Modes
        InfoSection(
          title: l10n.discountCalculationModes,
          icon: Icons.category,
          color: Colors.orange,
          children: [
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.discountMode,
                description: l10n.discountModeDesc,
                icon: Icons.local_offer,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.tipMode,
                description: l10n.tipModeDesc,
                icon: Icons.restaurant,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.taxMode,
                description: l10n.taxModeDesc,
                icon: Icons.receipt,
              ),
            ),
            GenericInfoDialog.buildFeatureItem(
              theme,
              FeatureItem(
                title: l10n.markupMode,
                description: l10n.markupModeDesc,
                icon: Icons.trending_up,
              ),
            ),
          ],
        ),

        // Usage Tips
        InfoSection(
          title: l10n.discountTips,
          icon: Icons.lightbulb_outline,
          color: Colors.indigo,
          children: [
            GenericInfoDialog.buildTipItem(theme, l10n.discountTip1),
            GenericInfoDialog.buildTipItem(theme, l10n.discountTip2),
            GenericInfoDialog.buildTipItem(theme, l10n.discountTip3),
            GenericInfoDialog.buildTipItem(theme, l10n.discountTip4),
            GenericInfoDialog.buildTipItem(theme, l10n.discountTip5),
          ],
        ),

        // Important Notes
        InfoSection(
          title: l10n.discountLimitations,
          icon: Icons.warning_outlined,
          color: Colors.amber,
          children: [
            GenericInfoDialog.buildBulletList(
              theme: theme,
              description: l10n.discountLimitationsDesc,
              items: [
                l10n.discountLimitation1,
                l10n.discountLimitation2,
                l10n.discountLimitation3,
                l10n.discountLimitation4,
                l10n.discountLimitation5,
              ],
            ),
          ],
        ), // Disclaimer
        InfoSection(
          title: l10n.discountLimitations,
          icon: Icons.info_outline,
          color: Colors.red,
          children: [
            GenericInfoDialog.buildDisclaimer(
              theme: theme,
              text: l10n.discountDisclaimer,
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
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
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
            onTap: () {
              _loadFromHistory(item);
              SnackbarUtils.showCustom(
                context,
                'Đã tải dữ liệu từ lịch sử',
              );
            },
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  await _controller.removeFromHistory(item.id);
                  if (context.mounted) {
                    SnackbarUtils.showCustom(
                      context,
                      l10n.historyItemDeleted,
                    );
                  }
                } else if (value == 'load') {
                  _loadFromHistory(item);
                  if (context.mounted) {
                    SnackbarUtils.showCustom(
                      context,
                      'Đã tải dữ liệu từ lịch sử',
                    );
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'load',
                  child: Row(
                    children: [
                      Icon(Icons.restore),
                      SizedBox(width: 8),
                      Text('Tải từ lịch sử'),
                    ],
                  ),
                ),
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
          ),
        );
      },
    );
  }

  IconData _getTabIcon(DiscountCalculationType type) {
    switch (type) {
      case DiscountCalculationType.discount:
        return Icons.local_offer;
      case DiscountCalculationType.tip:
        return Icons.restaurant;
      case DiscountCalculationType.tax:
        return Icons.receipt;
      case DiscountCalculationType.markup:
        return Icons.trending_up;
    }
  }

  void _showClearDataDialog(AppLocalizations l10n) {
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
              Navigator.of(context).pop();
              _clearAllFormData();
              _controller.clearTabData();
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

  void _showClearHistoryDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCalculationHistory),
        content: Text(l10n.confirmClearCalculatorHistory),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _controller.clearHistory();
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

  Widget _buildDiscountResultTable(
      AppLocalizations l10n, DiscountCalculationResult result) {
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
                    l10n.discountCalculatorResults,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () async {
                    try {
                      await _controller.saveDiscountToHistory();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.resultBookmarked)),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
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
                    l10n.originalPrice,
                    '\$${result.originalAmount.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.discountPercent,
                    '${result.discountPercent.toStringAsFixed(1)}%',
                  ),
                  _buildTableRow(
                    l10n.discountAmount,
                    '\$${result.discountAmount.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.finalAmount,
                    '\$${result.finalAmount.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.savedAmount,
                    '\$${result.savedAmount.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipResultTable(
      AppLocalizations l10n, TipCalculationResult result) {
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
                    l10n.tipCalculatorResults,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () async {
                    try {
                      await _controller.saveTipToHistory();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.resultBookmarked)),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
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
                    l10n.billAmount,
                    '\$${result.billAmount.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.tipPercent,
                    '${result.tipPercent.toStringAsFixed(1)}%',
                  ),
                  _buildTableRow(
                    l10n.numberOfPeople,
                    '${result.numberOfPeople}',
                  ),
                  _buildTableRow(
                    l10n.tipAmount,
                    '\$${result.tipAmount.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.totalBill,
                    '\$${result.totalBill.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.perPersonAmount,
                    '\$${result.perPersonAmount.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxResultTable(
      AppLocalizations l10n, TaxCalculationResult result) {
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
                    l10n.taxCalculatorResults,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () async {
                    try {
                      await _controller.saveTaxToHistory();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.resultBookmarked)),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
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
                    l10n.priceBeforeTax,
                    '\$${result.priceBeforeTax.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.taxRate,
                    '${result.taxRate.toStringAsFixed(1)}%',
                  ),
                  _buildTableRow(
                    l10n.taxAmount,
                    '\$${result.taxAmount.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.priceAfterTax,
                    '\$${result.priceAfterTax.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkupResultTable(
      AppLocalizations l10n, MarkupCalculationResult result) {
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
                    l10n.markupCalculatorResults,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () async {
                    try {
                      await _controller.saveMarkupToHistory();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.resultBookmarked)),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
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
                    l10n.costPrice,
                    '\$${result.costPrice.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.markupPercent,
                    '${result.markupPercent.toStringAsFixed(1)}%',
                  ),
                  _buildTableRow(
                    l10n.markupAmount,
                    '\$${result.markupAmount.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.sellingPrice,
                    '\$${result.sellingPrice.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    l10n.profitMargin,
                    '${result.profitMargin.toStringAsFixed(1)}%',
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
}
