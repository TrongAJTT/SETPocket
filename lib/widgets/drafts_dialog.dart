import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/models/text_template.dart';
import 'package:setpocket/services/draft_service.dart';

class DraftsDialog extends StatefulWidget {
  final Function(TemplateDraft draft)? onDraftSelected;

  const DraftsDialog({
    super.key,
    this.onDraftSelected,
  });

  @override
  State<DraftsDialog> createState() => _DraftsDialogState();
}

class _DraftsDialogState extends State<DraftsDialog> {
  List<TemplateDraft> _drafts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final drafts = await DraftService.getDrafts();
      setState(() {
        _drafts = drafts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDraft(TemplateDraft draft) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteDraft),
        content: Text(l10n.confirmDeleteDraftMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.deleteDraft),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DraftService.deleteDraft(draft.id);
        await _loadDrafts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.draftDeleted)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting draft: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _publishDraft(TemplateDraft draft) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      await DraftService.publishDraft(draft.id);
      await _loadDrafts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.draftPublished)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error publishing draft: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatDateMobile(DateTime date) {
    return DateFormat('dd/MM/yy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isDesktop = screenWidth >= 900;
    final isMobile = screenWidth < 600;

    return Dialog(
      insetPadding: isMobile
          ? const EdgeInsets.all(16)
          : const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 800 : (isMobile ? screenWidth - 32 : 600),
          maxHeight: isDesktop ? 700 : (isMobile ? screenHeight * 0.85 : 600),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha(50),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drafts,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.manageDrafts,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.draftsExpireAfter,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _drafts.isEmpty
                      ? _buildEmptyState(l10n)
                      : _buildDraftsList(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.drafts_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDraftsYet,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.createDraftsHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftsList(AppLocalizations l10n) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _drafts.length,
      itemBuilder: (context, index) {
        final draft = _drafts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and type
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        draft.displayTitle,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: draft.type == DraftType.create
                            ? Colors.green.withAlpha(50)
                            : Colors.blue.withAlpha(50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        draft.type == DraftType.create
                            ? l10n.newDraft
                            : l10n.editDraft,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: draft.type == DraftType.create
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Content preview
                if (draft.content.trim().isNotEmpty)
                  Text(
                    draft.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 12),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isMobile
                                ? _formatDateMobile(
                                    draft.createdAt) // Shorter date on mobile
                                : l10n.draftCreatedOn(_formatDate(
                                    draft.createdAt)), // Full text on desktop
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                          if (draft.updatedAt.isAfter(draft.createdAt))
                            Text(
                              isMobile
                                  ? 'Updated: ${_formatDateMobile(draft.updatedAt)}' // Shorter version
                                  : l10n.draftUpdatedOn(_formatDate(
                                      draft.updatedAt)), // Full text
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Actions - Responsive layout
                if (isMobile)
                  // Mobile: Column layout với buttons full width
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDraftSelected?.call(draft);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.continueDraft),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _publishDraft(draft),
                              icon: const Icon(Icons.publish),
                              label: Text(l10n.publishDraft),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _deleteDraft(draft),
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              label: Text(
                                l10n.deleteDraft,
                                style: const TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  // Desktop: Row layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _deleteDraft(draft),
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        label: Text(
                          l10n.deleteDraft,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _publishDraft(draft),
                        icon: const Icon(Icons.publish),
                        label: Text(l10n.publishDraft),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDraftSelected?.call(draft);
                        },
                        icon: const Icon(Icons.edit),
                        label: Text(l10n.continueDraft),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
