import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/template.dart';

class TemplateUseScreen extends StatefulWidget {
  final Template template;

  const TemplateUseScreen({
    super.key,
    required this.template,
  });

  @override
  State<TemplateUseScreen> createState() => _TemplateUseScreenState();
}

class _TemplateUseScreenState extends State<TemplateUseScreen>
    with SingleTickerProviderStateMixin {
  late String _previewText;
  late TabController _tabController;
  final Map<String, dynamic> _fieldValues = {};
  final List<TemplateElement> _elements = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _extractElements();
    _previewText = widget.template.content;
    _updatePreview();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _extractElements() {
    _elements.clear();
    _elements
        .addAll(TemplateManager.findElementsInContent(widget.template.content));

    // Sắp xếp các elements theo nhóm có cùng ID
    final elementGroups = TemplateManager.groupElementsById(_elements);

    // Initialize field values
    // Khởi tạo giá trị cho mỗi ID (không phải mỗi element)
    for (var entry in elementGroups.entries) {
      final element = entry.value.first; // Lấy element đầu tiên cho mỗi ID
      final id = element.id;

      switch (element.type) {
        case 'text':
          _fieldValues[id] = '';
          break;
        case 'largetext':
          _fieldValues[id] = '';
          break;
        case 'number':
          _fieldValues[id] = 0;
          break;
        case 'date':
          _fieldValues[id] = DateTime.now();
          break;
        case 'time':
          _fieldValues[id] = TimeOfDay.now();
          break;
        case 'datetime':
          _fieldValues[id] = DateTime.now();
          break;
      }
    }

    // Khởi tạo các vòng lặp dữ liệu
    final loops =
        TemplateManager.findDataLoopsInContent(widget.template.content);
    for (final loop in loops) {
      final loopId = loop.id;
      // Tạo một instance trống ban đầu cho mỗi vòng lặp
      _fieldValues['loop_instances_$loopId'] = [{}];
    }
  }

  void _updatePreview() {
    String content = widget.template.content;

    // Xử lý các vòng lặp trước
    final loops = TemplateManager.findDataLoopsInContent(content);
    for (final loop in loops) {
      final loopId = loop.id;
      final loopStartString = loop.toLoopStartString();
      final loopEndString = loop.toLoopEndString();

      // Tìm đoạn nội dung vòng lặp trong template
      final loopRegex = RegExp(
          RegExp.escape(loopStartString) +
              r'([\s\S]*?)' +
              RegExp.escape(loopEndString),
          multiLine: true);
      final loopMatch = loopRegex.firstMatch(content);

      if (loopMatch != null) {
        // Lấy nội dung mẫu của vòng lặp
        String loopTemplate = loopMatch.group(1) ?? '';

        // Danh sách các vòng lặp của loopId này
        final loopInstances = _getLoopInstances(loopId);
        String replacementContent = '';

        // Nếu không có instance nào, tạo một instance trống
        if (loopInstances.isEmpty) {
          _fieldValues['loop_instances_$loopId'] = [{}];
        }

        // Xử lý từng instance của vòng lặp
        for (int i = 0; i < loopInstances.length; i++) {
          final instance = loopInstances[i];
          String instanceContent = loopTemplate;

          // Thay thế các element trong vòng lặp
          final loopElements =
              _elements.where((e) => e.loopId == loopId).toList();
          for (var element in loopElements) {
            final instanceKey = '${element.id}_${loopId}_$i';
            String replacement;
            final value = instance[element.id];

            replacement = _getElementValueString(element, value);
            instanceContent = instanceContent.replaceAll(
                element.toElementString(), replacement);
          }

          replacementContent += instanceContent;
        }

        // Thay thế vòng lặp bằng nội dung đã xử lý
        content = content.replaceFirst(loopRegex, replacementContent);
      }
    }

    // Xử lý các element không thuộc vòng lặp
    for (var element in _elements.where((e) => e.loopId == null)) {
      String replacement;
      final value = _fieldValues[element.id];

      replacement = _getElementValueString(element, value);
      content = content.replaceAll(element.toElementString(), replacement);
    }

    setState(() {
      _previewText = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loops =
        TemplateManager.findDataLoopsInContent(widget.template.content);
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Document: ${widget.template.title}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Fill Data'),
            Tab(icon: Icon(Icons.visibility), text: 'Preview'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.description),
            tooltip: 'Show Document',
            onPressed: _showFinalDocument,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Fill Data
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Fill Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ..._buildFieldInputs(),
                  if (loops.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Data Loops',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...loops
                        .map((loop) => _buildDataLoopSection(loop))
                        .toList(),
                  ],
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _showFinalDocument,
                    icon: const Icon(Icons.text_snippet),
                    label: const Text('Generate Document'),
                  ),
                ],
              ),
            ),
          ),
          // Tab 2: Preview
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Preview',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                            onPressed: () => _copyPreviewText(),
                          ),
                        ],
                      ),
                      const Divider(),
                      Text(
                        _previewText,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFieldInputs() {
    final inputFields = <Widget>[];

    // Chỉ lấy các phần tử không thuộc vòng lặp
    final elementsNotInLoop = _elements.where((e) => e.loopId == null).toList();

    // Nhóm các elements theo ID
    final elementGroups = TemplateManager.groupElementsById(elementsNotInLoop);

    // Tạo 1 widget input cho mỗi ID duy nhất
    for (var entry in elementGroups.entries) {
      // Lấy element đại diện đầu tiên
      final element = entry.value.first;

      inputFields.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                element.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildInputForElement(element),
            ],
          ),
        ),
      );
    }

    return inputFields;
  }

  Widget _buildDataLoopSection(DataLoop loop) {
    final loopId = loop.id;

    // Tìm các phần tử trong vòng lặp này
    final loopElements = _elements.where((e) => e.loopId == loopId).toList();
    if (loopElements.isEmpty) {
      return const SizedBox.shrink();
    }

    // Lấy danh sách các instance hiện tại
    final loopInstances = _getLoopInstances(loopId);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  loop.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => _addLoopInstance(loopId),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New Row'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hiển thị từng instance của vòng lặp
            ...List.generate(loopInstances.length, (index) {
              return _buildLoopInstanceSection(loopId, index, loopElements);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoopInstanceSection(
      String loopId, int instanceIndex, List<TemplateElement> loopElements) {
    final instances = _getLoopInstances(loopId);
    final instance = instances[instanceIndex];
    final showDeleteButton = instances.length > 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Row ${instanceIndex + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (showDeleteButton)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () => _removeLoopInstance(loopId, instanceIndex),
                    tooltip: 'Delete this row',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...loopElements.map((element) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      element.title,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    _buildLoopElementInput(element, loopId, instanceIndex),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoopElementInput(
      TemplateElement element, String loopId, int instanceIndex) {
    final instances = _getLoopInstances(loopId);
    final instance = instances[instanceIndex];
    final value = instance[element.id];

    switch (element.type) {
      case 'text':
        return TextField(
          decoration: InputDecoration(
            hintText: 'Enter ${element.title.toLowerCase()}',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.text_fields),
          ),
          controller: TextEditingController(text: value?.toString() ?? ''),
          onChanged: (value) {
            _updateLoopInstanceValue(loopId, instanceIndex, element.id, value);
          },
        );

      case 'largetext':
        return TextField(
          decoration: InputDecoration(
            hintText: 'Enter ${element.title.toLowerCase()}',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.text_snippet),
          ),
          controller: TextEditingController(text: value?.toString() ?? ''),
          maxLines: null,
          minLines: 3,
          textAlignVertical: TextAlignVertical.top,
          onChanged: (value) {
            _updateLoopInstanceValue(loopId, instanceIndex, element.id, value);
          },
        );

      case 'number':
        return TextField(
          decoration: InputDecoration(
            hintText: 'Enter ${element.title.toLowerCase()}',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.numbers),
          ),
          controller: TextEditingController(text: value?.toString() ?? '0'),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _updateLoopInstanceValue(
                loopId, instanceIndex, element.id, int.tryParse(value) ?? 0);
          },
        );

      default:
        return Text('Field type ${element.type} not supported in loop');
    }
  }

  // Thêm một instance mới cho vòng lặp
  void _addLoopInstance(String loopId) {
    setState(() {
      final key = 'loop_instances_$loopId';
      List<Map<String, dynamic>> instances = _getLoopInstances(loopId);
      instances.add({});
      _fieldValues[key] = instances;
      _updatePreview();
    });
  }

  // Xóa một instance của vòng lặp
  void _removeLoopInstance(String loopId, int instanceIndex) {
    setState(() {
      final key = 'loop_instances_$loopId';
      List<Map<String, dynamic>> instances = _getLoopInstances(loopId);
      if (instances.length > 1) {
        instances.removeAt(instanceIndex);
        _fieldValues[key] = instances;
        _updatePreview();
      }
    });
  }

  // Cập nhật giá trị trong một instance của vòng lặp
  void _updateLoopInstanceValue(
      String loopId, int instanceIndex, String elementId, dynamic value) {
    setState(() {
      final key = 'loop_instances_$loopId';
      List<Map<String, dynamic>> instances = _getLoopInstances(loopId);
      instances[instanceIndex][elementId] = value;
      _fieldValues[key] = instances;
      _updatePreview();
    });
  }

  Widget _buildInputForElement(TemplateElement element) {
    switch (element.type) {
      case 'text':
        return TextField(
          decoration: InputDecoration(
            hintText: 'Enter ${element.title.toLowerCase()}',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.text_fields),
          ),
          onChanged: (value) {
            _fieldValues[element.id] = value;
            _updatePreview();
          },
        );

      case 'largetext':
        return TextField(
          decoration: InputDecoration(
            hintText: 'Enter ${element.title.toLowerCase()}',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.text_snippet),
          ),
          maxLines: null,
          minLines: 3,
          textAlignVertical: TextAlignVertical.top,
          onChanged: (value) {
            _fieldValues[element.id] = value;
            _updatePreview();
          },
        );

      case 'number':
        return TextField(
          decoration: InputDecoration(
            hintText: 'Enter ${element.title.toLowerCase()}',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.numbers),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _fieldValues[element.id] = int.tryParse(value) ?? 0;
            _updatePreview();
          },
        );

      case 'date':
        return InkWell(
          onTap: () async {
            final currentDate = _fieldValues[element.id] as DateTime?;
            final initialDate = currentDate ?? DateTime.now();
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                _fieldValues[element.id] = picked;
                _updatePreview();
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today),
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit_calendar),
                onPressed: () async {
                  final currentDate = _fieldValues[element.id] as DateTime?;
                  final initialDate = currentDate ?? DateTime.now();
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _fieldValues[element.id] = picked;
                      _updatePreview();
                    });
                  }
                },
              ),
            ),
            child: Text(
              _fieldValues[element.id] != null
                  ? DateFormat('dd/MM/yyyy')
                      .format(_fieldValues[element.id] as DateTime)
                  : 'Select date',
            ),
          ),
        );

      case 'time':
        return InkWell(
          onTap: () async {
            final currentTime = _fieldValues[element.id] as TimeOfDay?;
            final initialTime = currentTime ?? TimeOfDay.now();
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: initialTime,
            );
            if (picked != null) {
              setState(() {
                _fieldValues[element.id] = picked;
                _updatePreview();
              });
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.access_time),
              suffixIcon: IconButton(
                icon: const Icon(Icons.more_time),
                onPressed: () async {
                  final currentTime = _fieldValues[element.id] as TimeOfDay?;
                  final initialTime = currentTime ?? TimeOfDay.now();
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                  );
                  if (picked != null) {
                    setState(() {
                      _fieldValues[element.id] = picked;
                      _updatePreview();
                    });
                  }
                },
              ),
            ),
            child: Text(
              _fieldValues[element.id] != null
                  ? '${(_fieldValues[element.id] as TimeOfDay).hour.toString().padLeft(2, '0')}:${(_fieldValues[element.id] as TimeOfDay).minute.toString().padLeft(2, '0')}'
                  : 'Select time',
            ),
          ),
        );

      case 'datetime':
        return InkWell(
          onTap: () async {
            await _pickDateTime(element.id);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_month),
              suffixIcon: IconButton(
                icon: const Icon(Icons.edit_calendar),
                onPressed: () async {
                  await _pickDateTime(element.id);
                },
              ),
            ),
            child: Text(
              _fieldValues[element.id] != null
                  ? DateFormat('dd/MM/yyyy HH:mm')
                      .format(_fieldValues[element.id] as DateTime)
                  : 'Select date and time',
            ),
          ),
        );

      default:
        return const Text('Unsupported field type');
    }
  }

  Future<void> _pickDateTime(String elementId) async {
    final currentDate = _fieldValues[elementId] as DateTime?;
    final initialDate = currentDate ?? DateTime.now();

    // Pick date first
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Then pick time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        setState(() {
          _fieldValues[elementId] = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _updatePreview();
        });
      }
    }
  }

  // Lấy danh sách các instance của một vòng lặp
  List<Map<String, dynamic>> _getLoopInstances(String loopId) {
    final key = 'loop_instances_$loopId';
    if (_fieldValues.containsKey(key)) {
      final dynamicList = _fieldValues[key] as List<dynamic>;
      // Safely convert each map to Map<String, dynamic>
      return dynamicList.map((item) {
        if (item is Map) {
          // Convert each key to String and keep the dynamic values
          return Map<String, dynamic>.from(item);
        }
        // Fallback to empty map in case it's not a Map
        return <String, dynamic>{};
      }).toList();
    }
    return [];
  }

  // Lấy giá trị string hiển thị của một phần tử theo loại
  String _getElementValueString(TemplateElement element, dynamic value) {
    switch (element.type) {
      case 'text':
      case 'largetext':
        return value?.toString() ?? '';
      case 'number':
        return value?.toString() ?? '0';
      case 'date':
        if (value is DateTime) {
          return DateFormat('dd/MM/yyyy').format(value);
        }
        return '';
      case 'time':
        if (value is TimeOfDay) {
          return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
        }
        return '';
      case 'datetime':
        if (value is DateTime) {
          return DateFormat('dd/MM/yyyy HH:mm').format(value);
        }
        return '';
      default:
        return '';
    }
  }

  void _copyPreviewText() {
    Clipboard.setData(ClipboardData(text: _previewText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    });
  }

  void _showFinalDocument() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Completed Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: _previewText,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
              readOnly: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            onPressed: () {
              _copyPreviewText();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
