import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/layouts/base_responsive_layout.dart';
import 'package:setpocket/controllers/mobile_appbar_controller.dart';
import 'package:setpocket/utils/variables_utils.dart';
import 'package:setpocket/widgets/mobile_appbar.dart';
import 'package:setpocket/services/tab_navigation_state_manager.dart';

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
    with SingleTickerProviderStateMixin, BaseResponsiveLayout {
  late TabController _tabController;

  @override
  void syncMobileAppBar() {
    if (isMobileLayoutContext(context)) {
      // Collect all actions from both panels
      List<Widget> allActions = [];

      if (widget.mainPanelActions != null && _tabController.index == 0) {
        allActions.addAll(widget.mainPanelActions!);
      }

      if (widget.rightPanelActions != null && _tabController.index == 1) {
        allActions.addAll(widget.rightPanelActions!);
      }

      // AppBar controller will automatically use current tab context
      final controller = MobileAppBarController();
      controller.setAppBar(
        title: getScreenTitle(widget.title),
        actions: allActions,
      );

      // Save AppBar state to current tab
      final stateManager = TabNavigationStateManager.instance;
      final currentTabState = stateManager.currentTabState;
      currentTabState.updateAppBar(
        title: getScreenTitle(widget.title),
        actions: allActions
            .map((action) => {
                  'type': action.runtimeType.toString(),
                  'tooltip': action is IconButton ? action.tooltip : null,
                })
            .toList(),
      );
      stateManager.saveState();
    } else {
      print('📵 TwoPanelsLayout: Not syncing (desktop)');
    }
  }

  @override
  void initState() {
    super.initState();
    final tabCount = widget.rightPanel != null ? 2 : 1;
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(() {
      // Sync AppBar when tab changes
      if (isMobileLayoutContext(context)) {
        refreshMobileAppBar();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refreshMobileAppBarIfNotInitialized();
  }

  @override
  void didUpdateWidget(TwoPanelsLayout oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-sync AppBar khi có thay đổi actions hoặc title
    if (oldWidget.title != widget.title ||
        oldWidget.mainPanelActions != widget.mainPanelActions ||
        oldWidget.rightPanelActions != widget.rightPanelActions) {
      refreshMobileAppBar();
    }
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
      // Standalone mobile: Scaffold với MobileAppBar và TabBar
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
        appBar: hasTabs
            ? PreferredSize(
                preferredSize: const Size.fromHeight(
                    kToolbarHeight + 48.0), // 48.0 is default tab height
                child: Column(
                  children: [
                    const Flexible(child: MobileAppBar()),
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
                        if (widget.rightPanel != null)
                          Tab(
                            icon: widget.useCompactTabLayout
                                ? null
                                : const Icon(Icons.history),
                            text: widget.rightPanelTitle ??
                                AppLocalizations.of(context)!
                                    .calculationHistory,
                          ),
                      ],
                    ),
                  ],
                ),
              )
            : const MobileAppBar(),
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
