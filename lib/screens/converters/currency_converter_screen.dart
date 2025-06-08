import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/converter_models.dart';
import '../../services/currency_cache_service.dart';
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
    _addRow(); // Start with one row
    _initializeCurrencyRates();
  }

  @override
  void dispose() {
    // Dispose all row controllers
    for (var rowControllers in _rowControllers) {
      for (var controller in rowControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addRow() {
    final newRowControllers = <String, TextEditingController>{};
    final newRowValues = <String, double>{};

    for (var currency in _visibleCurrencies) {
      newRowControllers[currency] =
          TextEditingController(text: currency == 'USD' ? '1' : '0');
      newRowValues[currency] = currency == 'USD' ? 1.0 : 0.0;
    }
    setState(() {
      _rowControllers.add(newRowControllers);
      _rowValues.add(newRowValues);
      _rowBaseCurrencies.add('USD'); // Default base currency
    });

    // Update conversions for the new row
    if (_rowControllers.isNotEmpty) {
      _updateRowConversions(_rowControllers.length - 1, 'USD', 1.0);
    }
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
      await CurrencyCacheService.getRates();
      final cacheInfo = await CurrencyCacheService.getCacheInfo();

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

  Future<void> _refreshCurrencyRates() async {
    setState(() {
      _isLoadingRates = true;
    });

    try {
      await CurrencyCacheService.forceRefresh();
      final cacheInfo = await CurrencyCacheService.getCacheInfo();

      if (mounted) {
        setState(() {
          _lastUpdated = cacheInfo?.lastUpdated;
          _isUsingLiveRates = cacheInfo != null && cacheInfo.isValid;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isUsingLiveRates
                  ? 'Live rates updated successfully'
                  : 'Using static rates (live data unavailable)',
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update rates'),
            duration: Duration(seconds: 2),
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

  String _formatLastUpdated() {
    if (_lastUpdated == null) return '';

    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
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
            icon: Icon(_viewMode == CurrencyViewMode.cards
                ? Icons.table_chart
                : Icons.view_agenda),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == CurrencyViewMode.cards
                    ? CurrencyViewMode.table
                    : CurrencyViewMode.cards;
              });
            },
            tooltip: _viewMode == CurrencyViewMode.cards
                ? 'Table View'
                : 'Card View',
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showCurrencyCustomization,
            tooltip: 'Customize currencies',
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
            const Expanded(
              child: Text(
                'Loading rates...',
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
              _isUsingLiveRates ? 'Live' : 'Static',
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
                  '• ${_formatLastUpdated()}',
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else
              const Spacer(),
          ],
          IconButton(
            onPressed: _isLoadingRates ? null : _refreshCurrencyRates,
            icon: Icon(
              Icons.refresh,
              color: _isLoadingRates
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            tooltip: 'Refresh rates',
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsView() {
    return Column(
      children: [
        // Add card button
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Card',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cards: ${_rowControllers.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ), // Cards with responsive layout
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
                        'Converter ${index + 1}',
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
                        tooltip: 'Remove card',
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
                          decoration: const InputDecoration(
                            labelText: 'From',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 13), // Restored font
                          items: currencies.map((currency) {
                            final unit = _converter.units
                                .firstWhere((u) => u.id == currency);
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(
                                '${unit.symbol} - ${unit.name}',
                                overflow: TextOverflow.ellipsis,
                                style:
                                    const TextStyle(fontSize: 13), // Restored
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
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) =>
                            _onRowValueChanged(index, baseCurrency, value),
                      ),
                      const SizedBox(height: 8), // Reduced spacing
                      // Currency dropdown
                      DropdownButtonFormField<String>(
                        value: baseCurrency,
                        decoration: const InputDecoration(
                          labelText: 'From Currency',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: currencies.map((currency) {
                          final unit = _converter.units
                              .firstWhere((u) => u.id == currency);
                          return DropdownMenuItem<String>(
                            value: currency,
                            child: Text(
                              '${unit.symbol} - ${unit.name}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
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
                  'Converted to:',
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
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(
                                8), // Slightly larger radius
                          ),
                          child: Row(
                            children: [
                              // Currency symbol
                              SizedBox(
                                width:
                                    40, // Increased width for better alignment
                                child: Text(
                                  unit.symbol,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Improved font size
                                  ),
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
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          // Currency symbol
                          SizedBox(
                            width: 40,
                            child: Text(
                              unit.symbol,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
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
    final currencies = _visibleCurrencies.toList();

    return Column(
      children: [
        // Add row button
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add),
                label: const Text('Add Row'),
              ),
              const SizedBox(width: 16),
              Text(
                'Rows: ${_rowControllers.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                    const DataColumn(
                      label: SizedBox(
                        width: 40,
                        child: Text(
                          'Row',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    ...currencies.map((currency) {
                      final unit =
                          _converter.units.firstWhere((u) => u.id == currency);
                      return DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                unit.symbol,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                unit.name,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const DataColumn(
                      label: SizedBox(
                        width: 60,
                        child: Text(
                          'Actions',
                          style: TextStyle(fontWeight: FontWeight.bold),
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
                                    tooltip: 'Remove row',
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
                          'Customize Currencies',
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
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search currencies...',
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
                                  'No currencies found',
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

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surface,
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline
                                          .withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
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
                                  onTap: canUnselect
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
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme
                                                    .colorScheme.surfaceVariant,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              unit.symbol,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? theme
                                                        .colorScheme.onPrimary
                                                    : theme.colorScheme
                                                        .onSurfaceVariant,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
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
                                              Text(
                                                currency,
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? theme.colorScheme
                                                          .onPrimaryContainer
                                                      : theme.colorScheme
                                                          .onSurface,
                                                ),
                                              ),
                                              Text(
                                                unit.name,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: isSelected
                                                      ? theme.colorScheme
                                                          .onPrimaryContainer
                                                          .withOpacity(0.8)
                                                      : theme.colorScheme
                                                          .onSurfaceVariant,
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
                      // Selected count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_tempVisible.length} currencies selected',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
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
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                widget.onChanged(_tempVisible);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Apply Changes'),
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
