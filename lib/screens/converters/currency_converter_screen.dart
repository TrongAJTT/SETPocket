import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/converter_models.dart';
import '../../models/currency_preset_model.dart';
import '../../services/currency_cache_service.dart';
import '../../services/currency_service.dart';
import '../../services/currency_preset_service.dart';
import '../../services/settings_service.dart';
import '../../widgets/currency_fetch_progress_dialog.dart';
import '../../widgets/currency_fetch_status_dialog.dart';
import '../../widgets/unit_customization_dialog.dart';
import '../../services/currency_state_service.dart';
import '../../models/currency_state_model.dart';
import '../../l10n/app_localizations.dart';

enum CurrencyViewMode { cards, table }

class CurrencyConverterScreen extends StatefulWidget {
  final bool isEmbedded;

  const CurrencyConverterScreen({super.key, this.isEmbedded = false});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  CurrencyViewMode _viewMode = CurrencyViewMode.cards;
  final CurrencyConverter _converter = CurrencyConverter();

  // Status variables
  bool _isLoadingRates = false;
  DateTime? _lastUpdated;
  bool _isUsingLiveRates = false;

  // Currency visibility
  final Set<String> _visibleCurrencies = {
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'VND',
    'CNY',
    'THB',
    'SGD'
  };
  // Unified row management for both views
  final List<Map<String, TextEditingController>> _rowControllers = [];
  final List<Map<String, double>> _rowValues = [];
  final List<String> _rowBaseCurrencies =
      []; // Which currency is the base for each row
  final List<String> _cardNames = []; // Names for each card
  final List<Set<String>> _cardCurrencies = []; // Currencies for each card

  @override
  void initState() {
    super.initState();
    _loadState(); // Load saved state first
    _initializeCurrencyRates();
  }

