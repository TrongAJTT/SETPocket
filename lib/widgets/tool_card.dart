import 'package:flutter/material.dart';
import 'package:my_multi_tools/l10n/app_localizations.dart';

class ToolCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;
  final IconData icon;
  final Color? iconColor;
  final bool showActions;

  const ToolCard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
    this.icon = Icons.apps,
    this.iconColor,
    this.showActions = true,
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
                if (showActions)
                  PopupMenuButton<String>(
                    tooltip: AppLocalizations.of(context)!.options,
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'info',
                        child: ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: Text(AppLocalizations.of(context)!.about),
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
                                child:
                                    Text(AppLocalizations.of(context)!.close),
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
