import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/calculator_history_service.dart';

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
      // Mobile: Tab layout or single view
      final contentToUse = widget.mobileContent ?? widget.calculatorContent;

      if (widget.historyEnabled && widget.historyWidget != null) {
        final loc = AppLocalizations.of(context)!;
        content = Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  icon: const Icon(Icons.calculate),
                  text: loc.calculatorTools,
                ),
                Tab(
                  icon: const Icon(Icons.history),
                  text: loc.calculationHistory,
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Calculator tab - with proper constraints
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: contentToUse,
                  ),
                  // History tab
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: widget.historyWidget!,
                  ),
                ],
              ),
            ),
          ],
        );
      } else {
        // Mobile without history: Direct content with padding
        content = Padding(
          padding: const EdgeInsets.all(16),
          child: contentToUse,
        );
      }
    }

    // Return either the content directly (if embedded) or wrapped in a Scaffold
    if (widget.isEmbedded) {
      return content;
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
          actions: _buildAppBarActions(context),
        ),
        body: content,
      );
    }
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.onShowInfo != null) {
      return [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: widget.onShowInfo,
          tooltip: l10n.info,
        ),
      ];
    }

    return [];
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
