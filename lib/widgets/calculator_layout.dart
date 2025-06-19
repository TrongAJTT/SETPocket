import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/calculator_history_service.dart';
import 'package:setpocket/services/graphing_calculator_service.dart';
import 'package:setpocket/widgets/three_panel_layout.dart';

/// New calculator layout using ThreePanelLayout for consistency
class NewCalculatorLayout extends StatefulWidget {
  final Widget calculatorContent;
  final Widget? historyWidget;
  final bool historyEnabled;
  final bool hasHistory;
  final bool isEmbedded;
  final String title;
  final VoidCallback? onShowInfo;
  final List<Widget>? actions; // Additional actions for calculator panel
  final VoidCallback? onClearHistory; // Generic clear history callback
  final bool hasHistoryData; // Whether there is actually history data to clear
  final String?
      clearHistoryMessage; // Custom clear history confirmation message
  final String? historyClearedMessage; // Custom history cleared success message

  const NewCalculatorLayout({
    super.key,
    required this.calculatorContent,
    this.historyWidget,
    required this.historyEnabled,
    required this.hasHistory,
    required this.isEmbedded,
    required this.title,
    this.onShowInfo,
    this.actions,
    this.onClearHistory,
    this.hasHistoryData = false,
    this.clearHistoryMessage,
    this.historyClearedMessage,
  });

  @override
  State<NewCalculatorLayout> createState() => _NewCalculatorLayoutState();
}

class _NewCalculatorLayoutState extends State<NewCalculatorLayout> {
  List<Widget> _buildCalculatorActions(BuildContext context) {
    final actions = <Widget>[];

    // Add info button if available
    if (widget.onShowInfo != null) {
      actions.add(
        IconButton(
          onPressed: widget.onShowInfo,
          icon: const Icon(Icons.info_outline),
          tooltip: AppLocalizations.of(context)!.info,
        ),
      );
    }

    // Add additional actions
    if (widget.actions != null) {
      actions.addAll(widget.actions!);
    }

    return actions;
  }

  List<Widget> _buildHistoryActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actions = <Widget>[];

    // Add clear history button if callback is provided and there is data to clear
    if (widget.onClearHistory != null && widget.hasHistoryData) {
      actions.add(
        IconButton(
          onPressed: () => _showClearHistoryDialog(context),
          icon: const Icon(Icons.clear_all, size: 18),
          tooltip: l10n.clearAll,
        ),
      );
    }

    return actions;
  }

  Future<void> _showClearHistoryDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Use custom message if provided, otherwise fall back to generic calculator message
    final confirmMessage =
        widget.clearHistoryMessage ?? l10n.confirmClearCalculatorHistory;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAll),
        content: Text(confirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      widget.onClearHistory?.call();

      // Use custom success message if provided, otherwise fall back to generic calculator message
      final successMessage =
          widget.historyClearedMessage ?? l10n.calculatorHistoryCleared;

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(successMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ThreePanelLayout(
      mainPanel: widget.calculatorContent,
      topRightPanel: widget.historyWidget ?? Container(),
      bottomRightPanel: null, // Single panel for most calculators
      mainPanelTitle: widget.title,
      topRightPanelTitle: widget.historyEnabled && widget.historyWidget != null
          ? l10n.calculationHistory
          : null,
      title: widget.title,
      isEmbedded: widget.isEmbedded, // Pass the embedded flag
      hideBottomPanel: true, // Most calculators only need 2 panels
      mainPanelActions: _buildCalculatorActions(context),
      topRightPanelActions:
          widget.historyEnabled && widget.historyWidget != null
              ? _buildHistoryActions(context)
              : null,
    );
  }
}

/// Generic calculator widget base class for common functionality
abstract class CalculatorWidget extends StatefulWidget {
  final bool isEmbedded;

  const CalculatorWidget({super.key, this.isEmbedded = false});

  // Abstract methods that subclasses must implement
  String get title;
  IconData get icon => Icons.calculate;
  Widget buildCalculatorContent(BuildContext context);
  Widget? buildHistoryWidget(BuildContext context) => null;
  VoidCallback? getInfoCallback(BuildContext context) => null;
  bool get hasHistory => false; // Default to false, override if has history

  @override
  CalculatorWidgetState createState();
}

/// Generic state class for calculator widgets
abstract class CalculatorWidgetState<T extends CalculatorWidget>
    extends State<T> {
  bool _historyEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadHistorySettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistorySettings();
  }

  Future<void> _loadHistorySettings() async {
    final enabled = await GraphingCalculatorService.getRememberHistory();
    if (mounted) {
      setState(() {
        _historyEnabled = enabled;
      });
    }
  }

  // Override this to provide localized title
  String getLocalizedTitle(BuildContext context) {
    return widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorLayout(
      calculatorContent: widget.buildCalculatorContent(context),
      historyWidget: widget.buildHistoryWidget(context),
      historyEnabled: _historyEnabled,
      hasHistory: widget.hasHistory,
      isEmbedded: widget.isEmbedded,
      title: getLocalizedTitle(context),
      onShowInfo: widget.getInfoCallback(context),
    );
  }
}

