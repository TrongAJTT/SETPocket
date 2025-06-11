import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/converter_models.dart';
import '../../services/converter_services/mass_state_service.dart';
import '../../models/mass_state_model.dart';
import '../../widgets/converter_tools/unit_customization_dialog.dart';
import '../../l10n/app_localizations.dart';

enum MassViewMode { cards, table }

class MassConverterScreen extends StatefulWidget {
  final bool isEmbedded;

  const MassConverterScreen({super.key, this.isEmbedded = false});

  @override
  State<MassConverterScreen> createState() => _MassConverterScreenState();
}

class _MassConverterScreenState extends State<MassConverterScreen> {
  MassViewMode _viewMode = MassViewMode.cards;
  final MassConverter _converter = MassConverter();

  // Unit visibility
  final Set<String> _visibleUnits = {'kilograms', 'pounds', 'ounces'};

  // Unified row management for both views
  final List<Map<String, TextEditingController>> _rowControllers = [];
  final List<Map<String, double>> _rowValues = [];
  final List<String> _rowBaseUnits = []; // Which unit is the base for each row

  @override
  void initState() {
    super.initState();
    _loadState(); // Load saved state first
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
      final state = await MassStateService.loadState();

      // Clear existing data
      for (var rowControllers in _rowControllers) {
        for (var controller in rowControllers.values) {
          controller.dispose();
        }
      }
      _rowControllers.clear();
      _rowValues.clear();
      _rowBaseUnits.clear();

      // Update visible units
      setState(() {
        _visibleUnits.clear();
        _visibleUnits.addAll(state.visibleUnits);
      });

      // Restore cards
      for (final cardState in state.cards) {
        final newRowControllers = <String, TextEditingController>{};
        final newRowValues = <String, double>{};

        for (var unit in _visibleUnits) {
          final amount = unit == cardState.unitCode ? cardState.amount : 0.0;
          newRowControllers[unit] =
              TextEditingController(text: _formatValue(amount));
          newRowValues[unit] = amount;
        }

        _rowControllers.add(newRowControllers);
        _rowValues.add(newRowValues);
        _rowBaseUnits.add(cardState.unitCode);
      }

      print('MassConverter: Loaded state with ${_rowControllers.length} cards');
    } catch (e) {
      print('MassConverter: Error loading state: $e');
      // Fallback to default
      _addRow();
    }
  }

  // Save current state
  Future<void> _saveState() async {
    try {
      final cards = <MassCardState>[];

      for (int i = 0; i < _rowControllers.length; i++) {
        final baseUnit = _rowBaseUnits[i];
        final amount = _rowValues[i][baseUnit] ?? 1.0;

        cards.add(MassCardState(
          unitCode: baseUnit,
          amount: amount,
        ));
      }

      final state = MassStateModel(
        cards: cards,
        visibleUnits: _visibleUnits.toList(),
        lastUpdated: DateTime.now(),
      );

      await MassStateService.saveState(state);
      print('MassConverter: Saved state with ${cards.length} cards');
    } catch (e) {
      print('MassConverter: Error saving state: $e');
    }
  }

  void _addRow() {
    final newRowControllers = <String, TextEditingController>{};
    final newRowValues = <String, double>{};

    // Use kilograms as default
    const defaultUnit = 'kilograms';

    for (var unit in _visibleUnits) {
      newRowControllers[unit] =
          TextEditingController(text: unit == defaultUnit ? '1' : '0');
      newRowValues[unit] = unit == defaultUnit ? 1.0 : 0.0;
    }

    setState(() {
      _rowControllers.add(newRowControllers);
      _rowValues.add(newRowValues);
      _rowBaseUnits.add(defaultUnit);
    });

    // Update conversions for the new row
    if (_rowControllers.isNotEmpty) {
      _updateRowConversions(_rowControllers.length - 1, defaultUnit, 1.0);
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
        _rowBaseUnits.removeAt(index);
      });

      // Save state after removing row
      _saveState();
    }
  }

  void _updateRowConversions(int rowIndex, String fromUnit, double value) {
    if (rowIndex >= _rowValues.length) return;

    _rowBaseUnits[rowIndex] = fromUnit;

    for (var unitCode in _visibleUnits) {
      if (unitCode != fromUnit) {
        final convertedValue = _converter.convert(value, fromUnit, unitCode);
        _rowValues[rowIndex][unitCode] = convertedValue;
        _rowControllers[rowIndex][unitCode]?.text =
            _formatValue(convertedValue);
      } else {
        _rowValues[rowIndex][unitCode] = value;
      }
    }
    setState(() {});
  }

  String _formatValue(double value) {
    if (value == 0) return '0';
    if (value.abs() >= 1e6 || value.abs() < 1e-3) {
      return value.toStringAsExponential(3);
    }
    return value
        .toStringAsFixed(6)
        .replaceAll(RegExp(r'0*$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  void _onRowValueChanged(int rowIndex, String unitCode, String value) {
    if (rowIndex >= _rowValues.length) return;

    final numValue = double.tryParse(value) ?? 0.0;
    _rowValues[rowIndex][unitCode] = numValue;
    _updateRowConversions(rowIndex, unitCode, numValue);
  }

  void _updateUnitVisibility(Set<String> newVisible) {
    // Store current data for visible units
    final oldData = <int, Map<String, double>>{};
    for (int i = 0; i < _rowValues.length; i++) {
      oldData[i] = Map.from(_rowValues[i]);
    }

    setState(() {
      _visibleUnits.clear();
      _visibleUnits.addAll(newVisible);

      // Recreate controllers and values for new unit set
      for (int i = 0; i < _rowControllers.length; i++) {
        // Dispose old controllers
        for (var controller in _rowControllers[i].values) {
          controller.dispose();
        }

        // Create new controllers
        final newControllers = <String, TextEditingController>{};
        final newValues = <String, double>{};

        for (var unit in _visibleUnits) {
          final oldValue = oldData[i]?[unit] ?? 0.0;
          newControllers[unit] =
              TextEditingController(text: _formatValue(oldValue));
          newValues[unit] = oldValue;
        }

        _rowControllers[i] = newControllers;
        _rowValues[i] = newValues;

        // Ensure base unit is still visible, otherwise change it
        if (!_visibleUnits.contains(_rowBaseUnits[i])) {
          _rowBaseUnits[i] = _visibleUnits.first;
        }
      }
    });

    // Update conversions for all rows
    for (int i = 0; i < _rowControllers.length; i++) {
      final baseUnit = _rowBaseUnits[i];
      final baseValue = _rowValues[i][baseUnit] ?? 1.0;
      _updateRowConversions(i, baseUnit, baseValue);
    }

    // Save state after updating visibility
    _saveState();
  }

  void _showUnitCustomization() {
    final availableUnits = _converter.units
        .map((unit) => UnitItem(
              id: unit.id,
              name: unit.name,
              symbol: unit.symbol,
            ))
        .toList();

    showDialog(
      context: context,
      builder: (context) => UnitCustomizationDialog(
        title: AppLocalizations.of(context)!.customizeMassUnits,
        availableUnits: availableUnits,
        visibleUnits: Set.from(_visibleUnits),
        onChanged: _updateUnitVisibility,
        maxSelection: 10,
        minSelection: 2,
        showPresetOptions: false,
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _MassInfoDialog(),
    );
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
      _rowBaseUnits.clear();
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
        title: Text(l10n.massConverter),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: l10n.massConverterInfo,
          ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: _resetLayout,
            tooltip: l10n.resetLayout,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showUnitCustomization,
            tooltip: l10n.customizeUnits,
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
          _buildViewModeToggle(),
          const SizedBox(height: 16),
          Expanded(
            child: _viewMode == MassViewMode.cards
                ? _buildCardsView()
                : _buildTableView(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;

          if (isNarrow) {
            // Stack layout for narrow screens
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.balance,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.massConverter,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      l10n.unitVisibleStatus(_visibleUnits.length),
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<MassViewMode>(
                        segments: [
                          ButtonSegment<MassViewMode>(
                            value: MassViewMode.cards,
                            icon: const Icon(Icons.view_agenda, size: 16),
                            label: Text(l10n.cardView),
                          ),
                          ButtonSegment<MassViewMode>(
                            value: MassViewMode.table,
                            icon: const Icon(Icons.table_chart, size: 16),
                            label: Text(l10n.tableView),
                          ),
                        ],
                        selected: {_viewMode},
                        onSelectionChanged: (Set<MassViewMode> newSelection) {
                          setState(() {
                            _viewMode = newSelection.first;
                          });
                        },
                        style: SegmentedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            // Original horizontal layout for wider screens
            return Row(
              children: [
                Icon(
                  Icons.balance,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.massConverter,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  l10n.unitVisibleStatus(_visibleUnits.length),
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                SegmentedButton<MassViewMode>(
                  segments: [
                    ButtonSegment<MassViewMode>(
                      value: MassViewMode.cards,
                      icon: const Icon(Icons.view_agenda, size: 16),
                      label: Text(l10n.cardView),
                    ),
                    ButtonSegment<MassViewMode>(
                      value: MassViewMode.table,
                      icon: const Icon(Icons.table_chart, size: 16),
                      label: Text(l10n.tableView),
                    ),
                  ],
                  selected: {_viewMode},
                  onSelectionChanged: (Set<MassViewMode> newSelection) {
                    setState(() {
                      _viewMode = newSelection.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
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
        // Add card button
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
              const SizedBox(width: 16),
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
              final screenWidth = constraints.maxWidth;
              int crossAxisCount = 1;

              if (screenWidth > 1200) {
                crossAxisCount = 3;
              } else if (screenWidth > 800) {
                crossAxisCount = 2;
              } else {
                crossAxisCount = 1;
              }

              if (crossAxisCount == 1) {
                return ListView.builder(
                  itemCount: _rowControllers.length,
                  itemBuilder: (context, index) => _buildCard(index),
                );
              } else {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(
                        _rowControllers.length,
                        (index) => SizedBox(
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
    final baseUnit = _rowBaseUnits[index];
    final rowControllers = _rowControllers[index];
    final units = _visibleUnits.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 300;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 12 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Card header
                Row(
                  children: [
                    CircleAvatar(
                      radius: isDesktop ? 12 : 10,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: isDesktop ? 12 : 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l10n.converter} ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 16 : 14,
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
                          size: 20,
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
                SizedBox(height: isDesktop ? 16 : 12),

                // Base unit input and dropdown
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Use column layout if width is too narrow
                    final useColumnLayout = constraints.maxWidth < 500;

                    if (useColumnLayout) {
                      return Column(
                        children: [
                          TextField(
                            controller: rowControllers[baseUnit],
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.eE+-]')),
                            ],
                            decoration: InputDecoration(
                              labelText: l10n.amount,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            style: const TextStyle(fontSize: 14),
                            onChanged: (value) =>
                                _onRowValueChanged(index, baseUnit, value),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: baseUnit,
                            decoration: InputDecoration(
                              labelText: l10n.from,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            items: units.map((unit) {
                              final unitObj = _converter.units
                                  .firstWhere((u) => u.id == unit);
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(
                                  '${unitObj.symbol} - ${unitObj.name}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newUnit) {
                              if (newUnit != null) {
                                final currentValue =
                                    _rowValues[index][baseUnit] ?? 1.0;
                                _updateRowConversions(
                                    index, newUnit, currentValue);
                              }
                            },
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: rowControllers[baseUnit],
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.eE+-]')),
                              ],
                              decoration: InputDecoration(
                                labelText: l10n.amount,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 14),
                              onChanged: (value) =>
                                  _onRowValueChanged(index, baseUnit, value),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: baseUnit,
                              decoration: InputDecoration(
                                labelText: l10n.from,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              items: units.map((unit) {
                                final unitObj = _converter.units
                                    .firstWhere((u) => u.id == unit);
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(
                                    '${unitObj.symbol} - ${unitObj.name}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newUnit) {
                                if (newUnit != null) {
                                  final currentValue =
                                      _rowValues[index][baseUnit] ?? 1.0;
                                  _updateRowConversions(
                                      index, newUnit, currentValue);
                                }
                              },
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                SizedBox(height: isDesktop ? 12 : 8),

                Text(
                  '${l10n.convertedTo}:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isDesktop ? 15 : 14,
                  ),
                ),
                SizedBox(height: isDesktop ? 12 : 8),

                // Other units - compact layout for all devices
                if (isDesktop) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: units.where((u) => u != baseUnit).map((unit) {
                      final unitObj =
                          _converter.units.firstWhere((u) => u.id == unit);
                      final value = _rowValues[index][unit] ?? 0.0;

                      return SizedBox(
                        width: constraints.maxWidth > 500
                            ? (constraints.maxWidth - 44) / 2
                            : constraints.maxWidth - 20,
                        height: 52,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceVariant
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 40,
                                child: Text(
                                  unitObj.symbol,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  unitObj.name,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _formatValue(value),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  ...units.where((u) => u != baseUnit).map((unit) {
                    final unitObj =
                        _converter.units.firstWhere((u) => u.id == unit);
                    final value = _rowValues[index][unit] ?? 0.0;

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
                          SizedBox(
                            width: 40,
                            child: Text(
                              unitObj.symbol,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              unitObj.name,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatValue(value),
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
    final units = _visibleUnits.toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add),
                label: Text(l10n.addRow),
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
                    ...units.map((unit) {
                      final unitObj =
                          _converter.units.firstWhere((u) => u.id == unit);
                      return DataColumn(
                        label: SizedBox(
                          width: 120,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                unitObj.symbol,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                unitObj.name,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
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
                        ...units.map((unit) {
                          return DataCell(
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: rowControllers[unit],
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9.eE+-]')),
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
                                    _onRowValueChanged(index, unit, value),
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

class _MassInfoDialog extends StatelessWidget {
  const _MassInfoDialog();

  @override
  Widget build(BuildContext context) {
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
                    Icons.balance,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.massConverterInfo,
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
                    _buildSection(
                      context,
                      title: 'About This Feature',
                      content:
                          'Convert between 30+ mass units from metric system, imperial system, troy system, apothecaries system and other special units like carats and atomic mass units.',
                      icon: Icons.balance,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'How to Use',
                      content:
                          'Enter a value in any unit field to see instant conversions to all other units. Add multiple converter cards or use table view for bulk conversions.',
                      icon: Icons.help_outline,
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      context,
                      title: 'Unit Systems',
                      content:
                          'Metric: kg, g, mg, µg, ng, tonnes\nImperial: lb, oz, st, gr, dr, cwt, tons\nTroy: troy oz, troy lb, pennyweight\nApothecaries: oz ap, dr ap, scruple\nOther: carats, slugs, atomic mass units',
                      icon: Icons.list,
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
      ],
    );
  }
}
