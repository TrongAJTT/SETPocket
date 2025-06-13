import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/converter_models/generic_preset_model.dart';
import '../../services/converter_services/generic_preset_service.dart';
import '../../services/app_logger.dart';

// Generic Unit Item (replaces UnitItem and LengthUnitItem)
class GenericUnitItem {
  final String id;
  final String name;
  final String symbol;
  final String? description;

  const GenericUnitItem({
    required this.id,
    required this.name,
    required this.symbol,
    this.description,
  });
}

class EnhancedGenericUnitCustomizationDialog extends StatefulWidget {
  final String title;
  final List<GenericUnitItem> availableUnits;
  final Set<String> visibleUnits;
  final void Function(Set<String>) onChanged;
  final int maxSelection;
  final int minSelection;
  final bool showPresetOptions;
  final String presetType; // 'currency', 'length', 'weight', etc.

  const EnhancedGenericUnitCustomizationDialog({
    super.key,
    required this.title,
    required this.availableUnits,
    required this.visibleUnits,
    required this.onChanged,
    this.maxSelection = 10,
    this.minSelection = 2,
    this.showPresetOptions = true,
    required this.presetType,
  });

  @override
  State<EnhancedGenericUnitCustomizationDialog> createState() =>
      _EnhancedGenericUnitCustomizationDialogState();
}

