import 'package:flutter/material.dart';
import 'package:setpocket/models/p2p/p2p_models.dart';
import 'package:setpocket/l10n/app_localizations.dart';
import 'package:setpocket/utils/size_utils.dart';
import 'package:setpocket/utils/widget_layout_render_helper.dart';
import 'package:setpocket/widgets/generic/generic_dialog.dart';

class DataTransferProgressWidget extends StatelessWidget {
  final DataTransferTask task;
  final VoidCallback? onCancel;
  final VoidCallback? onClear;
  final void Function(bool deleteFile)? onClearWithFile;
  final bool isInBatch;

  const DataTransferProgressWidget({
    super.key,
    required this.task,
    this.onCancel,
    this.onClear,
    this.onClearWithFile,
    this.isInBatch = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isInBatch) {
      return _buildCompactView(context);
    } else {
      return _buildFullView(context);
    }
  }

  Widget _buildFullView(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildCompactView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: _buildContent(context, isCompact: true),
    );
  }

  Widget _buildContent(BuildContext context, {bool isCompact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with file info
        Row(
          children: [
            if (!isCompact)
              CircleAvatar(
                backgroundColor: _getStatusColor(),
                child: Icon(
                  _getStatusIcon(),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            if (!isCompact) const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.fileName,
                    style: TextStyle(
                      fontWeight:
                          isCompact ? FontWeight.normal : FontWeight.bold,
                      fontSize: isCompact ? 14 : 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isCompact)
                    Text(
                      '${task.isOutgoing ? "Gửi đến" : "Nhận từ"} ${task.targetUserName}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            _buildActionButtons(context, isCompact),
          ],
        ),

        if (!isCompact) const SizedBox(height: 12),

        // Progress bar (only for transferring status)
        if (task.status == DataTransferStatus.transferring) ...[
          LinearProgressIndicator(
            value: task.progress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
          ),
          const SizedBox(height: 8),
        ],

        // Status and details
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                      fontSize: isCompact ? 12 : 14,
                    ),
                  ),
                  if (task.status == DataTransferStatus.transferring)
                    Text(
                      _getProgressText(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: isCompact ? 11 : null,
                          ),
                    ),
                  if (task.errorMessage != null)
                    Text(
                      'Lỗi: ${task.errorMessage}',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: isCompact ? 11 : 12,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatFileSize(task.fileSize),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: isCompact ? 11 : null,
                      ),
                ),
                if (task.status == DataTransferStatus.transferring)
                  Text(
                    _getTransferSpeed(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: isCompact ? 11 : null,
                        ),
                  ),
              ],
            ),
          ],
        ),

        // Time information
        if (!isCompact &&
            (task.startedAt != null || task.completedAt != null)) ...[
          const SizedBox(height: 8),
          Text(
            _getTimeInfo(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isCompact) {
    final l10n = AppLocalizations.of(context)!;

    if (task.status == DataTransferStatus.transferring && onCancel != null) {
      return IconButton(
        onPressed: onCancel,
        icon: const Icon(Icons.cancel),
        tooltip: 'Hủy truyền tải',
        iconSize: isCompact ? 20 : 24,
      );
    }

    if (task.status == DataTransferStatus.cancelled ||
        task.status == DataTransferStatus.failed) {
      return IconButton(
        onPressed: onClear,
        icon: Icon(Icons.clear, color: Colors.grey[700]),
        tooltip: 'Xóa tác vụ',
        iconSize: isCompact ? 20 : 24,
      );
    }

    if (task.status == DataTransferStatus.completed) {
      // For completed incoming files, show delete with file option
      if (!task.isOutgoing && task.savePath != null) {
        return PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'clear') {
              onClear?.call();
            } else if (value == 'delete_with_file') {
              _showDeleteWithFileDialog(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  const Icon(Icons.delete_forever),
                  const SizedBox(width: 8),
                  Text(l10n.delete),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete_with_file',
              child: Row(
                children: [
                  const Icon(Icons.delete_sweep, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(l10n.deleteWithFile,
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          iconSize: isCompact ? 20 : 24,
        );
      } else {
        // For outgoing files or files without savePath, show regular clear option
        return PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'clear') {
              onClear?.call();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_forever),
                  SizedBox(width: 8),
                  Text('Xóa'),
                ],
              ),
            ),
          ],
          iconSize: isCompact ? 20 : 24,
        );
      }
    }

    return const SizedBox.shrink();
  }

  void _showDeleteWithFileDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => GenericDialog(
        header: GenericDialogHeader(title: l10n.deleteTaskWithFile),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteTaskWithFileConfirm),
            const SizedBox(height: 8),
            Text(
              task.fileName,
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
            if (task.savePath != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.path}: ${task.savePath}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hành động này không thể hoàn tác. File sẽ bị xóa vĩnh viễn.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        footer: GenericDialogFooter(
          child: WidgetLayoutRenderHelper.oneLeftTwoRight(
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClearWithFile?.call(false); // Clear task only
                },
                child: Text(l10n.deleteTaskOnly),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onClearWithFile?.call(true); // Delete task and file
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.deleteWithFile),
              ),
              threeInARowMinWidth: 400,
              twoInARowMinWidth: 0),
        ),
        decorator: GenericDialogDecorator(
            width: DynamicDimension.flexibilityMax(90, 700),
            displayTopDivider: true),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case DataTransferStatus.pending:
        return Icons.schedule;
      case DataTransferStatus.requesting:
        return Icons.help_outline;
      case DataTransferStatus.waitingForApproval:
        return Icons.hourglass_empty;
      case DataTransferStatus.rejected:
        return Icons.block;
      case DataTransferStatus.transferring:
        return Icons.sync;
      case DataTransferStatus.completed:
        return Icons.check_circle;
      case DataTransferStatus.failed:
        return Icons.error;
      case DataTransferStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor() {
    switch (task.status) {
      case DataTransferStatus.pending:
        return Colors.orange;
      case DataTransferStatus.requesting:
        return Colors.blue;
      case DataTransferStatus.waitingForApproval:
        return Colors.amber;
      case DataTransferStatus.rejected:
        return Colors.red;
      case DataTransferStatus.transferring:
        return Colors.green;
      case DataTransferStatus.completed:
        return Colors.green;
      case DataTransferStatus.failed:
        return Colors.red;
      case DataTransferStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (task.status) {
      case DataTransferStatus.pending:
        return 'Đang chờ';
      case DataTransferStatus.requesting:
        return 'Đang yêu cầu';
      case DataTransferStatus.waitingForApproval:
        return 'Chờ phê duyệt';
      case DataTransferStatus.rejected:
        return 'Bị từ chối';
      case DataTransferStatus.transferring:
        return task.isOutgoing ? 'Đang gửi...' : 'Đang nhận...';
      case DataTransferStatus.completed:
        return 'Hoàn thành';
      case DataTransferStatus.failed:
        return 'Thất bại';
      case DataTransferStatus.cancelled:
        return 'Đã hủy';
    }
  }

  String _getProgressText() {
    final progress = (task.progress * 100).toStringAsFixed(1);
    final transferred = _formatFileSize(task.transferredBytes);
    final total = _formatFileSize(task.fileSize);
    return '$progress% ($transferred / $total)';
  }

  String _getTransferSpeed() {
    if (task.startedAt == null ||
        task.status != DataTransferStatus.transferring) {
      return '';
    }

    final elapsed = DateTime.now().difference(task.startedAt!);
    if (elapsed.inSeconds == 0) {
      return '';
    }

    final bytesPerSecond = task.transferredBytes / elapsed.inSeconds;
    return '${_formatFileSize(bytesPerSecond.round())}/s';
  }

  String _getTimeInfo() {
    if (task.status == DataTransferStatus.cancelled ||
        task.status == DataTransferStatus.failed) {
      return 'Đã dừng';
    }
    if (task.completedAt != null) {
      final duration =
          task.completedAt!.difference(task.startedAt ?? task.createdAt);
      return 'Hoàn thành trong ${_formatDuration(duration)}';
    } else if (task.startedAt != null) {
      final elapsed = DateTime.now().difference(task.startedAt!);
      return 'Đã truyền ${_formatDuration(elapsed)}';
    } else {
      final waiting = DateTime.now().difference(task.createdAt);
      return 'Chờ ${_formatDuration(waiting)}';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDuration(Duration duration) {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds}s';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
  }
}
