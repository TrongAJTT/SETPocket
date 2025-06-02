import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'screens/batch_video_detail_viewer.dart';
import 'screens/template_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multi Tools',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is less than 600, we consider it mobile layout
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return const MobileLayout();
        } else {
          return const DesktopLayout();
        }
      },
    );
  }
}

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi Tools'),
      ),
      body: const ToolSelectionScreen(),
    );
  }
}

class DesktopLayout extends StatefulWidget {
  const DesktopLayout({super.key});

  @override
  State<DesktopLayout> createState() => _DesktopLayoutState();
}

class _DesktopLayoutState extends State<DesktopLayout> {
  Widget? currentTool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: ToolSelectionScreen(
              isDesktop: true,
              onToolSelected: (Widget tool) {
                setState(() {
                  currentTool = tool;
                });
              },
            ),
          ),
          Expanded(
            child: currentTool ??
                const Center(
                  child: Text('Select a tool from the sidebar'),
                ),
          ),
        ],
      ),
    );
  }
}

class ToolSelectionScreen extends StatelessWidget {
  final bool isDesktop;
  final Function(Widget)? onToolSelected;

  const ToolSelectionScreen({
    super.key,
    this.isDesktop = false,
    this.onToolSelected,
  });
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ToolCard(
          title: 'Batch Video Detail Viewer',
          description:
              'Xem thông tin chi tiết của nhiều video cùng lúc. Bạn có thể xem kích thước, thời lượng, bitrate, độ phân giải, tốc độ khung hình và thông tin âm thanh.',
          icon: Icons.video_library,
          iconColor: Colors.red.shade700,
          onTap: () {
            final tool = const BatchVideoDetailViewer();
            if (isDesktop) {
              onToolSelected?.call(tool);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => tool,
                ),
              );
            }
          },
        ),
        ToolCard(
          title: 'Tạo Văn Bản Theo Mẫu',
          description:
              'Tạo văn bản theo biểu mẫu có sẵn. Bạn có thể tạo các mẫu văn bản với các trường thông tin cần điền sau như văn bản, số, ngày tháng để sử dụng lại nhiều lần.',
          icon: Icons.description,
          iconColor: Colors.blue.shade800,
          onTap: () {
            final tool = const TemplateListScreen();
            if (isDesktop) {
              onToolSelected?.call(tool);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => tool,
                ),
              );
            }
          },
        ),
        // Các công cụ khác sẽ được thêm vào sau
      ],
    );
  }
}

class ToolCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final IconData icon;
  final Color? iconColor;

  const ToolCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.icon = Icons.apps,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Tooltip(
        message: description,
        waitDuration: const Duration(milliseconds: 500),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon,
                    size: 28,
                    color: iconColor ?? Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Options',
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'info',
                      child: ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text('About'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'info') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(title),
                          content: Text(description),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
