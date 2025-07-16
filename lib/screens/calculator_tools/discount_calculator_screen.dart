import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/layouts/two_panels_main_multi_tab_layout.dart';
import 'package:setpocket/services/function_info_service.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/widgets/generic_info_dialog.dart';
import 'package:setpocket/utils/percentage_input_utils.dart';
import 'package:setpocket/controllers/discount_calculator_controller.dart';
import 'package:setpocket/models/calculator_models/discount_calculator_models.dart';
import 'package:setpocket/utils/localization_utils.dart';
import 'package:setpocket/utils/generic_table_builder.dart' as table;
import 'package:setpocket/utils/generic_dialog_utils.dart';

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

  // Focus node to manage focus
  final Map<String, FocusNode> _discountFocusNodes = {
    'discountPercent': FocusNode(),
  };
  final Map<String, FocusNode> _tipFocusNodes = {
    'tipPercent': FocusNode(),
    'numberOfPeople': FocusNode(),
  };
  final Map<String, FocusNode> _taxFocusNodes = {
    'taxRate': FocusNode(),
  };
  final Map<String, FocusNode> _markupFocusNodes = {
    'markupPercent': FocusNode(),
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
          icon: const Icon(Icons.delete),
          onPressed: () => _showClearDataDialog(l10n),
          tooltip: l10n.clearTabData,
          iconSize: 20,
        ),
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: _showInfoDialog,
          tooltip: l10n.showCalculatorInfo,
          iconSize: 20,
        ),
      ],
      secondaryPanelActions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _showClearHistoryDialog(l10n),
          tooltip: l10n.clearCalculationHistory,
          iconSize: 20,
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
      secondaryPanel: _buildBookmarkPanel(),
      secondaryPanelTitle: l10n.bookmarks,
      secondaryTab: TabData(
        label: l10n.bookmarks,
        icon: Icons.bookmark,
        content: _buildBookmarkPanel(),
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
            nextFocusNode: _discountFocusNodes['discountPercent'],
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.discountPercent,
            hint: l10n.enterDiscountPercent,
            controller: _discountControllers['discountPercent']!,
            focusNode: _discountFocusNodes['discountPercent'],
            keyboardType: TextInputType.number,
            isPercentage: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateDiscount,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
            nextFocusNode: _tipFocusNodes['tipPercent']!,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.tipPercent,
            hint: l10n.enterTipPercent,
            controller: _tipControllers['tipPercent']!,
            focusNode: _tipFocusNodes['tipPercent'],
            nextFocusNode: _tipFocusNodes['numberOfPeople'],
            keyboardType: TextInputType.number,
            isPercentage: true,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.numberOfPeople,
            hint: l10n.enterNumberOfPeople,
            controller: _tipControllers['numberOfPeople']!,
            focusNode: _tipFocusNodes['numberOfPeople'],
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateTip,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
            nextFocusNode: _taxFocusNodes['taxRate'],
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.taxRate,
            hint: l10n.enterTaxRate,
            controller: _taxControllers['taxRate']!,
            focusNode: _taxFocusNodes['taxRate'],
            keyboardType: TextInputType.number,
            isPercentage: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateTax,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
            nextFocusNode: _markupFocusNodes['markupPercent'],
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: l10n.markupPercent,
            hint: l10n.enterMarkupPercent,
            controller: _markupControllers['markupPercent']!,
            focusNode: _markupFocusNodes['markupPercent'],
            keyboardType: TextInputType.number,
            isPercentage: true,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _calculateMarkup,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
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
      focusNode: focusNode,
      textInputAction:
          nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
      onFieldSubmitted: (value) {
        if (nextFocusNode != null) {
          FocusScope.of(context).requestFocus(nextFocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
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

  void _showInfoDialog() {
    FunctionInfo.show(context, FunctionInfoKeys.discountCalculator);
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

  Widget _buildBookmarkPanel() {
    final l10n = AppLocalizations.of(context)!;
    final history = _controller.history;

    if (history.isEmpty) {
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
                l10n.startCalculatingCreateBookmarkHint,
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
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history.toList()[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                _getTabIcon(item.type),
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: Text(_getL10nNameFromType(item.type, l10n)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.value}: ${item.displayTitle}',
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
            onTap: () {
              _loadFromHistory(item);
              SnackbarUtils.showTyped(
                context,
                'Bookmark loaded successfully',
                SnackBarType.success,
              );
            },
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  await _controller.removeFromHistory(item.id);
                  if (context.mounted) {
                    SnackbarUtils.showTyped(
                      context,
                      l10n.historyItemDeleted,
                      SnackBarType.info,
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
                      Text(l10n.delete),
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

  String _getL10nNameFromType(
      DiscountCalculationType type, AppLocalizations l10n) {
    switch (type) {
      case DiscountCalculationType.discount:
        return l10n.discountTab;
      case DiscountCalculationType.tip:
        return l10n.tipTab;
      case DiscountCalculationType.tax:
        return l10n.taxTab;
      case DiscountCalculationType.markup:
        return l10n.markupTab;
    }
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
    GenericDialogUtils.showSimpleGenericClearDialog(
      context: context,
      title: l10n.clearTabData,
      description: l10n.confirmClearTabData,
      onConfirm: () {
        _clearAllFormData();
        _controller.clearTabData();
        SnackbarUtils.showTyped(
          context,
          l10n.tabDataCleared,
          SnackBarType.info,
        );
      },
    );
  }

  void _showClearHistoryDialog(AppLocalizations l10n) {
    GenericDialogUtils.showSimpleHoldClearDialog(
      context: context,
      title: l10n.clearHistory,
      content: l10n.confirmClearHistory,
      duration: const Duration(seconds: 1),
      onConfirm: () {
        _controller.clearHistory();
        SnackbarUtils.showTyped(
          context,
          l10n.historyCleared,
          SnackBarType.info,
        );
      },
    );
  }

  Widget _buildDiscountResultTable(
      AppLocalizations l10n, DiscountCalculationResult result) {
    return table.GenericTableBuilder.buildResultCard(
      context,
      title: l10n.discountCalculatorResults,
      style: table.TableStyle.bordered,
      onSave: () => _saveDiscountToHistory(l10n),
      rows: [
        table.GenericTableBuilder.createRow(
          l10n.originalPrice,
          '\$${result.originalAmount.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.discountPercent,
          '${result.discountPercent.toStringAsFixed(1)}%',
        ),
        table.GenericTableBuilder.createRow(
          l10n.discountAmount,
          '\$${result.discountAmount.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.finalAmount,
          '\$${result.finalAmount.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.savedAmount,
          '\$${result.savedAmount.toStringAsFixed(2)}',
        ),
      ],
    );
  }

  Widget _buildTipResultTable(
      AppLocalizations l10n, TipCalculationResult result) {
    return table.GenericTableBuilder.buildResultCard(
      context,
      title: l10n.tipCalculatorResults,
      style: table.TableStyle.bordered,
      onSave: () => _saveTipToHistory(l10n),
      rows: [
        table.GenericTableBuilder.createRow(
          l10n.billAmount,
          '\$${result.billAmount.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.tipPercent,
          '${result.tipPercent.toStringAsFixed(1)}%',
        ),
        table.GenericTableBuilder.createRow(
          l10n.numberOfPeople,
          '${result.numberOfPeople}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.tipAmount,
          '\$${result.tipAmount.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.totalBill,
          '\$${result.totalBill.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.perPersonAmount,
          '\$${result.perPersonAmount.toStringAsFixed(2)}',
        ),
      ],
    );
  }

  Widget _buildTaxResultTable(
      AppLocalizations l10n, TaxCalculationResult result) {
    return table.GenericTableBuilder.buildResultCard(
      context,
      title: l10n.taxCalculatorResults,
      style: table.TableStyle.bordered,
      onSave: () => _saveTaxToHistory(l10n),
      rows: [
        table.GenericTableBuilder.createRow(
          l10n.priceBeforeTax,
          '\$${result.priceBeforeTax.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.taxRate,
          '${result.taxRate.toStringAsFixed(1)}%',
        ),
        table.GenericTableBuilder.createRow(
          l10n.taxAmount,
          '\$${result.taxAmount.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.priceAfterTax,
          '\$${result.priceAfterTax.toStringAsFixed(2)}',
        ),
      ],
    );
  }

  Widget _buildMarkupResultTable(
      AppLocalizations l10n, MarkupCalculationResult result) {
    return table.GenericTableBuilder.buildResultCard(
      context,
      title: l10n.markupCalculatorResults,
      style: table.TableStyle.bordered,
      onSave: () => _saveMarkupToHistory(l10n),
      rows: [
        table.GenericTableBuilder.createRow(
          l10n.costPrice,
          '\$${result.costPrice.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.markupPercent,
          '${result.markupPercent.toStringAsFixed(1)}%',
        ),
        table.GenericTableBuilder.createRow(
          l10n.markupAmount,
          '\$${result.markupAmount.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.sellingPrice,
          '\$${result.sellingPrice.toStringAsFixed(2)}',
        ),
        table.GenericTableBuilder.createRow(
          l10n.profitMargin,
          '${result.profitMargin.toStringAsFixed(1)}%',
        ),
      ],
    );
  }

  void _saveDiscountToHistory(AppLocalizations l10n) async {
    try {
      await _controller.saveDiscountToHistory();
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          l10n.resultBookmarked,
          SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error: $e',
          SnackBarType.error,
        );
      }
    }
  }

  void _saveTipToHistory(AppLocalizations l10n) async {
    try {
      await _controller.saveTipToHistory();
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          l10n.resultBookmarked,
          SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error: $e',
          SnackBarType.error,
        );
      }
    }
  }

  void _saveTaxToHistory(AppLocalizations l10n) async {
    try {
      await _controller.saveTaxToHistory();
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          l10n.resultBookmarked,
          SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error: $e',
          SnackBarType.error,
        );
      }
    }
  }

  void _saveMarkupToHistory(AppLocalizations l10n) async {
    try {
      await _controller.saveMarkupToHistory();
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          l10n.resultBookmarked,
          SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          'Error: $e',
          SnackBarType.error,
        );
      }
    }
  }
}
