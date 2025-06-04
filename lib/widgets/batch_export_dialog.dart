import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import '../models/text_template.dart';

class BatchExportDialog extends StatefulWidget {
  final List<Template> templates;
  final Map<String, String> initialFilenames;
  final Function(Map<String, String>) onExport;

  const BatchExportDialog({
    Key? key,
    required this.templates,
    required this.initialFilenames,
    required this.onExport,
  }) : super(key: key);

  @override
  State<BatchExportDialog> createState() => _BatchExportDialogState();
}

class _BatchExportDialogState extends State<BatchExportDialog> {
  late Map<String, String> _filenames;
  late Map<String, TextEditingController> _controllers;
  @override
  void initState() {
    super.initState();
    _filenames = Map.from(widget.initialFilenames);
    _controllers = {};

    for (final template in widget.templates) {
      // Remove .json extension for editing, keep only the filename part
      final fullFilename = _filenames[template.id] ?? '';
      final filenameWithoutExtension = fullFilename.endsWith('.json') 
          ? fullFilename.substring(0, fullFilename.length - 5)
          : fullFilename;
      
      _controllers[template.id] = TextEditingController(
        text: filenameWithoutExtension,
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.exportTemplates),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.editFilenames),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.templates.length,
                itemBuilder: (context, index) {
                  final template = widget.templates[index];
                  final controller = _controllers[template.id]!;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.filenameFor(template.title),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),                        TextFormField(
                          controller: controller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            suffixText: '.json',
                          ),
                          onChanged: (value) {
                            // Always append .json extension, user cannot modify it
                            _filenames[template.id] = '${value.trim()}.json';
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),        FilledButton(
          onPressed: () {
            // Update filenames from controllers
            for (final template in widget.templates) {
              final controller = _controllers[template.id]!;
              final filename = controller.text.trim();
              if (filename.isNotEmpty) {
                // Always use .json extension, no other extension allowed
                _filenames[template.id] = '$filename.json';
              }
            }

            Navigator.of(context).pop();
            widget.onExport(_filenames);
          },
          child: Text(l10n.batchExport),
        ),
      ],
    );
  }
}
