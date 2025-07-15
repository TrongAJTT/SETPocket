import 'package:flutter/material.dart';
import 'package:setpocket/controllers/converter_controller.dart'
    show ConverterController;
import 'package:setpocket/layouts/single_panel_layout.dart'
    show SinglePanelLayout;
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/converter_models/converter_base.dart'
    show ConverterViewMode;
import 'package:setpocket/services/focus_mode_service.dart'
    show FocusModeService;
import 'package:setpocket/widgets/converter_tools/generic_unit_custom_dialog.dart'
    show GenericUnitItem, EnhancedGenericUnitCustomizationDialog;
import 'package:setpocket/widgets/generic/icon_button_list.dart'
    show IconButtonList, IconButtonListItem;
import 'converter_card_widget.dart';
import 'converter_table_widget.dart';
import 'converter_status_widget.dart';

class GenericConverterView extends StatefulWidget {
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
  State<GenericConverterView> createState() => _GenericConverterViewState();
}

class _GenericConverterViewState extends State<GenericConverterView> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  int _previousCardCount = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _previousCardCount = widget.controller.state.cards.length;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Build actions for the unified AppBar (excluding info button which is handled by layout)
  IconButtonList _buildActions(
      BuildContext context, ConverterController controller) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;

    int visibleCount = ((screenSize.width - 340) ~/ 40).clamp(0, 4);

    List<IconButtonListItem> actionItems = [
      IconButtonListItem(
        icon: controller.isFocusMode
            ? Icons.center_focus_weak
            : Icons.center_focus_strong,
        label: controller.isFocusMode
            ? l10n.disableFocusMode
            : l10n.enableFocusMode,
        onPressed: () => _toggleFocusMode(context, controller),
      ),
      IconButtonListItem(
        icon: Icons.tune,
        label: l10n.customizeUnits,
        onPressed: () => _showGlobalUnitsCustomization(context, controller),
      ),
      IconButtonListItem(
        icon: Icons.restart_alt,
        label: l10n.resetLayout,
        onPressed: () => _showResetLayoutConfirmation(context, controller),
      ),
      IconButtonListItem(
        icon: Icons.info,
        label: l10n.info,
        onPressed: widget.onShowInfo ?? () {},
      ),
    ];

    return IconButtonList(
        buttons: actionItems, visibleCount: visibleCount, spacing: 4.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return _buildConverterContent(context, widget.controller);
    }

    final displayTitle =
        widget.title ?? widget.controller.converterService.displayName;

    // Use SinglePanelLayout with unified actions
    return SinglePanelLayout(
      title: displayTitle,
      actions: [_buildActions(context, widget.controller)],
      child: _buildConverterContent(context, widget.controller),
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
              onRefresh: widget.onRefresh ?? controller.refreshData,
              onShowStatus: widget.onShowStatus,
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
                if (widget.isEmbedded) ...[
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
                // Horizontal PageView layout for mobile
                return _buildMobilePageView(context, controller);
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

  Widget _buildMobilePageView(
      BuildContext context, ConverterController controller) {
    final cardCount = controller.state.cards.length;

    // Kiểm tra nếu có card mới được thêm
    if (cardCount > _previousCardCount && cardCount > 0) {
      // Card mới được thêm, chuyển đến card cuối cùng (card mới)
      _currentPageIndex = cardCount - 1;
      _previousCardCount = cardCount;

      // Animate đến card mới sau một delay nhỏ để đảm bảo PageView đã được build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && mounted) {
          _pageController.animateToPage(
            cardCount - 1,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    } else if (cardCount < _previousCardCount) {
      // Card bị xóa, cập nhật số lượng
      _previousCardCount = cardCount;
      // Đảm bảo currentPageIndex không vượt quá số card hiện có
      if (_currentPageIndex >= cardCount && cardCount > 0) {
        _currentPageIndex = cardCount - 1;
      }
    }

    return Column(
      children: [
        // PageView với các cards
        Expanded(
          child: cardCount > 0
              ? PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPageIndex = index;
                    });
                  },
                  itemCount: cardCount,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height * 0.5,
                          ),
                          child: ConverterCardWidget(
                            key: ValueKey('card_$index'),
                            cardIndex: index,
                            controller: controller,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('No cards available'),
                ),
        ),

        // Dấu chấm indicator với khả năng tap để chuyển card
        if (cardCount > 1) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              cardCount,
              (index) => GestureDetector(
                onTap: () {
                  // Animate to selected page when tapped
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPageIndex == index ? 12 : 8,
                  height: _currentPageIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPageIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
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
                if (widget.isEmbedded) ...[
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
      isEmbedded: widget.isEmbedded,
    );

    FocusModeService.showFocusModeNotification(
      context,
      isEnabled: controller.isFocusMode,
      exitInstruction: exitInstruction,
    );
  }

  Future<void> _showResetLayoutConfirmation(
      BuildContext context, ConverterController controller) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmResetLayout),
        content: Text(l10n.confirmResetLayoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      controller.resetLayout();
    }
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
