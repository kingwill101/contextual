import 'dart:async';

import 'package:contextual/contextual.dart';

/// A utility class for managing multiple loggers and their resources.
///
/// This class helps ensure proper cleanup of logger subscriptions and
/// stream controllers to prevent resource leaks and hanging processes.
///
/// Example usage:
/// ```dart
/// final manager = LoggerManager();
///
/// // Get loggers through the manager
/// final app = manager.getLogger('app', level: Level.info);
/// final db = manager.getLogger('app.database', level: Level.warning);
///
/// // Add listeners
/// manager.addListener(app, (entry) => print('App: ${entry.message}'));
///
/// // Use loggers...
/// app.info('Starting application');
/// db.warning('Slow query detected');
///
/// // Clean up everything
/// await manager.dispose();
/// ```
class LoggerManager {
  final Map<String, Logger> _loggers = {};
  final List<StreamSubscription<LogEntry>> _subscriptions = [];
  bool _disposed = false;

  /// Gets or creates a named logger with optional configuration.
  Logger getLogger(
    String name, {
    Level? level,
    LogMessageFormatter? formatter,
    bool addConsoleChannel = true,
  }) {
    if (_disposed) {
      throw StateError('LoggerManager has been disposed');
    }

    if (_loggers.containsKey(name)) {
      return _loggers[name]!;
    }

    final logger = Logger(name: name, level: level, formatter: formatter);

    if (addConsoleChannel) {
      logger.addChannel('console', ConsoleLogDriver());
    }

    _loggers[name] = logger;
    return logger;
  }

  /// Gets the root logger.
  Logger get root => Logger.root;

  /// Adds a listener to a logger and tracks the subscription for cleanup.
  StreamSubscription<LogEntry> addListener(
    Logger logger,
    void Function(LogEntry entry) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    if (_disposed) {
      throw StateError('LoggerManager has been disposed');
    }

    final subscription = logger.onRecord.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );

    _subscriptions.add(subscription);
    return subscription;
  }

  /// Removes a specific subscription from management.
  /// The subscription will no longer be automatically cancelled on dispose.
  void removeSubscription(StreamSubscription<LogEntry> subscription) {
    _subscriptions.remove(subscription);
  }

  /// Gets all managed loggers.
  Map<String, Logger> get loggers => Map.unmodifiable(_loggers);

  /// Gets all active subscriptions.
  List<StreamSubscription<LogEntry>> get subscriptions =>
      List.unmodifiable(_subscriptions);

  /// Cancels all subscriptions and shuts down all managed loggers.
  ///
  /// This method should be called when you're done with all logging
  /// to ensure proper resource cleanup and prevent hanging processes.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;

    // Cancel all subscriptions first
    for (final subscription in _subscriptions) {
      if (!subscription.isPaused) {
        subscription.cancel();
      }
    }
    _subscriptions.clear();

    // Shutdown all managed loggers
    final shutdownFutures = _loggers.values.map((logger) => logger.shutdown());
    await Future.wait(shutdownFutures);

    _loggers.clear();
  }

  /// Checks if the manager has been disposed.
  bool get isDisposed => _disposed;

  /// Gets the number of managed loggers.
  int get loggerCount => _loggers.length;

  /// Gets the number of active subscriptions.
  int get subscriptionCount => _subscriptions.length;
}