/// Generic layout widget for all calculator tools to ensure consistency
class CalculatorLayout extends StatefulWidget {
  final Widget calculatorContent;
  final Widget? mobileContent; // Different content for mobile if needed
  final Widget? historyWidget;
  final bool historyEnabled;
  final bool hasHistory;
  final bool isEmbedded;
  final String title;
  final VoidCallback? onShowInfo;

  const CalculatorLayout({
    super.key,
    required this.calculatorContent,
    this.mobileContent, // Optional mobile-specific content
    this.historyWidget,
    required this.historyEnabled,
    required this.hasHistory,
    required this.isEmbedded,
    required this.title,
    this.onShowInfo,
  });

  @override
  State<CalculatorLayout> createState() => _CalculatorLayoutState();
}

class _CalculatorLayoutState extends State<CalculatorLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _switchToCalculatorTab() {
    if (_tabController.index != 0) {
      _tabController.animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1200;

    Widget content;

    if (isLargeScreen) {
      if (widget.historyEnabled && widget.historyWidget != null) {
        // Desktop with history: 3:2 ratio with bordered containers and titles
        content = LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calculator content: 60% width (3/5) with border and title
                Expanded(
                  flex: 3,
                  child: Container(
                    height: constraints.maxHeight,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calculator title header
                        Container(
                          padding: const EdgeInsets.all(16),
                          height: 65,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calculate,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              if (widget.onShowInfo != null)
                                IconButton(
                                  onPressed: widget.onShowInfo,
                                  icon: Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  tooltip: AppLocalizations.of(context)!.info,
                                ),
                            ],
                          ),
                        ),
                        // Calculator content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: widget.calculatorContent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // History widget: 40% width (2/5) with border and title
                Expanded(
                  flex: 2,
                  child: Container(
                    height: constraints.maxHeight,
                    margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: widget.historyWidget!,
                  ),
                ),
              ],
            );
          },
        );
      } else {
        // Desktop without history: Calculator centered with border and title
        content = LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                // Left spacer: 20%
                const Expanded(flex: 1, child: SizedBox()),
                // Calculator content: 60% with border and title
                Expanded(
                  flex: 3,
                  child: Container(
                    height: constraints.maxHeight,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .dividerColor
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calculator title header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calculate,
                                size: 20,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              if (widget.onShowInfo != null)
                                IconButton(
                                  onPressed: widget.onShowInfo,
                                  icon: Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  tooltip: AppLocalizations.of(context)!.info,
                                ),
                            ],
                          ),
                        ),
                        // Calculator content
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: widget.calculatorContent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Right spacer: 20%
                const Expanded(flex: 1, child: SizedBox()),
              ],
            );
          },
        );
      }
    } else {
      // Mobile/Tablet: Use tab layout
      content = widget.historyEnabled && widget.historyWidget != null
          ? TabbedCalculatorLayout(
              tabController: _tabController,
              calculatorContent:
                  widget.mobileContent ?? widget.calculatorContent,
              historyWidget: widget.historyWidget!,
              title: widget.title,
              onShowInfo: widget.onShowInfo,
              showTabBar: false,
              onSwitchToCalculator: _switchToCalculatorTab,
            )
          : SingleCalculatorLayout(
              calculatorContent:
                  widget.mobileContent ?? widget.calculatorContent,
              title: widget.title,
              onShowInfo: widget.onShowInfo,
            );
    }

    if (widget.isEmbedded) {
      return content;
    } else {
      // Non-embedded: Add AppBar for mobile navigation
      if (isLargeScreen) {
        // Desktop: No AppBar needed
        return Scaffold(
          body: content,
        );
      } else {
        // Mobile/Tablet: Add AppBar with back button
        final tabbedContent =
            widget.historyEnabled && widget.historyWidget != null
                ? TabbedCalculatorLayout(
                    tabController: _tabController,
                    calculatorContent:
                        widget.mobileContent ?? widget.calculatorContent,
                    historyWidget: widget.historyWidget!,
                    title: widget.title,
                    onShowInfo: widget.onShowInfo,
                    showTabBar: false, // Hide tab bar, will be in AppBar
                    onSwitchToCalculator: _switchToCalculatorTab,
                  )
                : SingleCalculatorLayout(
                    calculatorContent:
                        widget.mobileContent ?? widget.calculatorContent,
                    title: widget.title,
                    onShowInfo: widget.onShowInfo,
                    showHeader: false, // No header when AppBar is present
                  );

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            elevation: 0,
            actions: widget.onShowInfo != null
                ? [
                    IconButton(
                      onPressed: widget.onShowInfo,
                      icon: const Icon(Icons.info_outline),
                      tooltip: AppLocalizations.of(context)!.info,
                    ),
                  ]
                : null,
            bottom: widget.historyEnabled && widget.historyWidget != null
                ? TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.calculate),
                        text: AppLocalizations.of(context)!.calculatorTools,
                      ),
                      Tab(
                        icon: const Icon(Icons.history),
                        text: AppLocalizations.of(context)!.calculationHistory,
                      ),
                    ],
                  )
                : null,
          ),
          body: tabbedContent,
        );
      }
    }
  }
}