class _EnhancedGenericUnitCustomizationDialogState
    extends State<EnhancedGenericUnitCustomizationDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Set<String> _tempVisible;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _tempVisible = Set.from(widget.visibleUnits);
    _controller.forward();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<GenericUnitItem> get _filteredUnits {
    if (_searchQuery.isEmpty) return widget.availableUnits;

    return widget.availableUnits.where((unit) {
      final query = _searchQuery.toLowerCase();
      return unit.name.toLowerCase().contains(query) ||
          unit.symbol.toLowerCase().contains(query) ||
          (unit.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  Future<void> _showSavePresetDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _SavePresetDialog(),
    );

    if (name != null && mounted) {
      try {
        await GenericPresetService.savePreset(
          presetType: widget.presetType,
          name: name,
          units: _tempVisible.toList(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Preset saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        logError('Error saving ${widget.presetType} preset: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving preset: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showLoadPresetDialog() async {
    try {
      final presets = await GenericPresetService.loadPresets(widget.presetType);

      if (mounted) {
        final result = await showDialog<Map<String, dynamic>>(
          context: context,
          builder: (context) => _LoadPresetDialog(
            presets: presets,
            presetType: widget.presetType,
          ),
        );

        if (result != null && mounted) {
          final action = result['action'] as String;
          final units = result['units'] as List<String>?;

          if (action == 'load' && units != null) {
            setState(() {
              _tempVisible = units.toSet();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Preset loaded successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      logError('Error loading ${widget.presetType} presets: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading presets: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTabletScreen = screenSize.width > 700;
    final isDesktopScreen = screenSize.width > 1400;
    final l10n = AppLocalizations.of(context)!;

    final dialogWidth =
        isTabletScreen ? screenSize.width * 0.6 : screenSize.width * 0.9;
    final dialogHeight = screenSize.height * 0.75;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isTabletScreen ? 80 : 16,
          vertical: isTabletScreen ? 60 : 40,
        ),
        child: SizedBox(
          width: dialogWidth,
          height: dialogHeight,
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune,
                        color: theme.colorScheme.onPrimary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onPrimary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search bar and preset buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                      ),
                      if (widget.showPresetOptions) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showSavePresetDialog(),
                                icon: const Icon(Icons.save, size: 18),
                                label: Text(l10n.savePreset),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showLoadPresetDialog(),
                                icon: const Icon(Icons.folder_open, size: 18),
                                label: Text(l10n.loadPreset),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Unit selection
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = isTabletScreen
                            ? isDesktopScreen
                                ? 3
                                : 2
                            : 1;

                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisExtent: 70,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _filteredUnits.length,
                          itemBuilder: (context, index) {
                            final unit = _filteredUnits[index];
                            final isSelected = _tempVisible.contains(unit.id);

                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline
                                          .withValues(alpha: 0.2),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withValues(alpha: 0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _tempVisible.remove(unit.id);
                                      } else if (_tempVisible.length <
                                          widget.maxSelection) {
                                        _tempVisible.add(unit.id);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? theme.colorScheme.primary
                                                  : theme.colorScheme.outline,
                                              width: 2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: isSelected
                                              ? Icon(
                                                  Icons.check,
                                                  size: 14,
                                                  color: theme
                                                      .colorScheme.onPrimary,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                unit.symbol,
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? theme.colorScheme
                                                          .onPrimaryContainer
                                                      : theme.colorScheme
                                                          .onSurface,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                unit.name,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: isSelected
                                                      ? theme.colorScheme
                                                          .onPrimaryContainer
                                                          .withValues(
                                                              alpha: 0.8)
                                                      : theme
                                                          .colorScheme.onSurface
                                                          .withValues(
                                                              alpha: 0.7),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Selection status
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (_tempVisible.length > widget.maxSelection
                                  ? Colors.red
                                  : (_tempVisible.length < widget.minSelection)
                                      ? Colors.orange
                                      : theme.colorScheme.primary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n.unitSelectedStatus(
                                _tempVisible.length,
                                widget.maxSelection,
                              ),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _tempVisible.length > widget.maxSelection
                                    ? Colors.red
                                    : (_tempVisible.length <
                                            widget.minSelection)
                                        ? Colors.orange
                                        : theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_tempVisible.length >= widget.maxSelection) ...[
                              const SizedBox(height: 4),
                              Text(
                                l10n.maximumSelectionReached,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            if (_tempVisible.length < widget.minSelection) ...[
                              const SizedBox(height: 4),
                              Text(
                                l10n.minimumSelectionRequired(
                                    widget.minSelection),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.orange,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(l10n.cancel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _tempVisible.length >=
                                          widget.minSelection &&
                                      _tempVisible.length <= widget.maxSelection
                                  ? () {
                                      widget.onChanged(_tempVisible);
                                      Navigator.of(context).pop();
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(l10n.applyChanges),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavePresetDialog extends StatefulWidget {
  @override
  State<_SavePresetDialog> createState() => _SavePresetDialogState();
}

class _SavePresetDialogState extends State<_SavePresetDialog> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.savePreset),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: l10n.presetName,
          hintText: l10n.enterPresetName,
          border: const OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isNotEmpty) {
              Navigator.of(context).pop(name);
            }
          },
          child: Text(l10n.savePreset),
        ),
      ],
    );
  }
}

class _LoadPresetDialog extends StatefulWidget {
  final List<GenericPresetModel> presets;
  final String presetType;

  const _LoadPresetDialog({
    required this.presets,
    required this.presetType,
  });

  @override
  State<_LoadPresetDialog> createState() => _LoadPresetDialogState();
}

class _LoadPresetDialogState extends State<_LoadPresetDialog> {
  GenericPresetModel? _selectedPreset;
  late List<GenericPresetModel> _presets;

  @override
  void initState() {
    super.initState();
    _presets = List.from(widget.presets);
  }

  Future<void> _showRenameDialog(GenericPresetModel preset) async {
    final nameController = TextEditingController(text: preset.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Preset'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Preset Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty && name != preset.name) {
                Navigator.of(context).pop(name);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null && mounted) {
      try {
        await GenericPresetService.renamePreset(
          widget.presetType,
          preset.id,
          newName,
        );

        // Refresh presets list
        final updatedPresets =
            await GenericPresetService.loadPresets(widget.presetType);
        setState(() {
          _presets = updatedPresets;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Preset renamed to "$newName"'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        logError('Error renaming preset: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error renaming preset: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showDeleteDialog(GenericPresetModel preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Are you sure you want to delete "${preset.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await GenericPresetService.deletePreset(widget.presetType, preset.id);

        // Refresh presets list
        final updatedPresets =
            await GenericPresetService.loadPresets(widget.presetType);
        setState(() {
          _presets = updatedPresets;
          if (_selectedPreset?.id == preset.id) {
            _selectedPreset = null;
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Preset "${preset.name}" deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        logError('Error deleting preset: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting preset: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              l10n.loadPreset,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _presets.isEmpty
                  ? Center(
                      child: Text(
                        'No presets available',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _presets.length,
                      itemBuilder: (context, index) {
                        final preset = _presets[index];
                        final isSelected = _selectedPreset?.id == preset.id;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.2),
                            ),
                          ),
                          child: ListTile(
                            title: Text(preset.name),
                            subtitle: Text(
                              '${preset.units.length} units • ${DateFormat('MM/dd/yyyy').format(preset.createdAt)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showRenameDialog(preset),
                                  tooltip: 'Rename preset',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _showDeleteDialog(preset),
                                  tooltip: 'Delete preset',
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _selectedPreset =
                                    _selectedPreset?.id == preset.id
                                        ? null
                                        : preset;
                              });
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedPreset != null
                        ? () => Navigator.of(context).pop({
                              'action': 'load',
                              'units': _selectedPreset!.units,
                            })
                        : null,
                    child: Text(l10n.select),
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
