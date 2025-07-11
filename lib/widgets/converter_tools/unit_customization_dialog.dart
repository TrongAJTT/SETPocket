import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/services/converter_services/currency_unified_service.dart';
import 'package:setpocket/services/app_logger.dart';

class UnitItem {
  final String id;
  final String name;
  final String symbol;
  final Map<String, dynamic>? metadata;

  const UnitItem({
    required this.id,
    required this.name,
    required this.symbol,
    this.metadata,
  });
}

class UnitCustomizationDialog extends StatefulWidget {
  final String title;
  final List<UnitItem> availableUnits;
  final Set<String> visibleUnits;
  final Function(Set<String>) onChanged;
  final int maxSelection;
  final int minSelection;
  final bool showPresetOptions;
  final String? presetKey;

  const UnitCustomizationDialog({
    super.key,
    required this.title,
    required this.availableUnits,
    required this.visibleUnits,
    required this.onChanged,
    this.maxSelection = 10,
    this.minSelection = 2,
    this.showPresetOptions = false,
    this.presetKey,
  });

  @override
  State<UnitCustomizationDialog> createState() =>
      _UnitCustomizationDialogState();
}

class _UnitCustomizationDialogState extends State<UnitCustomizationDialog>
    with TickerProviderStateMixin {
  late Set<String> _tempVisible;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tempVisible = Set.from(widget.visibleUnits);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<UnitItem> get _filteredUnits {
    if (_searchQuery.isEmpty) {
      return widget.availableUnits;
    }

    return widget.availableUnits.where((unit) {
      return unit.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          unit.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          unit.id.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // Show save preset dialog
  void _showSavePresetDialog() async {
    if (!widget.showPresetOptions) {
      return;
    }

    if (_tempVisible.isEmpty || _tempVisible.length > widget.maxSelection) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_tempVisible.isEmpty
              ? AppLocalizations.of(context)!.noUnitsSelected
              : AppLocalizations.of(context)!.maximumSelectionExceeded),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => _SavePresetDialog(),
    );

    if (result != null && result.isNotEmpty) {
      try {
        // Only work for currency converters for now
        await CurrencyUnifiedService.savePreset(
          name: result,
          units: _tempVisible.toList(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.presetSaved),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        AppLogger.instance.logError(e.toString(), e, StackTrace.current);
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

  // Show load preset dialog
  void _showLoadPresetDialog() async {
    if (!widget.showPresetOptions) {
      return;
    }

    try {
      final presets = await CurrencyUnifiedService.loadPresets();

      if (!mounted) {
        return;
      }

      if (presets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noPresetsFound),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final result = await showDialog<List<String>>(
        context: context,
        builder: (context) => _LoadPresetDialog(presets: presets),
      );

      if (result != null) {
        setState(() {
          _tempVisible.clear();
          _tempVisible.addAll(result);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.presetLoaded),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.instance.logError(e.toString(), e, StackTrace.current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading presets: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTableScreen = screenSize.width > 700;
    final isDesktopScreen = screenSize.width > 1400;
    final l10n = AppLocalizations.of(context)!;

    final dialogWidth =
        isTableScreen ? screenSize.width * 0.6 : screenSize.width * 0.9;
    final dialogHeight = screenSize.height * 0.75;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: isTableScreen ? 80 : 16,
          vertical: isTableScreen ? 60 : 40,
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

                // Search bar with integrated preset buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Search field
                      Expanded(
                        child: TextField(
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
                      ),
                      // Preset action buttons
                      if (widget.showPresetOptions) ...[
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => _showSavePresetDialog(),
                            icon: const Icon(Icons.bookmark_add),
                            tooltip: l10n.savePreset,
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              minimumSize: const Size(48, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () => _showLoadPresetDialog(),
                            icon: const Icon(Icons.folder_open),
                            tooltip: l10n.loadPreset,
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              minimumSize: const Size(48, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
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
                        final crossAxisCount = isTableScreen
                            ? isDesktopScreen
                                ? 3
                                : 2
                            : 1;
                        final filteredUnits = _filteredUnits;

                        if (filteredUnits.isEmpty) {
                          return Container(
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.noPresetsFound,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Unit grid
                            Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisExtent: 70,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: filteredUnits.length,
                                itemBuilder: (context, index) {
                                  final unit = filteredUnits[index];
                                  final isSelected =
                                      _tempVisible.contains(unit.id);
                                  const canUnselect = true;
                                  final canSelect = !isSelected &&
                                      _tempVisible.length < widget.maxSelection;

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primaryContainer
                                          : theme.colorScheme.surface,
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.outline
                                                .withValues(alpha: 0.3),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
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
                                        onTap: (isSelected
                                                ? canUnselect
                                                : canSelect)
                                            ? () {
                                                setState(() {
                                                  if (isSelected) {
                                                    _tempVisible
                                                        .remove(unit.id);
                                                  } else {
                                                    _tempVisible.add(unit.id);
                                                  }
                                                });
                                              }
                                            : null,
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              // Unit symbol
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? theme
                                                          .colorScheme.primary
                                                      : theme.colorScheme
                                                          .surfaceContainerHighest,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    unit.symbol,
                                                    style: TextStyle(
                                                      color: isSelected
                                                          ? theme.colorScheme
                                                              .onPrimary
                                                          : theme.colorScheme
                                                              .onSurfaceVariant,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              // Unit info
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      unit.id.toUpperCase(),
                                                      style: theme
                                                          .textTheme.titleSmall
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isSelected
                                                            ? theme.colorScheme
                                                                .onPrimaryContainer
                                                            : theme.colorScheme
                                                                .onSurface,
                                                      ),
                                                    ),
                                                    Text(
                                                      unit.name,
                                                      style: theme
                                                          .textTheme.bodySmall
                                                          ?.copyWith(
                                                        color: isSelected
                                                            ? theme.colorScheme
                                                                .onPrimaryContainer
                                                                .withValues(
                                                                    alpha: 0.8)
                                                            : theme.colorScheme
                                                                .onSurfaceVariant,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Checkbox
                                              AnimatedScale(
                                                scale: isSelected ? 1.0 : 0.8,
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                child: Icon(
                                                  isSelected
                                                      ? Icons.check_circle
                                                      : Icons
                                                          .radio_button_unchecked,
                                                  color: isSelected
                                                      ? theme
                                                          .colorScheme.primary
                                                      : theme
                                                          .colorScheme.outline,
                                                  size: 24,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Selected count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
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
  final List<Map<String, dynamic>> presets;

  const _LoadPresetDialog({required this.presets});

  @override
  State<_LoadPresetDialog> createState() => _LoadPresetDialogState();
}

class _LoadPresetDialogState extends State<_LoadPresetDialog> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.loadPreset),
      content: SizedBox(
        width: 300,
        height: 400,
        child: ListView.builder(
          itemCount: widget.presets.length,
          itemBuilder: (context, index) {
            final preset = widget.presets[index];
            return ListTile(
              title: Text(preset['name'] ?? ''),
              subtitle:
                  Text('${(preset['currencies'] as List?)?.length ?? 0} units'),
              onTap: () => Navigator.of(context).pop(preset['currencies']),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  try {
                    await CurrencyUnifiedService.deletePreset(
                        preset['id'] ?? '');
                    if (mounted) {
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      }
                    }
                  } catch (e) {
                    AppLogger.instance
                        .logError(e.toString(), e, StackTrace.current);
                  }
                },
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
