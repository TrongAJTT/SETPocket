import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/utils/template_parser.dart';
import 'package:setpocket/models/text_template/text_template_components.dart';
import 'package:setpocket/utils/snackbar_utils.dart';
import 'package:setpocket/widgets/generic/generic_date_time_picker.dart';
import 'package:setpocket/layouts/two_panels_layout.dart';

class TemplateUseScreen extends StatefulWidget {
  final TextTemplatesData template;
  final bool isEmbedded;
  final Function(Widget, String, {String? parentCategory, IconData? icon})?
      onToolSelected;

  const TemplateUseScreen({
    super.key,
    required this.template,
    this.isEmbedded = false,
    this.onToolSelected,
  });

  @override
  State<TemplateUseScreen> createState() => _TemplateUseScreenState();
}

class _TemplateUseScreenState extends State<TemplateUseScreen>
    with SingleTickerProviderStateMixin {
  late List<TemplateElement> _elements;
  late List<DataLoop> _loops;
  late TabController _tabController;
  bool _isInitialized = false;

  final Map<String, dynamic> _fieldValues = {};
  final Map<String, List<Map<String, dynamic>>> _loopInstances = {};
  final Map<String, TextEditingController> _controllers = {};

  String _generatedContent = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _updatePreview();
      _isInitialized = true;
    }
  }

  void _initializeData() {
    _elements = TemplateParser.findElementsInContent(widget.template.content);
    _loops = TemplateParser.findDataLoopsInContent(widget.template.content);

    for (var element in _elements.where((el) => el.loopId == null)) {
      final defaultValue = _getDefaultValueForType(element.type);
      _fieldValues[element.id] = defaultValue;

      if (defaultValue is String || defaultValue is num) {
        final controller = TextEditingController(text: defaultValue.toString());
        _controllers[element.id] = controller;
        controller.addListener(() {
          _fieldValues[element.id] = controller.text;
          _updatePreview();
        });
      }
    }

    for (var loop in _loops) {
      _loopInstances[loop.id] = [];
      _addLoopInstance(loop.id, shouldUpdateState: false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _formatValue(dynamic value, String type) {
    if (value is DateTime) {
      if (type == 'date') return DateFormat.yMd().format(value);
      if (type == 'datetime') return DateFormat.yMd().add_jm().format(value);
    }
    if (value is TimeOfDay) {
      return value.format(context);
    }
    return value.toString();
  }

  void _updatePreview() {
    String tempContent = widget.template.content;

    for (var element in _elements.where((el) => el.loopId == null)) {
      final placeholder = '{{${element.id}:${element.title}:${element.type}}}';
      final value = _fieldValues[element.id];
      tempContent = tempContent.replaceAll(
          placeholder, _formatValue(value, element.type));
    }

    for (var loop in _loops) {
      final loopBlockPattern = RegExp(
          '\\[\\[LOOP:${loop.id}:${loop.title}\\]\\](.*?)\\[\\[/LOOP:${loop.id}\\]\\]',
          dotAll: true);

      final generatedLoopContent = StringBuffer();
      final instances = _loopInstances[loop.id] ?? [];

      for (var instance in instances) {
        String instanceContent = loop.rawContent;
        for (var element in loop.elements) {
          final placeholder =
              '{{${element.id}:${element.title}:${element.type}}}';
          final value = instance[element.id];
          instanceContent = instanceContent.replaceAll(
              placeholder, _formatValue(value, element.type));
        }
        generatedLoopContent.write(instanceContent);
      }
      tempContent = tempContent.replaceAll(
          loopBlockPattern, generatedLoopContent.toString());
    }

    if (mounted) {
      setState(() {
        _generatedContent = tempContent;
      });
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _generatedContent));
    if (mounted) {
      SnackbarUtils.showTyped(
          context,
          AppLocalizations.of(context)!.copiedToClipboard,
          SnackBarType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final fillDataPanel = _buildFillDataPanel(l10n);
    final previewPanel = _buildPreviewPanel(l10n);

    return TwoPanelsLayout(
      mainPanel: fillDataPanel,
      rightPanel: previewPanel,
      title: '${l10n.generateDocument}: ${widget.template.title}',
      mainPanelTitle: l10n.fillDataTab,
      rightPanelTitle: l10n.preview,
      mainPanelIcon: Icons.edit,
      isEmbedded: widget.isEmbedded,
      mainPanelActions: [
        IconButton(
          icon: const Icon(Icons.copy),
          onPressed: _copyToClipboard,
          tooltip: l10n.copy,
        ),
      ],
    );
  }

  Widget _buildFillDataPanel(AppLocalizations l10n) {
    final elementsNotInLoop = _elements.where((e) => e.loopId == null).toList();
    return ListView(
      children: [
        ...elementsNotInLoop.map((element) => _buildInputField(element, l10n)),
        ..._loops.map((loop) => _buildDataLoopSection(loop, l10n)),
      ],
    );
  }

  Widget _buildPreviewPanel(AppLocalizations l10n) {
    return SingleChildScrollView(
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
                    l10n.preview,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.copy),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
              const Divider(),
              SelectableText(
                _generatedContent,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TemplateElement element, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(element.title,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _buildInputForElement(element, l10n, (value) {
            setState(() {
              _fieldValues[element.id] = value;
              _updatePreview();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildDataLoopSection(DataLoop loop, AppLocalizations l10n) {
    final loopInstances = _loopInstances[loop.id] ?? [];
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
                Text(loop.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                FilledButton.icon(
                  onPressed: () => _addLoopInstance(loop.id),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.addNewRow),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(loopInstances.length, (index) {
              return _buildLoopInstanceSection(loop, index, l10n);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoopInstanceSection(
      DataLoop loop, int instanceIndex, AppLocalizations l10n) {
    final showDeleteButton = (_loopInstances[loop.id]?.length ?? 0) > 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color:
          Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.rowNumber(instanceIndex + 1),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                if (showDeleteButton)
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error),
                    onPressed: () =>
                        _removeLoopInstance(loop.id, instanceIndex),
                  ),
              ],
            ),
            ...loop.elements.map((element) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(element.title,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    _buildInputForElement(element, l10n, (value) {
                      _updateLoopInstanceValue(
                          loop.id, instanceIndex, element.id, value);
                    }),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForElement(TemplateElement element, AppLocalizations l10n,
      Function(dynamic) onValueChanged) {
    final value = _fieldValues[element.id];

    switch (element.type) {
      case 'text':
      case 'largetext':
        return TextField(
          controller: _controllers[element.id],
          maxLines: element.type == 'largetext' ? 3 : 1,
          decoration: InputDecoration(
            hintText: l10n.enterField(element.title),
            border: const OutlineInputBorder(),
          ),
        );
      case 'number':
        return TextField(
          controller: _controllers[element.id],
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: l10n.enterField(element.title),
            border: const OutlineInputBorder(),
          ),
        );
      case 'date':
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value is DateTime ? value : DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) onValueChanged(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            child: Text(_formatValue(value, 'date')),
          ),
        );
      case 'time':
        return InkWell(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: value is TimeOfDay ? value : TimeOfDay.now(),
            );
            if (picked != null) onValueChanged(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            child: Text(_formatValue(value, 'time')),
          ),
        );
      case 'datetime':
        return InkWell(
          onTap: () async {
            final picked = await showGenericDateTimePickerDialog(
              context,
              initialDateTime: value is DateTime ? value : DateTime.now(),
              use24hrFormat: true,
            );
            if (picked != null) onValueChanged(picked);
          },
          child: InputDecorator(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            child: Text(_formatValue(value, 'datetime')),
          ),
        );
      default:
        return Text(l10n.unsupportedFieldType(element.type));
    }
  }

  void _addLoopInstance(String loopId, {bool shouldUpdateState = true}) {
    final loop = _loops.firstWhere((l) => l.id == loopId);
    final newInstance = <String, dynamic>{};
    for (var element in loop.elements) {
      newInstance[element.id] = _getDefaultValueForType(element.type);
    }

    if (shouldUpdateState) {
      setState(() => _loopInstances[loopId]!.add(newInstance));
    } else {
      _loopInstances[loopId]!.add(newInstance);
    }
  }

  void _removeLoopInstance(String loopId, int index) {
    if ((_loopInstances[loopId]?.length ?? 0) > 1) {
      setState(() => _loopInstances[loopId]!.removeAt(index));
    }
  }

  void _updateLoopInstanceValue(
      String loopId, int instanceIndex, String elementId, dynamic value) {
    setState(() {
      _loopInstances[loopId]![instanceIndex][elementId] = value;
      _updatePreview();
    });
  }

  dynamic _getDefaultValueForType(String type) {
    switch (type) {
      case 'text':
      case 'largetext':
        return '';
      case 'number':
        return 0;
      case 'date':
      case 'datetime':
        return DateTime.now();
      case 'time':
        return TimeOfDay.now();
      default:
        return '';
    }
  }
}
