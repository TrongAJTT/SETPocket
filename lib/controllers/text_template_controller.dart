import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:setpocket/models/text_template/text_templates_data.dart';
import 'package:setpocket/services/text_template_services/text_template_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class TextTemplateController extends GetxController {
  // --- Dependencies ---
  final TextTemplatesData? template;
  final String? initialTitle;
  final String? initialContent;

  // --- UI State & Controllers ---
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final contentFocusNode = FocusNode();
  late TabController tabController;

  // --- Internal State ---
  late Rx<TextTemplatesData> _currentTemplate;
  final _uuid = const Uuid();
  Timer? _autoSaveTimer;
  bool _hasUnsavedChanges = false;
  String _initialStateJson = '';

  TextTemplateController(
      {this.template, this.initialTitle, this.initialContent});

  // This method is required to be called from the State that uses the TickerProvider
  void initializeTabController(TickerProvider vsync) {
    tabController = TabController(length: 2, vsync: vsync);
  }

  @override
  void onInit() {
    super.onInit();
    _initializeTemplate();
    _setupListeners();
  }

  @override
  void onClose() {
    _autoSaveTimer?.cancel();
    titleController.dispose();
    contentController.dispose();
    contentFocusNode.dispose();
    tabController.dispose();
    super.onClose();
  }

  void _initializeTemplate() {
    if (template != null) {
      _currentTemplate = template!.obs;
    } else {
      _currentTemplate = (TextTemplatesData()
            ..id = _uuid.v4()
            ..title = initialTitle ?? ''
            ..content = initialContent ?? ''
            ..status = TemplateStatus.draft
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now())
          .obs;
    }
    titleController.text = _currentTemplate.value.title;
    contentController.text = _currentTemplate.value.content;
    _initialStateJson = _currentTemplate.value.toJson().toString();
  }

  void _setupListeners() {
    titleController.addListener(_onContentChanged);
    contentController.addListener(_onContentChanged);

    _autoSaveTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _autoSaveDraft();
    });
  }

  void _onContentChanged() {
    // Creating a new instance to compare for changes
    final tempState = TextTemplatesData()
      ..id = _currentTemplate.value.id
      ..title = titleController.text
      ..content = contentController.text
      ..status = _currentTemplate.value.status
      ..createdAt = _currentTemplate.value.createdAt
      ..updatedAt = _currentTemplate.value.updatedAt;

    _hasUnsavedChanges = tempState.toJson().toString() != _initialStateJson;
    update(); // Notify GetX listeners
  }

  Future<void> _autoSaveDraft() async {
    if (!_hasUnsavedChanges ||
        _currentTemplate.value.status != TemplateStatus.draft) {
      return;
    }
    _currentTemplate.update((val) {
      val!.title = titleController.text;
      val.content = contentController.text;
      val.updatedAt = DateTime.now();
    });

    await TemplateService.saveTemplate(_currentTemplate.value);
    _initialStateJson = _currentTemplate.value.toJson().toString();
    _hasUnsavedChanges = false;
    update();
  }

  Future<void> saveAsCompleteTemplate() async {
    if (formKey.currentState?.validate() != true) return;

    _currentTemplate.update((val) {
      val!.title = titleController.text;
      val.content = contentController.text;
      val.status = TemplateStatus.complete;
      val.updatedAt = DateTime.now();
    });

    await TemplateService.saveTemplate(_currentTemplate.value);
    Get.back(result: true); // Go back and indicate success
  }

  Future<bool> confirmDiscardUnsavedChanges() async {
    if (!_hasUnsavedChanges) return true;

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'Do you want to save the changes as a draft or discard them?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Stay')),
          TextButton(
              onPressed: () async {
                await _autoSaveDraft();
                Get.back(result: true);
              },
              child: const Text('Save Draft')),
          TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Discard')),
        ],
      ),
    );
    return result ?? false;
  }
}
