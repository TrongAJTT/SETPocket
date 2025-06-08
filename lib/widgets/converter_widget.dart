import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/converter_models.dart';
import 'package:my_multi_tools/services/currency_service.dart';
import 'package:my_multi_tools/services/currency_cache_service.dart';

enum ConverterViewMode { table, list }

class ConverterWidget extends StatefulWidget {
  final BaseConverter converter;
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final bool isEmbedded;

  const ConverterWidget({
    super.key,
    required this.converter,
    this.title,
    this.icon,
    this.iconColor,
    this.isEmbedded = false,
  });

  @override
  State<ConverterWidget> createState() => _ConverterWidgetState();
}

class _ConverterWidgetState extends State<ConverterWidget> {
  final TextEditingController _controller = TextEditingController();
  ConversionUnit? _selectedFromUnit;
  ConverterViewMode _viewMode = ConverterViewMode.table;
  Map<ConversionUnit, bool> _unitVisibility = {};
  double _inputValue = 0.0;
  Map<ConversionUnit, double> _conversions = {};
  bool _isLoadingRates = false;
  DateTime? _lastUpdated;
  bool _isUsingLiveRates = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
    _initializeCurrencyRates();
  }

  void _initializeDefaults() {
    final units = widget.converter.units;
    if (units.isNotEmpty) {
      _selectedFromUnit = units.first;
    }

    // Initialize all units as visible by default
    for (var unit in units) {
      _unitVisibility[unit] = true;
    }

    _controller.text = '1';
    _inputValue = 1.0;
    _updateConversions();
  }

  Future<void> _initializeCurrencyRates() async {
    // Only initialize live rates for currency converter
    if (widget.converter is CurrencyConverter) {
      setState(() {
        _isLoadingRates = true;
      });
      try {
        // Use CurrencyCacheService.getRates() which handles all logic internally
        // This respects the user's fetch mode settings
        await CurrencyCacheService.getRates();

        // Get cache info for display
        final cacheInfo = await CurrencyCacheService.getCacheInfo();

        if (mounted) {
          setState(() {
            _lastUpdated = cacheInfo?.lastUpdated;
            _isUsingLiveRates = cacheInfo != null && cacheInfo.isValid;
          });
        }

        _updateConversions();
      } catch (e) {
        print('Failed to initialize currency rates: $e');
        // Set fallback state
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
    if (mounted) {
      setState(() {
        _isLoadingRates = true;
      });
    }

    try {
      // Force refresh using cache service
      await CurrencyCacheService.forceRefresh();

      // Get updated cache info
      final cacheInfo = await CurrencyCacheService.getCacheInfo();

      if (mounted) {
        setState(() {
          _lastUpdated = cacheInfo?.lastUpdated;
          _isUsingLiveRates = cacheInfo != null && cacheInfo.isValid;
        });
      }

      _updateConversions();

      if (mounted) {
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

  void _updateConversions() {
    if (_selectedFromUnit == null) return;

    _conversions.clear();
    for (var unit in widget.converter.units) {
      if (_unitVisibility[unit] == true) {
        _conversions[unit] = widget.converter
            .convert(_inputValue, _selectedFromUnit!.id, unit.id);
      }
    }
    setState(() {});
  }

  void _onInputChanged(String value) {
    if (value.isEmpty) {
      _inputValue = 0.0;
    } else {
      _inputValue = double.tryParse(value) ?? 0.0;
    }
    _updateConversions();
  }

  void _showUnitCustomization() {
    showDialog(
      context: context,
      builder: (context) => _UnitCustomizationDialog(
        units: widget.converter.units,
        visibility: Map.from(_unitVisibility),
        onChanged: (newVisibility) {
          setState(() {
            _unitVisibility = newVisibility;
            _updateConversions();
          });
        },
      ),
    );
  }

  Widget _buildLiveRateIndicator() {
    return Row(
      children: [
        if (_isUsingLiveRates) ...[
          Icon(
            Icons.wifi,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            'Live',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ] else ...[
          Icon(
            Icons.wifi_off,
            size: 16,
            color: Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            'Static',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
        if (_lastUpdated != null) ...[
          const SizedBox(width: 8),
          Text(
            '• ${_formatLastUpdated()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        const SizedBox(width: 8),
        InkWell(
          onTap: _isLoadingRates ? null : _refreshCurrencyRates,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Icon(
              Icons.refresh,
              size: 16,
              color: _isLoadingRates
                  ? Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.5)
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatLastUpdated() {
    if (_lastUpdated == null) return '';

    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildCurrencyStatusRow() {
    return Row(
      children: [
        // Status indicator
        if (_isUsingLiveRates) ...[
          const Icon(
            Icons.wifi,
            size: 16,
            color: Colors.green,
          ),
          const SizedBox(width: 6),
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
          const SizedBox(width: 6),
          Text(
            'Static Rates',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],

        // Last updated info
        if (_lastUpdated != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Updated ${_formatLastUpdated()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else ...[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No update information',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],

        // Refresh button
        InkWell(
          onTap: _isLoadingRates ? null : _refreshCurrencyRates,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.refresh,
              size: 18,
              color: _isLoadingRates
                  ? Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.5)
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final body = Column(
      children: [
        // Input section
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: widget.iconColor, size: 24),
                      const SizedBox(width: 12),
                    ],
                    if (widget.title != null)
                      Text(
                        widget.title!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    const Spacer(),
                    if (widget.converter is CurrencyConverter) ...[
                      if (_isLoadingRates)
                        Row(
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Loading rates...',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        )
                      else
                        _buildLiveRateIndicator(),
                    ],
                  ],
                ),
                // Currency status indicator section
                if (widget.converter is CurrencyConverter) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withOpacity(0.2),
                      ),
                    ),
                    child: _isLoadingRates
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Loading currency rates...',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          )
                        : _buildCurrencyStatusRow(),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        decoration: InputDecoration(
                          labelText: loc.enterValue,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controller.clear();
                              _onInputChanged('');
                            },
                          ),
                        ),
                        onChanged: _onInputChanged,
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 140,
                      child: DropdownButtonFormField<ConversionUnit>(
                        value: _selectedFromUnit,
                        decoration: InputDecoration(
                          labelText: loc.fromUnit,
                          border: const OutlineInputBorder(),
                        ),
                        items: widget.converter.units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit.symbol),
                          );
                        }).toList(),
                        onChanged: (unit) {
                          setState(() {
                            _selectedFromUnit = unit;
                            _updateConversions();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (widget.converter is CurrencyConverter) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Last updated: ${CurrencyService.getLastUpdated()}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed:
                            _isLoadingRates ? null : _refreshCurrencyRates,
                        tooltip: 'Refresh rates',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // View mode and customization controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              SegmentedButton<ConverterViewMode>(
                segments: [
                  ButtonSegment(
                    value: ConverterViewMode.table,
                    label: Text(loc.tableView),
                    icon: const Icon(Icons.table_chart),
                  ),
                  ButtonSegment(
                    value: ConverterViewMode.list,
                    label: Text(loc.listView),
                    icon: const Icon(Icons.list),
                  ),
                ],
                selected: {_viewMode},
                onSelectionChanged: (Set<ConverterViewMode> selection) {
                  setState(() {
                    _viewMode = selection.first;
                  });
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.tune),
                tooltip: loc.customizeUnits,
                onPressed: _showUnitCustomization,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Results section
        Expanded(
          child: _viewMode == ConverterViewMode.table
              ? _buildTableView()
              : _buildListView(),
        ),
      ],
    );
    if (widget.isEmbedded) {
      return body;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? 'Converter'),
        ),
        body: body,
      );
    }
  }

  Widget _buildTableView() {
    final visibleUnits = widget.converter.units
        .where((unit) => _unitVisibility[unit] == true)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Table header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      AppLocalizations.of(context)!.unit,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      AppLocalizations.of(context)!.value,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),

            // Table rows
            ...visibleUnits.asMap().entries.map((entry) {
              final index = entry.key;
              final unit = entry.value;
              final value = _conversions[unit] ?? 0.0;
              final isSelected = unit == _selectedFromUnit;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.3)
                      : null,
                  border: index < visibleUnits.length - 1
                      ? Border(
                          bottom:
                              BorderSide(color: Theme.of(context).dividerColor))
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unit.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : null,
                                ),
                          ),
                          Text(
                            unit.symbol,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: SelectableText(
                        _formatValue(value),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : null,
                              fontFamily: 'monospace',
                            ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final visibleUnits = widget.converter.units
        .where((unit) => _unitVisibility[unit] == true)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visibleUnits.length,
      itemBuilder: (context, index) {
        final unit = visibleUnits[index];
        final value = _conversions[unit] ?? 0.0;
        final isSelected = unit == _selectedFromUnit;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: isSelected ? 4 : 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Text(
                  unit.symbol,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              title: Text(
                unit.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
              ),
              subtitle: Text(unit.symbol),
              trailing: SelectableText(
                _formatValue(value),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatValue(double value) {
    if (value == 0) return '0';
    if (value.abs() >= 1000000) {
      return value.toStringAsExponential(6);
    } else if (value.abs() < 0.00001) {
      return value.toStringAsExponential(6);
    } else {
      return value
          .toStringAsFixed(6)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _UnitCustomizationDialog extends StatefulWidget {
  final List<ConversionUnit> units;
  final Map<ConversionUnit, bool> visibility;
  final Function(Map<ConversionUnit, bool>) onChanged;

  const _UnitCustomizationDialog({
    required this.units,
    required this.visibility,
    required this.onChanged,
  });

  @override
  State<_UnitCustomizationDialog> createState() =>
      _UnitCustomizationDialogState();
}

class _UnitCustomizationDialogState extends State<_UnitCustomizationDialog> {
  late Map<ConversionUnit, bool> _tempVisibility;

  @override
  void initState() {
    super.initState();
    _tempVisibility = Map.from(widget.visibility);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(loc.customizeUnits),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.units.length,
          itemBuilder: (context, index) {
            final unit = widget.units[index];
            final isVisible = _tempVisibility[unit] ?? true;

            return CheckboxListTile(
              title: Text(unit.name),
              subtitle: Text(unit.symbol),
              value: isVisible,
              onChanged: (value) {
                setState(() {
                  _tempVisibility[unit] = value ?? true;
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc.cancel),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              for (var unit in widget.units) {
                _tempVisibility[unit] = true;
              }
            });
          },
          child: Text(loc.showAll),
        ),
        FilledButton(
          onPressed: () {
            widget.onChanged(_tempVisibility);
            Navigator.of(context).pop();
          },
          child: Text(loc.apply),
        ),
      ],
    );
  }
}
