import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'settings_service.dart';

/// Unified App Logger with integrated file logging
/// Features:
/// - Production mode: Only ERROR/FATAL to file, no console output
/// - Debug mode: All levels to both console and file
/// - High-performance buffered file writing
/// - Automatic file rotation and cleanup
class AppLogger {
  static AppLogger? _instance;
  static AppLogger get instance => _instance ??= AppLogger._();

  AppLogger._();

  late Logger _logger;
  late File _currentLogFile;
  late IOSink _logSink;
  late StreamSubscription _logSubscription;
  Timer? _dailyCleanupTimer;

  bool _isInitialized = false;
  final _logBuffer = StringBuffer();
  Timer? _flushTimer;
  int _bufferSize = 0;

  // Performance optimized constants
  static const int _maxBufferSize = 1024 * 8; // 8KB buffer
  static const int _maxFileSize = 1024 * 1024 * 3; // 3MB per file
  static const Duration _debugFlushInterval = Duration(seconds: 2);
  static const Duration _productionFlushInterval = Duration(seconds: 5);

  /// Initialize the unified logger
  Future<void> initialize({String loggerName = 'MyMultiTools'}) async {
    if (_isInitialized) return;

    try {
      // Configure logger based on build mode
      if (kReleaseMode) {
        // Production: Only INFO and above, prioritize file logging
        Logger.root.level = Level.INFO;
        hierarchicalLoggingEnabled = true;
      } else {
        // Debug: All levels for development
        Logger.root.level = Level.ALL;
        hierarchicalLoggingEnabled = true;
      }

      _logger = Logger(loggerName);

      // Initialize file logging
      await _initializeFileLogging();

      // Setup log listener with mode-specific filtering
      _logSubscription = Logger.root.onRecord.listen(_handleLogRecord);

      // Setup performance-optimized auto-flush
      _setupAutoFlush();

      // Setup daily cleanup
      _setupDailyCleanup();

      _isInitialized = true;

      if (kReleaseMode) {
        _logger
            .info('AppLogger: Production mode - file logging only for INFO+');
      } else {
        _logger.info('AppLogger: Debug mode - full logging enabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('[CRITICAL] AppLogger initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Initialize file logging with optimized performance
  Future<void> _initializeFileLogging() async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/logs');

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    await _createNewLogFile();
  }

  /// Create new log file with date-based naming
  Future<void> _createNewLogFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final logDir = Directory('${appDir.path}/logs');

    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    _currentLogFile = File('${logDir.path}/app_$dateStr.log');

    // Initialize file sink with optimized buffering
    _logSink = _currentLogFile.openWrite(
      mode: FileMode.append,
      encoding: utf8,
    );
  }

  /// Handle log records with mode-specific filtering and performance optimization
  void _handleLogRecord(LogRecord record) {
    if (!_isInitialized) return;

    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(record.time);
    final level = record.level.name.padRight(7);
    final loggerName = record.loggerName.length > 20
        ? record.loggerName.substring(0, 20)
        : record.loggerName.padRight(20);

    final message = record.message;
    final error = record.error;
    final stackTrace = record.stackTrace;

    if (kReleaseMode) {
      // Production mode: File logging for INFO+ levels, no console output
      if (record.level.value >= Level.INFO.value) {
        final logLine = '$timestamp [$level] $loggerName: $message';
        final finalLine = error != null
            ? '$logLine\nError: $error\n${stackTrace ?? ""}'
            : logLine;
        _addToFileBuffer('$finalLine\n');
      }
      // No console output in production
    } else {
      // Debug mode: Both console and file for all levels
      final logLine = '$timestamp [$level] $loggerName: $message';
      final finalLine = error != null
          ? '$logLine\nError: $error\n${stackTrace ?? ""}'
          : logLine;

      // Console output for debug
      if (kDebugMode) {
        print(finalLine);
      }

      // File output for debug
      _addToFileBuffer('$finalLine\n');
    }
  }

  /// Add log to file buffer with performance optimization
  void _addToFileBuffer(String line) {
    _logBuffer.write(line);
    _bufferSize += line.length;

    // Immediate flush for production errors (critical logs)
    if (kReleaseMode && line.contains('[SEVERE]') || line.contains('[SHOUT]')) {
      _flushBufferSync();
    }
    // Normal buffer-based flushing
    else if (_bufferSize >= _maxBufferSize) {
      _flushBufferSync();
    }
  }

  /// Setup auto-flush with mode-specific intervals
  void _setupAutoFlush() {
    _flushTimer?.cancel();

    const interval =
        kReleaseMode ? _productionFlushInterval : _debugFlushInterval;
    _flushTimer = Timer.periodic(interval, (_) => _flushBufferSync());
  }

  /// Synchronous buffer flush for immediate execution
  void _flushBufferSync() {
    if (_bufferSize == 0) return;

    try {
      final content = _logBuffer.toString();
      _logBuffer.clear();
      _bufferSize = 0;

      _logSink.write(content);
      // Don't await flush for performance, but schedule it
      _logSink.flush().catchError((e) {
        if (kDebugMode) print('[LOG_ERROR] Flush failed: $e');
      });

      // Check file rotation asynchronously
      _checkFileRotationAsync();
    } catch (e) {
      if (kDebugMode) print('[LOG_ERROR] Buffer flush failed: $e');
    }
  }

  /// Async file rotation check for performance
  void _checkFileRotationAsync() {
    _currentLogFile.length().then((fileSize) {
      if (fileSize > _maxFileSize) {
        _rotateLogFile();
      }
    }).catchError((e) {
      if (kDebugMode) print('[LOG_ERROR] File rotation check failed: $e');
    });
  }

  /// Rotate log file when size limit exceeded
  Future<void> _rotateLogFile() async {
    try {
      await _logSink.close();

      final timestamp =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final newName =
          _currentLogFile.path.replaceAll('.log', '_$timestamp.log');
      await _currentLogFile.rename(newName);

      await _createNewLogFile();
      _logger.info('Log file rotated to: $newName');
    } catch (e) {
      if (kDebugMode) print('[LOG_ERROR] Log rotation failed: $e');
      // Try to recreate log file
      try {
        await _createNewLogFile();
      } catch (recreateError) {
        if (kDebugMode) {
          print('[LOG_ERROR] Log file recreation failed: $recreateError');
        }
      }
    }
  }

  /// Setup daily cleanup with optimized timing
  void _setupDailyCleanup() {
    _dailyCleanupTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilMidnight = tomorrow.difference(now);

    _dailyCleanupTimer = Timer(timeUntilMidnight, () {
      _performCleanup();
      _dailyCleanupTimer = Timer.periodic(
        const Duration(days: 1),
        (_) => _performCleanup(),
      );
    });
  }

  /// Perform cleanup operation
  void _performCleanup() {
    cleanupOldLogs().catchError((e) {
      if (kDebugMode) print('[LOG_ERROR] Cleanup failed: $e');
    });
  }

  // Public logging methods with performance optimization

  /// Debug logging (debug mode only)
  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    if (kReleaseMode) return; // Skip in production
    _logger.fine(message, error, stackTrace);
  }

  /// Info logging (always logged to file in production)
  void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.info(message, error, stackTrace);
  }

