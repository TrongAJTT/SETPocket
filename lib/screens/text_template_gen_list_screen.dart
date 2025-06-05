import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import '../models/text_template.dart';
import '../services/template_service.dart';
import '../widgets/import_status_dialog.dart';
import '../widgets/batch_export_dialog.dart';
import '../widgets/batch_delete_dialog.dart';
import 'text_template_gen_edit_screen.dart';
import 'text_template_gen_use_screen.dart';

class TemplateListScreen extends StatefulWidget {
  const TemplateListScreen({super.key});

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  List<Template> _templates = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedTemplateIds = {};

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final templates = await TemplateService.getTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading templates: ${e.toString()}')),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text(l10n.selectedTemplates(_selectedTemplateIds.length))
            : Text(l10n.textTemplatesTitle),
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: _isSelectionMode
            ? [
                if (_selectedTemplateIds.length < _templates.length)
                  TextButton(
                    onPressed: _selectAll,
                    child: Text(l10n.selectAll),
                  ),
                if (_selectedTemplateIds.isNotEmpty)
                  TextButton(
                    onPressed: _deselectAll,
                    child: Text(l10n.deselectAll),
                  ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: l10n.help,
                  onPressed: () {
                    _showHelpDialog();
                  },
                ),
              ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? _buildEmptyState(l10n)
              : _buildTemplateList(l10n),
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddTemplateOptions(l10n),
              tooltip: l10n.addNewTemplate,
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: _isSelectionMode && _selectedTemplateIds.isNotEmpty
          ? _buildBottomActionBar(l10n)
          : null,
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 84,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noTemplatesYet,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.createTemplatesHint,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddTemplateOptions(l10n),
              icon: const Icon(Icons.add),
              label: Text(l10n.createNewTemplate),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateList(AppLocalizations l10n) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        final isSelected = _selectedTemplateIds.contains(template.id);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      _toggleTemplateSelection(template.id);
                    },
                  )
                : const Icon(Icons.description),
            title: Text(template.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.characterCount(template.characterCount)),
                Text(l10n.fieldsAndLoops(
                    template.fieldCount, template.loopCount)),
              ],
            ),
            trailing: _isSelectionMode
                ? null
                : PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await _navigateToEditTemplate(template);
                      } else if (value == 'delete') {
                        _confirmDeleteTemplate(template, l10n);
                      } else if (value == 'copy') {
                        await _duplicateTemplate(template, l10n);
                      } else if (value == 'export') {
                        await _exportTemplateToJson(template, l10n);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: const Icon(Icons.edit),
                          title: Text(l10n.edit),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'copy',
                        child: ListTile(
                          leading: const Icon(Icons.copy),
                          title: Text(l10n.copy),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        child: ListTile(
                          leading: const Icon(Icons.download),
                          title: Text(l10n.exportToJson),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: const Icon(Icons.delete, color: Colors.red),
                          title: Text(l10n.delete,
                              style: const TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
            onTap: _isSelectionMode
                ? () => _toggleTemplateSelection(template.id)
                : () => _navigateToUseTemplate(template),
            onLongPress: _isSelectionMode
                ? null
                : () => _enterSelectionMode(template.id),
          ),
        );
      },
    );
  }

  Future<void> _navigateToCreateTemplate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplateEditScreen(),
      ),
    );

    if (result == true) {
      _loadTemplates();
    }
  }

  Future<void> _navigateToEditTemplate(Template template) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditScreen(
          template: template,
        ),
      ),
    );

    if (result == true) {
      _loadTemplates();
    }
  }

  Future<void> _navigateToUseTemplate(Template template) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateUseScreen(
          template: template,
        ),
      ),
    );
  }

  void _confirmDeleteTemplate(Template template, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeletion),
        content: Text(l10n.confirmDeleteTemplateMsg(template.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteTemplate(template.id, l10n);
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTemplate(String id, AppLocalizations l10n) async {
    try {
      await TemplateService.deleteTemplate(id);
      _loadTemplates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.templateDeleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorDeletingTemplate(e.toString()))),
        );
      }
    }
  }

  void _showHelpDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.usageGuide),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.textTemplateToolIntro,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('• ${l10n.helpCreateNewTemplate}'),
              Text('• ${l10n.helpTapToUseTemplate}'),
              Text('• ${l10n.helpTapMenuForActions}'),
              Text('• ${l10n.longPressToSelect}'),
              const SizedBox(height: 16),
              Text(
                l10n.textTemplateScreenHint,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  void _showAddTemplateOptions(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.addTemplate),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateTemplate();
            },
            child: ListTile(
              leading: const Icon(Icons.create),
              title: Text(l10n.addManually),
              subtitle: Text(l10n.createTemplateFromScratch),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _importTemplateFromFile(l10n);
            },
            child: ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(l10n.addFromFile),
              subtitle: Text(l10n.importTemplateFromJson),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importTemplateFromFile(AppLocalizations l10n) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: true, // Enable multiple file selection
      );

      if (result != null && result.files.isNotEmpty) {
        List<ImportResult> importResults = [];

        // Process each selected file
        for (final file in result.files) {
          if (file.path != null) {
            try {
              final fileObj = File(file.path!);
              final jsonString = await fileObj.readAsString();
              final jsonData = jsonDecode(jsonString);
              final template = Template.fromJson(jsonData);

              // Generate a new ID for the imported template
              final newTemplate = template.copyWith(
                id: TemplateService.generateTemplateId(),
              );

              await TemplateService.saveTemplate(newTemplate);

              importResults.add(ImportResult(
                fileName: file.name,
                success: true,
              ));
            } catch (e) {
              importResults.add(ImportResult(
                fileName: file.name,
                success: false,
                errorMessage: e.toString(),
              ));
            }
          }
        }

        // Reload templates after import
        _loadTemplates();

        // Show import status dialog
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => ImportStatusDialog(results: importResults),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorImportingTemplate(e.toString())),
          ),
        );
      }
    }
  }

  Future<void> _duplicateTemplate(
      Template template, AppLocalizations l10n) async {
    try {
      // Create a new template with copied data and a new ID
      final newTemplate = Template(
        id: TemplateService.generateTemplateId(),
        title: '${template.title} (${l10n.copySuffix})',
        content: template.content,
      );

      // Save the duplicated template
      await TemplateService.saveTemplate(newTemplate);
      _loadTemplates();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.templateCopied),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorCopyingTemplate(e.toString())),
          ),
        );
      }
    }
  }

  // Multi-select functionality methods
  void _enterSelectionMode(String templateId) {
    setState(() {
      _isSelectionMode = true;
      _selectedTemplateIds.add(templateId);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTemplateIds.clear();
    });
  }

  void _toggleTemplateSelection(String templateId) {
    setState(() {
      if (_selectedTemplateIds.contains(templateId)) {
        _selectedTemplateIds.remove(templateId);
        if (_selectedTemplateIds.isEmpty) {
          _exitSelectionMode();
        }
      } else {
        _selectedTemplateIds.add(templateId);
      }
    });
  }

  void _selectAll() {
    setState(() {
      _selectedTemplateIds.addAll(_templates.map((t) => t.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedTemplateIds.clear();
    });
  }

  Widget _buildBottomActionBar(AppLocalizations l10n) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilledButton.icon(
            onPressed: _batchExport,
            icon: const Icon(Icons.download),
            label: Text(l10n.batchExport),
          ),
          FilledButton.icon(
            onPressed: _batchDelete,
            icon: const Icon(Icons.delete),
            label: Text(l10n.batchDelete),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _batchExport() async {
    final l10n = AppLocalizations.of(context)!;
    final selectedTemplates =
        _templates.where((t) => _selectedTemplateIds.contains(t.id)).toList();

    if (selectedTemplates.isEmpty) return;

    await _showBatchExportDialog(selectedTemplates, l10n);
  }

  void _batchDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final selectedTemplates =
        _templates.where((t) => _selectedTemplateIds.contains(t.id)).toList();

    if (selectedTemplates.isEmpty) return;

    await _showBatchDeleteDialog(selectedTemplates, l10n);
  }

  Future<void> _showBatchExportDialog(
      List<Template> templates, AppLocalizations l10n) async {
    final Map<String, String> filenames = {};

    // Initialize with default filenames
    for (final template in templates) {
      filenames[template.id] = '${template.title.replaceAll(' ', '_')}.json';
    }

    await showDialog(
      context: context,
      builder: (context) => BatchExportDialog(
        templates: templates,
        initialFilenames: filenames,
        onExport: (Map<String, String> finalFilenames) async {
          await _performBatchExport(templates, finalFilenames, l10n);
        },
      ),
    );
  }

  Future<void> _showBatchDeleteDialog(
      List<Template> templates, AppLocalizations l10n) async {
    await showDialog(
      context: context,
      builder: (context) => BatchDeleteDialog(
        templateCount: templates.length,
        onConfirm: () async {
          await _performBatchDelete(templates, l10n);
        },
      ),
    );
  }

  Future<void> _performBatchExport(List<Template> templates,
      Map<String, String> filenames, AppLocalizations l10n) async {
    try {
      // Choose directory
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) return;

      final List<String> errors = [];
      int successCount = 0;

      for (final template in templates) {
        try {
          final filename = filenames[template.id] ??
              '${template.title.replaceAll(' ', '_')}.json';
          final jsonData = template.toJson();
          final jsonString = jsonEncode(jsonData);

          final filePath = '$directoryPath/$filename';
          final file = File(filePath);
          await file.writeAsString(jsonString);

          successCount++;
        } catch (e) {
          errors.add('${template.title}: ${e.toString()}');
        }
      }

      _exitSelectionMode();

      if (mounted) {
        if (errors.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.batchExportCompleted(successCount)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorDuringBatchExport(errors.join(', '))),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during export: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _performBatchDelete(
      List<Template> templates, AppLocalizations l10n) async {
    try {
      for (final template in templates) {
        await TemplateService.deleteTemplate(template.id);
      }

      _exitSelectionMode();
      _loadTemplates();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.batchDeleteCompleted(templates.length)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during batch delete: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportTemplateToJson(
      Template template, AppLocalizations l10n) async {
    try {
      // Convert template to JSON
      final jsonData = template.toJson();
      final jsonString = jsonEncode(jsonData);

      // Choose directory to save the file
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: l10n.saveTemplateAsJson,
        fileName: '${template.title.replaceAll(' ', '_')}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputPath != null) {
        // Ensure file path has .json extension
        if (!outputPath.endsWith('.json')) {
          outputPath += '.json';
        }

        // Write to the file
        final file = File(outputPath);
        await file.writeAsString(jsonString);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.templateExported(outputPath)),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorExportingTemplate(e.toString())),
          ),
        );
      }
    }
  }
}
