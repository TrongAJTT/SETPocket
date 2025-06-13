import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../controllers/converter_controller.dart';
import '../../models/converter_models/converter_base.dart';
import '../../l10n/app_localizations.dart';
import 'unit_customization_dialog.dart' as unit_dialog;
import 'generic_unit_custom_dialog.dart';

class ConverterTableWidget extends StatelessWidget {
  final ConverterController controller;

  const ConverterTableWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cardGroups = _groupCardsByUnits();

    return SingleChildScrollView(
      child: Column(
        children: cardGroups.entries.map((entry) {
          final unitKey = entry.key;
          final cardIndices = entry.value;
          final units = unitKey.split(',');

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: _buildSingleTable(context, l10n, units, cardIndices),
          );
        }).toList(),
      ),
    );
  }

  // Group cards by their unit sets for table view
  Map<String, List<int>> _groupCardsByUnits() {
    final groups = <String, List<int>>{};

    for (int i = 0; i < controller.state.cards.length; i++) {
      final card = controller.state.cards[i];
      final cardUnits = card.visibleUnits.toList()..sort();
      final keyString = cardUnits.join(',');

      if (!groups.containsKey(keyString)) {
        groups[keyString] = [];
      }
      groups[keyString]!.add(i);
    }

    return groups;
  }

  Widget _buildSingleTable(
    BuildContext context,
    AppLocalizations l10n,
    List<String> units,
    List<int> cardIndices,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table header with unit info
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Text(
                l10n.tableWith(cardIndices.length),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '(${units.join(', ')})',
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
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.5),
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
                      l10n.cardName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ...units
                    .map((unitId) => _buildUnitColumn(context, unitId))
                    .toList(),
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
              rows: cardIndices
                  .map((index) => _buildTableRow(context, l10n, index, units))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  DataColumn _buildUnitColumn(BuildContext context, String unitId) {
    final unit = controller.converterService.getUnit(unitId);
    if (unit == null) {
      return DataColumn(
        label: SizedBox(
          width: 100,
          child: Text(unitId),
        ),
      );
    }

    final status = controller.converterService.getUnitStatus(unitId);
    final hasError =
        status == ConversionStatus.failed || status == ConversionStatus.timeout;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DataColumn(
      label: SizedBox(
        width: 100,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: hasError
              ? BoxDecoration(
                  color: isDarkMode
                      ? Colors.red.shade900.withValues(alpha: 0.3)
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color:
                        isDarkMode ? Colors.red.shade400 : Colors.red.shade300,
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
                        color: status == ConversionStatus.timeout
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
                      ? (isDarkMode ? Colors.red.shade400 : Colors.red.shade600)
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
  }

  DataRow _buildTableRow(
    BuildContext context,
    AppLocalizations l10n,
    int cardIndex,
    List<String> units,
  ) {
    final card = controller.state.cards[cardIndex];
    final cardControllers = controller.cardControllers[cardIndex];

    return DataRow(
      cells: [
        // Card name cell
        DataCell(
          Container(
            width: 100,
            alignment: Alignment.center,
            child: Text(
              card.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Unit value cells
        ...units
            .map((unitId) =>
                _buildUnitCell(context, cardIndex, unitId, cardControllers))
            .toList(),
        // Actions cell
        _buildActionsCell(context, l10n, cardIndex),
      ],
    );
  }

  DataCell _buildUnitCell(
    BuildContext context,
    int cardIndex,
    String unitId,
    Map<String, TextEditingController>? cardControllers,
  ) {
    if (cardControllers == null || !cardControllers.containsKey(unitId)) {
      return const DataCell(
        SizedBox(
          width: 100,
          child: Text('--'),
        ),
      );
    }

    return DataCell(
      SizedBox(
        width: 100,
        child: TextField(
          controller: cardControllers[unitId],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color:
                    Theme.of(context).colorScheme.outline.withValues(alpha: .5),
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            isDense: true,
          ),
          onChanged: (value) =>
              controller.onValueChanged(cardIndex, unitId, value),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  DataCell _buildActionsCell(
      BuildContext context, AppLocalizations l10n, int cardIndex) {
    return DataCell(
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
                onPressed: () => _editCardName(context, cardIndex),
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                tooltip: l10n.edit,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                padding: EdgeInsets.zero,
              ),
              // Edit units button
              IconButton(
                onPressed: () => _editCardUnits(context, cardIndex),
                icon: Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                  size: 16,
                ),
                tooltip: l10n.edit,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
                padding: EdgeInsets.zero,
              ),
              // Move up button
              if (cardIndex > 0)
                IconButton(
                  onPressed: () =>
                      controller.reorderCards(cardIndex, cardIndex - 1),
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 16,
                  ),
                  tooltip: l10n.moveUp,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),
              // Move down button
              if (cardIndex < controller.state.cards.length - 1)
                IconButton(
                  onPressed: () =>
                      controller.reorderCards(cardIndex, cardIndex + 2),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 16,
                  ),
                  tooltip: l10n.moveDown,
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  padding: EdgeInsets.zero,
                ),
              // Delete button
              if (controller.state.cards.length > 1)
                IconButton(
                  onPressed: () => controller.removeCard(cardIndex),
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
    );
  }

  void _editCardName(BuildContext context, int cardIndex) {
    final l10n = AppLocalizations.of(context)!;
    final card = controller.state.cards[cardIndex];
    final currentName = card.name;
    final textController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Card Name'), // Will be localized
        content: TextField(
          controller: textController,
          maxLength: 20,
          decoration: InputDecoration(
            labelText: l10n.cardName,
            hintText: l10n.cardNameHint,
            border: const OutlineInputBorder(),
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
              final newName = textController.text.trim();
              if (newName.isNotEmpty && newName.length <= 20) {
                controller.updateCardName(cardIndex, newName);
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _editCardUnits(BuildContext context, int cardIndex) {
    final card = controller.state.cards[cardIndex];

    // Use enhanced generic dialog for all converter types with proper preset handling
    final availableUnits = controller.units
        .map((unit) => GenericUnitItem(
              id: unit.id,
              name: unit.name,
              symbol: unit.symbol,
            ))
        .toList();

    // Ensure visibleUnits only contains valid units that exist in availableUnits
    final availableUnitIds = availableUnits.map((u) => u.id).toSet();
    final validVisibleUnits = card.visibleUnits
        .where((unitId) => availableUnitIds.contains(unitId))
        .toSet();

    showDialog(
      context: context,
      builder: (context) => EnhancedGenericUnitCustomizationDialog(
        title: AppLocalizations.of(context)!.customizeUnits,
        availableUnits: availableUnits,
        visibleUnits: validVisibleUnits,
        onChanged: (newUnits) {
          controller.updateCardUnits(cardIndex, newUnits);
        },
        maxSelection: 10,
        minSelection: 2,
        presetType: controller.converterService.converterType,
        showPresetOptions: true, // Enable presets for table level too
      ),
    );
  }
}
