import 'dart:async';


import '../log_entry.dart';

/// Defines an interface for a log driver that can be used to log messages.
///
/// Implementations of this interface are responsible for handling the actual
/// logging of messages, such as writing them to a file, sending them to a
/// remote logging service, or displaying them in the console.
abstract class LogDriver {
  final String name;

  /// Whether the driver has been notified of shutdown
  bool _isShuttingDown = false;

  /// Whether the driver has completed its shutdown
  bool _isShutdown = false;

  /// Completer that resolves when shutdown is complete
  final _shutdownCompleter = Completer<void>();

  LogDriver(this.name);

  /// Logs the provided [entry] using the driver's implementation
  Future<void> log(LogEntry entry);

  /// Notifies the driver that the logger is shutting down.
  /// The driver should complete any pending operations and clean up resources.
  /// Returns a Future that completes when the driver has finished shutting down.
  Future<void> notifyShutdown() async {
    if (_isShuttingDown) return _shutdownCompleter.future;
    _isShuttingDown = true;

    try {
      await performShutdown();
      _isShutdown = true;
      _shutdownCompleter.complete();
    } catch (e) {
      _shutdownCompleter.completeError(e);
      rethrow;
    }
  }

  /// Performs the actual shutdown operations.
  /// Implementations should override this to clean up resources.
  Future<void> performShutdown() async {}

  /// Returns whether the driver is currently shutting down
  bool get isShuttingDown => _isShuttingDown;

  /// Returns whether the driver has completed shutdown
  bool get isShutdown => _isShutdown;

  /// Returns a Future that completes when the driver has finished shutting down
  Future<void> get onShutdown => _shutdownCompleter.future;
}

/// Provides a factory for creating instances of [LogDriver] based on configuration.
///
/// The [LogDriverFactory] is responsible for registering different types of log drivers
/// and creating instances of them based on the provided configuration. This allows
/// the logging system to be easily extended with new log driver implementations
/// without modifying the core logging logic.
// LogDriverFactory was removed in v2. Use typed configuration instead.
