import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import '../models/text_template.dart';
import '../services/template_service.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading templates: ${e.toString()}')),
      );
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
        title: Text(l10n.textTemplatesTitle),
        actions: [
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTemplateOptions(l10n),
        tooltip: l10n.addNewTemplate,
        child: const Icon(Icons.add),
      ),
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
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: const Icon(Icons.description),
            title: Text(template.title),
            trailing: PopupMenuButton<String>(
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
            onTap: () => _navigateToUseTemplate(template),
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
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();

        try {
          final jsonData = jsonDecode(jsonString);
          final template = Template.fromJson(jsonData);

          // Generate a new ID for the imported template
          final newTemplate = template.copyWith(
            id: TemplateService.generateTemplateId(),
          );

          await TemplateService.saveTemplate(newTemplate);
          _loadTemplates();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.templateImported),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.invalidTemplateFormat(e.toString())),
              ),
            );
          }
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
