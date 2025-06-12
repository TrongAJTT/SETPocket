import 'package:flutter/material.dart';
import 'package:setpocket/l10n/app_localizations.dart';

class BatchDeleteDialog extends StatefulWidget {
  final int templateCount;
  final VoidCallback onConfirm;

  const BatchDeleteDialog({
    Key? key,
    required this.templateCount,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<BatchDeleteDialog> createState() => _BatchDeleteDialogState();
}

class _BatchDeleteDialogState extends State<BatchDeleteDialog> {
  final TextEditingController _confirmController = TextEditingController();
  bool _isConfirmationValid = false;

  @override
  void initState() {
    super.initState();
    _confirmController.addListener(_validateConfirmation);
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  void _validateConfirmation() {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isConfirmationValid = _confirmController.text.trim() == l10n.confirmText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.confirmBatchDelete),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.typeConfirmToDelete(widget.templateCount)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: l10n.confirmText,
            ),
            autofocus: true,
          ),
          const SizedBox(height: 8),
          if (_confirmController.text.isNotEmpty && !_isConfirmationValid)
            Text(
              l10n.confirmationRequired,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isConfirmationValid
              ? () {
                  Navigator.of(context).pop();
                  widget.onConfirm();
                }
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.batchDelete),
        ),
      ],
    );
  }
}
