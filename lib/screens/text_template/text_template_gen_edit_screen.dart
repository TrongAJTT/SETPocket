import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/text_template.dart';
import 'package:setpocket/services/template_service.dart';
import 'package:setpocket/services/draft_service.dart';
import 'dart:async';

class TemplateEditScreen extends StatefulWidget {
  final Template? template; // Null for create new, non-null for edit
  final TemplateDraft? draft; // For continuing a draft
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory, IconData? icon})?
      onToolSelected;
  final Function(Future<bool> Function()?)? onRegisterUnsavedChangesCallback;

  const TemplateEditScreen({
    super.key,
    this.template,
    this.draft,
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

  // Draft-related state
  String? _currentDraftId;
  Timer? _autoSaveTimer;
  Timer? _debounceTimer; // Thêm debounce timer cho refresh elements
  bool _hasUnsavedChanges = false;
  String _initialTitle = '';
  String _initialContent = '';
  bool _isUserExiting =
      false; // Để kiểm soát việc auto-save khi user thoát thủ công

  // Auto-save optimization
  String _lastAutoSavedTitle = '';
  String _lastAutoSavedContent = '';
  DateTime? _lastAutoSaveTime;

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

    // Initialize from template or draft
    if (widget.draft != null) {
      // Continue from draft
      _currentDraftId = widget.draft!.id;
      _titleController.text = widget.draft!.title;
      _contentController.text = widget.draft!.content;
      _initialTitle = widget.draft!.title;
      _initialContent = widget.draft!.content;
    } else if (widget.template != null) {
      // Edit existing template
      _titleController.text = widget.template!.title;
      _contentController.text = widget.template!.content;
      _initialTitle = widget.template!.title;
      _initialContent = widget.template!.content;
      _currentDraftId = DraftService.generateDraftId();
    } else {
      // Create new template
      _currentDraftId = DraftService.generateDraftId();
    }

    _refreshElements();
    _setupAutoSave();
    _registerEmergencySave();

    // Register unsaved changes callback for desktop navigation
    if (widget.onRegisterUnsavedChangesCallback != null) {
      widget.onRegisterUnsavedChangesCallback!(_checkUnsavedChanges);
    }
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
    final hasChanges = _titleController.text != _initialTitle ||
        _contentController.text != _initialContent;
    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  Future<void> _autoSaveDraft() async {
    if (!_hasUnsavedChanges || _currentDraftId == null) return;

    final currentTitle = _titleController.text;
    final currentContent = _contentController.text;

    // Skip auto-save if content hasn't changed since last auto-save
    if (currentTitle == _lastAutoSavedTitle &&
        currentContent == _lastAutoSavedContent) {
      return;
    }

    // Skip auto-save if last save was less than 10 seconds ago (avoid spam)
    final now = DateTime.now();
    if (_lastAutoSaveTime != null &&
        now.difference(_lastAutoSaveTime!).inSeconds < 10) {
      return;
    }

    try {
      await DraftService.autoSaveDraft(
        draftId: _currentDraftId!,
        type: widget.template != null ? DraftType.edit : DraftType.create,
        originalTemplateId: widget.template?.templateId,
        title: currentTitle,
        content: currentContent,
      );

      // Update auto-save tracking
      _lastAutoSavedTitle = currentTitle;
      _lastAutoSavedContent = currentContent;
      _lastAutoSaveTime = now;

      // Show auto-save success on mobile only (desktop saves silently)
      if (mounted && !widget.isEmbedded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.autoSaved),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green.withValues(alpha: 0.8),
          ),
        );
      }
    } catch (e) {
      // Auto-save failures should be silent in production
      // But show error in debug mode on mobile only
      if (mounted && !widget.isEmbedded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Auto-save failed: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _registerEmergencySave() {
    // Register emergency save callback on both mobile and desktop
    DraftService.registerEmergencySaveCallback(_emergencySave);
  }

  void _emergencySave() {
    // Auto-save on both mobile and desktop when app is closing
    // But NOT when user is manually exiting with "don't save" choice
    if (_hasUnsavedChanges && _currentDraftId != null && !_isUserExiting) {
      _autoSaveDraftSync();
    }
  }

  @override
  void deactivate() {
    // Save draft on both mobile and desktop when widget is deactivated
    // But NOT when user is manually exiting with "don't save" choice
    if (_hasUnsavedChanges && _currentDraftId != null && !_isUserExiting) {
      _autoSaveDraftSync();
    }
    super.deactivate();
  }

  void _autoSaveDraftSync() {
    if (!_hasUnsavedChanges || _currentDraftId == null) return;

    try {
      // Use synchronous version for critical saves
      final draft = TemplateDraft(
        id: _currentDraftId!,
        type: widget.template != null ? DraftType.edit : DraftType.create,
        originalTemplateId: widget.template?.templateId,
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // For critical saves, use immediate save
      DraftService.saveDraft(draft);
    } catch (e) {
      // Even critical saves should be silent
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSaveTimer?.cancel();
    _debounceTimer?.cancel(); // Cancel debounce timer

    // Always unregister emergency save callback
    DraftService.unregisterEmergencySaveCallback(_emergencySave);

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

    // Clear cache when content changes
    if (content != _lastContentForCache) {
      _cachedLoops = null;
      _cachedLoopsValid = null;
      _lastContentForCache = content;
    }

    setState(() {
      _elements = TemplateManager.findElementsInContent(content);
      _duplicateIds = TemplateManager.findDuplicateIds(_elements);
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
    final isEditing = widget.template != null;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1000;

    // Build the main content
    Widget content;

    if (isDesktop) {
      // Desktop layout with responsive ratio
      content = _buildDesktopLayout(l10n, isEditing);
    } else {
      // Mobile layout: Tab view
      content = _buildMobileLayout(l10n, isEditing);
    }

    if (_isEmbeddedInDesktop) {
      // Desktop embedded view - no AppBar, just content with header
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? l10n.editTemplate : l10n.createTemplate,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (!_isLoading)
                  TextButton.icon(
                    icon: const Icon(Icons.save),
                    label: Text(l10n.save),
                    onPressed: _saveTemplate,
                  ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      );
    }

    // Mobile view - normal Scaffold with AppBar
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? l10n.editTemplate : l10n.createTemplate),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.save),
              label: Text(l10n.save),
              onPressed: _isLoading ? null : _saveTemplate,
            ),
          ],
          bottom: !isDesktop
              ? TabBar(
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.edit_document),
                      text: l10n.contentTab,
                    ),
                    Tab(
                      icon: const Icon(Icons.view_module),
                      text: l10n.structureTab,
                    ),
                  ],
                )
              : null,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : content,
      ),
    );
  }

  Widget _buildDesktopLayout(AppLocalizations l10n, bool isEditing) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive ratio based on screen width
    // Small desktop (1000-1400px): 3:2 ratio (60%:40%)
    // Large desktop (>1400px): 3:1 ratio (75%:25%)
    final isLargeDesktop = screenWidth > 1400;
    final contentFlex = isLargeDesktop ? 3 : 3;
    final structureFlex = isLargeDesktop ? 1 : 2;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.templateTitleLabel,
                border: const OutlineInputBorder(),
                hintText: l10n.templateTitleHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Buttons for adding fields and loops
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddFieldDialog,
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(l10n.addDataField),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddLoopDialog(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.addDataLoop),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Desktop: Side by side layout with responsive ratio
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content panel: responsive width
                  Expanded(
                    flex: contentFlex,
                    child: _buildContentPanel(l10n),
                  ),
                  const SizedBox(width: 24),
                  // Structure panel: responsive width
                  Expanded(
                    flex: structureFlex,
                    child: _buildStructurePanel(l10n),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(AppLocalizations l10n, bool isEditing) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.templateTitleLabel,
                border: const OutlineInputBorder(),
                hintText: l10n.templateTitleHint,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Buttons for adding fields and loops
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showAddFieldDialog,
                    icon: const Icon(Icons.add_circle_outline),
                    label: Text(l10n.addDataField),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddLoopDialog(),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.addDataLoop),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // TabBarView for content and structure
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Content
                  _buildContentPanel(l10n),

                  // Tab 2: Structure
                  _buildStructurePanel(l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPanel(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.templateContentLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextFormField(
              controller: _contentController,
              focusNode: _contentFocusNode,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintText: l10n.templateContentHint,
              ),
              maxLines: null,
              expands: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterTemplateContent;
                }
                return null;
              },
              onChanged: (_) => _debouncedRefreshElements(),
            ),
          ),
        ),
      ],
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
      _cachedLoops = TemplateManager.findDataLoopsInContent(content);
      _cachedLoopsValid = TemplateManager.validateLoops(content);
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

  void _showAddFieldDialog() {
    String selectedType = 'text';
    final titleController = TextEditingController();

    // Lưu vị trí con trỏ hiện tại, ưu tiên selection hiện tại hơn saved position
    final currentSelection = _contentController.selection;
    if (currentSelection.isValid && currentSelection.start >= 0) {
      _savedCursorPosition = currentSelection;
    } else if (_contentFocusNode.hasFocus) {
      _savedCursorPosition = _contentController.selection;
    }

    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.addDataField),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Loại trường:'),
                  const SizedBox(height: 8),
                  _buildRadioOption(
                      'text',
                      AppLocalizations.of(context)!.fieldTypeText,
                      Icons.text_fields,
                      selectedType, (value) {
                    setState(() {
                      selectedType = value;
                    });
                  }),
                  _buildRadioOption(
                      'largetext',
                      AppLocalizations.of(context)!.fieldTypeLargeText,
                      Icons.text_snippet,
                      selectedType, (value) {
                    setState(() {
                      selectedType = value;
                    });
                  }),
                  _buildRadioOption(
                      'number',
                      AppLocalizations.of(context)!.fieldTypeNumber,
                      Icons.numbers,
                      selectedType, (value) {
                    setState(() {
                      selectedType = value;
                    });
                  }),
                  _buildRadioOption(
                      'date',
                      AppLocalizations.of(context)!.fieldTypeDate,
                      Icons.calendar_today,
                      selectedType, (value) {
                    setState(() {
                      selectedType = value;
                    });
                  }),
                  _buildRadioOption(
                      'time',
                      AppLocalizations.of(context)!.fieldTypeTime,
                      Icons.access_time,
                      selectedType, (value) {
                    setState(() {
                      selectedType = value;
                    });
                  }),
                  _buildRadioOption(
                      'datetime',
                      AppLocalizations.of(context)!.fieldTypeDateTime,
                      Icons.calendar_month,
                      selectedType, (value) {
                    setState(() {
                      selectedType = value;
                    });
                  }),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.fieldTitleLabel,
                      hintText: AppLocalizations.of(context)!.fieldTitleHint,
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              FilledButton.icon(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .pleaseEnterFieldTitle)),
                    );
                    return;
                  }

                  final id = _generateElementId();
                  final element = TemplateElement(
                    type: selectedType,
                    title: title,
                    id: id,
                  );

                  _insertElementAtCursor(element);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.add_task),
                label: Text(AppLocalizations.of(context)!.insertAtCursor),
              ),
              FilledButton.icon(
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(AppLocalizations.of(context)!
                              .pleaseEnterFieldTitle)),
                    );
                    return;
                  }

                  final id = _generateElementId();
                  final element = TemplateElement(
                    type: selectedType,
                    title: title,
                    id: id,
                  );

                  _appendElementAtEnd(element);
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_downward),
                label: Text(AppLocalizations.of(context)!.appendToEnd),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRadioOption(String value, String label, IconData icon,
      String groupValue, void Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onChanged(value),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: (val) => onChanged(val!),
            ),
            Icon(icon),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  String _generateElementId() {
    return '${DateTime.now().millisecondsSinceEpoch % 10000}${_elements.length + 1}';
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

  void _appendElementAtEnd(TemplateElement element) {
    final elementString = element.toElementString();
    final text = _contentController.text;

    // Always append to end
    final newText = text.isEmpty ? elementString : '$text\n$elementString';
    _contentController.text = newText;

    _refreshElements();
  }

  void _showAddLoopDialog() {
    final titleController = TextEditingController();

    // Lưu vị trí con trỏ hiện tại, ưu tiên selection hiện tại hơn saved position
    final currentSelection = _contentController.selection;
    if (currentSelection.isValid && currentSelection.start >= 0) {
      _savedCursorPosition = currentSelection;
    } else if (_contentFocusNode.hasFocus) {
      _savedCursorPosition = _contentController.selection;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addDataLoop),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tiêu đề vòng lặp:'),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.loopTitleLabel,
                  hintText: AppLocalizations.of(context)!.loopTitleHint,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton.icon(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.pleaseEnterFieldTitle)),
                );
                return;
              }

              final id = _generateLoopId();
              final loop = DataLoop(
                title: title,
                id: id,
              );

              _insertLoopAtCursor(loop);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.add_task),
            label: Text(AppLocalizations.of(context)!.insertAtCursor),
          ),
          FilledButton.icon(
            onPressed: () {
              final title = titleController.text.trim();
              if (title.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          AppLocalizations.of(context)!.pleaseEnterFieldTitle)),
                );
                return;
              }

              final id = _generateLoopId();
              final loop = DataLoop(
                title: title,
                id: id,
              );

              _appendLoopAtEnd(loop);
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_downward),
            label: Text(AppLocalizations.of(context)!.appendToEnd),
          ),
        ],
      ),
    );
  }

  String _generateLoopId() {
    return 'loop_${DateTime.now().millisecondsSinceEpoch % 10000}'; // Loop ID
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

  void _appendLoopAtEnd(DataLoop loop) {
    final loopStartString = loop.toLoopStartString();
    final loopEndString = loop.toLoopEndString();
    final defaultContent = '\n${AppLocalizations.of(context)!.loopContent}\n';
    final loopString = '$loopStartString$defaultContent$loopEndString';

    final text = _contentController.text;

    // Always append to end with proper spacing
    final newText = text.isEmpty ? loopString : '$text\n\n$loopString';
    _contentController.text = newText;

    _refreshElements();
  }

  Future<void> _saveTemplate() async {
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
      final title = _titleController.text.trim();
      final content = _contentController.text;
      final String templateId =
          widget.template?.templateId ?? TemplateService.generateTemplateId();

      final template = Template(
        templateId: templateId,
        title: title,
        content: content,
      );

      await TemplateService.saveTemplate(template);

      // Delete draft after successful save
      if (_currentDraftId != null && widget.draft != null) {
        await DraftService.deleteDraft(_currentDraftId!);
      }

      // Update initial values to prevent unsaved changes dialog
      _initialTitle = title;
      _initialContent = content;
      _hasUnsavedChanges = false;

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context)!.templateEditSuccessMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
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
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .errorSavingTemplate(e.toString()))),
        );
      }
    }
  }

  Widget _buildStructureDetails() {
    // Find loops in content
    final loops =
        TemplateManager.findDataLoopsInContent(_contentController.text);
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

  Future<bool> _onWillPop() async {
    // This method is only called on mobile (PopScope)
    if (!_hasUnsavedChanges) {
      return true;
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
            onPressed: () => Navigator.of(context).pop('draft'),
            child: Text(l10n.saveDraft),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('exit'),
            child: Text(l10n.exitWithoutSaving),
          ),
        ],
      ),
    );

    switch (result) {
      case 'draft':
        try {
          await _saveDraft();
          return true;
        } catch (e) {
          // If saving draft fails, show error and don't exit
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save draft: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }
      case 'exit':
        _isUserExiting = true; // Prevent auto-save
        await _deleteDraft(); // Delete draft when user chooses to exit without saving
        return true;
      case 'stay':
      default:
        return false;
    }
  }

  // Callback for desktop navigation - check if there are unsaved changes
  Future<bool> _checkUnsavedChanges() async {
    if (!_hasUnsavedChanges) {
      return false; // No unsaved changes, allow navigation
    }

    // Show dialog for unsaved changes
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
            onPressed: () => Navigator.of(context).pop('draft'),
            child: Text(l10n.saveDraft),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('exit'),
            child: Text(l10n.exitWithoutSaving),
          ),
        ],
      ),
    );

    switch (result) {
      case 'draft':
        try {
          await _saveDraft();
          return false; // Allow navigation after saving draft
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save draft: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return true; // Prevent navigation if save failed
        }
      case 'exit':
        _isUserExiting = true; // Prevent auto-save
        await _deleteDraft(); // Delete draft when user chooses to exit without saving
        return false; // Allow navigation after deleting draft
      case 'stay':
      default:
        return true; // Prevent navigation, stay on current screen
    }
  }

  Future<void> _deleteDraft() async {
    if (_currentDraftId == null) return;

    try {
      await DraftService.deleteDraft(_currentDraftId!);
    } catch (e) {
      // Silent fail for draft deletion
    }
  }

  Future<void> _saveDraft() async {
    if (_currentDraftId == null) return;

    try {
      final draft = TemplateDraft(
        id: _currentDraftId!,
        type: widget.template != null ? DraftType.edit : DraftType.create,
        originalTemplateId: widget.template?.templateId,
        title: _titleController.text,
        content: _contentController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await DraftService.saveDraft(draft);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.draftSaved),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving draft: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Save draft on app state changes for both mobile and desktop
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // App is being minimized, closed, or switched away from
        if (_hasUnsavedChanges && _currentDraftId != null) {
          _autoSaveDraftSync();
        }
        break;
      case AppLifecycleState.resumed:
        // App is resuming - no action needed
        break;
      case AppLifecycleState.hidden:
        // App is hidden (desktop platforms)
        if (_hasUnsavedChanges && _currentDraftId != null) {
          _autoSaveDraftSync();
        }
        break;
    }
  }
}