  /// Warning logging (always logged to file in production)
  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.warning(message, error, stackTrace);
  }

  /// Error logging (always logged to file, critical in production)
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.severe(message, error, stackTrace);
  }

  /// Fatal/Critical logging (immediate flush)
  void fatal(String message, [Object? error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;
    _logger.shout(message, error, stackTrace);
    // Force immediate flush for critical logs
    _flushBufferSync();
  }

  // File management methods

  /// Get total log size
  Future<int> getTotalLogSize() async {
    try {
      final files = await getLogFiles();
      int totalSize = 0;
      for (final file in files) {
        try {
          totalSize += await file.length();
        } catch (_) {
          // Skip files that can't be read
        }
      }
      return totalSize;
    } catch (e) {
      error('Failed to calculate total log size: $e');
      return 0;
    }
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get log files
  Future<List<File>> getLogFiles() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final logDir = Directory('${appDir.path}/logs');

      if (!await logDir.exists()) return [];

      final files = await logDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.log'))
          .cast<File>()
          .toList();

      files
          .sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return files;
    } catch (e) {
      error('Failed to get log files: $e');
      return [];
    }
  }

  /// Get log file names
  Future<List<String>> getLogFileNames() async {
    final files = await getLogFiles();
    return files
        .map((file) => file.path.split(Platform.pathSeparator).last)
        .toList();
  }

  /// Read log file content
  Future<String> readLogContent(String fileName) async {
    try {
      final files = await getLogFiles();
      final file = files.firstWhere(
        (file) => file.path.endsWith(fileName),
        orElse: () => throw Exception('Log file not found: $fileName'),
      );
      return await file.readAsString();
    } catch (e) {
      error('Failed to read log file $fileName: $e');
      return 'Error reading log file: $e';
    }
  }

  /// Cleanup old logs based on settings
  Future<void> cleanupOldLogs() async {
    try {
      final retentionDays = await SettingsService.getLogRetentionDays();
      if (retentionDays == -1) return; // Keep forever

      final files = await getLogFiles();
      final cutoffTime = DateTime.now().subtract(Duration(days: retentionDays));

      int deletedCount = 0;
      for (final file in files) {
        try {
          final lastModified = await file.lastModified();
          if (lastModified.isBefore(cutoffTime)) {
            await file.delete();
            deletedCount++;
          }
        } catch (e) {
          warning('Failed to delete log file ${file.path}: $e');
        }
      }

      if (deletedCount > 0) {
        info('Cleanup completed: $deletedCount log files deleted');
      }
    } catch (e) {
      error('Log cleanup failed: $e');
    }
  }

  /// Clear all logs
  Future<void> clearLogs() async {
    try {
      // Flush and close current sink
      _flushBufferSync();
      await _logSink.close();

      // Delete all log files
      final files = await getLogFiles();
      for (final file in files) {
        try {
          await file.delete();
        } catch (e) {
          warning('Failed to delete log file ${file.path}: $e');
        }
      }

      // Recreate current log file
      await _createNewLogFile();
      info('All log files cleared and new log file created');
    } catch (e) {
      error('Failed to clear logs: $e');
    }
  }

  /// Dispose logger and cleanup resources
  Future<void> dispose() async {
    if (!_isInitialized) return;

    try {
      _flushTimer?.cancel();
      _dailyCleanupTimer?.cancel();

      // Final flush
      _flushBufferSync();

      await _logSubscription.cancel();
      await _logSink.close();

      _isInitialized = false;
    } catch (e) {
      if (kDebugMode) print('[LOG_ERROR] AppLogger disposal failed: $e');
    }
  }
}

/// Extension for easy logging from any object
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

  void logFatal(String message, [Object? error, StackTrace? stackTrace]) {
    AppLogger.instance
        .fatal('[${runtimeType.toString()}] $message', error, stackTrace);
  }
}

// Global convenience functions
void logDebug(String message, [Object? error, StackTrace? stackTrace]) {
  AppLogger.instance.debug(message, error, stackTrace);
}

void logInfo(String message, [Object? error, StackTrace? stackTrace]) {
  AppLogger.instance.info(message, error, stackTrace);
}

void logWarning(String message, [Object? error, StackTrace? stackTrace]) {
  AppLogger.instance.warning(message, error, stackTrace);
}

void logError(String message, [Object? error, StackTrace? stackTrace]) {
  AppLogger.instance.error(message, error, stackTrace);
}

void logFatal(String message, [Object? error, StackTrace? stackTrace]) {
  AppLogger.instance.fatal(message, error, stackTrace);
}
