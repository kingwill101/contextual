import 'dart:async';
import 'dart:collection';

import 'package:contextual/src/log_level.dart';

import 'log_entry.dart';

typedef LogCallback = Future<void> Function(LogEntry entry);

/// A callback type for processing a batch of log entries.
/// This function must be a top-level or static function so that it can be sent to an isolate.

typedef LogBatchProcessor = Future<void> Function(List<LogEntry> batch);

/// Abstract base class for log sinks.
///
/// This defines the common interface that all log sinks must implement.
/// It provides the basic functionality for batching and processing log entries.
abstract class Sink {
  /// The maximum number of logs to accumulate before triggering a flush.
  int get batchSize;

  /// The interval between automatic flush operations.
  Duration get autoFlushInterval;

  /// The duration to wait after the last log before auto-closing the sink.
  Duration get autoCloseAfter;

  /// Adds a new log operation to the sink.
  ///
  /// The [entry] parameter specifies the log entry, and [logCallback] is the
  /// actual logging operation to perform.
  ///
  /// Emergency and critical logs are flushed immediately. Other logs are
  /// batched until either the [batchSize] is reached or the [autoFlushInterval]
  /// triggers a flush.
  Future<void> addLog(LogEntry entry, LogCallback logCallback);

  /// Closes the sink and releases any resources.
  ///
  /// This should be called when the sink is no longer needed to ensure proper cleanup.
  Future<void> close();
}

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

  /// The duration to wait after the last log before auto-closing the sink.
  /// This helps avoid requiring an explicit shutdown call.
  final Duration autoCloseAfter;

  /// Creates a new [LogSinkConfig] instance with the specified parameters.
  ///
  /// Parameters:
  /// - [batchSize]: Number of logs to accumulate before flushing (default: 10)
  /// - [flushInterval]: Time between automatic flushes (default: 1 second)
  /// - [maxRetries]: Number of retry attempts for failed operations (default: 3)
  /// - [autoFlush]: Enable/disable automatic flushing (default: true)
  /// - [autoCloseAfter]: Inactivity window before auto-close (default: 5 seconds)
  const LogSinkConfig({
    this.batchSize = 10,
    this.flushInterval = const Duration(seconds: 1),
    this.maxRetries = 3,
    this.autoFlush = true,
    this.autoCloseAfter = const Duration(seconds: 5),
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
class LogSink implements Sink {
  /// The maximum number of logs to accumulate before triggering a flush.
  @override
  final int batchSize;

  /// The interval between automatic flush operations.
  @override
  final Duration autoFlushInterval;

  /// The duration to wait after the last log before auto-closing the sink.
  @override
  final Duration autoCloseAfter;

  /// Internal flag to prevent concurrent flush operations.
  bool _isFlushing = false;

  /// Buffer to store pending log operations.
  final Queue<MapEntry<LogEntry, LogCallback>> _logBuffer = Queue();

  /// Timer for automatic flush operations.
  Timer? _flushTimer;

  /// Timer for automatic sink closure.
  Timer? _autoCloseTimer;

  /// Creates a new [LogSink] instance with the specified parameters.
  ///
  /// Parameters:
  /// - [config]: Optional configuration for the sink behavior
  LogSink({
    LogSinkConfig? config,
  })  : batchSize = config?.batchSize ?? 10,
        autoFlushInterval = config?.flushInterval ?? const Duration(seconds: 1),
        autoCloseAfter = config?.autoCloseAfter ?? const Duration(seconds: 5);

  /// Adds a new log operation to the sink.
  ///
  /// The [entry] parameter specifies the log entry, and [logCallback] is the
  /// actual logging operation to perform.
  ///
  /// Emergency and critical logs are flushed immediately. Other logs are
  /// batched until either the [batchSize] is reached or the [autoFlushInterval]
  /// triggers a flush.
  @override
  Future<void> addLog(LogEntry entry, LogCallback logCallback) async {
    if (_flushTimer == null) {
      _startFlushTimer();
    }

    _logBuffer.addFirst(MapEntry(entry, logCallback));
    _resetAutoCloseTimer();

    // Flush immediately for emergency/critical logs or batch threshold reached
    if (entry.record.level == Level.emergency ||
        entry.record.level == Level.critical ||
        _logBuffer.length >= batchSize) {
      await _flushPendingLogs(); // Immediate flush
    }
  }

  /// Starts the automatic flush timer.
  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(autoFlushInterval, (_) => _flushPendingLogs());
  }

  /// Flushes any pending log operations.
  Future<void> _flushPendingLogs() async {
    if (_isFlushing || _logBuffer.isEmpty) return;

    _isFlushing = true;
    try {
      while (_logBuffer.isNotEmpty) {
        final entry = _logBuffer.removeLast();
        await entry.value(entry.key);
      }
    } finally {
      _isFlushing = false;
    }
  }

  /// Resets the auto-close timer.
  void _resetAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(autoCloseAfter, () => close());
  }

  /// Closes the sink and releases any resources.
  ///
  /// This will:
  /// 1. Cancel any pending timers
  /// 2. Flush any remaining logs
  /// 3. Clean up resources
  @override
  Future<void> close() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    _autoCloseTimer?.cancel();
    await _flushPendingLogs(); // Flush pending logs before closing
  }
}
