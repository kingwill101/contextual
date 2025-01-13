import 'dart:async';
import 'dart:collection';

import 'log_level.dart';

typedef LogCallback = Future<void> Function();

/// A class that represents the configuration for a [LogSink].
///
/// This configuration controls how logs are batched, flushed, and retried.
///
/// Example usage:
///
/// ```dart
/// final config = LogSinkConfig(
///   batchSize: 20,
///   flushInterval: Duration(seconds: 2),
///   maxRetries: 5,
///   autoFlush: true,
/// );
/// ```
///
/// Options:
/// - [batchSize]: The number of logs to accumulate before triggering a flush operation.
///   - Default: 10
///   - Description: Determines how many log entries are batched together before being processed.
/// - [flushInterval]: The time interval between automatic flush operations when [autoFlush] is true.
///   - Default: 1 second
///   - Description: Specifies how frequently the sink should automatically flush logs.
/// - [maxRetries]: The maximum number of retry attempts when a log operation fails.
///   - Default: 3
///   - Description: Sets the number of times the sink will attempt to retry a failed log operation.
/// - [autoFlush]: Whether to automatically flush logs periodically based on [flushInterval].
///   - Default: true
///   - Description: Enables or disables automatic flushing of logs at regular intervals.
class LogSinkConfig {
  /// The number of logs to accumulate before triggering a flush operation.
  final int batchSize;

  /// The time interval between automatic flush operations when [autoFlush] is true.
  final Duration flushInterval;

  /// The maximum number of retry attempts when a log operation fails.
  final int maxRetries;

  /// Whether to automatically flush logs periodically based on [flushInterval].
  final bool autoFlush;

  /// Creates a new [LogSinkConfig] instance with the specified parameters.
  ///
  /// Parameters:
  /// - [batchSize]: Number of logs to accumulate before flushing (default: 10)
  /// - [flushInterval]: Time between automatic flushes (default: 1 second)
  /// - [maxRetries]: Number of retry attempts for failed operations (default: 3)
  /// - [autoFlush]: Enable/disable automatic flushing (default: true)
  const LogSinkConfig({
    this.batchSize = 10,
    this.flushInterval = const Duration(seconds: 1),
    this.maxRetries = 3,
    this.autoFlush = true,
  });
}

/// A sink for handling log messages with batching and automatic flushing capabilities.
///
/// The [LogSink] class provides functionality to:
/// - Buffer log messages for batch processing
/// - Automatically flush logs based on time intervals or batch size
/// - Handle emergency/critical logs immediately
/// - Manage resources with automatic closing
///
/// Example usage:
///
/// final sink = LogSink(
///   batchSize: 10,
///   autoFlushInterval: Duration(milliseconds: 500),
///   autoCloseAfter: Duration(milliseconds: 100),
/// );
///
/// // Add a log
/// await sink.addLog(Level.info.value, () async {
///   await someLoggingOperation();
/// });
///
/// // Close the sink when done
/// await sink.close();
///
class LogSink {
  /// The maximum number of logs to accumulate before triggering a flush.
  final int batchSize;

  /// The interval between automatic flush operations.
  final Duration autoFlushInterval;

  /// The duration to wait after the last log before auto-closing the sink.
  final Duration autoCloseAfter;

  /// Internal flag to prevent concurrent flush operations.
  bool _isFlushing = false;

  /// Buffer to store pending log operations.
  final Queue<MapEntry<Level, Future<void> Function()>> _logBuffer = Queue();

  /// Timer for automatic flush operations.
  Timer? _flushTimer;

  /// Timer for automatic sink closure.
  Timer? _autoCloseTimer;

  /// Creates a new [LogSink] instance with the specified parameters.
  ///
  /// Parameters:
  /// - [batchSize]: Maximum number of logs before forcing a flush (default: 10)
  /// - [autoFlushInterval]: Time between automatic flushes (default: 500ms)
  /// - [autoCloseAfter]: Time to wait before auto-closing (default: 100ms)
  LogSink({
    this.batchSize = 10,
    this.autoFlushInterval = const Duration(milliseconds: 500),
    this.autoCloseAfter = const Duration(milliseconds: 100),
  });

  /// Adds a new log operation to the sink.
  ///
  /// The [level] parameter specifies the log level, and [logCallback] is the
  /// actual logging operation to perform.
  ///
  /// Emergency and critical logs are flushed immediately. Other logs are
  /// batched until either the [batchSize] is reached or the [autoFlushInterval]
  /// triggers a flush.
  Future<void> addLog(
      Level level, Future<void> Function() logCallback) async {
    if (_flushTimer == null) {
      _startFlushTimer();
    }

    _logBuffer.addFirst(MapEntry(level, logCallback));
    _resetAutoCloseTimer();

    // Flush immediately for emergency logs or batch threshold reached
    if (level == Level.emergency ||
        level == Level.critical ||
        _logBuffer.length >= batchSize) {
      await _flushPendingLogs(); // Immediate flush for critical logs
    }
  }

  /// Starts the automatic flush timer.
  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(autoFlushInterval, (_) async {
      if (!_isFlushing && _logBuffer.isNotEmpty) {
        await _flushPendingLogs();
      }
    });
  }

  /// Flushes all pending logs in the buffer.
  ///
  /// This method ensures that all buffered logs are processed and prevents
  /// concurrent flush operations.
  Future<void> _flushPendingLogs() async {
    if (_isFlushing || _logBuffer.isEmpty) return;

    _isFlushing = true;

    try {
      while (_logBuffer.isNotEmpty) {
        final logEntry = _logBuffer.removeLast();
        await logEntry.value();
      }
    } catch (e) {
      print('[LogSink Error] Error during flush: $e');
    } finally {
      _isFlushing = false;
    }
  }

  /// Resets the auto-close timer.
  ///
  /// This method is called after each log operation to prevent premature closing
  /// of the sink while it's still in use.
  void _resetAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(autoCloseAfter, close);
  }

  /// Closes the sink and releases all resources.
  ///
  /// This method:
  /// - Cancels all active timers
  /// - Flushes any remaining logs
  /// - Should be called when the sink is no longer needed
  Future<void> close() async {
    _flushTimer?.cancel();
    _autoCloseTimer?.cancel();
    await _flushPendingLogs(); // Flush pending logs before closing
  }
}
