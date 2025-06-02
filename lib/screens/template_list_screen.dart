import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/template.dart';
import '../services/template_service.dart';
import 'template_edit_screen.dart';
import 'template_use_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Help',
            onPressed: () {
              _showHelpDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? _buildEmptyState()
              : _buildTemplateList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTemplateOptions(),
        tooltip: 'Add new template',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
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
              'No templates yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Create templates to improve your workflow. Press + button to start.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddTemplateOptions(),
              icon: const Icon(Icons.add),
              label: const Text('Create new template'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateList() {
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
                  _confirmDeleteTemplate(template);
                } else if (value == 'copy') {
                  await _duplicateTemplate(template);
                } else if (value == 'export') {
                  await _exportTemplateToJson(template);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('Copy'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Export to JSON'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
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

  void _confirmDeleteTemplate(Template template) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to delete "${template.title}" template?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteTemplate(template.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTemplate(String id) async {
    try {
      await TemplateService.deleteTemplate(id);
      _loadTemplates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting template: ${e.toString()}')),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usage Guide'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This tool helps you create reusable document templates.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• Press + button to create a new template'),
              Text('• Tap on a template to use it and create a document'),
              Text(
                  '• Tap on ... button to edit, copy, export or delete templates'),
              SizedBox(height: 16),
              Text(
                'In the template creation screen, you can add data fields to fill in later such as text, numbers, dates...',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAddTemplateOptions() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add Template'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCreateTemplate();
            },
            child: const ListTile(
              leading: Icon(Icons.create),
              title: Text('Add manually'),
              subtitle: Text('Create a new template from scratch'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _importTemplateFromFile();
            },
            child: const ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Add from file'),
              subtitle: Text('Import a template from JSON file'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importTemplateFromFile() async {
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
              const SnackBar(
                content: Text('Template imported successfully'),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid template format: ${e.toString()}'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error importing template: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _duplicateTemplate(Template template) async {
    try {
      // Create a new template with copied data and a new ID
      final newTemplate = Template(
        id: TemplateService.generateTemplateId(),
        title: '${template.title} (Copy)',
        content: template.content,
      );

      // Save the duplicated template
      await TemplateService.saveTemplate(newTemplate);
      _loadTemplates();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Template copied successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error copying template: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _exportTemplateToJson(Template template) async {
    try {
      // Convert template to JSON
      final jsonData = template.toJson();
      final jsonString = jsonEncode(jsonData);

      // Choose directory to save the file
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Template as JSON',
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
              content: Text('Template exported to: $outputPath'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting template: ${e.toString()}'),
          ),
        );
      }
    }
  }
}
