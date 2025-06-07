import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/models/tool_config.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 600;

    // Responsive dialog sizing with better mobile handling
    final dialogWidth = isDesktop
        ? (screenSize.width * 0.4).clamp(450.0, 600.0)
        : screenSize.width * 0.95; // Increased from 0.9 to 0.95 for more space
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
                    Icons.flash_on,
                    size: isDesktop ? 28 : 24, // Smaller icon on mobile
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: isDesktop ? 12 : 8), // Less spacing on mobile
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.manageQuickActions,
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
                          // Show appropriate description based on platform
                          (Platform.isAndroid || Platform.isIOS)
                              ? l10n.quickActionsEnableDescMobile
                              : l10n.quickActionsDialogDesc,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                            fontSize: isDesktop
                                ? null
                                : 12, // Smaller description on mobile
                          ),
                          maxLines:
                              isDesktop ? 2 : 3, // More lines allowed on mobile
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
                        // Info section
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(
                              isDesktop ? 16 : 12), // Smaller margin on mobile
                          padding: EdgeInsets.all(
                              isDesktop ? 16 : 12), // Smaller padding on mobile
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
                                    size: isDesktop
                                        ? 20
                                        : 18, // Smaller icon on mobile
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    // Add Expanded to prevent overflow
                                    child: Text(
                                      l10n.quickActionsInfo,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: isDesktop
                                            ? null
                                            : 13, // Smaller text on mobile
                                      ),
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
                        ), // Selected count
                        Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: isDesktop
                                  ? 16
                                  : 12), // Smaller margin on mobile
                          child: Row(
                            children: [
                              Icon(
                                Icons.flash_on,
                                size: isDesktop
                                    ? 16
                                    : 14, // Smaller icon on mobile
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                // Add Expanded to prevent overflow
                                child: Text(
                                  l10n.selectedCount(
                                      _enabledQuickActions.length,
                                      QuickActionsService.maxQuickActions),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    fontSize: isDesktop
                                        ? null
                                        : 13, // Smaller text on mobile
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height: isDesktop
                                ? 16
                                : 12), // Smaller spacing on mobile

                        // Tool list
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: isDesktop
                                    ? 16
                                    : 12), // Smaller padding on mobile
                            itemCount: _allTools.length,
                            itemBuilder: (context, index) {
                              final tool = _allTools[index];
                              final isEnabled = _isQuickActionEnabled(tool.id);
                              return Container(
                                margin: EdgeInsets.only(
                                    bottom: isDesktop
                                        ? 8
                                        : 6), // Smaller margin on mobile
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
                                  subtitle: Text(
                                    tool.getLocalizedDesc(context),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                      fontSize: isDesktop
                                          ? null
                                          : 11, // Smaller subtitle on mobile
                                    ),
                                    maxLines: isDesktop
                                        ? 2
                                        : 1, // Less lines on mobile
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: Transform.scale(
                                    scale: isDesktop
                                        ? 1.0
                                        : 0.8, // Smaller switch on mobile
                                    child: Switch(
                                      value: isEnabled,
                                      onChanged: (value) =>
                                          _toggleQuickAction(tool),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ), // Bottom actions
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
    // Lower breakpoint for better mobile experience
    final isWideEnough = screenWidth >= 480;

    if (isWideEnough) {
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
            label: Text(l10n.clearAllQuickActions),
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

                    if (isWideEnough) {
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
          if (_enabledQuickActions.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _enabledQuickActions.clear();
                    _hasChanges = true;
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: Text(l10n.clearAllQuickActions),
              ),
            ),
          if (_enabledQuickActions.isNotEmpty) const SizedBox(height: 8),
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
