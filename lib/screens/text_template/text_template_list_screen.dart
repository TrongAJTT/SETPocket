import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/services/text_template_services/text_template_service.dart';
import 'package:setpocket/utils/size_utils.dart';
import 'text_template_use_screen.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/utils/template_parser.dart';
import 'text_template_edit_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:setpocket/widgets/generic/generic_dialog.dart';
import 'package:setpocket/widgets/generic/option_card.dart';
import 'package:setpocket/widgets/generic/option_item.dart';
import 'package:setpocket/utils/icon_utils.dart';
import 'package:setpocket/widgets/import_status_dialog.dart';
import 'package:setpocket/widgets/generic/enter_text_dialog.dart';
import 'package:setpocket/widgets/generic/icon_button_list.dart';
import 'package:archive/archive_io.dart';

class TemplateListScreen extends StatefulWidget {
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory, IconData? icon})?
      onToolSelected;
  final Function()? onNewTemplate;
  final Function(TextTemplatesData)? onTemplateSelected;

  const TemplateListScreen({
    super.key,
    this.isEmbedded = false,
    this.onToolSelected,
    this.onNewTemplate,
    this.onTemplateSelected,
  });

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  List<TextTemplatesData> _completedTemplates = [];
  List<TextTemplatesData> _drafts = [];
  bool _isLoading = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedTemplateIds = {};
  bool _viewingDrafts = false; // Re-introduce view toggle state

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final completed = await TemplateService.getCompletedTemplates();
      final drafts = await TemplateService.getDraftTemplates();
      if (mounted) {
        setState(() {
          _completedTemplates = completed;
          _drafts = drafts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarUtils.showTyped(
            context, 'Error loading templates: $e', SnackBarType.error);
      }
    }
  }

  void _toggleView() {
    setState(() {
      _viewingDrafts = !_viewingDrafts;
      _exitSelectionMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final templatesToShow = _viewingDrafts ? _drafts : _completedTemplates;
    final title = _viewingDrafts ? "Drafts" : l10n.textTemplatesTitle;

    Widget mainContent = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildTemplateList(templatesToShow, l10n);

    if (widget.isEmbedded) {
      return Column(
        children: [
          _buildDesktopHeader(l10n, templatesToShow.isNotEmpty),
          Expanded(child: mainContent),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: _buildAppBarActions(l10n, templatesToShow.isNotEmpty),
      ),
      body: mainContent,
      floatingActionButton: !_isSelectionMode && templatesToShow.isNotEmpty
          ? FloatingActionButton(
              onPressed: _showAddTemplateDialog,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar:
          _isSelectionMode ? _buildBottomActionBar(l10n) : null,
    );
  }

  List<Widget> _buildAppBarActions(AppLocalizations l10n, bool hasTemplates) {
    if (_isSelectionMode) {
      return [
        TextButton(
          onPressed: _selectAll,
          child: Text(l10n.selectAll),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSelectionMode,
        ),
      ];
    }
    return [
      if (hasTemplates) ...[
        IconButton(
          icon:
              Icon(_viewingDrafts ? Icons.description : Icons.drafts_outlined),
          tooltip:
              _viewingDrafts ? l10n.textTemplatesTitle : l10n.draftsDialogTitle,
          onPressed: () => _showTemplateStatusDialog('draft'),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: l10n.trashDialogTitle,
          onPressed: () => _showTemplateStatusDialog('deleted'),
        ),
      ],
    ];
  }

  Widget _buildDesktopHeader(AppLocalizations l10n, bool hasTemplates) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _viewingDrafts ? "Drafts" : l10n.textTemplatesTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ..._buildAppBarActions(l10n, hasTemplates),
          if (!_isSelectionMode && hasTemplates)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: ElevatedButton.icon(
                onPressed: _showAddTemplateDialog,
                icon: const Icon(Icons.add),
                label: Text(l10n.add),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTemplateList(
      List<TextTemplatesData> templates, AppLocalizations l10n) {
    if (templates.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return ListView.builder(
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        final isSelected = _selectedTemplateIds.contains(template.id);
        final parser = TemplateParser.findElementsInContent(template.content);
        final fieldCount =
            parser.map((e) => e.id).toSet().length; // Count unique fields
        final loopCount =
            TemplateParser.findDataLoopsInContent(template.content).length;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: isSelected ? Theme.of(context).primaryColorLight : null,
          child: ListTile(
            title: Text(template.title),
            subtitle: Text(
              '${template.content.length} chars • $fieldCount fields • $loopCount loops',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              if (_isSelectionMode) {
                _toggleSelection(template.id);
              } else {
                _navigateToUseTemplate(template);
              }
            },
            onLongPress: () {
              if (!_isSelectionMode) {
                setState(() {
                  _isSelectionMode = true;
                  _selectedTemplateIds.add(template.id);
                });
              }
            },
            trailing: _isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) => _toggleSelection(template.id),
                  )
                : _buildActionButtons(template),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(TextTemplatesData template) {
    final l10n = AppLocalizations.of(context)!;
    // Using a simple width check for mobile/desktop breakpoint
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final visibleCount = ((width - 220) ~/ 30).clamp(0, 4); // tối đa 4 nút
        final buttons = [
          IconButtonListItem(
            icon: Icons.edit,
            label: l10n.edit,
            onPressed: () => _navigateToEditScreen(template: template),
          ),
          IconButtonListItem(
            icon: Icons.delete_outline,
            label: l10n.delete,
            onPressed: () => _showDeleteDialog(template),
          ),
          IconButtonListItem(
            icon: Icons.ios_share,
            label: l10n.export,
            onPressed: () => _showExportDialog(template),
          ),
          IconButtonListItem(
            icon: Icons.copy,
            label: l10n.duplicate,
            onPressed: () => _showDuplicateDialog(template, l10n),
          ),
        ];
        return IconButtonList(
          buttons: buttons,
          visibleCount: visibleCount,
          spacing: 0,
        );
      },
    );
  }

  void _showDeleteDialog(TextTemplatesData template) {
    bool isPermanent = false;
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return GenericDialog(
            header: GenericDialogHeader(title: l10n.deleteTemplateTitle),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.deleteTemplateConfirmation(template.title)),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: Text(l10n.moveToTrash),
                  subtitle: Text(l10n.permanentDeleteWarning),
                  value: !isPermanent,
                  onChanged: (bool value) {
                    setState(() {
                      isPermanent = !value;
                    });
                  },
                ),
              ],
            ),
            footer: GenericDialogFooter.cancelSave(
              cancelText: l10n.cancel,
              saveText: l10n.delete,
              onCancel: () => Navigator.of(context).pop(),
              onSave: () {
                Navigator.of(context).pop();
                _deleteTemplate(template.id, isPermanent);
              },
            ),
            decorator: GenericDialogDecorator(
                width: DynamicDimension.flexibilityMax(90, 600),
                displayTopDivider: true),
          );
        });
      },
    );
  }

  Future<void> _deleteTemplate(String id, bool permanent) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await TemplateService.deleteTemplate(id, permanent: permanent);
      SnackbarUtils.showTyped(
          context, l10n.templateDeletedSuccess, SnackBarType.success);
      _loadAllData(); // Refresh the list
    } catch (e) {
      SnackbarUtils.showTyped(
          context, l10n.templateDeleteError(e.toString()), SnackBarType.error);
    }
  }

  void _showExportDialog(TextTemplatesData template) {
    final l10n = AppLocalizations.of(context)!;
    final fileNameController = TextEditingController(
        text: template.title
            .replaceAll(RegExp(r'[^\w\s]+'), '')
            .replaceAll(' ', '_'));
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenericDialog(
          header: GenericDialogHeader(title: l10n.exportTemplateTitle),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: fileNameController,
                decoration: InputDecoration(
                  labelText: l10n.fileNameLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              OptionCard(
                option: OptionItem<String>(
                    value: 'export_json',
                    label: l10n.exportAsJson,
                    subtitle: l10n.exportAsJsonDescription,
                    icon: GenericIcon.icon(Icons.save_alt)),
                onTap: () {
                  Navigator.of(context).pop();
                  _exportToJsonFile(template, fileNameController.text);
                },
              ),
              const SizedBox(height: 8),
              OptionCard(
                option: OptionItem<String>(
                    value: 'share',
                    label: l10n.shareTemplate,
                    subtitle: l10n.shareTemplateDescription,
                    icon: GenericIcon.icon(Icons.share)),
                onTap: () {
                  Navigator.of(context).pop();
                  _shareTemplate(template);
                },
              ),
            ],
          ),
          footer: GenericDialogFooter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportToJsonFile(
      TextTemplatesData template, String fileName) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final jsonString = jsonEncode(template.toJson());
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: '$fileName.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputPath != null) {
        final file = File(outputPath);
        await file.writeAsString(jsonString);
        SnackbarUtils.showTyped(context,
            l10n.templateExportedSuccess(outputPath), SnackBarType.success);
      }
    } catch (e) {
      SnackbarUtils.showTyped(
          context, l10n.templateExportError(e.toString()), SnackBarType.error);
    }
  }

  Future<void> _shareTemplate(TextTemplatesData template) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final jsonString = jsonEncode(template.toJson());
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${template.title}.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);

      await Share.shareXFiles([XFile(filePath)],
          text: 'Template: ${template.title}');
    } catch (e) {
      SnackbarUtils.showTyped(
          context, l10n.shareTemplateError(e.toString()), SnackBarType.error);
    }
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              _viewingDrafts ? Icons.drafts_outlined : Icons.note_add_outlined,
              size: 80,
              color: theme.colorScheme.secondary.withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            Text(
              _viewingDrafts
                  ? "You have no drafts"
                  : "No templates created yet",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _viewingDrafts
                  ? "Your saved drafts will appear here."
                  : "Create your first template to get started with text generation.",
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddTemplateDialog,
              icon: const Icon(Icons.add),
              label: Text("Create a New Template"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(AppLocalizations l10n) {
    final isBatch = _selectedTemplateIds.length > 1;
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.delete),
            label: Text("${l10n.delete} (${_selectedTemplateIds.length})"),
            onPressed: () => _showDeleteDialogBatch(l10n),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
          ),
          TextButton.icon(
            icon: const Icon(Icons.ios_share),
            label: Text(l10n.export),
            onPressed: () => _showExportDialogBatch(l10n),
          ),
        ],
      ),
    );
  }

  void _toggleSelection(String templateId) {
    setState(() {
      if (_selectedTemplateIds.contains(templateId)) {
        _selectedTemplateIds.remove(templateId);
        if (_selectedTemplateIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedTemplateIds.add(templateId);
      }
    });
  }

  void _selectAll() {
    final templatesToShow = _viewingDrafts ? _drafts : _completedTemplates;
    setState(() {
      if (_selectedTemplateIds.length == templatesToShow.length) {
        _selectedTemplateIds.clear();
      } else {
        _selectedTemplateIds.addAll(templatesToShow.map((t) => t.id).toList());
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedTemplateIds.clear();
    });
  }

  void _deleteSelectedTemplates() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text(
            "Are you sure you want to delete ${_selectedTemplateIds.length} templates?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete)),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await TemplateService.batchMoveToTrash(_selectedTemplateIds.toList());
      _exitSelectionMode();
      await _loadAllData(); // Refresh list
    }
  }

  void _navigateToUseTemplate(TextTemplatesData template) async {
    final useScreen = TemplateUseScreen(
      template: template,
      isEmbedded: widget.isEmbedded,
      onToolSelected: widget.onToolSelected,
    );

    if (widget.isEmbedded && widget.onToolSelected != null) {
      // Desktop mode: callback to display in the main widget
      widget.onToolSelected!(useScreen, 'Generate Document: ${template.title}',
          parentCategory: 'TemplateListScreen', icon: Icons.description);
    } else {
      // Mobile mode: normal navigation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => useScreen,
        ),
      );
    }
  }

  void _navigateToEditScreen(
      {TextTemplatesData? template,
      String? initialTitle,
      String? initialContent}) {
    if (widget.isEmbedded && widget.onToolSelected != null) {
      // Desktop embedded view
      widget.onToolSelected!(
        TemplateEditScreen(
          template: template,
          initialTitle: initialTitle,
          initialContent: initialContent,
          isEmbedded: true,
        ),
        template != null ? 'Edit Template' : 'Create Template',
        parentCategory: 'TemplateListScreen',
        icon: Icons.edit,
      );
    } else {
      // Mobile view
      if (widget.onTemplateSelected != null) {
        widget.onTemplateSelected!(template!);
      } else {
        // Default navigation
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TemplateEditScreen(
              template: template,
              isEmbedded: widget.isEmbedded,
            ),
          ),
        );
      }
    }
  }

  void _showHelpDialog() {
    // This can be reimplemented if needed.
  }

  Future<void> _importTemplatesFromJson(List<PlatformFile> files) async {
    final List<ImportResult> importResults = [];
    for (final file in files) {
      try {
        final String content;
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        } else if (file.path != null) {
          content = await File(file.path!).readAsString();
        } else {
          throw Exception("Could not read the selected file.");
        }
        final jsonData = jsonDecode(content);
        final template = TextTemplatesData.fromJson(jsonData);
        await TemplateService.saveTemplate(template);
        importResults.add(ImportResult(fileName: file.name, success: true));
      } catch (e) {
        importResults.add(ImportResult(
            fileName: file.name, success: false, errorMessage: e.toString()));
      }
    }
    if (importResults.any((r) => r.success)) {
      await _loadAllData();
    }
    if (mounted) {
      _showImportResultDialog(importResults);
    }
  }

  void _showImportResultDialog(List<ImportResult> results) {
    final l10n = AppLocalizations.of(context)!;
    final successful = results.where((r) => r.success).toList();
    final failed = results.where((r) => !r.success).toList();
    showDialog(
      context: context,
      builder: (context) => GenericDialog(
        header: GenericDialogHeader(title: l10n.importResults),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.importSummary(failed.length, successful.length),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (successful.isNotEmpty) ...[
              Text(l10n.successfulImports(successful.length),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green[700])),
              const SizedBox(height: 8),
              ...successful.map((r) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Expanded(child: Text(r.fileName)),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
            ],
            if (failed.isNotEmpty) ...[
              Text(l10n.failedImports(failed.length),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.red[700])),
              const SizedBox(height: 8),
              ...failed.map((r) => Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error, size: 16, color: Colors.red[700]),
                            const SizedBox(width: 8),
                            Expanded(child: Text(r.fileName)),
                          ],
                        ),
                        if (r.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 24, top: 2),
                            child: Text(r.errorMessage!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.red[600])),
                          ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
        footer: GenericDialogFooter(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: Text(l10n.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        decorator: GenericDialogDecorator(
          width: DynamicDimension.flexibilityMax(90, 600),
          displayTopDivider: true,
        ),
      ),
    );
  }

  Future<void> _importFromClipboard(AppLocalizations l10n) async {
    // Logic to import from clipboard
  }

  Future<void> _showImportOptions(AppLocalizations l10n) async {
    // Logic to show import options
  }

  Future<void> _showAddTemplateDialog() async {
    final l10n = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) {
        return GenericDialog(
          header: GenericDialogHeader(title: l10n.addTemplate),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              OptionCard(
                option: OptionItem<String>(
                  value: 'manual',
                  label: l10n.createManually ?? 'Create Manually',
                  icon: GenericIcon.icon(Icons.edit_note),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditScreen();
                },
              ),
              const SizedBox(height: 8),
              OptionCard(
                option: OptionItem<String>(
                  value: 'import',
                  label: l10n.importFromFile ?? 'Import from File',
                  icon: GenericIcon.icon(Icons.file_open),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _importTemplateFromFile();
                },
              ),
            ],
          ),
          footer: GenericDialogFooter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(l10n.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _importTemplateFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        await _importTemplatesFromJson(result.files);
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
            context, 'Error importing file: $e', SnackBarType.error);
      }
    }
  }

  void _showTemplateStatusDialog(String status) async {
    final l10n = AppLocalizations.of(context)!;
    List<TextTemplatesData> templates = [];
    if (status == 'draft') {
      templates = await TemplateService.getDraftTemplates();
    } else if (status == 'deleted') {
      templates = await TemplateService.getDeletedTemplates();
    }
    showDialog(
      context: context,
      builder: (context) {
        return GenericDialog(
          header: GenericDialogHeader(
            title: status == 'draft'
                ? l10n.draftsDialogTitle
                : l10n.trashDialogTitle,
          ),
          body: SizedBox(
            width: 400,
            child: templates.isEmpty
                ? Center(child: Text(l10n.noTemplatesYet))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      final now = DateTime.now();
                      final baseTime = template.updatedAt;
                      final expireDays = status == 'draft' ? 7 : 30;
                      final daysLeft =
                          expireDays - now.difference(baseTime).inDays;
                      final parser = TemplateParser.findElementsInContent(
                          template.content);
                      final fieldCount = parser.map((e) => e.id).toSet().length;
                      final loopCount = TemplateParser.findDataLoopsInContent(
                              template.content)
                          .length;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(template.title),
                          subtitle: Text(
                            '${template.content.length} chars • $fieldCount fields • $loopCount loops\n${l10n.daysLeft(daysLeft)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (status == 'deleted')
                                IconButton(
                                  icon: const Icon(Icons.restore),
                                  tooltip: l10n.restore,
                                  onPressed: () => _restoreTemplate(template),
                                ),
                              if (status == 'draft')
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: l10n.edit,
                                  onPressed: () =>
                                      _navigateToEditScreen(template: template),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever),
                                tooltip: l10n.permanentlyDelete,
                                onPressed: () =>
                                    _permanentlyDeleteTemplate(template),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          footer: GenericDialogFooter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(l10n.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _restoreTemplate(TextTemplatesData template) async {
    await TemplateService.restoreFromTrash(template.id);
    Navigator.of(context).pop();
    _loadAllData();
  }

  Future<void> _permanentlyDeleteTemplate(TextTemplatesData template) async {
    await TemplateService.deleteTemplatePermanently(template.id);
    Navigator.of(context).pop();
    _loadAllData();
  }

  void _showDuplicateDialog(TextTemplatesData template, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => EnterTextDialog(
        icon: Icons.copy,
        title: l10n.duplicate,
        description: l10n.enterNewTemplateName,
        initialText: '${template.title} (Copy)',
        cancelText: l10n.cancel,
        applyText: l10n.apply,
        onApply: (newTitle) async {
          final newTemplate = TextTemplatesData()
            ..id = DateTime.now().millisecondsSinceEpoch.toString()
            ..title = newTitle
            ..content = template.content
            ..status = TemplateStatus.complete
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();
          await TemplateService.saveTemplate(newTemplate);
          if (mounted) _loadAllData();
        },
      ),
    );
  }

  void _showDeleteDialogBatch(AppLocalizations l10n) {
    final count = _selectedTemplateIds.length;
    bool isPermanent = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return GenericDialog(
            header: GenericDialogHeader(title: l10n.deleteTemplateTitle),
            body: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.areYouSureToDeleteNTemplates(count)),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: Text(l10n.moveToTrash),
                  subtitle: Text(l10n.permanentDeleteWarning),
                  value: !isPermanent,
                  onChanged: (bool value) {
                    setState(() {
                      isPermanent = !value;
                    });
                  },
                ),
              ],
            ),
            footer: GenericDialogFooter.cancelSave(
              cancelText: l10n.cancel,
              saveText: l10n.delete,
              onCancel: () => Navigator.of(context).pop(),
              onSave: () {
                Navigator.of(context).pop();
                _deleteTemplates(_selectedTemplateIds.toList(), isPermanent);
              },
            ),
            decorator: GenericDialogDecorator(
                width: DynamicDimension.flexibilityMax(90, 600),
                displayTopDivider: true),
          );
        });
      },
    );
  }

  Future<void> _deleteTemplates(List<String> ids, bool permanent) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      for (final id in ids) {
        await TemplateService.deleteTemplate(id, permanent: permanent);
      }
      SnackbarUtils.showTyped(
          context, l10n.templateDeletedSuccess, SnackBarType.success);
      _exitSelectionMode();
      _loadAllData();
    } catch (e) {
      SnackbarUtils.showTyped(
          context, l10n.templateDeleteError(e.toString()), SnackBarType.error);
    }
  }

  void _showExportDialogBatch(AppLocalizations l10n) {
    final count = _selectedTemplateIds.length;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GenericDialog(
          header: GenericDialogHeader(title: l10n.exportTemplates),
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.youAreAboutToExportNTemplates(count)),
              const SizedBox(height: 16),
              OptionCard(
                option: OptionItem<String>(
                    value: 'export_json',
                    label: l10n.exportAsJson,
                    subtitle: l10n.exportAsJsonDescription,
                    icon: GenericIcon.icon(Icons.save_alt)),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _exportTemplatesToJson(_selectedTemplateIds.toList());
                },
              ),
              const SizedBox(height: 8),
              OptionCard(
                option: OptionItem<String>(
                  value: 'share',
                  label: l10n.share,
                  subtitle: 'Share all selected templates as a zip file',
                  icon: GenericIcon.icon(Icons.share),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _shareTemplatesBatch(_selectedTemplateIds.toList());
                },
              ),
            ],
          ),
          footer: GenericDialogFooter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text(l10n.cancel),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportTemplatesToJson(List<String> ids) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      String? directoryPath = await FilePicker.platform.getDirectoryPath();
      if (directoryPath == null) return;
      int successCount = 0;
      for (final id in ids) {
        final template = _completedTemplates.firstWhere((t) => t.id == id,
            orElse: () => _drafts.firstWhere((t) => t.id == id));
        final fileName = template.title
            .replaceAll(RegExp(r'[^\w\s]+'), '')
            .replaceAll(' ', '_');
        final jsonData = template.toJson();
        final jsonString = jsonEncode(jsonData);
        final filePath = '$directoryPath/$fileName.json';
        final file = File(filePath);
        await file.writeAsString(jsonString);
        successCount++;
      }
      SnackbarUtils.showTyped(context, l10n.batchExportCompleted(successCount),
          SnackBarType.success);
      _exitSelectionMode();
    } catch (e) {
      SnackbarUtils.showTyped(context,
          l10n.errorDuringBatchExport(e.toString()), SnackBarType.error);
    }
  }

  Future<void> _shareTemplatesBatch(List<String> ids) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final tempDir = await getTemporaryDirectory();
      final files = <File>[];
      for (final id in ids) {
        final template = _completedTemplates.firstWhere((t) => t.id == id,
            orElse: () => _drafts.firstWhere((t) => t.id == id));
        final fileName = template.title
            .replaceAll(RegExp(r'[^-\u007F]+'), '')
            .replaceAll(' ', '_');
        final filePath = '${tempDir.path}/$fileName.json';
        final file = File(filePath);
        await file.writeAsString(jsonEncode(template.toJson()));
        files.add(file);
      }
      // Zip các file lại bằng archive
      final encoder = ZipFileEncoder();
      final zipPath = '${tempDir.path}/templates_export.zip';
      encoder.create(zipPath);
      for (final file in files) {
        encoder.addFile(file);
      }
      encoder.close();
      await Share.shareXFiles([XFile(zipPath)], text: 'Exported templates');
    } catch (e) {
      SnackbarUtils.showTyped(context,
          l10n.errorDuringBatchExport(e.toString()), SnackBarType.error);
    }
  }
}
