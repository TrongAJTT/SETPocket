import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/tool_config.dart';
import 'package:setpocket/services/tool_visibility_service.dart';
import 'package:setpocket/utils/size_utils.dart';
import 'package:setpocket/widgets/generic/generic_dialog.dart';
import 'package:setpocket/utils/icon_utils.dart';

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
    if (!_hasVisibleTools()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorMinOneTool),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

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
      Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final backColor = theme.colorScheme.surface.withValues(alpha: 0.3);

    return GenericDialog(
      decorator: GenericDialogDecorator(
        width: DynamicDimension.flexibilityMax(90, 600),
        headerBackColor: backColor.withValues(alpha: 0.5),
        bodyBackColor: backColor,
        footerBackColor: backColor,
        footerPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        displayTopDivider: true,
        displayBottomDivider: true,
      ),
      header: GenericDialogHeader(
        icon: GenericIcon.icon(Icons.tune,
            color: Theme.of(context).colorScheme.primary),
        title: l10n.manageToolVisibility,
        subtitle: l10n.dragToReorder,
        displayExitButton: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildReorderableList(l10n),
      footer: GenericDialogFooter.defaultCancelSave(
        onReset: _resetToDefault,
        onCancel: () => Navigator.of(context).pop(),
        onSave: _hasChanges ? _saveChanges : () {},
        saveText: l10n.save,
      ),
    );
  }

  Widget _buildReorderableList(AppLocalizations l10n) {
    final theme = Theme.of(context);

    return ReorderableListView.builder(
      padding: EdgeInsets.zero, // Remove padding to align with dialog edges
      itemCount: _tools.length,
      onReorder: _reorderTools,
      buildDefaultDragHandles: false, // Disable default handles
      proxyDecorator: (Widget child, int index, Animation<double> animation) {
        return Material(
          type: MaterialType.card,
          elevation: 8.0,
          borderRadius: BorderRadius.circular(12),
          shadowColor: Colors.black.withValues(alpha: 0.5),
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final tool = _tools[index];
        return ListTile(
          key: ValueKey(tool.id),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: tool.iconColorData.withValues(alpha: 0.1),
            child: Icon(
              tool.iconData,
              color: tool.iconColorData,
              size: 20,
            ),
          ),
          title: Text(tool.getLocalizedName(context)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch(
                value: tool.isVisible,
                onChanged: (value) => _toggleVisibility(index),
              ),
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.drag_handle),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
