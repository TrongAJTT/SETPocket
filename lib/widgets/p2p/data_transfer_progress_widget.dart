import 'package:flutter/material.dart';
import 'package:setpocket/models/p2p_models.dart';

class DataTransferProgressWidget extends StatelessWidget {
  final DataTransferTask task;
  final VoidCallback? onCancel;
  final VoidCallback? onClear;

  const DataTransferProgressWidget({
    super.key,
    required this.task,
    this.onCancel,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with file info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(),
                  child: Icon(
                    _getStatusIcon(),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
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
                if (task.status == DataTransferStatus.transferring &&
                    onCancel != null)
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel),
                    tooltip: 'Hủy truyền tải',
                  ),
                if (task.status == DataTransferStatus.cancelled ||
                    task.status == DataTransferStatus.failed)
                  IconButton(
                    onPressed: onClear,
                    icon: Icon(Icons.clear, color: Colors.grey[700]),
                    tooltip: 'Xóa tác vụ',
                  ),
                if (task.status == DataTransferStatus.completed)
                  PopupMenuButton<String>(
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
                  ),
              ],
            ),

            const SizedBox(height: 12),

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
                        ),
                      ),
                      if (task.status == DataTransferStatus.transferring)
                        Text(
                          _getProgressText(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (task.errorMessage != null)
                        Text(
                          'Lỗi: ${task.errorMessage}',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
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
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (task.status == DataTransferStatus.transferring)
                      Text(
                        _getTransferSpeed(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),

            // Time information
            if (task.startedAt != null || task.completedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                _getTimeInfo(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (task.status) {
      case DataTransferStatus.pending:
        return Icons.schedule;
      case DataTransferStatus.requesting:
        return Icons.help_outline;
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
        task.status != DataTransferStatus.transferring) return '';

    final elapsed = DateTime.now().difference(task.startedAt!);
    if (elapsed.inSeconds == 0) return '';

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
