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
        // Save current group button (moved from functions panel)
        if (showSaveButton && onSaveCurrentGroup != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSaveCurrentGroup,
                    icon: const Icon(Icons.save, size: 18),
                    label: Text(l10n.saveCurrentToHistory),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withValues(alpha: 0.1),
                      foregroundColor: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),

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
                    final dateFormat = DateFormat.yMMMd(
                        Localizations.localeOf(context).languageCode);
                    final formattedDate = dateFormat.format(group.savedAt);

                    // Get first 3 functions for preview
                    final previewFunctions = group.functions.take(3).toList();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Function count badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${group.functions.length}',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
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
                          ],
                        ),
                        title: Text(
                          l10n.functionGroup,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.savedOn(formattedDate),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              l10n.functionsCount(group.functions.length),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                            // Show first few function expressions
                            ...previewFunctions.map((func) => Text(
                                  '${l10n.graphingFunction}${func.expression}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        fontFamily: 'monospace',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                            if (group.functions.length > 3)
                              Text(
                                '...',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                              ),
                          ],
                        ),
                        trailing: Row(
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
                        ),
                        onTap: () => onLoadGroup(group),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
