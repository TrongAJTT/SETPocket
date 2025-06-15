import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/models/converter_models/converter_base.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'generic_unit_custom_dialog.dart';

class ConverterCardWidget extends StatefulWidget {
  final ConverterController controller;
  final int cardIndex;
  final VoidCallback? onRemove;
  final VoidCallback? onCustomize;

  const ConverterCardWidget({
    super.key,
    required this.controller,
    required this.cardIndex,
    this.onRemove,
    this.onCustomize,
  });

  @override
  State<ConverterCardWidget> createState() => _ConverterCardWidgetState();
}

class _ConverterCardWidgetState extends State<ConverterCardWidget> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _debouncedOnChanged(int cardIndex, String unitId, String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.controller.onValueChanged(cardIndex, unitId, value);
    });
  }

  ConverterController get controller => widget.controller;
  int get cardIndex => widget.cardIndex;

  @override
  Widget build(BuildContext context) {
    if (cardIndex >= controller.state.cards.length) {
      return const SizedBox.shrink();
    }

    final card = controller.state.cards[cardIndex];
    final cardControllers = controller.cardControllers[cardIndex];

    if (cardControllers == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 300;
        final isMobile = ConverterController.isMobile(context);

        // On mobile, don't use DragTarget since we're using context menu
        if (isMobile) {
          return _buildCardContent(
              context, constraints, isDesktop, card, cardControllers);
        }

        // Desktop: Use DragTarget with improved visual feedback
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) {
            return details.data != cardIndex;
          },
          onAcceptWithDetails: (details) {
            final draggedIndex = details.data;
            if (draggedIndex != cardIndex) {
              controller.reorderCards(draggedIndex, cardIndex);
            }
          },
          builder: (context, candidateData, rejectedData) {
            final isReceivingDrag = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.all(isReceivingDrag ? 4 : 0),
              decoration: BoxDecoration(
                border: isReceivingDrag
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isReceivingDrag
                    ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: _buildCardContent(
                  context, constraints, isDesktop, card, cardControllers),
            );
          },
        );
      },
    );
  }

  Widget _buildCardContent(
    BuildContext context,
    BoxConstraints constraints,
    bool isDesktop,
    ConverterCardState card,
    Map<String, TextEditingController> cardControllers,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 12 : 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card header
            _buildCardHeader(context, l10n, isDesktop, card),
            SizedBox(height: isDesktop ? 16 : 12),

            // Base unit input and dropdown
            _buildBaseUnitSection(context, l10n, card, cardControllers),
            SizedBox(height: isDesktop ? 12 : 8),

            // "Converted to" label
            Text(
              '${l10n.convertedTo}:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isDesktop ? 15 : 14,
              ),
            ),
            SizedBox(height: isDesktop ? 12 : 8),

            // Other units
            _buildOtherUnits(context, constraints, isDesktop, card),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, AppLocalizations l10n,
      bool isDesktop, ConverterCardState card) {
    return Row(
      children: [
        // Drag handle
        _buildDragHandle(context),
        const SizedBox(width: 8),

        // Card name
        Expanded(
          child: Text(
            card.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 16 : 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Action buttons
        _buildActionButtons(context, l10n),
      ],
    );
  }

  Widget _buildDragHandle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = ConverterController.isMobile(context);

    if (isMobile) {
      // Mobile: Show context menu on tap
      return GestureDetector(
        onTap: () => _showMobileCardActionsMenu(context),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.drag_handle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
      );
    } else {
      // Desktop: Keep drag functionality but make it work better with grid
      return Draggable<int>(
        data: cardIndex,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.9),
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
                    controller.state.cards[cardIndex].name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dragging,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer
                          .withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        childWhenDragging: Container(
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.drag_handle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.drag_handle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
      );
    }
  }

  void _showMobileCardActionsMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalCards = controller.state.cards.length;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.cardActions,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Divider(),

            // Action buttons
            if (cardIndex > 0) ...[
              ListTile(
                leading: const Icon(Icons.keyboard_double_arrow_up),
                title: Text(l10n.moveToFirst),
                onTap: () {
                  Navigator.pop(context);
                  controller.moveCardToFirst(cardIndex);
                },
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_arrow_up),
                title: Text(l10n.moveUp),
                onTap: () {
                  Navigator.pop(context);
                  controller.moveCardUp(cardIndex);
                },
              ),
            ],
            if (cardIndex < totalCards - 1) ...[
              ListTile(
                leading: const Icon(Icons.keyboard_arrow_down),
                title: Text(l10n.moveDown),
                onTap: () {
                  Navigator.pop(context);
                  controller.moveCardDown(cardIndex);
                },
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_double_arrow_down),
                title: Text(l10n.moveToLast),
                onTap: () {
                  Navigator.pop(context);
                  controller.moveCardToLast(cardIndex);
                },
              ),
            ],

            // Cancel button
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit name button
        IconButton(
          onPressed: () => _editCardName(context),
          icon: Icon(
            Icons.edit,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          tooltip: l10n.edit,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),

        // Edit units button
        IconButton(
          onPressed: () => _editCardUnits(context),
          icon: Icon(
            Icons.tune,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          tooltip: l10n.edit,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
        ),

        // Delete button
        if (controller.state.cards.length > 1)
          IconButton(
            onPressed: () => controller.removeCard(cardIndex),
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
    );
  }

  Widget _buildBaseUnitSection(
    BuildContext context,
    AppLocalizations l10n,
    ConverterCardState card,
    Map<String, TextEditingController> cardControllers,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useColumnLayout = constraints.maxWidth < 500;

        if (useColumnLayout) {
          return Column(
            children: [
              _buildAmountField(context, l10n, card, cardControllers),
              const SizedBox(height: 12),
              _buildBaseUnitDropdown(context, l10n, card),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildAmountField(context, l10n, card, cardControllers),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildBaseUnitDropdown(context, l10n, card),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildAmountField(
    BuildContext context,
    AppLocalizations l10n,
    ConverterCardState card,
    Map<String, TextEditingController> cardControllers,
  ) {
    // Use different labels based on converter type
    final isCurrency = controller.converterService.converterType == 'currency';
    final labelText = isCurrency ? l10n.amount : l10n.quantity;

    return TextField(
      controller: cardControllers[card.baseUnitId],
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 14),
      onChanged: (value) =>
          _debouncedOnChanged(cardIndex, card.baseUnitId, value),
    );
  }

  Widget _buildBaseUnitDropdown(
    BuildContext context,
    AppLocalizations l10n,
    ConverterCardState card,
  ) {
    // Get unique visible units and ensure they exist
    final availableUnits = controller.converterService.units;
    final availableUnitIds = availableUnits.map((u) => u.id).toSet();
    final validVisibleUnits = card.visibleUnits
        .where((unitId) => availableUnitIds.contains(unitId))
        .toSet()
        .toList();

    // Ensure baseUnitId is in the list
    final dropdownValue = validVisibleUnits.contains(card.baseUnitId)
        ? card.baseUnitId
        : (validVisibleUnits.isNotEmpty ? validVisibleUnits.first : null);

    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: InputDecoration(
        labelText: l10n.from,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      items: validVisibleUnits
          .map((unitId) {
            final unit = controller.converterService.getUnit(unitId);
            if (unit == null) return null;

            return DropdownMenuItem<String>(
              value: unitId,
              child: Text(
                '${unit.symbol} - ${unit.name}',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            );
          })
          .where((item) => item != null)
          .cast<DropdownMenuItem<String>>()
          .toList(),
      onChanged: (newUnitId) {
        if (newUnitId != null) {
          final currentValue = card.baseValue;
          _debouncedOnChanged(cardIndex, newUnitId, currentValue.toString());
        }
      },
    );
  }

  Widget _buildOtherUnits(
    BuildContext context,
    BoxConstraints constraints,
    bool isDesktop,
    ConverterCardState card,
  ) {
    // Get unique visible units and ensure they exist
    final availableUnits = controller.converterService.units;
    final availableUnitIds = availableUnits.map((u) => u.id).toSet();
    final validVisibleUnits = card.visibleUnits
        .where((unitId) => availableUnitIds.contains(unitId))
        .toSet();

    final otherUnits =
        validVisibleUnits.where((u) => u != card.baseUnitId).toList();

    if (isDesktop) {
      return _buildDesktopUnitsLayout(context, constraints, otherUnits, card);
    } else {
      return _buildMobileUnitsLayout(context, otherUnits, card);
    }
  }

  Widget _buildDesktopUnitsLayout(
    BuildContext context,
    BoxConstraints constraints,
    List<String> otherUnits,
    ConverterCardState card,
  ) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: otherUnits.map((unitId) {
        return SizedBox(
          width: constraints.maxWidth >= 500
              ? (constraints.maxWidth - 44) / 2
              : constraints.maxWidth - 20,
          height: 52,
          child: _buildUnitDisplayTile(context, unitId, card),
        );
      }).toList(),
    );
  }

  Widget _buildMobileUnitsLayout(
    BuildContext context,
    List<String> otherUnits,
    ConverterCardState card,
  ) {
    return Column(
      children: otherUnits.map((unitId) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          child: _buildUnitDisplayTile(context, unitId, card),
        );
      }).toList(),
    );
  }

  Widget _buildUnitDisplayTile(
      BuildContext context, String unitId, ConverterCardState card) {
    final unit = controller.converterService.getUnit(unitId);
    if (unit == null) return const SizedBox.shrink();

    final value = card.values[unitId] ?? 0.0;
    final status = card.statuses[unitId] ?? ConversionStatus.success;
    final hasError =
        status == ConversionStatus.failed || status == ConversionStatus.timeout;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final errorBackgroundColor = hasError
        ? (isDarkMode
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50)
        : Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3);
    final errorBorderColor = hasError
        ? (isDarkMode ? Colors.red.shade400 : Colors.red.shade300)
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
          // Unit symbol with status indicator
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
                        color: status == ConversionStatus.timeout
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

          // Unit name
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
            unit.formatValue(value),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _editCardName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final card = controller.state.cards[cardIndex];
    final currentName = card.name;
    final textController = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.edit),
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

  void _editCardUnits(BuildContext context) {
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
        showPresetOptions: true, // Enable presets for card level too
      ),
    );
  }
}
