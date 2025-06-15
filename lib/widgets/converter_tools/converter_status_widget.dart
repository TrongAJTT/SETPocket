import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:setpocket/controllers/converter_controller.dart';
import 'package:setpocket/l10n/app_localizations.dart';

class ConverterStatusWidget extends StatelessWidget {
  final ConverterController controller;
  final VoidCallback? onRefresh;
  final VoidCallback? onShowStatus;

  const ConverterStatusWidget({
    super.key,
    required this.controller,
    this.onRefresh,
    this.onShowStatus,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: .3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 500;

          if (isNarrow) {
            return _buildNarrowLayout(context, l10n);
          } else {
            return _buildWideLayout(context, l10n);
          }
        },
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatusIndicator(context, l10n),
            const Spacer(),
            _buildActionButtons(context, l10n),
          ],
        ),
        if (controller.lastUpdated != null && !controller.isLoading)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatLastUpdated(l10n),
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        _buildStatusIndicator(context, l10n),
        if (controller.lastUpdated != null && !controller.isLoading) ...[
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '• ${_formatLastUpdated(l10n)}',
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ] else
          const Spacer(),
        _buildActionButtons(context, l10n),
      ],
    );
  }

  Widget _buildStatusIndicator(BuildContext context, AppLocalizations l10n) {
    if (controller.isLoading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            controller.lastUpdated == null
                ? 'No data available' // Will be localized
                : 'Updating...', // Will be localized
            style: const TextStyle(fontSize: 12),
          ),
        ],
      );
    }

    if (!controller.requiresRealTimeData) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calculate,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Local calculation', // Will be localized
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          controller.isUsingLiveData ? Icons.wifi : Icons.wifi_off,
          size: 16,
          color: controller.isUsingLiveData ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 8),
        Text(
          controller.isUsingLiveData ? l10n.liveRates : l10n.staticRates,
          style: TextStyle(
            color: controller.isUsingLiveData ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onShowStatus != null)
          IconButton(
            onPressed: onShowStatus,
            icon: Icon(
              Icons.assessment,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            tooltip: l10n.viewDataStatus,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        if (onRefresh != null) ...[
          if (onShowStatus != null) const SizedBox(width: 4),
          IconButton(
            onPressed: controller.isLoading ? null : onRefresh,
            icon: Icon(
              Icons.refresh,
              color: controller.isLoading
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            tooltip: l10n.refreshRates,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ],
    );
  }

  String _formatLastUpdated(AppLocalizations l10n) {
    if (controller.lastUpdated == null) return '';

    final dateFormat = DateFormat('MM/dd/yyyy');
    final timeFormat = DateFormat('HH:mm:ss');

    final date = dateFormat.format(controller.lastUpdated!);
    final time = timeFormat.format(controller.lastUpdated!);

    return l10n.lastUpdatedAt(date, time);
  }
}
