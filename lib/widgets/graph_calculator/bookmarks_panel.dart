import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookmarksPanel extends StatelessWidget {
  final List<Map<String, dynamic>> groupHistory;
  final Function(Map<String, dynamic>) onLoadGroup;
  final Function(Map<String, dynamic>) onRemoveGroup;
  final VoidCallback? onSaveCurrentGroup;
  final bool showSaveButton;

  const BookmarksPanel({
    super.key,
    required this.groupHistory,
    required this.onLoadGroup,
    required this.onRemoveGroup,
    this.onSaveCurrentGroup,
    this.showSaveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (groupHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Bookmarks Available', // Using hardcoded text
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: groupHistory.length,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemBuilder: (context, index) {
        final group = groupHistory[index];
        final functions = (group['functions'] as List<dynamic>?)
                ?.map((e) => e['expression'].toString())
                .toList() ??
            [];
        final timestamp = group['timestamp'] != null
            ? DateTime.parse(group['timestamp'])
            : DateTime.now();
        final colors = (group['functions'] as List<dynamic>?)
                ?.map((e) => Color(e['color'] as int))
                .toList() ??
            [];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        functions.length.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (colors.isNotEmpty)
                      Row(
                        children: colors
                            .take(4)
                            .map((color) => Container(
                                  width: 12,
                                  height: 12,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ))
                            .toList(),
                      ),
                    if (colors.length > 4)
                      const Text(
                        '...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_task_outlined),
                      tooltip: 'Load Bookmark', // Using hardcoded text
                      onPressed: () => onLoadGroup(group),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: theme.colorScheme.error),
                      tooltip: 'Delete Bookmark', // Using hardcoded text
                      onPressed: () => onRemoveGroup(group),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const Divider(height: 16),
                ...functions.take(3).map((expr) => Text(
                      'f(x) = $expr',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontFamily: 'monospace'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                if (functions.length > 3)
                  Text(
                    '...',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontFamily: 'monospace'),
                  ),
                const SizedBox(height: 8),
                Text(
                  DateFormat.yMd().add_jm().format(timestamp),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
