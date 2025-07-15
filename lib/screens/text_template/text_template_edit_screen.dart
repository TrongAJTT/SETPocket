import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/models/text_template/text_template_components.dart';
import 'package:setpocket/services/text_template_services/text_template_service.dart';
import 'package:setpocket/utils/size_utils.dart';
import 'package:setpocket/utils/template_parser.dart';
import 'dart:async';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/layouts/two_panels_layout.dart';
import 'package:setpocket/widgets/generic/generic_dialog.dart';
import 'package:setpocket/utils/icon_utils.dart';
import 'package:uuid/uuid.dart';

class TemplateEditScreen extends StatefulWidget {
  final TextTemplatesData? template; // Null for create new, non-null for edit
  final String? initialTitle;
  final String? initialContent;
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory, IconData? icon})?
      onToolSelected;
  final Function(Future<bool> Function()?)? onRegisterUnsavedChangesCallback;

  const TemplateEditScreen({
    super.key,
    this.template,
    this.initialTitle,
    this.initialContent,
    this.isEmbedded = false,
    this.onToolSelected,
    this.onRegisterUnsavedChangesCallback,
  });

  @override
  State<TemplateEditScreen> createState() => _TemplateEditScreenState();
}

class _TemplateEditScreenState extends State<TemplateEditScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _contentFocusNode = FocusNode();
  late List<TemplateElement> _elements = [];
  bool _isLoading = false;
  Map<String, List<TemplateElement>> _duplicateIds = {};
  int _elementCount = 0;
  TextSelection? _savedCursorPosition;
  // Tab controller
  late TabController _tabController;

  // Cache for expensive operations
  List<DataLoop>? _cachedLoops;
  bool? _cachedLoopsValid;
  String _lastContentForCache = '';

  // Unified state management
  late TextTemplatesData _currentTemplate;
  Timer? _autoSaveTimer;
  Timer? _debounceTimer; // Thêm debounce timer cho refresh elements
  bool _hasUnsavedChanges = false;
  String _initialTitle = '';
  String _initialContent = '';

  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Refresh when tab changes
          _refreshElements();
        });
      }
    });

    _initializeTemplate();
    _refreshElements();
    _setupAutoSave();

    // Register unsaved changes callback for desktop navigation
    if (widget.onRegisterUnsavedChangesCallback != null) {
      widget.onRegisterUnsavedChangesCallback!(_checkUnsavedChanges);
    }
  }

  void _initializeTemplate() {
    if (widget.template != null) {
      // Editing an existing template (could be a draft or complete)
      _currentTemplate = widget.template!;
    } else {
      // Creating a new template, starts as a draft
      _currentTemplate = TextTemplatesData()
        ..id = _uuid.v4()
        ..title = widget.initialTitle ?? ''
        ..content = widget.initialContent ?? ''
        ..status = TemplateStatus.draft
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
    }

    _titleController.text = _currentTemplate.title;
    _contentController.text = _currentTemplate.content;
    _initialTitle = _currentTemplate.title;
    _initialContent = _currentTemplate.content;
  }

  void _setupAutoSave() {
    // Listen to text changes for auto-save
    _titleController.addListener(_onContentChanged);
    _contentController.addListener(_onContentChanged);

    // Enable auto-save timer on both mobile and desktop
    // Auto-save every 30 seconds
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _autoSaveDraft();
    });
  }

  void _onContentChanged() {
    _debouncedRefreshElements(); // Refresh structure panel with a debounce
    final hasChanges = _titleController.text != _initialTitle ||
        _contentController.text != _initialContent;
    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  Future<void> _autoSaveDraft() async {
    if (!_hasUnsavedChanges ||
        _currentTemplate.status != TemplateStatus.draft) {
      return;
    }

    _currentTemplate.title = _titleController.text;
    _currentTemplate.content = _contentController.text;
    _currentTemplate.updatedAt = DateTime.now();

    try {
      await TemplateService.saveTemplate(_currentTemplate);
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false; // Reset after successful auto-save
        });
      }

      if (mounted && !_isEmbeddedInDesktop) {
        SnackbarUtils.showTyped(
          context,
          AppLocalizations.of(context)!.autoSaved,
          SnackBarType.info,
        );
      }
    } catch (e) {
      // Silent failure for auto-save
    }
  }

  void _autoSaveDraftSync() {
    if (!_hasUnsavedChanges ||
        _currentTemplate.status != TemplateStatus.draft) {
      return;
    }

    try {
      // Update the existing _currentTemplate object and save it
      _currentTemplate.title = _titleController.text;
      _currentTemplate.content = _contentController.text;
      _currentTemplate.updatedAt = DateTime.now();
      // For critical saves, we can call a synchronous method if available,
      // but here we use the async one and don't wait for it.
      TemplateService.saveTemplate(_currentTemplate);
    } catch (e) {
      // Even critical saves should be silent
    }
  }

  @override
  void deactivate() {
    // This is a good place to trigger a final auto-save if needed,
    // as it's called when the widget is removed from the tree.
    if (_hasUnsavedChanges && _currentTemplate.status == TemplateStatus.draft) {
      _autoSaveDraftSync();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel(); // Cancel debounce timer

    // Unregister unsaved changes callback
    if (widget.onRegisterUnsavedChangesCallback != null) {
      widget.onRegisterUnsavedChangesCallback!(null);
    }

    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _refreshElements() {
    final content = _contentController.text;

    if (content != _lastContentForCache) {
      _cachedLoops = null;
      _cachedLoopsValid = null;
      _lastContentForCache = content;
    }

    setState(() {
      _elements = TemplateParser.findElementsInContent(content);
      _duplicateIds = TemplateParser.findDuplicateIds(_elements);
      _elementCount = _elements.length;
    });
  }

  void _debouncedRefreshElements() {
    // Cancel previous timer if exists
    _debounceTimer?.cancel();

    // Set new timer with 300ms delay
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _refreshElements();
      }
    });
  }

  bool get _isEmbeddedInDesktop {
    return widget.isEmbedded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final mainContent = PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop == true && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.templateTitleLabel,
                border: const OutlineInputBorder(),
              ),
              maxLength: 30,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterTitle;
                }
                if (value.length > 30) {
                  return l10n.exceedLimitCharacters(30);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Stack(
                children: [
                  TextFormField(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    decoration: InputDecoration(
                      labelText: l10n.templateContentHint,
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: FloatingActionButton(
                      onPressed: () => _showAddElementDialog(context),
                      tooltip: l10n.addElement,
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final structurePanel = _buildStructurePanel(l10n);

    final saveButton = IconButton(
      icon: const Icon(Icons.save),
      tooltip: l10n.save,
      onPressed: _isLoading ? null : _saveAsCompleteTemplate,
    );

    return TwoPanelsLayout(
      mainPanel: mainContent,
      rightPanel: structurePanel,
      title: _currentTemplate.status == TemplateStatus.draft
          ? l10n.createNewTemplate
          : l10n.editTemplate,
      mainPanelTitle: _currentTemplate.status == TemplateStatus.draft
          ? l10n.createNewTemplate
          : l10n.editTemplate,
      mainPanelActions: [saveButton],
      rightPanelTitle: l10n.templateStructure,
      mainPanelIcon: Icons.edit,
      isEmbedded: _isEmbeddedInDesktop,
      useCompactTabLayout: true,
    );
  }

  Widget _buildStructurePanel(AppLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.templateStructure,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.templateStructureOverview,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const Divider(),
                  _buildElementSummary(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detailed field list
          if (_elements.isNotEmpty) _buildStructureDetails(),
        ],
      ),
    );
  }

  Widget _buildElementSummary() {
    // Use cached loops or compute if cache is invalid
    final content = _contentController.text;
    if (_cachedLoops == null || content != _lastContentForCache) {
      _cachedLoops = TemplateParser.findDataLoopsInContent(content);
      _cachedLoopsValid = TemplateParser.validateLoops(content);
      _lastContentForCache = content;
    }

    final loops = _cachedLoops!;
    final loopCount = loops.length;
    final loopsValid = _cachedLoopsValid!;

    // Tìm các element ngoài vòng lặp
    final elementsNotInLoop = _elements.where((e) => e.loopId == null).toList();
    final elementsInLoopCount = _elements.length - elementsNotInLoop.length;

    return Card(
      color: (_duplicateIds.isNotEmpty || !loopsValid)
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  (_duplicateIds.isNotEmpty || !loopsValid)
                      ? Icons.error_outline
                      : Icons.info_outline,
                  color: (_duplicateIds.isNotEmpty || !loopsValid)
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!
                      .fieldCount(_elementCount.toString()),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _duplicateIds.isNotEmpty
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '• ${elementsNotInLoop.length} ${AppLocalizations.of(context)!.basicFieldCount}'),
                  if (loopCount > 0)
                    Text(
                        '• $elementsInLoopCount ${AppLocalizations.of(context)!.loopFieldCount}'),
                ],
              ),
            ),
            if (loopCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Icon(
                      !loopsValid ? Icons.error_outline : Icons.refresh,
                      color: !loopsValid
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!
                          .loopDataCount(loopCount.toString()),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: !loopsValid
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            if (_duplicateIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  AppLocalizations.of(context)!
                      .duplicateIdWarning(_duplicateIds.length.toString()),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_elements.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề cho trường dữ liệu thông thường
                    if (_elements.any((e) => e.loopId == null))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          AppLocalizations.of(context)!.normalFields,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ),

                    // Hiển thị các trường dữ liệu không thuộc vòng lặp nào
                    if (_elements.any((e) => e.loopId == null))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _elements
                              .where((e) => e.loopId == null)
                              .map((element) {
                            final isDuplicate =
                                _duplicateIds.containsKey(element.id);
                            return Chip(
                              label: Text(
                                element.title,
                                style: TextStyle(
                                  color: isDuplicate
                                      ? Theme.of(context).colorScheme.error
                                      : null,
                                ),
                              ),
                              backgroundColor: isDuplicate
                                  ? Theme.of(context).colorScheme.errorContainer
                                  : null,
                              side: isDuplicate
                                  ? BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.error)
                                  : null,
                              avatar: _getElementTypeIcon(
                                  element.type, isDuplicate),
                            );
                          }).toList(),
                        ),
                      ),

                    // Hiển thị các trường dữ liệu theo từng vòng lặp
                    ..._buildLoopElementGroups(loops),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLoopElementGroups(List<DataLoop> loops) {
    final widgets = <Widget>[];

    for (final loop in loops) {
      // Lấy các phần tử trong vòng lặp này
      final loopElements = _elements.where((e) => e.loopId == loop.id).toList();
      if (loopElements.isEmpty) continue;

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề vòng lặp
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.refresh, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      AppLocalizations.of(context)!.loopLabel(loop.title),
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Container đặc biệt cho các chip trong vòng lặp
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((0.3 * 255).toInt()),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha((0.05 * 255).toInt()),
                ),
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(left: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hiển thị đường nối giữa các phần tử
                    if (loopElements.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 2.0),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha((0.3 * 255).toInt()),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha((0.3 * 255).toInt()),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withAlpha((0.3 * 255).toInt()),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Các chip
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: loopElements.map((element) {
                        final isDuplicate =
                            _duplicateIds.containsKey(element.id);
                        return ActionChip(
                          label: Text(
                            element.title,
                            style: TextStyle(
                              color: isDuplicate
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: isDuplicate
                              ? Theme.of(context).colorScheme.errorContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha((0.1 * 255).toInt()),
                          side: isDuplicate
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.error)
                              : BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withAlpha((0.5 * 255).toInt())),
                          elevation: 2,
                          shadowColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha((0.3 * 255).toInt()),
                          onPressed: () {
                            // Hiển thị tooltip hoặc thông tin chi tiết về trường dữ liệu trong vòng lặp
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context)!
                                      .fieldInLoop(element.title, loop.title),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          avatar: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: isDuplicate
                                    ? Theme.of(context)
                                        .colorScheme
                                        .errorContainer
                                        .withAlpha((0.7 * 255).toInt())
                                    : Theme.of(context)
                                        .colorScheme
                                        .tertiary
                                        .withAlpha((0.2 * 255).toInt()),
                                radius: 12,
                                child: _getElementTypeIcon(
                                    element.type, isDuplicate),
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.refresh,
                                    size: 8,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _getElementTypeIcon(String type, bool isError) {
    IconData iconData;
    switch (type) {
      case 'text':
        iconData = Icons.text_fields;
        break;
      case 'largetext':
        iconData = Icons.text_snippet;
        break;
      case 'number':
        iconData = Icons.numbers;
        break;
      case 'date':
        iconData = Icons.calendar_today;
        break;
      case 'time':
        iconData = Icons.access_time;
        break;
      case 'datetime':
        iconData = Icons.calendar_month;
        break;
      default:
        iconData = Icons.help_outline;
    }

    return Icon(iconData,
        color: isError ? Theme.of(context).colorScheme.error : null, size: 18);
  }

  void _showAddElementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddElementDialog(
        onAddField: _insertElementAtCursor,
        onAddLoop: _insertLoopAtCursor,
      ),
    );
  }

  void _insertElementAtCursor(TemplateElement element) {
    final elementString = element.toElementString();
    final text = _contentController.text;

    // Ưu tiên sử dụng saved position, fallback to current selection
    TextSelection? targetSelection = _savedCursorPosition;
    if (targetSelection == null ||
        !targetSelection.isValid ||
        targetSelection.start < 0) {
      targetSelection = _contentController.selection;
    }

    if (targetSelection.isValid &&
        targetSelection.start >= 0 &&
        targetSelection.start <= text.length) {
      // Insert at target cursor position
      final newText = text.replaceRange(
          targetSelection.start, targetSelection.end, elementString);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: targetSelection.start + elementString.length),
      );

      // Focus back to content field after insertion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _contentFocusNode.requestFocus();
        }
      });
    } else {
      // Fallback: Append to end
      final newText = text.isEmpty ? elementString : '$text $elementString';
      _contentController.text = newText;

      // Set cursor to end
      _contentController.selection =
          TextSelection.collapsed(offset: newText.length);

      // Focus back to content field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _contentFocusNode.requestFocus();
        }
      });
    }

    // Clear saved position after use
    _savedCursorPosition = null;
    _refreshElements();
  }

  void _insertLoopAtCursor(DataLoop loop) {
    final loopStartString = loop.toLoopStartString();
    final loopEndString = loop.toLoopEndString();
    final defaultContent =
        '\n${AppLocalizations.of(context)!.loopContent}\n'; // Default loop content
    final loopString = '$loopStartString$defaultContent$loopEndString';

    final text = _contentController.text;

    // Ưu tiên sử dụng saved position, fallback to current selection
    TextSelection? targetSelection = _savedCursorPosition;
    if (targetSelection == null ||
        !targetSelection.isValid ||
        targetSelection.start < 0) {
      targetSelection = _contentController.selection;
    }

    if (targetSelection.isValid &&
        targetSelection.start >= 0 &&
        targetSelection.start <= text.length) {
      // Insert at target cursor position
      final newText = text.replaceRange(
          targetSelection.start, targetSelection.end, loopString);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: targetSelection.start + loopString.length),
      );

      // Focus back to content field after insertion
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _contentFocusNode.requestFocus();
        }
      });
    } else {
      // Fallback: Append to end
      final newText = text.isEmpty ? loopString : '$text\n$loopString';
      _contentController.text = newText;

      // Set cursor to end
      _contentController.selection =
          TextSelection.collapsed(offset: newText.length);

      // Focus back to content field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _contentFocusNode.requestFocus();
        }
      });
    }

    // Clear saved position after use
    _savedCursorPosition = null;
    _refreshElements();
  }

  Future<void> _saveAsCompleteTemplate() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    if (_duplicateIds.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pleaseFixDuplicateIds),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      _currentTemplate.title = _titleController.text.trim();
      _currentTemplate.content = _contentController.text;
      _currentTemplate.status = TemplateStatus.complete; // Mark as complete
      _currentTemplate.updatedAt = DateTime.now();

      await TemplateService.saveTemplate(_currentTemplate);
      _initialTitle = _currentTemplate.title;
      _initialContent = _currentTemplate.content;
      _hasUnsavedChanges = false;
      if (mounted) {
        // Show success message
        SnackbarUtils.showTyped(
          context,
          AppLocalizations.of(context)!.templateEditSuccessMessage,
          SnackBarType.success,
        );
        // Handle navigation based on mode
        if (!_isEmbeddedInDesktop) {
          // Mobile mode: Use normal navigation
          Navigator.pop(context, true); // Return true to indicate success
        } else {
          // Desktop embedded mode: Just show success message
          // User can continue editing or use back button to return to list
          // No automatic navigation after save
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          AppLocalizations.of(context)!.errorSavingTemplate(e.toString()),
          SnackBarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAsDraft() async {
    _currentTemplate.title = _titleController.text;
    _currentTemplate.content = _contentController.text;
    _currentTemplate.status = TemplateStatus.draft; // Ensure it's a draft
    _currentTemplate.updatedAt = DateTime.now();

    try {
      await TemplateService.saveTemplate(_currentTemplate);
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          AppLocalizations.of(context)!.draftSaved,
          SnackBarType.success,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showTyped(
          context,
          AppLocalizations.of(context)!.errorSavingTemplate(e.toString()),
          SnackBarType.error,
        );
      }
    }
  }

  Widget _buildStructureDetails() {
    // Find loops in content
    final loops =
        TemplateParser.findDataLoopsInContent(_contentController.text);
    final elementsNotInLoop = _elements.where((e) => e.loopId == null).toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.structureDetail,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 16),

            // Trường dữ liệu cơ bản
            if (elementsNotInLoop.isNotEmpty) ...[
              _buildStructureSection(
                AppLocalizations.of(context)!.basicFields,
                elementsNotInLoop,
                Icons.text_fields,
              ),
              const SizedBox(height: 16),
            ],

            // Trường dữ liệu trong vòng lặp
            ...loops.map((loop) {
              final loopElements =
                  _elements.where((e) => e.loopId == loop.id).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStructureSection(
                    AppLocalizations.of(context)!.loopLabel(loop.title),
                    loopElements,
                    Icons.refresh,
                    isLoop: true,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStructureSection(
      String title, List<TemplateElement> elements, IconData icon,
      {bool isLoop = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(${elements.length})',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isLoop
                  ? Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha((0.3 * 255).toInt())
                  : Theme.of(context)
                      .colorScheme
                      .outline
                      .withAlpha((0.3 * 255).toInt()),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isLoop
                ? Theme.of(context)
                    .colorScheme
                    .primary
                    .withAlpha((0.05 * 255).toInt())
                : null,
          ),
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: elements.map((element) {
              final isDuplicate = _duplicateIds.containsKey(element.id);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    _getElementTypeIcon(element.type, isDuplicate),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        element.title,
                        style: TextStyle(
                          color: isDuplicate
                              ? Theme.of(context).colorScheme.error
                              : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      element.id,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha((0.6 * 255).toInt()),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<bool> _checkUnsavedChanges() async {
    if (!_hasUnsavedChanges) {
      return false;
    }

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChanges),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('stay'),
            child: Text(l10n.stayHere),
          ),
          TextButton(
            onPressed: () async {
              await _saveAsDraft();
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop('save_draft');
              }
            },
            child: Text(l10n.saveDraft),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop('exit');
            },
            child: Text(l10n.exitWithoutSaving),
          ),
        ],
      ),
    );

    if (result == 'exit') {
      return true;
    }
    if (result == 'save_draft') return true;

    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // On desktop, this is a good place to trigger auto-save when focus is lost.
    // On mobile, this handles when the app goes to the background.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      if (_hasUnsavedChanges &&
          _currentTemplate.status == TemplateStatus.draft) {
        _autoSaveDraftSync();
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.unsavedChanges),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('stay'),
            child: Text(l10n.stayHere),
          ),
          TextButton(
            onPressed: () async {
              await _saveAsDraft();
              if (mounted) {
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop('save_draft');
              }
            },
            child: Text(l10n.saveDraft),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop('exit');
            },
            child: Text(l10n.exitWithoutSaving),
          ),
        ],
      ),
    );

    if (result == 'exit') {
      return true;
    }
    if (result == 'save_draft') return true;

    return false; // Stay on page
  }
}

