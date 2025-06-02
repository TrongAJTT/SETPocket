import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';
import '../models/text_template.dart';
import '../services/template_service.dart';

class TemplateEditScreen extends StatefulWidget {
  final Template? template; // Null for create new, non-null for edit

  const TemplateEditScreen({super.key, this.template});

  @override
  State<TemplateEditScreen> createState() => _TemplateEditScreenState();
}

class _TemplateEditScreenState extends State<TemplateEditScreen>
    with SingleTickerProviderStateMixin {
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
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // Refresh when tab changes
          _refreshElements();
        });
      }
    });

    if (widget.template != null) {
      _titleController.text = widget.template!.title;
      _contentController.text = widget.template!.content;
      _refreshElements();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _refreshElements() {
    final content = _contentController.text;
    setState(() {
      _elements = TemplateManager.findElementsInContent(content);
      _duplicateIds = TemplateManager.findDuplicateIds(_elements);
      _elementCount = _elements.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.template != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? AppLocalizations.of(context)!.editTemplate
            : AppLocalizations.of(context)!.createTemplate),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.save),
            label: Text(AppLocalizations.of(context)!.save),
            onPressed: _isLoading ? null : _saveTemplate,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.edit_document),
              text: AppLocalizations.of(context)!.contentTab,
            ),
            Tab(
              icon: const Icon(Icons.view_module),
              text: AppLocalizations.of(context)!.structureTab,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
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
                        labelText:
                            AppLocalizations.of(context)!.templateTitleLabel,
                        border: const OutlineInputBorder(),
                        hintText:
                            AppLocalizations.of(context)!.templateTitleHint,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppLocalizations.of(context)!.pleaseEnterTitle;
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
                            label: Text(
                                AppLocalizations.of(context)!.addDataField),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddLoopDialog(),
                            icon: const Icon(Icons.refresh),
                            label:
                                Text(AppLocalizations.of(context)!.addDataLoop),
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
                          _buildContentTab(),

                          // Tab 2: Structure
                          _buildStructureTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildElementSummary() {
    // Tìm các vòng lặp trong nội dung
    final loops =
        TemplateManager.findDataLoopsInContent(_contentController.text);
    final loopCount = loops.length;

    // Tìm các element ngoài vòng lặp
    final elementsNotInLoop = _elements.where((e) => e.loopId == null).toList();
    final elementsInLoopCount = _elements.length - elementsNotInLoop.length;

    // Kiểm tra tính hợp lệ của các vòng lặp
    final loopsValid = TemplateManager.validateLoops(_contentController.text);

    return Card(
      color: (_duplicateIds.isNotEmpty || !loopsValid)
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.surfaceVariant,
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
                  'Trường dữ liệu: $_elementCount',
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
                  Text('• ${elementsNotInLoop.length} trường dữ liệu cơ bản'),
                  if (loopCount > 0)
                    Text(
                        '• $elementsInLoopCount trường dữ liệu trong vòng lặp'),
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
                      'Vòng lặp dữ liệu: $loopCount',
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
                  'Phát hiện ${_duplicateIds.length} ID trùng lặp không nhất quán. Element có cùng ID phải có cùng loại và tiêu đề.',
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
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          'Trường dữ liệu thông thường:',
                          style: TextStyle(
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
                      'Vòng lặp: ${loop.title}',
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
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.05),
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
                                    .withOpacity(0.3),
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
                                      .withOpacity(0.3),
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
                                    .withOpacity(0.3),
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
                                  .withOpacity(0.1),
                          side: isDuplicate
                              ? BorderSide(
                                  color: Theme.of(context).colorScheme.error)
                              : BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5)),
                          elevation: 2,
                          shadowColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          onPressed: () {
                            // Hiển thị tooltip hoặc thông tin chi tiết về trường dữ liệu trong vòng lặp
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Trường "${element.title}" thuộc vòng lặp "${loop.title}"',
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
                                        .withOpacity(0.7)
                                    : Theme.of(context)
                                        .colorScheme
                                        .tertiary
                                        .withOpacity(0.2),
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

    // Lưu vị trí con trỏ trước khi hiển thị dialog
    _savedCursorPosition =
        _contentFocusNode.hasFocus ? _contentController.selection : null;

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
              TextButton.icon(
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

                  // Copy to clipboard and close dialog
                  Clipboard.setData(
                          ClipboardData(text: element.toElementString()))
                      .then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Đã sao chép vào clipboard')),
                    );
                    Navigator.of(context).pop();
                  });
                },
                icon: const Icon(Icons.copy),
                label: Text(AppLocalizations.of(context)!.copyAndClose),
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
    final selection = _savedCursorPosition ??
        (_contentFocusNode.hasFocus
            ? _contentController.selection
            : const TextSelection.collapsed(offset: -1));

    if (selection.start >= 0) {
      // Insert at cursor position
      final newText =
          text.replaceRange(selection.start, selection.end, elementString);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: selection.start + elementString.length),
      );
    } else {
      // Append to end
      final newText = text.isEmpty ? elementString : '$text $elementString';
      _contentController.text = newText;
    }

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

    // Lưu vị trí con trỏ trước khi hiển thị dialog
    _savedCursorPosition =
        _contentFocusNode.hasFocus ? _contentController.selection : null;

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
          TextButton.icon(
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
              // Copy to clipboard and close dialog
              final loopString =
                  '${loop.toLoopStartString()}\nNội dung vòng lặp\n${loop.toLoopEndString()}';
              Clipboard.setData(ClipboardData(text: loopString)).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép vào clipboard')),
                );
                Navigator.of(context).pop();
              });
            },
            icon: const Icon(Icons.copy),
            label: Text(AppLocalizations.of(context)!.copyAndClose),
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
    final defaultContent = '\nNội dung vòng lặp\n';
    final loopString = '$loopStartString$defaultContent$loopEndString';

    final text = _contentController.text;
    final selection = _savedCursorPosition ??
        (_contentFocusNode.hasFocus
            ? _contentController.selection
            : const TextSelection.collapsed(offset: -1));

    if (selection.start >= 0) {
      // Insert at cursor position
      final newText =
          text.replaceRange(selection.start, selection.end, loopString);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: selection.start + loopString.length),
      );
    } else {
      // Append to end
      final newText = text.isEmpty ? loopString : '$text\n$loopString';
      _contentController.text = newText;
    }

    _refreshElements();
  }

  void _appendLoopAtEnd(DataLoop loop) {
    final loopStartString = loop.toLoopStartString();
    final loopEndString = loop.toLoopEndString();
    final defaultContent = '\nLoop content\n'; // Default loop content
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
      final String id =
          widget.template?.id ?? TemplateService.generateTemplateId();

      final template = Template(
        id: id,
        title: title,
        content: content,
      );

      await TemplateService.saveTemplate(template);

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
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

  Widget _buildContentTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.templateContentLabel,
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
                hintText: AppLocalizations.of(context)!.templateContentHint,
              ),
              maxLines: null,
              expands: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppLocalizations.of(context)!
                      .pleaseEnterTemplateContent;
                }
                return null;
              },
              onChanged: (_) => _refreshElements(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStructureTab() {
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
                    AppLocalizations.of(context)!.templateStructure,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.templateStructureOverview,
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
              'Chi tiết cấu trúc',
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
                'Trường dữ liệu cơ bản',
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
                    'Vòng lặp: ${loop.title}',
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
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(8),
            color: isLoop
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
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
                            .withOpacity(0.6),
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
}
