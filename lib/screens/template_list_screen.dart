import 'package:flutter/material.dart';
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
        SnackBar(content: Text('Lỗi khi tải mẫu: ${e.toString()}')),
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
        title: const Text('Mẫu văn bản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Hướng dẫn',
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
        onPressed: () => _navigateToCreateTemplate(),
        tooltip: 'Thêm mẫu mới',
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
              'Chưa có mẫu văn bản nào',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Tạo mẫu văn bản để tăng hiệu quả công việc của bạn. Bấm nút + để bắt đầu.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _navigateToCreateTemplate(),
              icon: const Icon(Icons.add),
              label: const Text('Tạo mẫu mới'),
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
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Sửa'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Xóa', style: TextStyle(color: Colors.red)),
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
        title: const Text('Xác nhận xóa'),
        content:
            Text('Bạn có chắc chắn muốn xóa mẫu "${template.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteTemplate(template.id);
            },
            child: const Text('Xóa'),
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
          const SnackBar(content: Text('Đã xóa mẫu thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa mẫu: ${e.toString()}')),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hướng dẫn sử dụng'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Công cụ này giúp bạn tạo các mẫu văn bản có thể tái sử dụng.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• Nhấn vào nút + để tạo mẫu mới'),
              Text('• Nhấn vào mẫu để sử dụng và tạo văn bản'),
              Text('• Nhấn vào nút ... để sửa hoặc xóa mẫu'),
              SizedBox(height: 16),
              Text(
                'Trong màn hình tạo mẫu, bạn có thể thêm các trường thông tin để điền sau này như văn bản, số, ngày tháng...',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}
