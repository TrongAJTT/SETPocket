import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/services/quick_actions_service.dart';
import 'package:my_multi_tools/services/tool_visibility_service.dart';

class QuickActionsDialog extends StatefulWidget {
  final VoidCallback? onChanged;

  const QuickActionsDialog({super.key, this.onChanged});

  @override
  State<QuickActionsDialog> createState() => _QuickActionsDialogState();
}

class _QuickActionsDialogState extends State<QuickActionsDialog> {
  List<ToolConfig> _allTools = [];
  List<ToolConfig> _enabledQuickActions = [];
  bool _loading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allTools = await ToolVisibilityService.getVisibleToolsInOrder();
    final enabledActions = await QuickActionsService.getEnabledQuickActions();

    setState(() {
      _allTools = allTools;
      _enabledQuickActions = enabledActions;
      _loading = false;
    });
  }

  Future<void> _saveChanges() async {
    await QuickActionsService.saveEnabledQuickActions(_enabledQuickActions);
    setState(() {
      _hasChanges = false;
    });
    widget.onChanged?.call();
  }

  void _toggleQuickAction(ToolConfig tool) {
    setState(() {
      final isCurrentlyEnabled =
          _enabledQuickActions.any((t) => t.id == tool.id);

      if (isCurrentlyEnabled) {
        // Remove from enabled list
        _enabledQuickActions.removeWhere((t) => t.id == tool.id);
      } else {
        // Add to enabled list if under limit
        if (_enabledQuickActions.length < QuickActionsService.maxQuickActions) {
          _enabledQuickActions.add(tool);
        } else {
          // Show warning about limit
          _showLimitWarning();
          return;
        }
      }
      _hasChanges = true;
    });
  }

  void _showLimitWarning() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.maxQuickActionsReached),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  bool _isQuickActionEnabled(String toolId) {
    return _enabledQuickActions.any((tool) => tool.id == toolId);
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

  String _getLocalizedDesc(BuildContext context, String descKey) {
    final l10n = AppLocalizations.of(context)!;
    switch (descKey) {
      case 'textTemplateGenDesc':
        return l10n.textTemplateGenDesc;
      case 'randomDesc':
        return l10n.randomDesc;
      default:
        return descKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 600;

    // Responsive dialog sizing
    final dialogWidth = isDesktop
        ? (screenSize.width * 0.4).clamp(450.0, 600.0)
        : screenSize.width * 0.9;
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
                    Icons.flash_on,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.manageQuickActions,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),                        const SizedBox(height: 4),
                        Text(
                          // Show appropriate description based on platform
                          (Platform.isAndroid || Platform.isIOS) 
                            ? l10n.quickActionsEnableDescMobile
                            : l10n.quickActionsDialogDesc,
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
                        // Info section
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 20,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.quickActionsInfo,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.selectUpTo4Tools,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.quickActionsEnableDesc,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Selected count
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flash_on,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.selectedCount(_enabledQuickActions.length,
                                    QuickActionsService.maxQuickActions),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Tool list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _allTools.length,
                            itemBuilder: (context, index) {
                              final tool = _allTools[index];
                              final isEnabled = _isQuickActionEnabled(tool.id);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  border: Border.all(
                                    color: isEnabled
                                        ? theme.colorScheme.primary
                                            .withValues(alpha: 0.5)
                                        : theme.colorScheme.outline
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
                                  subtitle: Text(
                                    _getLocalizedDesc(context, tool.descKey),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  trailing: Switch(
                                    value: isEnabled,
                                    onChanged: (value) =>
                                        _toggleQuickAction(tool),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),

            // Bottom actions
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

  Widget _buildResponsiveActions(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 600;

    if (isDesktop) {
      // Horizontal layout for wider screens
      return Row(
        children: [
          // Clear all button
          TextButton.icon(
            onPressed: _enabledQuickActions.isNotEmpty
                ? () {
                    setState(() {
                      _enabledQuickActions.clear();
                      _hasChanges = true;
                    });
                  }
                : null,
            icon: const Icon(Icons.clear_all),
            label: Text(l10n.clearAll),
          ),
          const Spacer(),
          // Cancel button
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          const SizedBox(width: 8),
          // Save button
          FilledButton(
            onPressed: _hasChanges
                ? () async {
                    await _saveChanges();

                    if (!mounted) return;

                    if (isDesktop) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.quickActionsUpdated),
                          backgroundColor: theme.colorScheme.primary,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      // ignore: use_build_context_synchronously
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
          // Clear all button on its own row
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _enabledQuickActions.isNotEmpty
                  ? () {
                      setState(() {
                        _enabledQuickActions.clear();
                        _hasChanges = true;
                      });
                    }
                  : null,
              icon: const Icon(Icons.clear_all),
              label: Text(l10n.clearAll),
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
                  onPressed: _hasChanges
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
}
