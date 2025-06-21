import 'package:flutter/material.dart';
import 'package:setpocket/models/p2p_models.dart';

class FileTransferProgressWidget extends StatelessWidget {
  final FileTransferTask task;
  final VoidCallback? onCancel;

  const FileTransferProgressWidget({
    super.key,
    required this.task,
    this.onCancel,
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
                if (task.status == FileTransferStatus.transferring &&
                    onCancel != null)
                  IconButton(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel),
                    tooltip: 'Hủy truyền tải',
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress bar (only for transferring status)
            if (task.status == FileTransferStatus.transferring) ...[
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
                      if (task.status == FileTransferStatus.transferring)
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
                    if (task.status == FileTransferStatus.transferring)
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
      case FileTransferStatus.pending:
        return Icons.schedule;
      case FileTransferStatus.requesting:
        return Icons.help_outline;
      case FileTransferStatus.transferring:
        return Icons.sync;
      case FileTransferStatus.completed:
        return Icons.check_circle;
      case FileTransferStatus.failed:
        return Icons.error;
      case FileTransferStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor() {
    switch (task.status) {
      case FileTransferStatus.pending:
        return Colors.orange;
      case FileTransferStatus.requesting:
        return Colors.blue;
      case FileTransferStatus.transferring:
        return Colors.green;
      case FileTransferStatus.completed:
        return Colors.green;
      case FileTransferStatus.failed:
        return Colors.red;
      case FileTransferStatus.cancelled:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (task.status) {
      case FileTransferStatus.pending:
        return 'Đang chờ';
      case FileTransferStatus.requesting:
        return 'Đang yêu cầu';
      case FileTransferStatus.transferring:
        return 'Đang truyền';
      case FileTransferStatus.completed:
        return 'Hoàn thành';
      case FileTransferStatus.failed:
        return 'Thất bại';
      case FileTransferStatus.cancelled:
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
    if (task.startedAt == null) return '';

    final elapsed = DateTime.now().difference(task.startedAt!);
    if (elapsed.inSeconds == 0) return '';

    final bytesPerSecond = task.transferredBytes / elapsed.inSeconds;
    return '${_formatFileSize(bytesPerSecond.round())}/s';
  }

  String _getTimeInfo() {
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
