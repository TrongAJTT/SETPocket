import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/function_group_history.dart';
import 'package:intl/intl.dart';

class HistoryPanel extends StatelessWidget {
  final List<FunctionGroupHistory> groupHistory;
  final Function(FunctionGroupHistory) onLoadGroup;
  final Function(String) onRemoveGroup;
  final VoidCallback? onSaveCurrentGroup;
  final bool showSaveButton;

  const HistoryPanel({
    super.key,
    required this.groupHistory,
    required this.onLoadGroup,
    required this.onRemoveGroup,
    this.onSaveCurrentGroup,
    required this.showSaveButton,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // History list
        Expanded(
          child: groupHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noHistoryAvailable,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: groupHistory.length,
                  itemBuilder: (context, index) {
                    final group = groupHistory[index];
                    final previewFunctions = group.functions.take(3).toList();
                    return _buildHistoryCard(
                        context, group, l10n, previewFunctions);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, FunctionGroupHistory group,
      AppLocalizations l10n, List<dynamic> previewFunctions) {
    final dateTimeFormat = DateFormat('dd/MM HH:mm');
    final formattedDateTime = dateTimeFormat.format(group.savedAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with function count and actions
            Row(
              children: [
                // Function count badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${group.functions.length}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Function color indicators
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: previewFunctions.map((func) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: func.color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
                // Action buttons - show differently based on width
                LayoutBuilder(
                  builder: (context, constraints) {
                    // If parent width is small, show only menu button
                    return MediaQuery.of(context).size.width < 400
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'load') {
                                onLoadGroup(group);
                              } else if (value == 'delete') {
                                onRemoveGroup(group.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'load',
                                child: Row(
                                  children: [
                                    Icon(Icons.add,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                    const SizedBox(width: 8),
                                    Text(l10n.loadHistoryGroup),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                                    const SizedBox(width: 8),
                                    Text(l10n.removeFromHistory),
                                  ],
                                ),
                              ),
                            ],
                            child: const Icon(Icons.more_vert, size: 20),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: () => onLoadGroup(group),
                                tooltip: l10n.loadHistoryGroup,
                                style: IconButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                onPressed: () => onRemoveGroup(group.id),
                                tooltip: l10n.removeFromHistory,
                                style: IconButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ],
                          );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Show first few function expressions
            ...previewFunctions.map((func) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${l10n.graphingFunction}${func.expression}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Theme.of(context).colorScheme.outline,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
            if (group.functions.length > 3)
              Text(
                '...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            const SizedBox(height: 8),
            // Date/time at the bottom
            Text(
              formattedDateTime,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