  @override
  void dispose() {
    _saveState(); // Save state before disposing
    // Dispose all row controllers
    for (var rowControllers in _rowControllers) {
      for (var controller in rowControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  // Load saved state
  Future<void> _loadState() async {
    try {
      final state = await CurrencyStateService.loadState();

      // Clear existing data
      for (var rowControllers in _rowControllers) {
        for (var controller in rowControllers.values) {
          controller.dispose();
        }
      }
      _rowControllers.clear();
      _rowValues.clear();
      _rowBaseCurrencies.clear();
      _cardNames.clear();
      _cardCurrencies.clear();

      // Update visible currencies
      setState(() {
        _visibleCurrencies.clear();
        _visibleCurrencies.addAll(state.visibleCurrencies);
      });

      // Restore cards
      for (final cardState in state.cards) {
        final cardCurrencies =
            Set<String>.from(cardState.currencies ?? _visibleCurrencies);
        final newRowControllers = <String, TextEditingController>{};
        final newRowValues = <String, double>{};

        for (var currency in cardCurrencies) {
          final amount =
              currency == cardState.currencyCode ? cardState.amount : 0.0;
          newRowControllers[currency] =
              TextEditingController(text: amount.toStringAsFixed(2));
          newRowValues[currency] = amount;
        }

        _rowControllers.add(newRowControllers);
        _rowValues.add(newRowValues);
        _rowBaseCurrencies.add(cardState.currencyCode);
        _cardNames.add(cardState.name ?? 'Converter ${_rowControllers.length}');
        _cardCurrencies.add(cardCurrencies);
      }

      print(
          'CurrencyConverter: Loaded state with ${_rowControllers.length} cards');
    } catch (e) {
      print('CurrencyConverter: Error loading state: $e');
      // Fallback to default
      _addRow();
    }
  }

  // Save current state
  Future<void> _saveState() async {
    try {
      final cards = <CurrencyCardState>[];

      for (int i = 0; i < _rowControllers.length; i++) {
        final baseCurrency = _rowBaseCurrencies[i];
        final amount = _rowValues[i][baseCurrency] ?? 1.0;
        final name =
            i < _cardNames.length ? _cardNames[i] : 'Converter ${i + 1}';
        final currencies = i < _cardCurrencies.length
            ? _cardCurrencies[i].toList()
            : _visibleCurrencies.toList();

        cards.add(CurrencyCardState(
          currencyCode: baseCurrency,
          amount: amount,
          name: name,
          currencies: currencies,
        ));
      }

      final state = CurrencyStateModel(
        cards: cards,
        visibleCurrencies: _visibleCurrencies.toList(),
        lastUpdated: DateTime.now(),
      );

      await CurrencyStateService.saveState(state);
      print('CurrencyConverter: Saved state with ${cards.length} cards');
    } catch (e) {
      print('CurrencyConverter: Error saving state: $e');
    }
  }

  void _addRow() {
    final newRowControllers = <String, TextEditingController>{};
    final newRowValues = <String, double>{};

    // Use first visible currency as default instead of hardcoded USD
    final defaultCurrency = _visibleCurrencies.first;

    // Use current visible currencies for the new card
    for (var currency in _visibleCurrencies) {
      newRowControllers[currency] =
          TextEditingController(text: currency == defaultCurrency ? '1' : '0');
      newRowValues[currency] = currency == defaultCurrency ? 1.0 : 0.0;
    }
    setState(() {
      _rowControllers.add(newRowControllers);
      _rowValues.add(newRowValues);
      _rowBaseCurrencies.add(defaultCurrency); // Use first visible currency
      _cardNames.add('Converter ${_rowControllers.length}'); // Add default name
      _cardCurrencies
          .add(Set.from(_visibleCurrencies)); // Use current visible currencies
    });

    // Update conversions for the new row
    if (_rowControllers.isNotEmpty) {
      _updateRowConversions(_rowControllers.length - 1, defaultCurrency, 1.0);
    }

    // Save state after adding row
    _saveState();
  }

  void _removeRow(int index) {
    if (_rowControllers.length > index && _rowControllers.length > 1) {
      // Dispose controllers for this row
      for (var controller in _rowControllers[index].values) {
        controller.dispose();
      }

      setState(() {
        _rowControllers.removeAt(index);
        _rowValues.removeAt(index);
        _rowBaseCurrencies.removeAt(index);
        if (index < _cardNames.length) _cardNames.removeAt(index);
        if (index < _cardCurrencies.length) _cardCurrencies.removeAt(index);
      });

      // Save state after removing row
      _saveState();
    }
  }

  void _updateRowConversions(int rowIndex, String fromCurrency, double value) {
    if (rowIndex >= _rowValues.length) return;

    _rowBaseCurrencies[rowIndex] = fromCurrency;

    // Get currencies for this specific card
    final cardCurrencies = rowIndex < _cardCurrencies.length
        ? _cardCurrencies[rowIndex]
        : _visibleCurrencies;

    for (var currencyCode in cardCurrencies) {
      if (currencyCode != fromCurrency) {
        final convertedValue =
            _converter.convert(value, fromCurrency, currencyCode);
        _rowValues[rowIndex][currencyCode] = convertedValue;
        _rowControllers[rowIndex][currencyCode]?.text =
            convertedValue.toStringAsFixed(2);
      } else {
        _rowValues[rowIndex][currencyCode] = value;
      }
    }
    setState(() {});
  }

  void _onRowValueChanged(int rowIndex, String currencyCode, String value) {
    if (rowIndex >= _rowValues.length) return;

    final numValue = double.tryParse(value) ?? 0.0;
    _rowValues[rowIndex][currencyCode] = numValue;
    _updateRowConversions(rowIndex, currencyCode, numValue);
  }

  // Edit card name
  void _editCardName(int cardIndex) {
    final l10n = AppLocalizations.of(context)!;
    final currentName = cardIndex < _cardNames.length
        ? _cardNames[cardIndex]
        : 'Converter ${cardIndex + 1}';
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Card Name'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: InputDecoration(
            labelText: 'Card Name',
            hintText: 'Enter card name (max 20 characters)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName.length <= 20) {
                setState(() {
                  while (_cardNames.length <= cardIndex) {
                    _cardNames.add('Converter ${_cardNames.length + 1}');
                  }
                  _cardNames[cardIndex] = newName;
                });
                _saveState();
                Navigator.of(context).pop();
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // Edit card currencies
  void _editCardCurrencies(int cardIndex) {
    final l10n = AppLocalizations.of(context)!;
    final converter = CurrencyConverter();
    final availableUnits = converter.units
        .map((unit) => UnitItem(
              id: unit.id,
              name: unit.name,
              symbol: unit.symbol,
            ))
        .toList();

    final currentCurrencies = cardIndex < _cardCurrencies.length
        ? _cardCurrencies[cardIndex]
        : Set.from(_visibleCurrencies);

    showDialog(
      context: context,
      builder: (context) => UnitCustomizationDialog(
        title: 'Customize Card Currencies',
        availableUnits: availableUnits,
        visibleUnits: currentCurrencies.cast<String>(),
        onChanged: (newCurrencies) {
          _updateCardCurrencies(cardIndex, newCurrencies);
        },
        maxSelection: 10,
        minSelection: 0,
        showPresetOptions: true,
        presetKey: 'card_currencies',
      ),
    );
  }

  // Update card currencies
  void _updateCardCurrencies(int cardIndex, Set<String> newCurrencies) {
    if (newCurrencies.length < 2) {
      // Don't allow less than 2 currencies for proper conversion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least 2 currencies'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      // Ensure arrays are properly sized
      while (_cardCurrencies.length <= cardIndex) {
        _cardCurrencies.add(Set.from(_visibleCurrencies));
      }

      final oldCurrencies = _cardCurrencies[cardIndex];
      _cardCurrencies[cardIndex] = Set.from(newCurrencies);

      // Update controllers and values
      final newRowControllers = <String, TextEditingController>{};
      final newRowValues = <String, double>{};
      final baseCurrency = _rowBaseCurrencies[cardIndex];

      // Preserve existing values where possible
      for (var currency in newCurrencies) {
        final existingValue = _rowValues[cardIndex][currency] ??
            (currency == baseCurrency ? 1.0 : 0.0);
        newRowControllers[currency] =
            TextEditingController(text: existingValue.toStringAsFixed(2));
        newRowValues[currency] = existingValue;
      }

      // Dispose old controllers
      for (var controller in _rowControllers[cardIndex].values) {
        controller.dispose();
      }

      _rowControllers[cardIndex] = newRowControllers;
      _rowValues[cardIndex] = newRowValues;

      // Ensure base currency is still in the new set
      if (!newCurrencies.contains(baseCurrency)) {
        _rowBaseCurrencies[cardIndex] = newCurrencies.first;
      }

      // Update conversions
      final baseValue =
          _rowValues[cardIndex][_rowBaseCurrencies[cardIndex]] ?? 1.0;
      _updateRowConversions(
          cardIndex, _rowBaseCurrencies[cardIndex], baseValue);
    });

    _saveState();
  }

  Future<void> _initializeCurrencyRates() async {
    setState(() {
      _isLoadingRates = true;
    });

    try {
      // Get rates from cache service and update CurrencyService
      final rates = await CurrencyCacheService.getRates();
      final cacheInfo = await CurrencyCacheService.getCacheInfo();

      // Update CurrencyService with the cached rates
      await _updateCurrencyServiceRates(rates);

      if (mounted) {
        setState(() {
          _lastUpdated = cacheInfo?.lastUpdated;
          _isUsingLiveRates = cacheInfo != null && cacheInfo.isValid;
        });
      }

      // Update all existing rows
      for (int i = 0; i < _rowControllers.length; i++) {
        final baseCurrency = _rowBaseCurrencies[i];
        final baseValue = _rowValues[i][baseCurrency] ?? 1.0;
        _updateRowConversions(i, baseCurrency, baseValue);
      }
    } catch (e) {
      print('Failed to initialize currency rates: $e');
      if (mounted) {
        setState(() {
          _lastUpdated = null;
          _isUsingLiveRates = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRates = false;
        });
      }
    }
  }

  // Helper method to update CurrencyService with fresh rates
  Future<void> _updateCurrencyServiceRates(Map<String, double> rates) async {
    // Update CurrencyService with cached rates
    CurrencyService.updateCurrentRates(rates);
    print(
        'Currency Converter: Updated CurrencyService with ${rates.length} rates');
  }

  Future<void> _refreshCurrencyRates() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoadingRates = true;
    });

    try {
      // Get timeout from settings
      final fetchTimeout = await SettingsService.getFetchTimeout();

      // Show progress dialog
      final currencies =
          CurrencyService.getSupportedCurrencies().map((c) => c.code).toList();

      // Show dialog and wait for completion
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CurrencyFetchProgressDialog(
          timeoutSeconds: fetchTimeout,
          currencies: currencies,
          onCancel: () {
            // Handle cancel if needed
          },
        ),
      );

      final rates = await CurrencyCacheService.forceRefresh();
      final cacheInfo = await CurrencyCacheService.getCacheInfo();

      // Close progress dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Update CurrencyService with fresh rates
      await _updateCurrencyServiceRates(rates);

      if (mounted) {
        setState(() {
          _lastUpdated = cacheInfo?.lastUpdated;
          _isUsingLiveRates = cacheInfo != null && cacheInfo.isValid;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isUsingLiveRates ? l10n.liveRatesUpdated : l10n.staticRatesUsed,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Update all existing rows
      for (int i = 0; i < _rowControllers.length; i++) {
        final baseCurrency = _rowBaseCurrencies[i];
        final baseValue = _rowValues[i][baseCurrency] ?? 1.0;
        _updateRowConversions(i, baseCurrency, baseValue);
      }
    } catch (e) {
      print('Failed to refresh currency rates: $e');

      // Close progress dialog if still open
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateRates),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRates = false;
        });
      }
    }
  }

  void _updateCurrencyVisibility(Set<String> newVisible) {
    // Store current data for visible currencies
    final oldData = <int, Map<String, double>>{};
    for (int i = 0; i < _rowValues.length; i++) {
      oldData[i] = Map.from(_rowValues[i]);
    }

    setState(() {
      _visibleCurrencies.clear();
      _visibleCurrencies.addAll(newVisible);

      // Recreate controllers and values for new currency set
      for (int i = 0; i < _rowControllers.length; i++) {
        // Dispose old controllers
        for (var controller in _rowControllers[i].values) {
          controller.dispose();
        }

        // Create new controllers
        final newControllers = <String, TextEditingController>{};
        final newValues = <String, double>{};

        for (var currency in _visibleCurrencies) {
          final oldValue = oldData[i]?[currency] ?? 0.0;
          newControllers[currency] =
              TextEditingController(text: oldValue.toStringAsFixed(2));
          newValues[currency] = oldValue;
        }

        _rowControllers[i] = newControllers;
        _rowValues[i] = newValues;

        // Ensure base currency is still visible, otherwise change it
        if (!_visibleCurrencies.contains(_rowBaseCurrencies[i])) {
          _rowBaseCurrencies[i] = _visibleCurrencies.first;
        }
      }
    });

    // Update conversions for all rows
    for (int i = 0; i < _rowControllers.length; i++) {
      final baseCurrency = _rowBaseCurrencies[i];
      final baseValue = _rowValues[i][baseCurrency] ?? 1.0;
      _updateRowConversions(i, baseCurrency, baseValue);
    }

    // Save state after updating visibility
    _saveState();
  }

  void _showCurrencyCustomization() {
    final converter = CurrencyConverter();
    final availableUnits = converter.units
        .map((unit) => UnitItem(
              id: unit.id,
              name: unit.name,
              symbol: unit.symbol,
            ))
        .toList();

    showDialog(
      context: context,
      builder: (context) => UnitCustomizationDialog(
        title: AppLocalizations.of(context)!.customizeCurrenciesDialog,
        availableUnits: availableUnits,
        visibleUnits: Set.from(_visibleCurrencies),
        onChanged: _updateCurrencyVisibility,
        maxSelection: 10,
        minSelection: 0,
        showPresetOptions: true,
        presetKey: 'global_currencies',
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.currencyConverterInfo),
        content: Text(l10n.currencyConverterDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _showFetchStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CurrencyFetchStatusDialog(),
    );
  }

  String _formatLastUpdated(AppLocalizations l10n) {
    if (_lastUpdated == null) return '';

    final dateFormat = DateFormat('MM/dd/yyyy');
    final timeFormat = DateFormat('HH:mm:ss');

    final date = dateFormat.format(_lastUpdated!);
    final time = timeFormat.format(_lastUpdated!);

    return l10n.lastUpdatedAt(date, time);
  }

  void _resetLayout() {
    // Dispose all existing controllers
    for (var rowControllers in _rowControllers) {
      for (var controller in rowControllers.values) {
        controller.dispose();
      }
    }

    setState(() {
      _rowControllers.clear();
      _rowValues.clear();
      _rowBaseCurrencies.clear();
      _cardNames.clear();
      _cardCurrencies.clear();
    });

    // Add one default row
    _addRow();
  }

  void _reorderCards(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      // Reorder all related lists
      final item = _rowControllers.removeAt(oldIndex);
      _rowControllers.insert(newIndex, item);

      final values = _rowValues.removeAt(oldIndex);
      _rowValues.insert(newIndex, values);

      final baseCurrency = _rowBaseCurrencies.removeAt(oldIndex);
      _rowBaseCurrencies.insert(newIndex, baseCurrency);

      if (oldIndex < _cardNames.length && newIndex < _cardNames.length) {
        final name = _cardNames.removeAt(oldIndex);
        _cardNames.insert(newIndex, name);
      }

      if (oldIndex < _cardCurrencies.length &&
          newIndex < _cardCurrencies.length) {
        final currencies = _cardCurrencies.removeAt(oldIndex);
        _cardCurrencies.insert(newIndex, currencies);
      }
    });

    // Save state after reordering
    _saveState();
  }

  // Group cards by their currency sets for table view
  Map<String, List<int>> _groupCardsByCurrencies() {
    final groups = <String, List<int>>{};

    for (int i = 0; i < _rowControllers.length; i++) {
      final cardCurrencies =
          i < _cardCurrencies.length ? _cardCurrencies[i] : _visibleCurrencies;

      final currencyKey = cardCurrencies.toList()..sort();
      final keyString = currencyKey.join(',');

      if (!groups.containsKey(keyString)) {
        groups[keyString] = [];
      }
      groups[keyString]!.add(i);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.isEmbedded) {
      return _buildConverterContent();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.currencyConverter),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: l10n.currencyConverterInfo,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetLayout,
            tooltip: l10n.resetLayout,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showCurrencyCustomization,
            tooltip: l10n.customizeCurrencies,
          ),
        ],
      ),
      body: _buildConverterContent(),
    );
  }

  Widget _buildConverterContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildStatusRow(),
          const SizedBox(height: 16),
          Expanded(
            child: _viewMode == CurrencyViewMode.cards
                ? _buildCardsView()
                : _buildTableView(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;

          if (isNarrow) {
            // Stack layout for narrow screens
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (_isLoadingRates) ...[
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _lastUpdated == null
                              ? l10n.noRatesAvailable
                              : l10n.updatingRates,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else ...[
                      Icon(
                        _isUsingLiveRates ? Icons.wifi : Icons.wifi_off,
                        size: 16,
                        color: _isUsingLiveRates ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _isUsingLiveRates ? l10n.liveRates : l10n.staticRates,
                          style: TextStyle(
                            color: _isUsingLiveRates
                                ? Colors.green
                                : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _showFetchStatusDialog(context),
                          icon: Icon(
                            Icons.assessment,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          tooltip: l10n.viewFetchStatus,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _isLoadingRates ? null : _refreshCurrencyRates,
                          icon: Icon(
                            Icons.refresh,
                            color: _isLoadingRates
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          tooltip: l10n.refreshRates,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_lastUpdated != null && !_isLoadingRates)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatLastUpdated(l10n),
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            );
          } else {
            // Original horizontal layout for wider screens
            return Row(
              children: [
                if (_isLoadingRates) ...[
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _lastUpdated == null
                          ? l10n.noRatesAvailable
                          : l10n.updatingRates,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  Icon(
                    _isUsingLiveRates ? Icons.wifi : Icons.wifi_off,
                    size: 16,
                    color: _isUsingLiveRates ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isUsingLiveRates ? l10n.liveRates : l10n.staticRates,
                    style: TextStyle(
                      color: _isUsingLiveRates ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  if (_lastUpdated != null) ...[
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '• ${_formatLastUpdated(l10n)}',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else
                    const Spacer(),
                ],
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showFetchStatusDialog(context),
                      icon: Icon(
                        Icons.assessment,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      tooltip: l10n.viewFetchStatus,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: _isLoadingRates ? null : _refreshCurrencyRates,
                      icon: Icon(
                        Icons.refresh,
                        color: _isLoadingRates
                            ? Theme.of(context).disabledColor
                            : Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      tooltip: l10n.refreshRates,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildCardsView() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Add card button and view mode toggle
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, size: 16),
                label: Text(
                  l10n.addCard,
                  style: const TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _viewMode = CurrencyViewMode.table;
                  });
                },
                icon: const Icon(Icons.table_chart, size: 16),
                label: Text(
                  l10n.tableView,
                  style: const TextStyle(fontSize: 12),
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${l10n.cards}: ${_rowControllers.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Cards with responsive layout
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine number of columns based on screen width
              final screenWidth = constraints.maxWidth;
              int crossAxisCount = 1;

              // More conservative breakpoints to avoid layout issues
              if (screenWidth > 1200) {
                crossAxisCount = 3; // Large desktop - 3 columns
              } else if (screenWidth > 800) {
                crossAxisCount = 2; // Tablet/medium desktop - 2 columns
              } else {
                crossAxisCount = 1; // Mobile - 1 column
              }
              if (crossAxisCount == 1) {
                // Single column layout for mobile
                return ListView.builder(
                  itemCount: _rowControllers.length,
                  itemBuilder: (context, index) => _buildCard(index),
                );
              } else {
                // Multi-column layout for larger screens - cards fill available width
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(
                        _rowControllers.length,
                        (index) => SizedBox(
                          // Ensure cards take up full available width with spacing
                          width: (constraints.maxWidth -
                                  16 -
                                  (16 * (crossAxisCount - 1))) /
                              crossAxisCount,
                          child: _buildCard(index),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCard(int index) {
    if (index >= _rowControllers.length) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final baseCurrency = _rowBaseCurrencies[index];
    final rowControllers = _rowControllers[index];
    final cardCurrencies = index < _cardCurrencies.length
        ? _cardCurrencies[index].toList()
        : _visibleCurrencies.toList();
    final cardName = index < _cardNames.length
        ? _cardNames[index]
        : 'Converter ${index + 1}';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 300;

        return DragTarget<int>(
          onAccept: (draggedIndex) {
            if (draggedIndex != index) {
              _reorderCards(draggedIndex, index);
            }
          },
          builder: (context, candidateData, rejectedData) {
            final isReceivingDrag = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                border: isReceivingDrag
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildCardContent(index, constraints, isDesktop, l10n,
                  baseCurrency, rowControllers, cardCurrencies, cardName),
            );
          },
        );
      },
    );
  }

  Widget _buildCardContent(
      int index,
      BoxConstraints constraints,
      bool isDesktop,
      AppLocalizations l10n,
      String baseCurrency,
      Map<String, TextEditingController> rowControllers,
      List<String> cardCurrencies,
      String cardName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 12 : 8), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card header with drag handle, name, and action buttons
            Row(
              children: [
                // Drag handle icon
                Draggable<int>(
                  data: index,
                  feedback: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: constraints.maxWidth * 0.8,
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              cardName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dragging...',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  childWhenDragging: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.drag_handle,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.5),
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.drag_handle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cardName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 16 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Edit name button
                IconButton(
                  onPressed: () => _editCardName(index),
                  icon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  tooltip: 'Edit name',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                // Edit currencies button
                IconButton(
                  onPressed: () => _editCardCurrencies(index),
                  icon: Icon(
                    Icons.currency_exchange,
                    color: Theme.of(context).colorScheme.primary,
                    size: 18,
                  ),
                  tooltip: 'Edit currencies',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                // Delete button
                if (_rowControllers.length > 1)
                  IconButton(
                    onPressed: () => _removeRow(index),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 18,
                    ),
                    tooltip: l10n.removeCard,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
              ],
            ),
            SizedBox(height: isDesktop ? 16 : 12), // Restored spacing

            // Base currency input and dropdown - responsive layout
            LayoutBuilder(
              builder: (context, constraints) {
                // Use column layout if width is too narrow
                final useColumnLayout = constraints.maxWidth < 500;

                if (useColumnLayout) {
                  return Column(
                    children: [
                      TextField(
                        controller: rowControllers[baseCurrency],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          labelText: l10n.amount,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: (value) =>
                            _onRowValueChanged(index, baseCurrency, value),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: baseCurrency,
                        decoration: InputDecoration(
                          labelText: l10n.from,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        items: cardCurrencies.map((currency) {
                          final unit = _converter.units
                              .firstWhere((u) => u.id == currency);
                          return DropdownMenuItem<String>(
                            value: currency,
                            child: Text(
                              '${unit.symbol} - ${unit.name}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newCurrency) {
                          if (newCurrency != null) {
                            final currentValue =
                                _rowValues[index][baseCurrency] ?? 1.0;
                            _updateRowConversions(
                                index, newCurrency, currentValue);
                          }
                        },
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      // Amount input
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: rowControllers[baseCurrency],
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.]')),
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.amount,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (value) =>
                              _onRowValueChanged(index, baseCurrency, value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Currency dropdown
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          value: baseCurrency,
                          decoration: InputDecoration(
                            labelText: l10n.from,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          items: cardCurrencies.map((currency) {
                            final unit = _converter.units
                                .firstWhere((u) => u.id == currency);
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(
                                '${unit.symbol} - ${unit.name}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (newCurrency) {
                            if (newCurrency != null) {
                              final currentValue =
                                  _rowValues[index][baseCurrency] ?? 1.0;
                              _updateRowConversions(
                                  index, newCurrency, currentValue);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: isDesktop ? 12 : 8), // Restored spacing

            // "Converted to" label - restored size
            Text(
              '${l10n.convertedTo}:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 15 : 14, // Restored font size
              ),
            ),
            SizedBox(
                height: isDesktop
                    ? 12
                    : 8), // Restored spacing// Other currencies - compact layout for all devices
            if (isDesktop) ...[
              // Desktop: Enhanced Wrap layout with generous spacing and proper 2-column display
              Wrap(
                spacing: 12, // Increased spacing between items
                runSpacing: 8, // Increased vertical spacing
                children: cardCurrencies
                    .where((c) => c != baseCurrency)
                    .map((currency) {
                  final unit =
                      _converter.units.firstWhere((u) => u.id == currency);
                  final value = _rowValues[index][currency] ?? 0.0;
                  final currencyStatus =
                      CurrencyService.getCurrencyStatus(currency);
                  final hasError = currencyStatus == CurrencyStatus.failed ||
                      currencyStatus == CurrencyStatus.timeout;

                  // Improved error colors for dark mode compatibility
                  final isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;
                  final errorBackgroundColor = hasError
                      ? (isDarkMode
                          ? Colors.red.shade900.withOpacity(0.3)
                          : Colors.red.shade50)
                      : Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3);
                  final errorBorderColor = hasError
                      ? (isDarkMode ? Colors.red.shade400 : Colors.red.shade300)
                      : null;

                  return SizedBox(
                    // Optimized width calculation for proper 2-item display with generous spacing
                    width: constraints.maxWidth > 500
                        ? (constraints.maxWidth - 44) /
                            2 // 2 columns: account for 12px spacing + 16px padding each side
                        : constraints.maxWidth -
                            20, // 1 column with minimal padding
                    height: 52, // Increased height for better proportions
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12), // Enhanced padding
                      decoration: BoxDecoration(
                        color: errorBackgroundColor,
                        borderRadius:
                            BorderRadius.circular(8), // Slightly larger radius
                        border: hasError
                            ? Border.all(
                                color: errorBorderColor!,
                                width: 1,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          // Currency symbol with status indicator
                          SizedBox(
                            width: 40, // Increased width for better alignment
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Text(
                                  unit.symbol,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Improved font size
                                    color: hasError
                                        ? (Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.red.shade300
                                            : Colors.red.shade700)
                                        : null,
                                  ),
                                ),
                                if (hasError)
                                  Positioned(
                                    top: -2,
                                    right: 2,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: currencyStatus ==
                                                CurrencyStatus.timeout
                                            ? Colors.orange.shade600
                                            : Colors.red.shade600,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                              width:
                                  8), // Increased spacing                              // Currency name
                          Expanded(
                            child: Text(
                              unit.name,
                              style: const TextStyle(
                                  fontSize: 12), // Better font size
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                              width:
                                  8), // Increased spacing                              // Value
                          Text(
                            value.toStringAsFixed(2),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14, // Consistent with symbol size
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              // Mobile: More compact Column layout
              ...cardCurrencies.where((c) => c != baseCurrency).map((currency) {
                final unit =
                    _converter.units.firstWhere((u) => u.id == currency);
                final value = _rowValues[index][currency] ?? 0.0;
                final currencyStatus =
                    CurrencyService.getCurrencyStatus(currency);
                final hasError = currencyStatus == CurrencyStatus.failed ||
                    currencyStatus == CurrencyStatus.timeout;

                // Improved error colors for dark mode compatibility
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final errorBackgroundColor = hasError
                    ? (isDarkMode
                        ? Colors.red.shade900.withOpacity(0.3)
                        : Colors.red.shade50)
                    : Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withOpacity(0.3);
                final errorBorderColor = hasError
                    ? (isDarkMode ? Colors.red.shade400 : Colors.red.shade300)
                    : null;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: errorBackgroundColor,
                    borderRadius: BorderRadius.circular(6),
                    border: hasError
                        ? Border.all(
                            color: errorBorderColor!,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Currency symbol with status indicator
                      SizedBox(
                        width: 40,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              unit.symbol,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: hasError
                                    ? (isDarkMode
                                        ? Colors.red.shade300
                                        : Colors.red.shade700)
                                    : null,
                              ),
                            ),
                            if (hasError)
                              Positioned(
                                top: -2,
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color:
                                        currencyStatus == CurrencyStatus.timeout
                                            ? Colors.orange.shade600
                                            : Colors.red.shade600,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Currency name
                      Expanded(
                        child: Text(
                          unit.name,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Value
                      Text(
                        value.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTableView() {
    final l10n = AppLocalizations.of(context)!;
    final cardGroups = _groupCardsByCurrencies();

    return Column(
      children: [
        // Add row button and view mode toggle
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add),
                label: Text(l10n.addRow),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _viewMode = CurrencyViewMode.cards;
                  });
                },
                icon: const Icon(Icons.view_agenda),
                label: Text(l10n.cardView),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${l10n.rows}: ${_rowControllers.length} • Tables: ${cardGroups.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Multiple Tables
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: cardGroups.entries.map((entry) {
                final currencyKey = entry.key;
                final cardIndices = entry.value;
                final currencies = currencyKey.split(',');

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: _buildSingleTable(currencies, cardIndices, l10n),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleTable(
      List<String> currencies, List<int> cardIndices, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table header with currency info
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text(
                'Table ${cardIndices.length} cards',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '(${currencies.join(', ')})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Table
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DataTable(
              headingRowHeight: 60,
              dataRowMinHeight: 56,
              dataRowMaxHeight: 56,
              columnSpacing: 16,
              horizontalMargin: 16,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              columns: [
                DataColumn(
                  label: SizedBox(
                    width: 100,
                    child: Text(
                      'Tên Card',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ...currencies.map((currency) {
                  final unit =
                      _converter.units.firstWhere((u) => u.id == currency);
                  final currencyStatus =
                      CurrencyService.getCurrencyStatus(currency);
                  final hasError = currencyStatus == CurrencyStatus.failed ||
                      currencyStatus == CurrencyStatus.timeout;
                  final isDarkMode =
                      Theme.of(context).brightness == Brightness.dark;

                  return DataColumn(
                    label: SizedBox(
                      width: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        decoration: hasError
                            ? BoxDecoration(
                                color: isDarkMode
                                    ? Colors.red.shade900.withOpacity(0.3)
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.red.shade400
                                      : Colors.red.shade300,
                                  width: 1,
                                ),
                              )
                            : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  unit.symbol,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: hasError
                                        ? (isDarkMode
                                            ? Colors.red.shade300
                                            : Colors.red.shade700)
                                        : null,
                                  ),
                                ),
                                if (hasError) ...[
                                  const SizedBox(width: 2),
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: currencyStatus ==
                                              CurrencyStatus.timeout
                                          ? Colors.orange.shade600
                                          : Colors.red.shade600,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              unit.name,
                              style: TextStyle(
                                fontSize: 10,
                                color: hasError
                                    ? (isDarkMode
                                        ? Colors.red.shade400
                                        : Colors.red.shade600)
                                    : null,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                DataColumn(
                  label: SizedBox(
                    width: 160,
                    child: Text(
                      l10n.actions,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              rows: cardIndices.map((index) {
                final rowControllers = _rowControllers[index];
                final cardName = index < _cardNames.length
                    ? _cardNames[index]
                    : 'Converter ${index + 1}';

                return DataRow(
                  cells: [
                    DataCell(
                      Container(
                        width: 100,
                        alignment: Alignment.center,
                        child: Text(
                          cardName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    ...currencies.map((currency) {
                      return DataCell(
                        SizedBox(
                          width: 100,
                          child: TextField(
                            controller: rowControllers[currency],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]')),
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withOpacity(0.5),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              isDense: true,
                            ),
                            onChanged: (value) =>
                                _onRowValueChanged(index, currency, value),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      );
                    }).toList(),
                    DataCell(
                      Container(
                        width: 160,
                        alignment: Alignment.center,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit name button
                              IconButton(
                                onPressed: () => _editCardName(index),
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                                tooltip: 'Edit name',
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              // Edit currencies button
                              IconButton(
                                onPressed: () => _editCardCurrencies(index),
                                icon: Icon(
                                  Icons.currency_exchange,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                                tooltip: 'Edit currencies',
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              // Move up button
                              if (index > 0)
                                IconButton(
                                  onPressed: () =>
                                      _reorderCards(index, index - 1),
                                  icon: Icon(
                                    Icons.keyboard_arrow_up,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 16,
                                  ),
                                  tooltip: 'Move up',
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              // Move down button
                              if (index < _rowControllers.length - 1)
                                IconButton(
                                  onPressed: () =>
                                      _reorderCards(index, index + 2),
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    size: 16,
                                  ),
                                  tooltip: 'Move down',
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                              // Delete button
                              if (_rowControllers.length > 1)
                                IconButton(
                                  onPressed: () => _removeRow(index),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 16,
                                  ),
                                  tooltip: l10n.removeRow,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencyInfoDialog extends StatelessWidget {
  const _CurrencyInfoDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 16,
        vertical: isDesktop ? 40 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 600 : screenSize.width * 0.9,
          maxHeight: screenSize.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
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
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.currencyConverterInfo,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // About this feature
                    _buildSection(
                      context,
                      title: l10n.aboutThisFeature,
                      content: l10n.aboutThisFeatureDesc,
                      icon: Icons.currency_exchange,
                    ),

                    const SizedBox(height: 24),

                    // How to use
                    _buildSection(
                      context,
                      title: l10n.howToUse,
                      content: l10n.howToUseDesc,
                      icon: Icons.help_outline,
                    ),

                    const SizedBox(height: 24),

                    // Static rates info
                    _buildSection(
                      context,
                      title: l10n.staticRatesInfo,
                      content: l10n.staticRatesInfoDesc,
                      icon: Icons.table_chart,
                      hasButton: true,
                      buttonText: l10n.viewStaticRates,
                      onButtonPressed: () => _showStaticRatesDialog(context),
                    ),

                    const SizedBox(height: 16),

                    // Last update info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.update,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.lastStaticUpdate,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    bool hasButton = false,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        if (hasButton && buttonText != null) ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onButtonPressed,
            icon: const Icon(Icons.visibility, size: 18),
            label: Text(buttonText),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ],
    );
  }

  void _showStaticRatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _StaticRatesDialog(),
    );
  }
}

class _StaticRatesDialog extends StatelessWidget {
  const _StaticRatesDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;
    final staticRates = CurrencyService.getStaticRates();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 60 : 16,
        vertical: isDesktop ? 40 : 40,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 800 : screenSize.width * 0.95,
          maxHeight: screenSize.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade600,
                    Colors.blue.shade500,
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
                  Icon(
                    Icons.table_chart,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.staticRatesList,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // Info banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.rateBasedOnUSD,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Rates list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: staticRates.length,
                itemBuilder: (context, index) {
                  final entry = staticRates.entries.elementAt(index);
                  final currencyCode = entry.key;
                  final rate = entry.value;

                  // Get currency info
                  final currencies = CurrencyService.getSupportedCurrencies();
                  final currency = currencies.firstWhere(
                    (c) => c.code == currencyCode,
                    orElse: () =>
                        Currency(currencyCode, currencyCode, currencyCode),
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: currencyCode == 'USD'
                          ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                          : theme.colorScheme.surface,
                      border: Border.all(
                        color: currencyCode == 'USD'
                            ? theme.colorScheme.primary.withOpacity(0.3)
                            : theme.colorScheme.outline.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        // Currency symbol
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: currencyCode == 'USD'
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              currency.symbol,
                              style: TextStyle(
                                color: currencyCode == 'USD'
                                    ? theme.colorScheme.onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Currency info
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currencyCode,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                currency.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Rate
                        Expanded(
                          child: Text(
                            currencyCode == 'USD'
                                ? '1.0'
                                : rate.toStringAsFixed(rate >= 1 ? 2 : 4),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: currencyCode == 'USD'
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