// Thêm widget dialog mới dùng SegmentedButton
class _AddElementDialog extends StatefulWidget {
  final void Function(TemplateElement) onAddField;
  final void Function(DataLoop) onAddLoop;

  const _AddElementDialog({
    required this.onAddField,
    required this.onAddLoop,
  });

  @override
  State<_AddElementDialog> createState() => _AddElementDialogState();
}

class _AddElementDialogState extends State<_AddElementDialog> {
  int _selectedTab = 0; // 0: Field, 1: Loop

  // Field form state
  String _fieldType = 'text';
  final TextEditingController _fieldTitleController = TextEditingController();
  final _fieldIdController =
      TextEditingController(text: const Uuid().v4().substring(0, 5));

  // Loop form state
  final TextEditingController _loopTitleController = TextEditingController();
  final _loopIdController =
      TextEditingController(text: const Uuid().v4().substring(0, 5));

  @override
  void dispose() {
    _fieldTitleController.dispose();
    _fieldIdController.dispose();
    _loopTitleController.dispose();
    _loopIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    return GenericDialog(
      header: GenericDialogHeader(
        title: l10n.addElement,
        icon: GenericIcon.icon(Icons.add),
        displayExitButton: true,
      ),
      body: SizedBox(
        height: screenSize.height * 0.8 > 500 ? 500 : screenSize.height * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<int>(
                segments: [
                  ButtonSegment(
                    value: 0,
                    label: Text(l10n.dataFields),
                    icon: const Icon(Icons.text_fields),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text(l10n.dataLoops),
                    icon: const Icon(Icons.repeat),
                  ),
                ],
                selected: {_selectedTab},
                onSelectionChanged: (s) {
                  setState(() => _selectedTab = s.first);
                },
              ),
              const SizedBox(height: 20),
              if (_selectedTab == 0) ...[
                // Add Data Field form
                TextField(
                  controller: _fieldTitleController,
                  decoration: InputDecoration(
                    labelText: l10n.fieldTitleLabel,
                    hintText: l10n.fieldTitleHint,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${l10n.fieldType}:'),
                ),
                const SizedBox(height: 8),
                _buildRadioOption(
                    'text', l10n.fieldTypeText, Icons.text_fields),
                _buildRadioOption(
                    'largetext', l10n.fieldTypeLargeText, Icons.text_snippet),
                _buildRadioOption(
                    'number', l10n.fieldTypeNumber, Icons.numbers),
                _buildRadioOption(
                    'date', l10n.fieldTypeDate, Icons.calendar_today),
                _buildRadioOption(
                    'time', l10n.fieldTypeTime, Icons.access_time),
                _buildRadioOption(
                    'datetime', l10n.fieldTypeDateTime, Icons.calendar_month),
              ] else ...[
                // Add Data Loop form
                TextField(
                  controller: _loopTitleController,
                  decoration: InputDecoration(
                    labelText: l10n.loopTitleLabel,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              ],
            ],
          ),
        ),
      ),
      footer: GenericDialogFooter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () {
                if (_selectedTab == 0) {
                  // Add Data Field
                  final title = _fieldTitleController.text.trim();
                  if (title.isEmpty) {
                    SnackbarUtils.showTyped(context, l10n.pleaseEnterFieldTitle,
                        SnackBarType.error);
                    return;
                  }
                  final element = TemplateElement(
                    type: _fieldType,
                    title: title,
                    id: _fieldIdController.text,
                  );
                  widget.onAddField(element);
                  Navigator.of(context).pop();
                } else {
                  // Add Data Loop
                  final title = _loopTitleController.text.trim();
                  if (title.isEmpty) {
                    SnackbarUtils.showTyped(context, l10n.pleaseEnterFieldTitle,
                        SnackBarType.error);
                    return;
                  }
                  final loop = DataLoop(
                      title: title,
                      id: _loopIdController.text,
                      elements: [],
                      rawContent: '');
                  widget.onAddLoop(loop);
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.add_task),
              label: Text(l10n.insertAtCursor),
            ),
          ],
        ),
      ),
      decorator: GenericDialogDecorator(
          width: DynamicDimension.flexibilityMax(94, 700)),
    );
  }

  Widget _buildRadioOption(String value, String label, IconData icon) {
    return RadioListTile<String>(
      value: value,
      groupValue: _fieldType,
      onChanged: (v) => setState(() => _fieldType = v!),
      title: Text(label),
      secondary: Icon(icon),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
