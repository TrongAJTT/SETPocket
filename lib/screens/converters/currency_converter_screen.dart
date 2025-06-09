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

      // Update visible currencies
      setState(() {
        _visibleCurrencies.clear();
        _visibleCurrencies.addAll(state.visibleCurrencies);
      });

      // Restore cards
      for (final cardState in state.cards) {
        final newRowControllers = <String, TextEditingController>{};
        final newRowValues = <String, double>{};

        for (var currency in _visibleCurrencies) {
          final amount =
              currency == cardState.currencyCode ? cardState.amount : 0.0;
          newRowControllers[currency] =
              TextEditingController(text: amount.toStringAsFixed(2));
          newRowValues[currency] = amount;
        }

        _rowControllers.add(newRowControllers);
        _rowValues.add(newRowValues);
        _rowBaseCurrencies.add(cardState.currencyCode);
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

        cards.add(CurrencyCardState(
          currencyCode: baseCurrency,
          amount: amount,
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

    for (var currency in _visibleCurrencies) {
      newRowControllers[currency] =
          TextEditingController(text: currency == defaultCurrency ? '1' : '0');
      newRowValues[currency] = currency == defaultCurrency ? 1.0 : 0.0;
    }
    setState(() {
      _rowControllers.add(newRowControllers);
      _rowValues.add(newRowValues);
      _rowBaseCurrencies.add(defaultCurrency); // Use first visible currency
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
      });

      // Save state after removing row
      _saveState();
    }
  }

  void _updateRowConversions(int rowIndex, String fromCurrency, double value) {
    if (rowIndex >= _rowValues.length) return;

    _rowBaseCurrencies[rowIndex] = fromCurrency;

    for (var currencyCode in _visibleCurrencies) {
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
    showDialog(
      context: context,
      builder: (context) => _CurrencyCustomizationDialog(
        availableCurrencies: _converter.units.map((u) => u.id).toSet(),
        visibleCurrencies: Set.from(_visibleCurrencies),
        onChanged: _updateCurrencyVisibility,
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CurrencyInfoDialog(),
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
    });

    // Add one default row
    _addRow();
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
      child: Row(
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
    final currencies = _visibleCurrencies.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 300;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 12 : 8), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card header with row number and delete button - more compact
                Row(
                  children: [
                    CircleAvatar(
                      radius: isDesktop ? 12 : 10, // Restored size
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: isDesktop ? 12 : 10, // Restored font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8), // Restored spacing
                    Expanded(
                      child: Text(
                        '${l10n.converter} ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 16 : 14, // Restored font size
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_rowControllers.length > 1)
                      IconButton(
                        onPressed: () => _removeRow(index),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 20, // Restored icon size
                        ),
                        tooltip: l10n.removeCard,
                        padding: const EdgeInsets.all(4), // Restored padding
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: isDesktop ? 16 : 12), // Restored spacing

                // Base currency input and dropdown - more compact for desktop
                if (isDesktop) ...[
                  // Desktop layout - very compact horizontal arrangement
                  Row(
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
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(
                              fontSize: 14), // Restored font size
                          onChanged: (value) =>
                              _onRowValueChanged(index, baseCurrency, value),
                        ),
                      ),
                      const SizedBox(width: 12), // Restored spacing
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
                          items: currencies.map((currency) {
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
                  ),
                ] else ...[
                  // Mobile layout - vertical arrangement
                  Column(
                    children: [
                      // Amount input
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
                        onChanged: (value) =>
                            _onRowValueChanged(index, baseCurrency, value),
                      ),
                      const SizedBox(height: 8), // Reduced spacing
                      // Currency dropdown
                      DropdownButtonFormField<String>(
                        value: baseCurrency,
                        decoration: InputDecoration(
                          labelText: l10n.fromCurrency,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        items: currencies.map((currency) {
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
                  ),
                ],
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
                    children: currencies
                        .where((c) => c != baseCurrency)
                        .map((currency) {
                      final unit =
                          _converter.units.firstWhere((u) => u.id == currency);
                      final value = _rowValues[index][currency] ?? 0.0;
                      final currencyStatus =
                          CurrencyService.getCurrencyStatus(currency);
                      final hasError =
                          currencyStatus == CurrencyStatus.failed ||
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
                          ? (isDarkMode
                              ? Colors.red.shade400
                              : Colors.red.shade300)
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
                            borderRadius: BorderRadius.circular(
                                8), // Slightly larger radius
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
                                width:
                                    40, // Increased width for better alignment
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
                  ...currencies.where((c) => c != baseCurrency).map((currency) {
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
                        ? (isDarkMode
                            ? Colors.red.shade400
                            : Colors.red.shade300)
                        : null;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
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
      },
    );
  }

  Widget _buildTableView() {
    final l10n = AppLocalizations.of(context)!;
    final currencies = _visibleCurrencies.toList();

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
                  '${l10n.rows}: ${_rowControllers.length}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Table
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.5),
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
                        width: 40,
                        child: Text(
                          l10n.rows,
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
                      final hasError =
                          currencyStatus == CurrencyStatus.failed ||
                              currencyStatus == CurrencyStatus.timeout;
                      final isDarkMode =
                          Theme.of(context).brightness == Brightness.dark;

                      return DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: hasError
                                ? BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.red.shade900.withOpacity(0.3)
                                        : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
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
                                        fontSize: 16,
                                        color: hasError
                                            ? (isDarkMode
                                                ? Colors.red.shade300
                                                : Colors.red.shade700)
                                            : null,
                                      ),
                                    ),
                                    if (hasError) ...[
                                      const SizedBox(width: 4),
                                      Container(
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
                                    ],
                                  ],
                                ),
                                Text(
                                  unit.name,
                                  style: TextStyle(
                                    fontSize: 12,
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
                        width: 60,
                        child: Text(
                          l10n.actions,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                  rows: _rowControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final rowControllers = entry.value;

                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            width: 40,
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ...currencies.map((currency) {
                          return DataCell(
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: rowControllers[currency],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
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
                            width: 60,
                            alignment: Alignment.center,
                            child: _rowControllers.length > 1
                                ? IconButton(
                                    onPressed: () => _removeRow(index),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      size: 20,
                                    ),
                                    tooltip: l10n.removeRow,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
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

class _CurrencyCustomizationDialog extends StatefulWidget {
  final Set<String> availableCurrencies;
  final Set<String> visibleCurrencies;
  final Function(Set<String>) onChanged;

  const _CurrencyCustomizationDialog({
    required this.availableCurrencies,
    required this.visibleCurrencies,
    required this.onChanged,
  });

  @override
  State<_CurrencyCustomizationDialog> createState() =>
      _CurrencyCustomizationDialogState();
}

class _CurrencyCustomizationDialogState
    extends State<_CurrencyCustomizationDialog> with TickerProviderStateMixin {
  late Set<String> _tempVisible;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempVisible = Set.from(widget.visibleCurrencies);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return widget.availableCurrencies.toList();
    }

    final converter = CurrencyConverter();
    return widget.availableCurrencies.where((currency) {
      final unit = converter.units.firstWhere((u) => u.id == currency);
      return unit.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          unit.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          currency.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Show save preset dialog
  void _showSavePresetDialog() async {
    if (_tempVisible.isEmpty || _tempVisible.length > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tempVisible.isEmpty
              ? AppLocalizations.of(context)!.currenciesSelected(0)
              : AppLocalizations.of(context)!.maxCurrenciesSelected),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => _SavePresetDialog(),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await CurrencyPresetService.savePreset(
          name: result,
          currencies: _tempVisible.toList(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.presetSaved),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Show load preset dialog
  void _showLoadPresetDialog() async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _LoadPresetDialog(),
    );

    if (result != null) {
      setState(() {
        _tempVisible.clear();
        _tempVisible.addAll(result);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.presetLoaded),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final converter = CurrencyConverter();
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTableScreen = screenSize.width > 700;
    final isDesktopScreen = screenSize.width > 1400;

    // Fixed screen-relative dialog dimensions
    final dialogWidth = isTableScreen
        ? screenSize.width * 0.6 // 60% of screen width on desktop
        : screenSize.width * 0.9; // 90% of screen width on mobile
    final dialogHeight = screenSize.height * 0.75; // 75% of screen height

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isTableScreen ? 80 : 16,
          vertical: isTableScreen ? 60 : 40,
        ),
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Container(
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
                // Header với gradient đẹp
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16), // Reduced vertical padding
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
                        Icons.tune,
                        color: theme.colorScheme.onPrimary,
                        size: 22, // Smaller icon
                      ),
                      const SizedBox(width: 10), // Reduced spacing
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!
                              .customizeCurrenciesDialog,
                          style: theme.textTheme.titleLarge?.copyWith(
                            // Changed from headlineSmall to titleLarge
                            color: theme.colorScheme.onPrimary,
                            fontWeight:
                                FontWeight.w600, // Slightly lighter weight
                            fontSize: 18, // Explicit smaller font size
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(6), // Smaller radius
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onPrimary,
                            size: 20, // Smaller close icon
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ), // Smaller button constraints
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar đẹp
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              AppLocalizations.of(context)!.searchCurrencies,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor:
                              theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showSavePresetDialog(),
                              icon: const Icon(Icons.save, size: 18),
                              label: Text(
                                  AppLocalizations.of(context)!.savePreset),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showLoadPresetDialog(),
                              icon: const Icon(Icons.folder_open, size: 18),
                              label: Text(
                                  AppLocalizations.of(context)!.loadPreset),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ), // Currency selection với card đẹp - Fixed height area
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = isTableScreen
                            ? isDesktopScreen
                                ? 3
                                : 2
                            : 1;
                        final filteredCurrencies = _filteredCurrencies;

                        if (filteredCurrencies.isEmpty) {
                          return Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppLocalizations.of(context)!
                                      .noCurrenciesFound,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisExtent: 70,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: filteredCurrencies.length,
                          itemBuilder: (context, index) {
                            final currency = filteredCurrencies[index];
                            final unit = converter.units
                                .firstWhere((u) => u.id == currency);
                            final isSelected = _tempVisible.contains(currency);
                            final canUnselect =
                                _tempVisible.length > 1 || !isSelected;
                            final canSelect =
                                !isSelected && _tempVisible.length < 10;
                            final currencyStatus =
                                CurrencyService.getCurrencyStatus(currency);
                            final hasError =
                                currencyStatus == CurrencyStatus.failed ||
                                    currencyStatus == CurrencyStatus.timeout;

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (hasError
                                        ? Colors.red.shade50
                                        : theme.colorScheme.primaryContainer)
                                    : (hasError
                                        ? Colors.red.shade50
                                        : theme.colorScheme.surface),
                                border: Border.all(
                                  color: hasError
                                      ? Colors.red.shade400
                                      : (isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.outline
                                              .withOpacity(0.3)),
                                  width: hasError ? 2 : (isSelected ? 2 : 1),
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: (hasError
                                                  ? Colors.red.shade200
                                                  : theme.colorScheme.primary)
                                              .withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: (isSelected ? canUnselect : canSelect)
                                      ? () {
                                          setState(() {
                                            if (isSelected) {
                                              _tempVisible.remove(currency);
                                            } else {
                                              _tempVisible.add(currency);
                                            }
                                          });
                                        }
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Currency symbol với background đẹp
                                        Stack(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: hasError
                                                    ? Colors.red.shade100
                                                    : (isSelected
                                                        ? theme
                                                            .colorScheme.primary
                                                        : theme.colorScheme
                                                            .surfaceVariant),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  unit.symbol,
                                                  style: TextStyle(
                                                    color: hasError
                                                        ? Colors.red.shade700
                                                        : (isSelected
                                                            ? theme.colorScheme
                                                                .onPrimary
                                                            : theme.colorScheme
                                                                .onSurfaceVariant),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (hasError)
                                              Positioned(
                                                top: -2,
                                                right: -2,
                                                child: Container(
                                                  width: 16,
                                                  height: 16,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade600,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    currencyStatus ==
                                                            CurrencyStatus
                                                                .timeout
                                                        ? Icons.access_time
                                                        : Icons.error,
                                                    color: Colors.white,
                                                    size: 10,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        // Currency info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      currency,
                                                      style: theme
                                                          .textTheme.titleSmall
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: hasError
                                                            ? Colors
                                                                .red.shade700
                                                            : (isSelected
                                                                ? theme
                                                                    .colorScheme
                                                                    .onPrimaryContainer
                                                                : theme
                                                                    .colorScheme
                                                                    .onSurface),
                                                      ),
                                                    ),
                                                  ),
                                                  if (hasError)
                                                    Tooltip(
                                                      message: CurrencyService
                                                          .getLocalizedStatusDescription(
                                                              currency,
                                                              AppLocalizations
                                                                  .of(context)),
                                                      child: Icon(
                                                        Icons.info_outline,
                                                        size: 14,
                                                        color:
                                                            Colors.red.shade600,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              Text(
                                                unit.name,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: hasError
                                                      ? Colors.red.shade600
                                                      : (isSelected
                                                          ? theme.colorScheme
                                                              .onPrimaryContainer
                                                              .withOpacity(0.8)
                                                          : theme.colorScheme
                                                              .onSurfaceVariant),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Checkbox với animation
                                        AnimatedScale(
                                          scale: isSelected ? 1.0 : 0.8,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Icon(
                                            isSelected
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.outline,
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Footer với selected count và buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Selected count with validation
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (_tempVisible.length > 10
                                  ? Colors.red
                                  : theme.colorScheme.primary)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .currenciesSelected(_tempVisible.length),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _tempVisible.length > 10
                                    ? Colors.red
                                    : theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_tempVisible.length > 10) ...[
                              const SizedBox(height: 4),
                              Text(
                                AppLocalizations.of(context)!
                                    .maxCurrenciesSelected,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _tempVisible.isNotEmpty
                                  ? () {
                                      widget.onChanged(_tempVisible);
                                      Navigator.of(context).pop();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                  AppLocalizations.of(context)!.applyChanges),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Save Preset Dialog
class _SavePresetDialog extends StatefulWidget {
  @override
  _SavePresetDialogState createState() => _SavePresetDialogState();
}

class _SavePresetDialogState extends State<_SavePresetDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _savePreset() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.presetNameRequired;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final nameExists = await CurrencyPresetService.presetNameExists(name);
      if (nameExists) {
        setState(() {
          _errorMessage = 'Preset name already exists';
          _isLoading = false;
        });
        return;
      }

      Navigator.of(context).pop(name);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.savePresetDialog),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.presetName,
              hintText: l10n.enterPresetName,
              border: const OutlineInputBorder(),
              errorText: _errorMessage,
            ),
            onSubmitted: (_) => _savePreset(),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _savePreset,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.savePreset),
        ),
      ],
    );
  }
}

// Load Preset Dialog
class _LoadPresetDialog extends StatefulWidget {
  @override
  _LoadPresetDialogState createState() => _LoadPresetDialogState();
}

class _LoadPresetDialogState extends State<_LoadPresetDialog> {
  List<CurrencyPresetModel> _presets = [];
  bool _isLoading = true;
  PresetSortOrder _sortOrder = PresetSortOrder.date;

  @override
  void initState() {
    super.initState();
    _loadPresets();
  }

  Future<void> _loadPresets() async {
    setState(() => _isLoading = true);
    try {
      final presets =
          await CurrencyPresetService.loadPresets(sortOrder: _sortOrder);
      setState(() {
        _presets = presets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePreset(CurrencyPresetModel preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deletePreset),
        content: Text(AppLocalizations.of(context)!.confirmDeletePreset),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CurrencyPresetService.deletePreset(preset.id);
        _loadPresets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.presetDeleted),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_open, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.loadPresetDialog,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            ),

            // Sort options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('${l10n.sortBy}: '),
                  DropdownButton<PresetSortOrder>(
                    value: _sortOrder,
                    items: [
                      DropdownMenuItem(
                        value: PresetSortOrder.date,
                        child: Text(l10n.sortByDate),
                      ),
                      DropdownMenuItem(
                        value: PresetSortOrder.name,
                        child: Text(l10n.sortByName),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _sortOrder = value);
                        _loadPresets();
                      }
                    },
                  ),
                ],
              ),
            ),

            // Presets list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _presets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_off,
                                size: 64,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noPresetsFound,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _presets.length,
                          itemBuilder: (context, index) {
                            final preset = _presets[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(preset.name
                                      .substring(0, 1)
                                      .toUpperCase()),
                                ),
                                title: Text(preset.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n
                                        .currencies(preset.currencies.length)),
                                    Text(
                                      l10n.createdOn(DateFormat('MM/dd/yyyy')
                                          .format(preset.createdAt)),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context)
                                          .pop(preset.currencies),
                                      child: Text(l10n.select),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _deletePreset(preset),
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
