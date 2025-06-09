import 'package:flutter/material.dart';
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
              ? 'No units selected'
              : 'Maximum selection exceeded'),
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
              content: Text('Preset saved: $result'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
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
      final presets = await CurrencyPresetService.loadPresets();

      if (presets.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No presets found'),
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
              content: Text('Preset loaded'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading presets: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
                  color: Colors.black.withOpacity(0.15),
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
                        theme.colorScheme.primary.withOpacity(0.8),
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
                          color: theme.colorScheme.onPrimary.withOpacity(0.1),
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
                          fillColor:
                              theme.colorScheme.surfaceVariant.withOpacity(0.5),
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

                        return GridView.builder(
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
                            final isSelected = _tempVisible.contains(unit.id);
                            final canUnselect = true;
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
                                          .withOpacity(0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.2),
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
                                  onTap: (isSelected ? canUnselect : canSelect)
                                      ? () {
                                          setState(() {
                                            if (isSelected) {
                                              _tempVisible.remove(unit.id);
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
                                                ? theme.colorScheme.primary
                                                : theme
                                                    .colorScheme.surfaceVariant,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Center(
                                            child: Text(
                                              unit.symbol,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? theme
                                                        .colorScheme.onPrimary
                                                    : theme.colorScheme
                                                        .onSurfaceVariant,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                                                  fontWeight: FontWeight.bold,
                                                  color: isSelected
                                                      ? theme.colorScheme
                                                          .onPrimaryContainer
                                                      : theme.colorScheme
                                                          .onSurface,
                                                ),
                                              ),
                                              Text(
                                                unit.name,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  color: isSelected
                                                      ? theme.colorScheme
                                                          .onPrimaryContainer
                                                          .withOpacity(0.8)
                                                      : theme.colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Checkbox
                                        AnimatedScale(
                                          scale: isSelected ? 1.0 : 0.8,
                                          duration:
                                              const Duration(milliseconds: 200),
                                          child: Icon(
                                            isSelected
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.outline,
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
                        );
                      },
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
                                  : theme.colorScheme.primary)
                              .withOpacity(0.1),
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
                                    : theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_tempVisible.length > widget.maxSelection) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Maximum selection exceeded',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.red,
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
      title: Text(l10n.savePresetDialog),
      content: TextField(
        controller: _nameController,
        decoration: InputDecoration(
          labelText: l10n.presetName,
          hintText: l10n.enterPresetName,
          border: OutlineInputBorder(),
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_open, color: theme.colorScheme.onPrimary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.loadPresetDialog,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: theme.colorScheme.onPrimary),
                  ),
                ],
              ),
            ),

            // Sort options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(l10n.sortByLabel),
                  DropdownButton<PresetSortOrder>(
                    value: _sortOrder,
                    items: [
                      DropdownMenuItem(
                        value: PresetSortOrder.date,
                        child: Text(l10n.sortByDate),
                      ),
                      DropdownMenuItem(
                        value: PresetSortOrder.name,
                        child: Text(l10n.sortByName),
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _presets.length,
                          itemBuilder: (context, index) {
                            final preset = _presets[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: Text(preset.name
                                      .substring(0, 1)
                                      .toUpperCase()),
                                ),
                                title: Text(preset.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.currenciesCount(
                                        preset.currencies.length)),
                                    Text(
                                      l10n.createdDate(DateFormat('MM/dd/yyyy')
                                          .format(preset.createdAt)),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context)
                                          .pop(preset.currencies),
                                      child: Text(l10n.selectPreset),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _deletePreset(preset),
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Close button
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
