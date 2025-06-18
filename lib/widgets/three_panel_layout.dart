import 'package:flutter/material.dart';

class ThreePanelLayout extends StatefulWidget {
  final Widget mainPanel;
  final Widget topRightPanel;
  final Widget? bottomRightPanel;
  final String? mainPanelTitle;
  final String? topRightPanelTitle;
  final String? bottomRightPanelTitle;
  final bool isEmbedded;
  final String? title;
  final bool hideBottomPanel;

  const ThreePanelLayout({
    super.key,
    required this.mainPanel,
    required this.topRightPanel,
    this.bottomRightPanel,
    this.mainPanelTitle,
    this.topRightPanelTitle,
    this.bottomRightPanelTitle,
    this.isEmbedded = false,
    this.title,
    this.hideBottomPanel = false,
  });

  @override
  State<ThreePanelLayout> createState() => _ThreePanelLayoutState();
}

class _ThreePanelLayoutState extends State<ThreePanelLayout>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabCount =
        widget.hideBottomPanel || widget.bottomRightPanel == null ? 2 : 3;
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(ThreePanelLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update tab controller if hideBottomPanel changed
    final oldTabCount =
        oldWidget.hideBottomPanel || oldWidget.bottomRightPanel == null ? 2 : 3;
    final newTabCount =
        widget.hideBottomPanel || widget.bottomRightPanel == null ? 2 : 3;

    if (oldTabCount != newTabCount) {
      _tabController.dispose();
      _tabController = TabController(length: newTabCount, vsync: this);
      _tabController.addListener(() {
        setState(() {});
      });
// Reset to first tab
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    if (isDesktop) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Main panel - 60% width
        Expanded(
          flex: 60,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.mainPanelTitle != null)
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
                          Icons.show_chart,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.mainPanelTitle!,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: widget.mainPanel),
              ],
            ),
          ),
        ),

        // Right side panels - 40% width
        Expanded(
          flex: 40,
          child: widget.hideBottomPanel || widget.bottomRightPanel == null
              ? // Single panel taking full height
              Container(
                  margin: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          Theme.of(context).dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.topRightPanelTitle != null)
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
                                Icons.functions,
                                size: 20,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.topRightPanelTitle!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(child: widget.topRightPanel),
                    ],
                  ),
                )
              : // Two panels split vertically
              Column(
                  children: [
                    // Top right panel - 50% height
                    Expanded(
                      flex: 50,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 8, 8, 4),
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
                            if (widget.topRightPanelTitle != null)
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
                                      Icons.functions,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.topRightPanelTitle!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(child: widget.topRightPanel),
                          ],
                        ),
                      ),
                    ),

                    // Bottom right panel - 50% height
                    Expanded(
                      flex: 50,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 4, 8, 8),
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
                            if (widget.bottomRightPanelTitle != null)
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
                                      Icons.history,
                                      size: 20,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      widget.bottomRightPanelTitle!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(child: widget.bottomRightPanel!),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    // Determine number of tabs based on hideBottomPanel
    // final tabCount =
    //     widget.hideBottomPanel || widget.bottomRightPanel == null ? 2 : 3;

    return Column(
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            tabs: [
              Tab(
                icon: const Icon(Icons.show_chart, size: 20),
                text: widget.mainPanelTitle ?? 'Main',
              ),
              Tab(
                icon: const Icon(Icons.functions, size: 20),
                text: widget.topRightPanelTitle ?? 'Functions',
              ),
              if (!widget.hideBottomPanel && widget.bottomRightPanel != null)
                Tab(
                  icon: const Icon(Icons.history, size: 20),
                  text: widget.bottomRightPanelTitle ?? 'History',
                ),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              widget.mainPanel,
              widget.topRightPanel,
              if (!widget.hideBottomPanel && widget.bottomRightPanel != null)
                widget.bottomRightPanel!,
            ],
          ),
        ),
      ],
    );
  }
}
