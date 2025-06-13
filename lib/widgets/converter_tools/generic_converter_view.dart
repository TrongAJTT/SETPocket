import 'package:flutter/material.dart';
import '../../controllers/converter_controller.dart';
import '../../models/converter_models/converter_base.dart';
import '../../l10n/app_localizations.dart';
import '../../services/focus_mode_service.dart';
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
  final VoidCallback? onShowStatus;
  final VoidCallback? onRefresh;

  const GenericConverterView({
    super.key,
    required this.controller,
    this.isEmbedded = false,
    this.title,
    this.titleIcon,
    this.onShowInfo,
    this.onShowStatus,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmbedded) {
      return _buildConverterContent(context, controller);
    }

    final l10n = AppLocalizations.of(context)!;
    final displayTitle = title ?? controller.converterService.displayName;
    final isMobile = MediaQuery.of(context).size.width < 600;

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

          // Mobile: Show more actions menu
          if (isMobile) ...[
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              tooltip: l10n.moreActions,
              onSelected: (value) {
                switch (value) {
                  case 'focus_mode':
                    _toggleFocusMode(context, controller);
                    break;
                  case 'reset_layout':
                    controller.resetLayout();
                    break;
                  case 'customize_units':
                    _showGlobalUnitsCustomization(context, controller);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'focus_mode',
                  child: Row(
                    children: [
                      Icon(
                        controller.isFocusMode
                            ? Icons.center_focus_weak
                            : Icons.center_focus_strong,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        controller.isFocusMode
                            ? l10n.disableFocusMode
                            : l10n.enableFocusMode,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'reset_layout',
                  child: Row(
                    children: [
                      const Icon(Icons.restart_alt),
                      const SizedBox(width: 12),
                      Text(l10n.resetLayout),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'customize_units',
                  child: Row(
                    children: [
                      const Icon(Icons.tune),
                      const SizedBox(width: 12),
                      Text(l10n.customizeUnits),
                    ],
                  ),
                ),
              ],
            ),
          ]
          // Desktop/Tablet: Show individual buttons
          else ...[
            IconButton(
              icon: Icon(
                controller.isFocusMode
                    ? Icons.center_focus_weak
                    : Icons.center_focus_strong,
              ),
              onPressed: () => _toggleFocusMode(context, controller),
              tooltip: controller.isFocusMode
                  ? l10n.disableFocusMode
                  : l10n.enableFocusMode,
            ),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              onPressed: controller.resetLayout,
              tooltip: l10n.resetLayout,
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: () =>
                  _showGlobalUnitsCustomization(context, controller),
              tooltip: l10n.customizeUnits,
            ),
          ],
        ],
      ),
      body: _buildConverterContent(context, controller),
    );
  }

  Widget _buildConverterContent(
      BuildContext context, ConverterController controller) {
    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Only show status widget for converters that require real-time data
          if (controller.requiresRealTimeData && !controller.isFocusMode) ...[
            ConverterStatusWidget(
              controller: controller,
              onRefresh: onRefresh ?? controller.refreshData,
              onShowStatus: onShowStatus,
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: controller.viewMode == ConverterViewMode.cards
                ? _buildCardsView(context, controller)
                : _buildTableView(context, controller),
          ),
        ],
      ),
    );

    // Add gesture detection for zoom-based focus mode toggle on mobile
    return GestureDetector(
      onScaleUpdate: (details) {
        // Only handle zoom gestures on mobile devices
        if (FocusModeService.isMobile) {
          FocusModeService.handleScaleGesture(
            scale: details.scale,
            currentFocusMode: controller.isFocusMode,
            onEnterFocusMode: () => _toggleFocusMode(context, controller),
            onExitFocusMode: () => _toggleFocusMode(context, controller),
          );
        }
      },
      child: content,
    );
  }

  Widget _buildCardsView(BuildContext context, ConverterController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Add card button and view mode toggle - hidden in focus mode
        if (!controller.isFocusMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: controller.addCard,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    l10n.add,
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
                // Add focus button for embedded mode
                if (isEmbedded) ...[
                  IconButton(
                    icon: Icon(
                      controller.isFocusMode
                          ? Icons.center_focus_weak
                          : Icons.center_focus_strong,
                      size: 20,
                    ),
                    onPressed: () => _toggleFocusMode(context, controller),
                    tooltip: controller.isFocusMode
                        ? l10n.disableFocusMode
                        : l10n.enableFocusMode,
                  ),
                  const SizedBox(width: 12),
                ],
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
                // Multi-column layout for larger screens with proper drag support
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildDesktopGridLayout(
                        context, constraints, crossAxisCount, controller),
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
        // Add row button and view mode toggle - hidden in focus mode
        if (!controller.isFocusMode)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: controller.addCard,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    l10n.add,
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
                      controller.setViewMode(ConverterViewMode.cards),
                  icon: const Icon(Icons.view_agenda, size: 16),
                  label: Text(
                    l10n.cardView,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 12),
                // Add focus button for embedded mode
                if (isEmbedded) ...[
                  IconButton(
                    icon: Icon(
                      controller.isFocusMode
                          ? Icons.center_focus_weak
                          : Icons.center_focus_strong,
                      size: 20,
                    ),
                    onPressed: () => _toggleFocusMode(context, controller),
                    tooltip: controller.isFocusMode
                        ? l10n.disableFocusMode
                        : l10n.enableFocusMode,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    '${l10n.rows}: ${controller.state.cards.length}',
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

  void _toggleFocusMode(BuildContext context, ConverterController controller) {
    controller.toggleFocusMode();

    final exitInstruction = FocusModeService.getExitInstruction(
      context,
      isEmbedded: isEmbedded,
    );

    FocusModeService.showFocusModeNotification(
      context,
      isEnabled: controller.isFocusMode,
      exitInstruction: exitInstruction,
    );
  }

  Widget _buildDesktopGridLayout(
      BuildContext context,
      BoxConstraints constraints,
      int crossAxisCount,
      ConverterController controller) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: List.generate(
        controller.state.cards.length,
        (index) => SizedBox(
          width: (constraints.maxWidth - 16 - (16 * (crossAxisCount - 1))) /
              crossAxisCount,
          child: ConverterCardWidget(
            key: ValueKey('card_$index'),
            cardIndex: index,
            controller: controller,
          ),
        ),
      ),
    );
  }
}
