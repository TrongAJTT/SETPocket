import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../services/cache_service.dart';
import '../l10n/app_localizations.dart';

class CacheDetailsDialog extends StatefulWidget {
  const CacheDetailsDialog({super.key});

  @override
  State<CacheDetailsDialog> createState() => _CacheDetailsDialogState();
}

class _CacheDetailsDialogState extends State<CacheDetailsDialog> {
  Map<String, CacheInfo> _cacheInfo = {};
  bool _loading = true;
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      _loadCacheInfo();
    }
  }

  Future<void> _loadCacheInfo() async {
    setState(() => _loading = true);
    try {
      final loc = AppLocalizations.of(context)!;
      final cacheInfo = await CacheService.getAllCacheInfo(
        textTemplatesName: loc.cacheTypeTextTemplates,
        textTemplatesDesc: loc.cacheTypeTextTemplatesDesc,
        appSettingsName: loc.cacheTypeAppSettings,
        appSettingsDesc: loc.cacheTypeAppSettingsDesc,
        randomGeneratorsName: loc.cacheTypeRandomGenerators,
        randomGeneratorsDesc: loc.cacheTypeRandomGeneratorsDesc,
        converterToolsName: loc.cacheTypeConverterTools,
        converterToolsDesc: loc.cacheTypeConverterToolsDesc,
        featureStatesName: loc.cacheTypeFeatureStates,
        featureStatesDesc: loc.cacheTypeFeatureStatesDesc,
      );
      setState(() {
        _cacheInfo = cacheInfo;
        _loading = false;
      });
    } catch (e) {
      Logger().e('Error loading cache info: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _clearCache(String cacheType, String cacheName) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.clearCache),
        content: Text(loc.confirmClearCache(cacheName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(loc.clearCache),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await CacheService.clearCache(cacheType);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.cacheCleared(cacheName)),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadCacheInfo(); // Refresh the cache info
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.errorClearingCache(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearAllCache() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await _showConfirmDialog();

    if (confirmed == true) {
      try {
        await CacheService.clearAllCache();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.allCacheCleared),
              backgroundColor: Colors.green,
            ),
          );
        }
        await _loadCacheInfo(); // Refresh the cache info
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.errorClearingCache(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<bool?> _showConfirmDialog() async {
    final loc = AppLocalizations.of(context)!;
    final textController = TextEditingController();

    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(loc.clearAllCache),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(loc.confirmClearAllCache),
              const SizedBox(height: 16),
              Text(
                loc.typeConfirmToProceed,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'confirm',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(loc.cancel),
            ),
            FilledButton(
              onPressed: textController.text.toLowerCase() == 'confirm'
                  ? () => Navigator.of(context).pop(true)
                  : null,
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: Text(loc.clearAllCache),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCacheSection(String cacheType, CacheInfo info) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCacheIcon(cacheType),
                  color: _getCacheColor(cacheType),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        info.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (cacheType !=
                    'settings') // Don't allow clearing settings cache
                  IconButton(
                    onPressed: info.itemCount > 0
                        ? () => _clearCache(cacheType, info.name)
                        : null,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    tooltip: AppLocalizations.of(context)!.clearCache,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      AppLocalizations.of(context)!.cacheItems,
                      info.itemCount.toString(),
                      Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      AppLocalizations.of(context)!.cacheSize,
                      info.formattedSize,
                      Icons.storage_outlined,
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

  Widget _buildInfoChip(String label, String value, IconData icon) {
    return Container(
      constraints: const BoxConstraints(
          minHeight: 64), // Use minHeight instead of fixed height
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize:
                  MainAxisSize.min, // Allow column to shrink if needed
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCacheIcon(String cacheType) {
    switch (cacheType) {
      case 'text_templates':
        return Icons.description;
      case 'settings':
        return Icons.settings;
      case 'random_generators':
        return Icons.casino;
      case 'converter_tools':
        return Icons.swap_horiz;
      case 'feature_states':
        return Icons.save_alt;
      default:
        return Icons.storage;
    }
  }

  Color _getCacheColor(String cacheType) {
    switch (cacheType) {
      case 'text_templates':
        return Colors.blue;
      case 'settings':
        return Colors.grey;
      case 'random_generators':
        return Colors.purple;
      case 'converter_tools':
        return Colors.green;
      case 'feature_states':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final totalSize =
        _cacheInfo.values.fold(0, (sum, info) => sum + info.sizeBytes);
    final totalItems =
        _cacheInfo.values.fold(0, (sum, info) => sum + info.itemCount);

    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width >= 600;

    // Responsive sizing for dialog
    final dialogWidth = isDesktop ? 600.0 : screenSize.width * 0.95;
    final dialogMaxHeight =
        screenSize.height * 0.85; // Increase from 0.8 to 0.85

    return Dialog(
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: dialogMaxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isDesktop ? 20 : 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.storage,
                    size: isDesktop ? 24 : 20,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  SizedBox(width: isDesktop ? 12 : 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.cacheDetails,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? null : 18,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isDesktop ? 4 : 2),
                        Text(
                          '${loc.total}: $totalItems ${loc.cacheItems}, ${CacheService.formatCacheSize(totalSize)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontSize: isDesktop ? null : 12,
                                  ),
                          maxLines: isDesktop ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      size: isDesktop ? 24 : 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

            // Content - Use Expanded instead of Flexible to take remaining space
            Expanded(
              child: _loading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      children: [
                        // Scrollable content
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.all(isDesktop ? 16 : 12),
                            children: [
                              ..._cacheInfo.entries.map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(
                                      bottom: isDesktop ? 8 : 6),
                                  child: _buildCacheSection(
                                      entry.key, entry.value),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Fixed bottom button area
                        Container(
                          padding: EdgeInsets.all(isDesktop ? 16 : 12),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: totalItems > 0 ? _clearAllCache : null,
                              icon: const Icon(Icons.delete_sweep),
                              label: Text(loc.clearAllCache),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isDesktop ? 16 : 14,
                                ),
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
