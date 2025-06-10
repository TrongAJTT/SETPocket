import 'dart:async';
import 'dart:io';
import 'package:logging/logging.dart';
import 'package:my_multi_tools/services/app_logger.dart';
import 'package:my_multi_tools/services/settings_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

/// High-performance file logging service
/// Sử dụng Dart official logging package với file appender
class FileLoggerService {
  static FileLoggerService? _instance;
  static FileLoggerService get instance => _instance ??= FileLoggerService._();

  FileLoggerService._();

  late Logger _logger;
  late File _currentLogFile;
  late IOSink _logSink;
  late StreamSubscription _logSubscription;
  Timer? _dailyCleanupTimer;

  bool _isInitialized = false;
  final _logBuffer = StringBuffer();
  Timer? _flushTimer;
  int _bufferSize = 0;
  static const int _maxBufferSize = 1024 * 10; // 10KB buffer
  static const int _maxFileSize = 1024 * 1024 * 5; // 5MB per file
  static const Duration _flushInterval = Duration(seconds: 3);

  /// Khởi tạo file logger service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Setup logging level
      Logger.root.level = Level.ALL;

      // Tạo logger instance
      _logger = Logger('AppFileLogger');

      // Tạo log file
      await _createLogFile();

      // Setup log listener với hiệu năng cao
      _logSubscription = Logger.root.onRecord.listen(_handleLogRecord);

      // Setup auto-flush timer
      _setupAutoFlush();

      // Setup daily cleanup timer
      _setupDailyCleanup();

      _isInitialized = true;
      _logger.info('FileLoggerService initialized successfully');
    } catch (e) {
      logError('Failed to initialize FileLoggerService: $e');
      rethrow;
    }
  }

  /// Tạo log file mới với tên theo ngày
  Future<void> _createLogFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/logs');

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    _currentLogFile = File('${logDir.path}/app_$dateStr.log');

    // Mở file với append mode và buffer
    _logSink = _currentLogFile.openWrite(mode: FileMode.append);
  }

  /// Xử lý log record với hiệu năng cao
  void _handleLogRecord(LogRecord record) {
    if (!_isInitialized) return;

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(record.time);
    final level = record.level.name.padRight(7);
    final loggerName = record.loggerName.padRight(15);

    final logLine = '$timestamp [$level] $loggerName: ${record.message}';
    final finalLine = record.error != null
        ? '$logLine\nError: ${record.error}\n${record.stackTrace ?? ""}'
        : logLine;

    // Thêm vào buffer thay vì ghi trực tiếp
    _addToBuffer('$finalLine\n');
  }

  /// Thêm log vào buffer với quản lý kích thước
  void _addToBuffer(String line) {
    _logBuffer.write(line);
    _bufferSize += line.length;

    // Flush nếu buffer quá lớn
    if (_bufferSize >= _maxBufferSize) {
      _flushBuffer();
    }
  }

  /// Setup auto-flush timer
  void _setupAutoFlush() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flushBuffer());
  }

  /// Setup daily cleanup timer (runs at midnight)
  void _setupDailyCleanup() {
    _dailyCleanupTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    // Set timer to run at midnight, then every 24 hours
    _dailyCleanupTimer = Timer(timeUntilMidnight, () {
      cleanupOldLogs();

      // Setup recurring daily timer
      _dailyCleanupTimer = Timer.periodic(
        const Duration(days: 1),
        (_) => cleanupOldLogs(),
      );
    });

    _logger.info('Daily cleanup scheduled for: ${tomorrow.toString()}');
  }

  /// Flush buffer to file
  Future<void> _flushBuffer() async {
    if (_bufferSize == 0) return;

    try {
      final content = _logBuffer.toString();
      _logBuffer.clear();
      _bufferSize = 0;

      _logSink.write(content);
      await _logSink.flush();

      // Kiểm tra rotate file nếu cần
      await _checkFileRotation();
    } catch (e) {
      logError('Failed to flush log buffer: $e');
    }
  }

  /// Kiểm tra và rotate file nếu quá lớn
  Future<void> _checkFileRotation() async {
    try {
      final fileSize = await _currentLogFile.length();
      if (fileSize > _maxFileSize) {
        await _rotateLogFile();
      }
    } catch (e) {
      logError('Failed to check file rotation: $e');
    }
  }

  /// Rotate log file khi quá lớn
  Future<void> _rotateLogFile() async {
    try {
      // Đóng sink hiện tại
      await _logSink.close();

      // Đổi tên file hiện tại
      final timestamp =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final newName =
          _currentLogFile.path.replaceAll('.log', '_$timestamp.log');
      await _currentLogFile.rename(newName);

      // Tạo file mới
      await _createLogFile();

      _logger.info('Log file rotated to: $newName');
    } catch (e) {
      logError('Failed to rotate log file: $e');
    }
  }

  /// Public logging methods với hiệu năng cao
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.fine(message, error, stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.info(message, error, stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.warning(message, error, stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  /// Lấy danh sách log files
  Future<List<File>> getLogFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDir.path}/logs');

      if (!await logDir.exists()) {
        return [];
      }

      final files = await logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.log'))
          .cast<File>()
          .toList();

      // Sort by modification time, newest first
      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return files;
    } catch (e) {
      logError('Failed to get log files: $e');
      return [];
    }
  }

  /// Đọc nội dung log file
  Future<String> readLogFile(File file) async {
    try {
      return await file.readAsString();
    } catch (e) {
      return 'Error reading log file: $e';
    }
  }

  /// Xóa tất cả log files và tự động tạo lại file log của ngày hôm nay
  Future<void> clearAllLogs() async {
    try {
      // Đóng sink hiện tại trước khi xóa
      await _logSink.close();

      // Xóa tất cả file log
      final files = await getLogFiles();
      for (final file in files) {
        await file.delete();
      }

      // Tự động tạo lại file log mới cho ngày hôm nay
      await _createLogFile();

      _logger.info('All log files cleared and new log file created');
    } catch (e) {
      _logger.severe('Failed to clear log files', e);
      // Đảm bảo có file log để ghi dù có lỗi
      try {
        await _createLogFile();
      } catch (createError) {
        _logger.severe(
            'Failed to recreate log file after clear error', createError);
      }
    }
  }

  /// Cleanup old log files (sử dụng setting từ user)
  Future<void> cleanupOldLogs() async {
    try {
      final retentionDays = await SettingsService.getLogRetentionDays();
      final files = await getLogFiles();
      final cutoffTime = DateTime.now().subtract(Duration(days: retentionDays));

      for (final file in files) {
        final lastModified = await file.lastModified();
        if (lastModified.isBefore(cutoffTime)) {
          await file.delete();
          _logger.info(
              'Deleted old log file: ${file.path} (${retentionDays}d retention)');
        }
      }
    } catch (e) {
      _logger.severe('Failed to cleanup old logs', e);
    }
  }

  /// Dispose service
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      _flushTimer?.cancel();
      _dailyCleanupTimer?.cancel();
      await _flushBuffer();
      await _logSubscription.cancel();
      await _logSink.close();
      _isInitialized = false;
    } catch (e) {
      logError('Error disposing FileLoggerService: $e');
    }
  }
}
