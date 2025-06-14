import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:setpocket/models/converter_models/unit_models.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/services/unit_conversion_service.dart';
import 'package:setpocket/services/converter_services/currency_service.dart';
import 'package:setpocket/services/converter_services/currency_cache_service.dart';

class UnitConverterScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const UnitConverterScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputController = TextEditingController();
  UnitCategory? _category;
  Unit? _fromUnit;
  Unit? _toUnit;
  double _inputValue = 0.0;
  List<ConversionResult> _allConversions = [];

  // Currency specific
  Map<String, double> _exchangeRates = {};
  bool _isLoadingRates = false;
  DateTime? _lastUpdated;
  bool _isUsingLiveRates = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategory();
    _loadExchangeRates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _loadCategory() {
    if (widget.categoryId == 'currency') {
      // Handle currency separately
      _category = UnitCategory(
        id: 'currency',
        name: 'Currency',
        description: 'Currency exchange rates',
        units: CurrencyService.getSupportedCurrencies()
            .map((currency) => Unit(
                  id: currency.code,
                  name: currency.name,
                  symbol: currency.code,
                  factor: 1.0,
                ))
            .toList(),
      );
    } else {
      _category = UnitConversionService.getCategory(widget.categoryId);
    }

    if (_category != null && _category!.units.isNotEmpty) {
      _fromUnit = _category!.units.first;
      _toUnit = _category!.units.length > 1
          ? _category!.units[1]
          : _category!.units.first;
    }
  }

  void _loadExchangeRates() async {
    if (widget.categoryId == 'currency') {
      setState(() {
        _isLoadingRates = true;
      });

      try {
        // Use CurrencyCacheService instead of direct CurrencyService
        _exchangeRates = await CurrencyCacheService.getRates();

        // Get cache info for display
        final cacheInfo = await CurrencyCacheService.getCacheInfo();

        if (mounted) {
          setState(() {
            _lastUpdated = cacheInfo?.lastUpdated;
            _isUsingLiveRates = cacheInfo != null && cacheInfo.isValid;
          });
        }
      } catch (e) {
        logError('Failed to load exchange rates: $e');
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
  }

  Future<void> _refreshCurrencyRates() async {
    if (widget.categoryId != 'currency') return;

    setState(() {
      _isLoadingRates = true;
    });

    try {
      // Force refresh using cache service
      _exchangeRates = await CurrencyCacheService.forceRefresh();

      // Get updated cache info
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
    } catch (e) {
      logError('Failed to refresh currency rates: $e');
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

  void _convertValue() {
    if (_category == null || _fromUnit == null || _toUnit == null) return;

    final inputText = _inputController.text.trim();
    if (inputText.isEmpty) {
      setState(() {
        _inputValue = 0.0;
        _allConversions.clear();
      });
      return;
    }

    final value = double.tryParse(inputText);
    if (value == null) return;

    setState(() {
      _inputValue = value;

      if (widget.categoryId == 'currency') {
        _allConversions = _convertCurrency(value, _fromUnit!);
      } else {
        _allConversions = UnitConversionService.convertToAllUnits(
          value,
          _fromUnit!,
          widget.categoryId,
        );
      }
    });
  }

  List<ConversionResult> _convertCurrency(double value, Unit fromUnit) {
    if (_exchangeRates.isEmpty) return [];

    final fromRate = _exchangeRates[fromUnit.id] ?? 1.0;

    return _category!.units.where((unit) => unit.id != fromUnit.id).map((unit) {
      final toRate = _exchangeRates[unit.id] ?? 1.0;
      final convertedValue = (value / fromRate) * toRate;

      return ConversionResult(
        value: convertedValue,
        fromUnit: fromUnit,
        toUnit: unit,
        timestamp: DateTime.now(),
      );
    }).toList();
  }

  double _getSingleConversion() {
    if (_category == null ||
        _fromUnit == null ||
        _toUnit == null ||
        _inputValue == 0) {
      return 0.0;
    }

    if (widget.categoryId == 'currency') {
      final fromRate = _exchangeRates[_fromUnit!.id] ?? 1.0;
      final toRate = _exchangeRates[_toUnit!.id] ?? 1.0;
      return (_inputValue / fromRate) * toRate;
    } else {
      return UnitConversionService.convert(
          _inputValue, _fromUnit!, _toUnit!, widget.categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Converter', icon: Icon(Icons.swap_horiz)),
            Tab(text: 'All Units', icon: Icon(Icons.list)),
          ],
        ),
      ),
      body: _category == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConverterTab(),
                _buildAllUnitsTab(),
              ],
            ),
    );
  }

  Widget _buildConverterTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Currency status widget
          if (widget.categoryId == 'currency') _buildCurrencyStatusWidget(),

          // Input field
          TextField(
            controller: _inputController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Enter value',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _inputController.clear();
                  _convertValue();
                },
              ),
            ),
            onChanged: (_) => _convertValue(),
          ),

          const SizedBox(height: 20),

          // From Unit Selector
          _buildUnitSelector(
            label: 'From',
            selectedUnit: _fromUnit,
            onChanged: (unit) {
              setState(() {
                _fromUnit = unit;
              });
              _convertValue();
            },
          ),

          const SizedBox(height: 16),

          // Swap button
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                final temp = _fromUnit;
                _fromUnit = _toUnit;
                _toUnit = temp;
              });
              _convertValue();
            },
            icon: const Icon(Icons.swap_vert),
            label: const Text('Swap'),
          ),

          const SizedBox(height: 16),

          // To Unit Selector
          _buildUnitSelector(
            label: 'To',
            selectedUnit: _toUnit,
            onChanged: (unit) {
              setState(() {
                _toUnit = unit;
              });
              _convertValue();
            },
          ),

          const SizedBox(height: 20),

          // Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).primaryColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Result',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_getSingleConversion().toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')} ${_toUnit?.symbol ?? ''}',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: _getSingleConversion().toString(),
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllUnitsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Input field
          TextField(
            controller: _inputController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Enter value',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _convertValue(),
          ),

          const SizedBox(height: 16),

          // From Unit Selector
          _buildUnitSelector(
            label: 'From',
            selectedUnit: _fromUnit,
            onChanged: (unit) {
              setState(() {
                _fromUnit = unit;
              });
              _convertValue();
            },
          ),

          const SizedBox(height: 16),

          // Results list
          Expanded(
            child: _allConversions.isEmpty
                ? const Center(
                    child: Text('Enter a value to see conversions'),
                  )
                : ListView.builder(
                    itemCount: _allConversions.length,
                    itemBuilder: (context, index) {
                      final result = _allConversions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            '${result.formattedValue} ${result.toUnit.symbol}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(result.toUnit.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                text: result.value.toString(),
                              ));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Copied to clipboard')),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitSelector({
    required String label,
    required Unit? selectedUnit,
    required ValueChanged<Unit?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Unit>(
              value: selectedUnit,
              isExpanded: true,
              items: _category?.units.map((unit) {
                return DropdownMenuItem<Unit>(
                  value: unit,
                  child: Text('${unit.name} (${unit.symbol})'),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyStatusWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.currency_exchange,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Currency Rate Status',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (_isLoadingRates)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                InkWell(
                  onTap: _refreshCurrencyRates,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.refresh,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Live/Static indicator
              if (_isUsingLiveRates) ...[
                const Icon(
                  Icons.wifi,
                  size: 16,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'Live Rates',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ] else ...[
                const Icon(
                  Icons.wifi_off,
                  size: 16,
                  color: Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  'Static Rates',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              const SizedBox(width: 16),
              // Last updated time
              if (_lastUpdated != null) ...[
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatLastUpdated(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ] else ...[
                Text(
                  'No cache data',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated() {
    if (_lastUpdated == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
