import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/variables.dart';

/// A responsive layout that shows two panels side-by-side on larger screens
/// and as tabs on smaller screens.
class TwoPanelsLayout extends StatefulWidget {
  // Main (left) panel content and customization
  final Widget mainPanel;
  final String? mainPanelTitle;
  final List<Widget>? mainPanelActions;
  final IconData? mainPanelIcon;

  // Right panel (history/secondary) content and customization
  final Widget? rightPanel;
  final String? rightPanelTitle;
  final List<Widget>? rightPanelActions;

  // General layout options
  final String? title; // For mobile AppBar
  final bool isEmbedded;
  final bool useCompactTabLayout; // New parameter for compact tabs
  final bool showInfoInRightPanelHeader;

  const TwoPanelsLayout({
    super.key,
    required this.mainPanel,
    this.rightPanel,
    this.title,
    this.mainPanelTitle,
    this.isEmbedded = false,
    this.rightPanelTitle,
    this.rightPanelActions,
    this.mainPanelActions,
    this.mainPanelIcon,
    this.useCompactTabLayout = false,
    this.showInfoInRightPanelHeader = false,
  });

  @override
  _TwoPanelsLayoutState createState() => _TwoPanelsLayoutState();
}

class _TwoPanelsLayoutState extends State<TwoPanelsLayout>
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
    if (widget.isEmbedded) {
      // Desktop layout
      return Row(
        children: [
          Expanded(
            flex: 3,
            child: Card(
              elevation: 0,
              color: Colors.transparent,
              margin: const EdgeInsets.fromLTRB(12, 12, 6, 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: .2),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: kToolbarHeight,
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.mainPanelTitle ?? '',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (widget.mainPanelActions != null)
                            ...widget.mainPanelActions!,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: widget.mainPanel,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.rightPanel != null) ...[
            Expanded(
              flex: 2,
              child: Card(
                elevation: 0,
                color: Colors.transparent,
                margin: const EdgeInsets.fromLTRB(6, 12, 12, 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: .2),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: kToolbarHeight,
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.rightPanelTitle ?? '',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (widget.rightPanelActions != null)
                              ...widget.rightPanelActions!,
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
                        child: widget.rightPanel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      );
    } else {
      // Mobile layout with tabs
      final hasTabs = widget.rightPanel != null;
      Widget tabbedContent = hasTabs
          ? TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: widget.mainPanel,
                ),
                if (widget.rightPanel != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
                    child: widget.rightPanel!,
                  ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: widget.mainPanel,
            );

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? appName),
          elevation: 0,
          actions: widget.mainPanelActions ?? [],
          bottom: hasTabs
              ? TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: widget.useCompactTabLayout
                          ? null
                          : Icon(widget.mainPanelIcon ?? Icons.calculate),
                      text: widget.mainPanelTitle ??
                          AppLocalizations.of(context)!.calculatorTools,
                    ),
                    Tab(
                      icon: widget.useCompactTabLayout
                          ? null
                          : const Icon(Icons.history),
                      text: widget.rightPanelTitle ??
                          AppLocalizations.of(context)!.calculationHistory,
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
