import 'package:flutter/material.dart';
import 'package:my_multi_tools/services/app_logger.dart';
import '../l10n/app_localizations.dart';
import '../services/currency_preset_service.dart';
import '../models/currency_preset_model.dart';
import 'package:intl/intl.dart';

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
  final String? presetKey; // Optional key for saving/loading presets on hive

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
        await CurrencyPresetService.savePreset(
          name: result,
          currencies: _tempVisible.toList(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.presetSaved(result)),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        AppLogger.instance.logError(e.toString(), e, StackTrace.current);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorSavingPreset(e.toString())),
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
      final presets = await CurrencyPresetService.loadPresets();

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
            content: Text(AppLocalizations.of(context)!
                .errorLoadingPresets(e.toString())),
          ),
        );
      }
      AppLogger.instance.logError(e.toString(), e, StackTrace.current);
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

                // Search bar and Select/Deselect All buttons
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
                                  const canUnselect =
                                      true; // Always allow deselection to 0
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
  final List<CurrencyPresetModel> presets;

  const _LoadPresetDialog({required this.presets});

  @override
  State<_LoadPresetDialog> createState() => _LoadPresetDialogState();
}

class _LoadPresetDialogState extends State<_LoadPresetDialog> {
  List<CurrencyPresetModel> _presets = [];
  bool _isLoading = true;
  PresetSortOrder _sortOrder = PresetSortOrder.date;
  CurrencyPresetModel? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _presets = widget.presets;
    _sortPresets();
    setState(() => _isLoading = false);
  }

  void _sortPresets() {
    switch (_sortOrder) {
      case PresetSortOrder.name:
        _presets.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case PresetSortOrder.date:
        _presets
            .sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
        break;
    }
  }

  Future<void> _loadPresets() async {
    setState(() => _isLoading = true);
    try {
      final presets =
          await CurrencyPresetService.loadPresets(sortOrder: _sortOrder);
      setState(() {
        _presets = presets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      AppLogger.instance.logError(e.toString(), e, StackTrace.current);
    }
  }

  Future<void> _renamePreset(CurrencyPresetModel preset) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: preset.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renamePreset),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.presetName,
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
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.of(context).pop(name);
              }
            },
            child: Text(l10n.rename),
          ),
        ],
      ),
    );

    if (newName != null && newName != preset.name) {
      try {
        await CurrencyPresetService.updatePreset(preset.id, name: newName);
        _loadPresets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.presetRenamedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        AppLogger.instance.logError(e.toString(), e, StackTrace.current);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.errorLabel} $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deletePreset(CurrencyPresetModel preset) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePresetTitle),
        content: Text(l10n.deletePresetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.deletePresetAction),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CurrencyPresetService.deletePreset(preset.id);
        _loadPresets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.presetDeletedSuccess),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.errorLabel} $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        AppLogger.instance.logError(e.toString(), e, StackTrace.current);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 800;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 20,
        vertical: isDesktop ? 60 : 40,
      ),
      child: Container(
        width: isDesktop ? 600 : screenSize.width * 0.9,
        height: isDesktop ? 700 : screenSize.height * 0.8,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.onPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder_open_rounded,
                      color: theme.colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.loadPreset,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.chooseFromSavedPresets,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sort options
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.sortByLabel,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PresetSortOrder>(
                          value: _sortOrder,
                          isDense: true,
                          items: [
                            DropdownMenuItem(
                              value: PresetSortOrder.date,
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16),
                                  const SizedBox(width: 8),
                                  Text(l10n.sortByDate),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: PresetSortOrder.name,
                              child: Row(
                                children: [
                                  const Icon(Icons.sort_by_alpha, size: 16),
                                  const SizedBox(width: 8),
                                  Text(l10n.sortByName),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _sortOrder = value);
                              _sortPresets();
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Presets list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _presets.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.folder_off,
                                size: 64,
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
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: _presets.length,
                          itemBuilder: (context, index) {
                            final preset = _presets[index];
                            final isSelected = _selectedPreset?.id == preset.id;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primaryContainer
                                        .withValues(alpha: 0.3)
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline
                                          .withValues(alpha: 0.12),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                            .withValues(alpha: 0.15)
                                        : Colors.black.withValues(alpha: 0.05),
                                    blurRadius: isSelected ? 12 : 8,
                                    offset: Offset(0, isSelected ? 4 : 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    setState(() {
                                      _selectedPreset =
                                          _selectedPreset?.id == preset.id
                                              ? null
                                              : preset;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        // Preset icon
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.colorScheme
                                                    .primaryContainer,
                                                theme.colorScheme
                                                    .primaryContainer
                                                    .withValues(alpha: 0.7),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Center(
                                            child: Text(
                                              preset.name
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: theme.textTheme.titleLarge
                                                  ?.copyWith(
                                                color: theme.colorScheme
                                                    .onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Preset info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                preset.name,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .account_balance_wallet_outlined,
                                                    size: 16,
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    l10n.currenciesCount(preset
                                                        .currencies.length),
                                                    style: theme
                                                        .textTheme.bodyMedium
                                                        ?.copyWith(
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.schedule_rounded,
                                                    size: 16,
                                                    color: theme.colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    l10n.createdDate(DateFormat(
                                                            'MM/dd/yyyy')
                                                        .format(
                                                            preset.createdAt)),
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: theme.colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Actions
                                        isDesktop
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _renamePreset(preset),
                                                    icon: const Icon(Icons.edit,
                                                        size: 16),
                                                    label: Text(
                                                      l10n.rename,
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  OutlinedButton.icon(
                                                    onPressed: () =>
                                                        _deletePreset(preset),
                                                    icon: const Icon(
                                                        Icons
                                                            .delete_outline_rounded,
                                                        size: 16),
                                                    label: Text(
                                                      l10n.delete,
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    style: OutlinedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                      side: BorderSide(
                                                          color: Colors.red
                                                              .withValues(
                                                                  alpha: 0.5)),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 8,
                                                        vertical: 6,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : PopupMenuButton<String>(
                                                icon: const Icon(
                                                    Icons.more_vert,
                                                    size: 20),
                                                onSelected: (value) {
                                                  if (value == 'rename') {
                                                    _renamePreset(preset);
                                                  } else if (value ==
                                                      'delete') {
                                                    _deletePreset(preset);
                                                  }
                                                },
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    value: 'rename',
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.edit,
                                                            size: 16),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(l10n.rename),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                            Icons
                                                                .delete_outline,
                                                            size: 16,
                                                            color: Colors.red),
                                                        const SizedBox(
                                                            width: 8),
                                                        Text(l10n.delete,
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .red)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
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

            // Footer with Select button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _selectedPreset != null
                          ? () => Navigator.of(context)
                              .pop(_selectedPreset!.currencies)
                          : null,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(l10n.select),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
