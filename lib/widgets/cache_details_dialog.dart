import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:setpocket/services/cache_service.dart';
import 'package:setpocket/services/app_logger.dart';
import 'package:setpocket/l10n/app_localizations.dart';

class CacheDetailsDialog extends StatefulWidget {
  const CacheDetailsDialog({super.key});

  @override
  State<CacheDetailsDialog> createState() => _CacheDetailsDialogState();
}

class _CacheDetailsDialogState extends State<CacheDetailsDialog> {
  Map<String, CacheInfo> _cacheInfo = {};
  bool _loading = true;
  bool _hasLoadedOnce = false;
  String _logInfo = 'Calculating...';
  bool _clearingLogs = false;

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
      _loadLogInfo();
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
        calculatorToolsName: loc.cacheTypeCalculatorTools,
        calculatorToolsDesc: loc.cacheTypeCalculatorToolsDesc,
        converterToolsName: loc.cacheTypeConverterTools,
        converterToolsDesc: loc.cacheTypeConverterToolsDesc,
        p2pDataTransferName: loc.p2pDataTransfer,
        p2pDataTransferDesc: loc.p2pDataTransferCacheDesc,
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

  Future<void> _loadLogInfo() async {
    try {
      final totalSize = await AppLogger.instance.getTotalLogSize();
      final fileCount = await AppLogger.instance.getLogFileNames();
      setState(() {
        _logInfo =
            '${fileCount.length} files • ${AppLogger.formatFileSize(totalSize)}';
      });
    } catch (e) {
      setState(() {
        _logInfo = 'Unknown';
      });
    }
  }

  Future<void> _clearCache(String cacheType, String cacheName) async {
    final loc = AppLocalizations.of(context)!;

    // Check if cache can be cleared
    final canClear = await CacheService.canClearCache(cacheType);
    if (!canClear) {
      final reason = await CacheService.getClearCacheBlockReason(cacheType);

      // Show blocking dialog
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Cannot Clear Cache'),
            ],
          ),
          content:
              Text(reason ?? 'This cache cannot be cleared at the moment.'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

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
    await CacheService.confirmAndClearAllCache(context, l10n: loc);
    // Refresh cache info after dialog closes, regardless of outcome
    await _loadCacheInfo();
  }

  Future<void> _clearLogs() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(loc.clearLogs),
        content:
            Text('${loc.confirmClearAllCache}\n\n${loc.typeConfirmToProceed}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(loc.clearLogs),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _clearingLogs = true;
      });

      try {
        await AppLogger.instance.clearLogs();
        await _loadLogInfo(); // Refresh log info

        setState(() {
          _clearingLogs = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All logs cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _clearingLogs = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing logs: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _debugP2PCache() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Debugging P2P cache...'),
            ],
          ),
        ),
      );

      // Force sync P2P data and debug
      await CacheService.syncP2PDataToCache();
      final debugInfo = await CacheService.debugP2PCache();

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show debug results
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('P2P Cache Debug'),
          content: SingleChildScrollView(
            child: Text(
              'Service Status:\n'
              '  - Enabled: ${debugInfo['service_enabled']}\n'
              '  - Discovered: ${debugInfo['discovered_users']}\n'
              '  - Paired: ${debugInfo['paired_users']}\n'
              '  - Stored: ${debugInfo['stored_users']}\n\n'
              'Hive Boxes:\n${_formatHiveBoxes(debugInfo['hive_boxes'])}\n\n'
              'Cache Info:\n'
              '  - Items: ${debugInfo['cache_info']?['item_count']}\n'
              '  - Size: ${debugInfo['cache_info']?['size_bytes']} bytes\n\n'
              '${debugInfo['error'] != null ? 'Error: ${debugInfo['error']}' : ''}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadCacheInfo(); // Refresh cache display
              },
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatHiveBoxes(dynamic boxes) {
    if (boxes == null) return 'No data';

    final Map<String, dynamic> boxMap = boxes as Map<String, dynamic>;
    final buffer = StringBuffer();

    for (final entry in boxMap.entries) {
      final boxName = entry.key;
      final boxData = entry.value as Map<String, dynamic>;

      buffer.write('  $boxName:\n');
      buffer.write('    - Exists: ${boxData['exists']}\n');
      if (boxData['length'] != null) {
        buffer.write('    - Length: ${boxData['length']}\n');
      }
      if (boxData['keys'] != null) {
        buffer.write('    - Keys: ${boxData['keys']}\n');
      }
      if (boxData['error'] != null) {
        buffer.write('    - Error: ${boxData['error']}\n');
      }
      buffer.write('\n');
    }

    return buffer.toString().trim();
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Debug button for P2P cache
                    if (cacheType == 'p2lan_transfer')
                      IconButton(
                        onPressed: () => _debugP2PCache(),
                        icon: Icon(Icons.bug_report, size: 16),
                        tooltip: 'Debug P2P Cache',
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    if (cacheType == 'p2lan_transfer') const SizedBox(width: 8),

                    // Clear cache button
                    if (cacheType !=
                        'settings') // Don't allow clearing settings cache
                      FutureBuilder<bool>(
                        future: CacheService.canClearCache(cacheType),
                        builder: (context, snapshot) {
                          final canClear = snapshot.data ?? true;

                          return IconButton(
                            onPressed: info.itemCount > 0 && canClear
                                ? () => _clearCache(cacheType, info.name)
                                : null,
                            icon: Icon(
                              canClear
                                  ? Icons.delete_outline
                                  : Icons.lock_outline,
                              size: 16,
                            ),
                            tooltip: canClear
                                ? AppLocalizations.of(context)!.clearCache
                                : 'Cannot clear (service active)',
                            style: FilledButton.styleFrom(
                              backgroundColor: canClear
                                  ? Colors.red.shade600
                                  : Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
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
      case 'p2lan_transfer':
        return Icons.wifi;
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
      case 'p2lan_transfer':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Widget _buildLogSection(AppLocalizations loc) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.logs,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Application log files and debug information',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _clearingLogs ? null : _clearLogs,
                  icon: _clearingLogs
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline, size: 16),
                  tooltip: loc.clearLogs,
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
                      'Log Files',
                      _logInfo.split(' • ').first,
                      Icons.inventory_2_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip(
                      'Log Size',
                      _logInfo.contains(' • ')
                          ? _logInfo.split(' • ').last
                          : 'Unknown',
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
                              // Log section
                              Padding(
                                padding:
                                    EdgeInsets.only(bottom: isDesktop ? 8 : 6),
                                child: _buildLogSection(loc),
                              ),
                            ],
                          ),
                        ), // Fixed bottom button area
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
