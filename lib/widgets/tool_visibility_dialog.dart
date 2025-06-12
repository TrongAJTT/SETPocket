import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/tool_config.dart';
import 'package:setpocket/services/tool_visibility_service.dart';

class ToolVisibilityDialog extends StatefulWidget {
  final VoidCallback? onChanged;

  const ToolVisibilityDialog({super.key, this.onChanged});

  @override
  State<ToolVisibilityDialog> createState() => _ToolVisibilityDialogState();
}

class _ToolVisibilityDialogState extends State<ToolVisibilityDialog> {
  List<ToolConfig> _tools = [];
  bool _loading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadTools();
  }

  Future<void> _loadTools() async {
    final tools = await ToolVisibilityService.getAllToolsInOrder();
    setState(() {
      _tools = tools;
      _loading = false;
    });
  }

  Future<void> _saveChanges() async {
    final visibility = Map.fromEntries(
      _tools.map((tool) => MapEntry(tool.id, tool.isVisible)),
    );
    final order = _tools.map((tool) => tool.id).toList();

    await ToolVisibilityService.saveToolVisibility(visibility);
    await ToolVisibilityService.saveToolOrder(order);

    setState(() {
      _hasChanges = false;
    });

    widget.onChanged?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.toolVisibilityChanged),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _resetToDefault() async {
    await ToolVisibilityService.resetToDefault();
    await _loadTools();
    setState(() {
      _hasChanges = true;
    });
  }

  void _toggleVisibility(int index) {
    setState(() {
      _tools[index] = _tools[index].copyWith(
        isVisible: !_tools[index].isVisible,
      );
      _hasChanges = true;
    });
  }

  void _reorderTools(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _tools.removeAt(oldIndex);
      _tools.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  bool _hasVisibleTools() {
    return _tools.any((tool) => tool.isVisible);
  }

  Widget _buildResponsiveActions(BuildContext context, AppLocalizations l10n,
      ThemeData theme, bool isDesktop) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Lower breakpoint for better mobile experience
    final isWideEnough = screenWidth >= 480;

    if (isWideEnough) {
      // Horizontal layout for wider screens
      return Row(
        children: [
          TextButton.icon(
            onPressed: _resetToDefault,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.resetToDefault),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _hasChanges && _hasVisibleTools()
                ? () async {
                    await _saveChanges();
                    if (!mounted) return;
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  }
                : null,
            child: Text(l10n.save),
          ),
        ],
      );
    } else {
      // Vertical layout for narrower screens
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Reset button on its own row
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _resetToDefault,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.resetToDefault),
            ),
          ),
          const SizedBox(height: 8),
          // Cancel and Save buttons in a row
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: _hasChanges && _hasVisibleTools()
                      ? () async {
                          await _saveChanges();
                          if (!mounted) return;
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: Text(l10n.save),
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 600;

    // Responsive dialog sizing with better mobile handling
    final dialogWidth = isDesktop
        ? 500.0
        : screenSize.width * 0.95; // Increased from fixed width for mobile
    final dialogMaxHeight = screenSize.height * 0.8;

    return Dialog(
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: dialogMaxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(
                  isDesktop ? 24 : 16), // Smaller padding on mobile
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: isDesktop ? 28 : 24, // Smaller icon on mobile
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: isDesktop ? 12 : 8), // Less spacing on mobile
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.manageToolVisibility,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop
                                ? null
                                : 18, // Smaller title on mobile
                          ),
                          maxLines:
                              isDesktop ? 1 : 2, // Allow wrapping on mobile
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.dragToReorder,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontSize: isDesktop
                                ? null
                                : 12, // Smaller description on mobile
                          ),
                          maxLines:
                              isDesktop ? 1 : 2, // More lines allowed on mobile
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    iconSize:
                        isDesktop ? 24 : 20, // Smaller close button on mobile
                    tooltip: l10n.close,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      children: [
                        // Tool list
                        Expanded(
                          child: ReorderableListView.builder(
                            padding: EdgeInsets.all(isDesktop
                                ? 16
                                : 12), // Smaller padding on mobile
                            itemCount: _tools.length,
                            onReorder: _reorderTools,
                            proxyDecorator: (child, index, animation) {
                              return AnimatedBuilder(
                                animation: animation,
                                builder: (context, child) {
                                  final animValue = Curves.easeInOut
                                      .transform(animation.value);
                                  return Transform.scale(
                                    scale: 1.0 + (animValue * 0.05),
                                    child: Material(
                                      elevation: 8.0 * animValue,
                                      shadowColor: theme.colorScheme.shadow
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surface,
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(
                                                    alpha: 0.6 +
                                                        (animValue * 0.4)),
                                            width: 1.5 + (animValue * 0.5),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: child,
                                      ),
                                    ),
                                  );
                                },
                                child: child,
                              );
                            },
                            itemBuilder: (context, index) {
                              final tool = _tools[index];
                              return Container(
                                key: ValueKey(tool.id),
                                margin: EdgeInsets.only(
                                    bottom: isDesktop
                                        ? 8
                                        : 6), // Smaller margin on mobile
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isDesktop
                                        ? 16
                                        : 12, // Smaller padding on mobile
                                    vertical: isDesktop
                                        ? 8
                                        : 4, // Smaller padding on mobile
                                  ),
                                  leading: CircleAvatar(
                                    radius: isDesktop
                                        ? 20
                                        : 18, // Smaller avatar on mobile
                                    backgroundColor: tool.iconColorData
                                        .withValues(alpha: 0.1),
                                    child: Icon(
                                      tool.iconData,
                                      color: tool.iconColorData,
                                      size: isDesktop
                                          ? 20
                                          : 18, // Smaller icon on mobile
                                    ),
                                  ),
                                  title: Text(
                                    tool.getLocalizedName(context),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isDesktop
                                          ? null
                                          : 14, // Smaller title on mobile
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Transform.scale(
                                        scale: isDesktop
                                            ? 1.0
                                            : 0.8, // Smaller switch on mobile
                                        child: Switch(
                                          value: tool.isVisible,
                                          onChanged: (_) =>
                                              _toggleVisibility(index),
                                        ),
                                      ),
                                      SizedBox(
                                          width: isDesktop
                                              ? 8
                                              : 4), // Less spacing on mobile
                                      Icon(
                                        Icons.drag_handle,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
                                        size: isDesktop
                                            ? 24
                                            : 20, // Smaller drag handle on mobile
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Warning if no tools visible
                        if (!_hasVisibleTools())
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: isDesktop
                                    ? 16
                                    : 12), // Smaller margin on mobile
                            padding: EdgeInsets.all(isDesktop
                                ? 16
                                : 12), // Smaller padding on mobile
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.error
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: theme.colorScheme.error,
                                  size: isDesktop
                                      ? 20
                                      : 18, // Smaller icon on mobile
                                ),
                                SizedBox(
                                    width: isDesktop
                                        ? 12
                                        : 8), // Less spacing on mobile
                                Expanded(
                                  child: Text(
                                    l10n.enableAtLeastOneTool,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                      fontSize: isDesktop
                                          ? null
                                          : 13, // Smaller text on mobile
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),

            // Bottom actions
            Container(
              padding: EdgeInsets.all(
                  isDesktop ? 16 : 12), // Smaller padding on mobile
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: _buildResponsiveActions(context, l10n, theme, isDesktop),
            ),
          ],
        ),
      ),
    );
  }
}
