import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import 'package:my_multi_tools/services/app_logger.dart';

class LogViewerScreen extends StatefulWidget {
  final bool isEmbedded;

  const LogViewerScreen({super.key, this.isEmbedded = false});

  @override
  State<LogViewerScreen> createState() => _LogViewerScreenState();
}

class _LogViewerScreenState extends State<LogViewerScreen> {
  List<String> _logFiles = [];
  String? _selectedFile;
  String _logContent = '';
  bool _loading = false;
  bool _loadingFiles = true;

  @override
  void initState() {
    super.initState();
    _loadLogFiles();
  }

  Future<void> _loadLogFiles() async {
    try {
      setState(() {
        _loadingFiles = true;
      });

      final files = await AppLogger.instance.getLogFileNames();
      setState(() {
        _logFiles = files;
        _loadingFiles = false;

        // Auto-select the most recent log file
        if (files.isNotEmpty) {
          _selectedFile = files.first;
          _loadLogContent();
        }
      });
    } catch (e) {
      setState(() {
        _loadingFiles = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load log files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadLogContent() async {
    if (_selectedFile == null) return;

    try {
      setState(() {
        _loading = true;
      });

      final content = await AppLogger.instance.readLogContent(_selectedFile!);
      setState(() {
        _logContent = content;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load log content: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _logContent));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Log content copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _clearLogs() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllCache), // Reuse existing localization
        content: const Text(
            'Are you sure you want to clear all log files? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Logs'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AppLogger.instance.clearLogs();
        await _loadLogFiles();
        setState(() {
          _selectedFile = null;
          _logContent = '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All log files cleared'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear logs: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatFileName(String fileName) {
    // Extract date from filename like "my_multi_tools_2024-12-10.log"
    final parts = fileName.replaceAll('.log', '').split('_');
    if (parts.length >= 4) {
      final datePart = parts.sublist(3).join('-');
      return 'Log $datePart';
    }
    return fileName;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.isEmbedded) {
      return _buildContent(l10n);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Logs'),
        // Remove action buttons to make space for log file dropdown
      ),
      body: _buildContent(l10n),
      floatingActionButton: _logFiles.isNotEmpty ? _buildActionMenu() : null,
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return Column(
      children: [
        // File selector
        if (!_loadingFiles && _logFiles.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.3),
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 20),
                const SizedBox(width: 12),
                const Text('Log File:'),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedFile,
                    isExpanded: true,
                    items: _logFiles.map((file) {
                      return DropdownMenuItem<String>(
                        value: file,
                        child: Text(_formatFileName(file)),
                      );
                    }).toList(),
                    onChanged: (newFile) {
                      setState(() {
                        _selectedFile = newFile;
                      });
                      _loadLogContent();
                    },
                  ),
                ),
                // Remove action buttons to make space for dropdown
              ],
            ),
          ),

        // Log content
        Expanded(
          child: _loadingFiles
              ? const Center(child: CircularProgressIndicator())
              : _logFiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 64,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No log files available',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Log files will appear here as the app generates them',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5),
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Container(
                          padding: const EdgeInsets.all(16),
                          child: _logContent.isEmpty
                              ? Center(
                                  child: Text(
                                    'Selected log file is empty',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: SelectableText(
                                      _logContent,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
        ),
      ],
    );
  }

  Widget _buildActionMenu() {
    return FloatingActionButton(
      onPressed: () => _showActionBottomSheet(),
      child: const Icon(Icons.more_vert),
      tooltip: 'Log Actions',
    );
  }

  void _showActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy to Clipboard'),
              onTap: () {
                Navigator.pop(context);
                if (_logContent.isNotEmpty) _copyToClipboard();
              },
              enabled: _logContent.isNotEmpty,
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Refresh'),
              onTap: () {
                Navigator.pop(context);
                _loadLogFiles();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear All Logs'),
              onTap: () {
                Navigator.pop(context);
                _clearLogs();
              },
            ),
          ],
        ),
      ),
    );
  }
}
