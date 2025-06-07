import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/services/tool_visibility_service.dart';

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

    // Note: No longer showing SnackBar here as it's handled in the UI action
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'description':
        return Icons.description;
      case 'casino':
        return Icons.casino;
      default:
        return Icons.extension;
    }
  }

  Color _getIconColor(String colorName) {
    switch (colorName) {
      case 'blue800':
        return Colors.blue.shade800;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getLocalizedName(BuildContext context, String nameKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (nameKey) {
      case 'textTemplateGen':
        return l10n.textTemplateGen;
      case 'random':
        return l10n.random;
      default:
        return nameKey;
    }
  }

  bool _hasVisibleTools() {
    return _tools.any((tool) => tool.isVisible);
  }

  Widget _buildResponsiveActions(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 600;
    
    // Check if we have enough space for horizontal layout
    final hasEnoughWidth = screenWidth >= 500;
    
    if (hasEnoughWidth) {
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
                    // For desktop mode, don't close dialog immediately
                    // Show a success message instead
                    if (isDesktop && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.toolVisibilityChanged),
                          backgroundColor: theme.colorScheme.primary,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (mounted) {
                      Navigator.of(context).pop();
                    }
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
                          // For desktop mode, don't close dialog immediately
                          if (isDesktop && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.toolVisibilityChanged),
                                backgroundColor: theme.colorScheme.primary,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } else if (mounted) {
                            Navigator.of(context).pop();
                          }
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
    
    // Responsive dialog sizing
    final dialogWidth = isDesktop ? 
        (screenSize.width * 0.4).clamp(450.0, 600.0) : 
        screenSize.width * 0.9;
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
              padding: const EdgeInsets.all(24),
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
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.manageToolVisibility,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.dragToReorder,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
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
                            padding: const EdgeInsets.all(16),
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
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  border: Border.all(
                                    color: theme.colorScheme.outline
                                        .withValues(alpha: 0.3),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _getIconColor(tool.iconColor)
                                            .withValues(alpha: 0.1),
                                    child: Icon(
                                      _getIconData(tool.icon),
                                      color: _getIconColor(tool.iconColor),
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    _getLocalizedName(context, tool.nameKey),
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Switch(
                                        value: tool.isVisible,
                                        onChanged: (_) =>
                                            _toggleVisibility(index),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.drag_handle,
                                        color: theme.colorScheme.onSurface
                                            .withValues(alpha: 0.4),
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
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
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
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.enableAtLeastOneTool,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),            // Bottom actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: _buildResponsiveActions(context, l10n, theme),
            ),
          ],
        ),
      ),
    );
  }
}
