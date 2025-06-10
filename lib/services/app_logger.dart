import 'package:logging/logging.dart';
import 'file_logger_service.dart';

/// App-wide logger service wrapper
/// Cung cấp interface đơn giản cho việc logging
class AppLogger {
  static AppLogger? _instance;
  static AppLogger get instance => _instance ??= AppLogger._();

  AppLogger._();

  late Logger _logger;
  bool _isInitialized = false;

  /// Khởi tạo app logger
  Future<void> initialize({String loggerName = 'MyMultiTools'}) async {
    if (_isInitialized) return;

    try {
      // Khởi tạo file logger service trước
      await FileLoggerService.instance.initialize();

      // Tạo logger cho app
      _logger = Logger(loggerName);

      _isInitialized = true;
      _logger.info('AppLogger initialized for: $loggerName');

      // Cleanup old logs
      await FileLoggerService.instance.cleanupOldLogs();
    } catch (e) {
      print('Failed to initialize AppLogger: $e');
      rethrow;
    }
  }

  /// Log debug message
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.fine(message, error, stackTrace);
  }

  /// Log info message
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.info(message, error, stackTrace);
  }

  /// Log warning message
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.warning(message, error, stackTrace);
  }

  /// Log error message
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.severe(message, error, stackTrace);
  }

  /// Lấy tổng kích thước tất cả log files
  Future<int> getTotalLogSize() async {
    final files = await FileLoggerService.instance.getLogFiles();
    int totalSize = 0;
    for (final file in files) {
      try {
        final size = await file.length();
        totalSize += size;
      } catch (e) {
        // Ignore individual file errors
      }
    }
    return totalSize;
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Lấy danh sách log files
  Future<List<String>> getLogFileNames() async {
    final files = await FileLoggerService.instance.getLogFiles();
    return files.map((file) => file.path.split('/').last).toList();
  }

  /// Đọc nội dung log file
  Future<String> readLogContent(String fileName) async {
    final files = await FileLoggerService.instance.getLogFiles();
    final file = files.firstWhere(
      (file) => file.path.endsWith(fileName),
      orElse: () => throw Exception('Log file not found: $fileName'),
    );
    return await FileLoggerService.instance.readLogFile(file);
  }

  /// Cleanup old logs based on retention setting
  Future<void> cleanupOldLogs() async {
    await FileLoggerService.instance.cleanupOldLogs();
  }

  /// Xóa tất cả logs
  Future<void> clearLogs() async {
    await FileLoggerService.instance.clearAllLogs();
  }

  /// Dispose
  Future<void> dispose() async {
    if (!_isInitialized) return;
    await FileLoggerService.instance.dispose();
    _isInitialized = false;
  }
}

/// Extension cho easy logging
extension AppLogging on Object {
  void logDebug(String message, [Object? error, StackTrace? stackTrace]) {
    AppLogger.instance
        .debug('[${runtimeType.toString()}] $message', error, stackTrace);
  }

  void logInfo(String message, [Object? error, StackTrace? stackTrace]) {
    AppLogger.instance
        .info('[${runtimeType.toString()}] $message', error, stackTrace);
  }

  void logWarning(String message, [Object? error, StackTrace? stackTrace]) {
    AppLogger.instance
        .warning('[${runtimeType.toString()}] $message', error, stackTrace);
  }

  void logError(String message, [Object? error, StackTrace? stackTrace]) {
    AppLogger.instance
        .error('[${runtimeType.toString()}] $message', error, stackTrace);
  }
}
