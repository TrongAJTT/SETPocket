import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';

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
    final tabCount = widget.rightPanel != null ? 2 : 1;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Không clear AppBar khi dispose để tránh conflicts và null context error
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (widget.isEmbedded) {
      // Embedded mode: content only, no Scaffold
      if (isMobile) {
        // Mobile embedded: single panel with optional tabs
        return _buildMobileEmbeddedContent(context);
      } else {
        // Desktop embedded: two panels side by side
        return _buildDesktopEmbeddedPanels(context);
      }
    } else {
      // Standalone mode: with Scaffold and AppBar
      return _buildStandaloneLayout(context, isMobile);
    }
  }

  /// Builds the mobile UI when embedded inside another layout.
  Widget _buildMobileEmbeddedContent(BuildContext context) {
    final hasTabs = widget.rightPanel != null;
    if (!hasTabs) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: widget.mainPanel,
      );
    }

    // Use a simple TabBar for mobile embedded view
    return Column(
      children: [
        TabBar(
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
              icon:
                  widget.useCompactTabLayout ? null : const Icon(Icons.history),
              text: widget.rightPanelTitle ??
                  AppLocalizations.of(context)!.calculationHistory,
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: widget.mainPanel,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0),
                child: widget.rightPanel!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the desktop UI (two panels) when embedded.
  Widget _buildDesktopEmbeddedPanels(BuildContext context) {
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
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
  }

  /// Builds the layout with its own Scaffold and AppBar (not embedded).
  Widget _buildStandaloneLayout(BuildContext context, bool isMobile) {
    if (isMobile) {
      // Standalone mobile: Scaffold with standard AppBar and TabBar
      final hasTabs = widget.rightPanel != null;
      Widget tabbedContent = hasTabs
          ? TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: widget.mainPanel,
                ),
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
          title: Text(widget.title ?? widget.mainPanelTitle ?? ''),
          elevation: 0,
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
                    if (widget.rightPanel != null)
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
          actions: widget.mainPanelActions,
        ),
        body: tabbedContent,
      );
    } else {
      // Standalone desktop: Scaffold with AppBar and two panels in body
      List<Widget> allActions = [];
      if (widget.mainPanelActions != null) {
        allActions.addAll(widget.mainPanelActions!);
      }
      if (widget.rightPanelActions != null) {
        allActions.addAll(widget.rightPanelActions!);
      }

      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title ?? ''),
          elevation: 0,
          actions: allActions,
        ),
        body: _buildDesktopEmbeddedPanels(context),
      );
    }
  }
}