/// Generic two-tab calculator layout for mobile/tablet
class TabbedCalculatorLayout extends StatelessWidget {
  final TabController tabController;
  final Widget calculatorContent;
  final Widget historyWidget;
  final String title;
  final VoidCallback? onShowInfo;
  final bool showTabBar;
  final VoidCallback? onSwitchToCalculator;

  const TabbedCalculatorLayout({
    super.key,
    required this.tabController,
    required this.calculatorContent,
    required this.historyWidget,
    required this.title,
    this.onShowInfo,
    this.showTabBar = true,
    this.onSwitchToCalculator,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Tab bar - only show if needed
        if (showTabBar)
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              controller: tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.calculate),
                  text: l10n.calculatorTools,
                ),
                Tab(
                  icon: const Icon(Icons.history),
                  text: l10n.calculationHistory,
                ),
              ],
            ),
          ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              // Calculator tab
              SingleCalculatorLayout(
                calculatorContent: calculatorContent,
                title: title,
                onShowInfo: onShowInfo,
                showHeader:
                    showTabBar, // Show header only if no separate tab bar
              ),
              // History tab
              _HistoryWidgetWrapper(
                onSwitchToCalculator: onSwitchToCalculator,
                child: historyWidget,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Single calculator layout without tabs
class SingleCalculatorLayout extends StatelessWidget {
  final Widget calculatorContent;
  final String title;
  final VoidCallback? onShowInfo;
  final bool showHeader;

  const SingleCalculatorLayout({
    super.key,
    required this.calculatorContent,
    required this.title,
    this.onShowInfo,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showHeader) {
      return calculatorContent;
    }

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calculate,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const Spacer(),
              if (onShowInfo != null)
                IconButton(
                  onPressed: onShowInfo,
                  icon: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tooltip: AppLocalizations.of(context)!.info,
                ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: calculatorContent,
          ),
        ),
      ],
    );
  }
}

/// Generic calculator history widget builder for consistency
class CalculatorHistoryWidget extends StatefulWidget {
  final String historyType;
  final List<CalculatorHistoryItem> history;
  final String title;
  final VoidCallback? onClearHistory;
  final Function(String)? onCopyExpression;
  final Function(String)? onCopyResult;
  final Widget Function(CalculatorHistoryItem, BuildContext)? customItemBuilder;

  const CalculatorHistoryWidget({
    super.key,
    required this.historyType,
    required this.history,
    required this.title,
    this.onClearHistory,
    this.onCopyExpression,
    this.onCopyResult,
    this.customItemBuilder,
  });

  @override
  State<CalculatorHistoryWidget> createState() =>
      _CalculatorHistoryWidgetState();
}

class _CalculatorHistoryWidgetState extends State<CalculatorHistoryWidget> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                if (widget.onClearHistory != null && widget.history.isNotEmpty)
                  IconButton(
                    onPressed: widget.onClearHistory,
                    icon: const Icon(Icons.clear_all),
                    tooltip: loc.clearAll,
                    iconSize: 20,
                  ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: widget.history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.noCalculationHistory,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: widget.history.length,
                    itemBuilder: (context, index) {
                      final item = widget.history[index];

                      if (widget.customItemBuilder != null) {
                        return widget.customItemBuilder!(item, context);
                      }

                      return _buildDefaultHistoryItem(item, context, loc);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultHistoryItem(
      CalculatorHistoryItem item, BuildContext context, AppLocalizations loc) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expression
            if (item.expression.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.input,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.expression,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  if (widget.onCopyExpression != null)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () =>
                          widget.onCopyExpression!(item.expression),
                      tooltip: 'Copy Expression',
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Result
            Row(
              children: [
                Icon(
                  Icons.output,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.result,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ),
                if (widget.onCopyResult != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 16),
                    onPressed: () => widget.onCopyResult!(item.result),
                    tooltip: 'Copy Result',
                  ),
              ],
            ),

            // Timestamp
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  item.timestamp.toString().substring(0, 19),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper to inject callback into history widgets
class _HistoryWidgetWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSwitchToCalculator;

  const _HistoryWidgetWrapper({
    required this.child,
    this.onSwitchToCalculator,
  });

  @override
  Widget build(BuildContext context) {
    return CalculatorTabSwitcher(
      onSwitchToCalculator: onSwitchToCalculator,
      child: child,
    );
  }
}

/// InheritedWidget to provide tab switching callback
class CalculatorTabSwitcher extends InheritedWidget {
  final VoidCallback? onSwitchToCalculator;

  const CalculatorTabSwitcher({
    super.key,
    required this.onSwitchToCalculator,
    required super.child,
  });

  static CalculatorTabSwitcher? of(BuildContext context) {
    return context.getInheritedWidgetOfExactType<CalculatorTabSwitcher>();
  }

  @override
  bool updateShouldNotify(CalculatorTabSwitcher oldWidget) {
    return onSwitchToCalculator != oldWidget.onSwitchToCalculator;
  }
}
