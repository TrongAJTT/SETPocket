import 'package:flutter/material.dart';
import '../../controllers/converter_controller.dart';
import '../../l10n/app_localizations.dart';
import 'generic_unit_custom_dialog.dart';
import 'converter_card_widget.dart';
import 'converter_table_widget.dart';
import 'converter_status_widget.dart';

class GenericConverterView extends StatelessWidget {
  final ConverterController controller;
  final bool isEmbedded;
  final String? title;
  final IconData? titleIcon;
  final VoidCallback? onShowInfo;

  const GenericConverterView({
    super.key,
    required this.controller,
    this.isEmbedded = false,
    this.title,
    this.titleIcon,
    this.onShowInfo,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmbedded) {
      return _buildConverterContent(context, controller);
    }

    final l10n = AppLocalizations.of(context)!;
    final displayTitle = title ?? controller.converterService.displayName;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          displayTitle,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (onShowInfo != null)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: onShowInfo,
              tooltip: '$displayTitle Info',
            ),
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: controller.resetLayout,
            tooltip: l10n.resetLayout,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showGlobalUnitsCustomization(context, controller),
            tooltip: l10n.customizeCurrencies, // Will be generalized
          ),
        ],
      ),
      body: _buildConverterContent(context, controller),
    );
  }

  Widget _buildConverterContent(
      BuildContext context, ConverterController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ConverterStatusWidget(
            controller: controller,
            onRefresh:
                controller.requiresRealTimeData ? controller.refreshData : null,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: controller.viewMode == ConverterViewMode.cards
                ? _buildCardsView(context, controller)
                : _buildTableView(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsView(BuildContext context, ConverterController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Add card button and view mode toggle
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: controller.addCard,
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
                onPressed: () =>
                    controller.setViewMode(ConverterViewMode.table),
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
                  '${l10n.cards}: ${controller.state.cards.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        // Cards
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Determine number of columns based on screen width
              final screenWidth = constraints.maxWidth;
              int crossAxisCount = 1;

              if (screenWidth > 1200) {
                crossAxisCount = 3; // Large desktop - 3 columns
              } else if (screenWidth > 800) {
                crossAxisCount = 2; // Tablet/medium desktop - 2 columns
              } else {
                crossAxisCount = 1; // Mobile - 1 column
              }

              if (crossAxisCount == 1) {
                // Single column layout for mobile
                return ReorderableListView.builder(
                  itemCount: controller.state.cards.length,
                  onReorder: controller.reorderCards,
                  itemBuilder: (context, index) => ConverterCardWidget(
                    key: ValueKey('card_$index'),
                    cardIndex: index,
                    controller: controller,
                  ),
                );
              } else {
                // Multi-column layout for larger screens
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(
                        controller.state.cards.length,
                        (index) => SizedBox(
                          width: (constraints.maxWidth -
                                  16 -
                                  (16 * (crossAxisCount - 1))) /
                              crossAxisCount,
                          child: ConverterCardWidget(
                            key: ValueKey('card_$index'),
                            cardIndex: index,
                            controller: controller,
                          ),
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

  Widget _buildTableView(BuildContext context, ConverterController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Add row button and view mode toggle
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: controller.addCard,
                icon: const Icon(Icons.add),
                label: Text(l10n.addRow),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    controller.setViewMode(ConverterViewMode.cards),
                icon: const Icon(Icons.view_agenda),
                label: Text(l10n.cardView),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${l10n.rows}: ${controller.state.cards.length}',
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
          child: ConverterTableWidget(
            controller: controller,
          ),
        ),
      ],
    );
  }

  void _showGlobalUnitsCustomization(
      BuildContext context, ConverterController controller) {
    final availableUnits = controller.units
        .map((unit) => GenericUnitItem(
              id: unit.id,
              name: unit.name,
              symbol: unit.symbol,
            ))
        .toList();

    showDialog(
      context: context,
      builder: (context) => EnhancedGenericUnitCustomizationDialog(
        title: 'Customize ${controller.converterService.displayName} Units',
        availableUnits: availableUnits,
        visibleUnits: controller.state.globalVisibleUnits,
        onChanged: controller.updateGlobalVisibleUnits,
        maxSelection: 10,
        minSelection: 2,
        presetType: controller.converterService.converterType,
      ),
    );
  }
}
