import 'package:contextual/contextual.dart';
import 'package:contextual/src/middleware_processor.dart';

/// A log driver that combines multiple drivers into a single logging pipeline.
///
/// The stack driver allows you to send logs to multiple destinations simultaneously
/// while providing error handling and middleware support for each destination.
///
/// Features:
/// * Send logs to multiple destinations
/// * Per-driver middleware support
/// * Configurable error handling
/// * Detailed error reporting
///
/// Example:
/// ```dart
/// final stack = StackLogDriver([
///   ConsoleLogDriver(),
///   FileLogDriver('app.log'),
///   WebhookLogDriver(Uri.parse('https://logs.example.com')),
/// ]);
///
/// // Configure error handling
/// final stack = StackLogDriver(
///   drivers,
///   ignoreExceptions: true, // Continue if one driver fails
/// );
/// ```
class StackLogDriver extends LogDriver {
  /// The list of underlying log drivers
  final List<LogDriver> _drivers;

  /// Whether to continue logging if a driver fails
  final bool ignoreExceptions;

  /// Middleware specific to each driver type
  Map<String, List<DriverMiddleware>> _driverMiddlewares = {};

  /// Middleware specific to each named channel
  Map<String, List<DriverMiddleware>> _channelMiddlewares = {};

  /// Creates a stack driver that sends logs to multiple destinations.
  ///
  /// The [_drivers] list specifies the underlying drivers to send logs to.
  /// If [ignoreExceptions] is true, failures in one driver won't prevent
  /// logs from being sent to other drivers.
  StackLogDriver(this._drivers, {this.ignoreExceptions = false})
      : super("stack");

  /// Configures middleware for the stack driver.
  ///
  /// [driverMiddlewares] are applied based on the driver's type.
  /// [channelMiddlewares] are applied based on the channel name.
  void setMiddlewares(Map<String, List<DriverMiddleware>> driverMiddlewares,
      Map<String, List<DriverMiddleware>> channelMiddlewares) {
    _driverMiddlewares = driverMiddlewares;
    _channelMiddlewares = channelMiddlewares;
  }

  @override
  Future<void> log(LogEntry entry) async {
    Map<String, dynamic> errors = {};

    for (var driver in _drivers) {
      try {
        final driverName = driver.runtimeType.toString();

        // Process the log entry through driver-specific middleware
        final channelMiddlewares = _channelMiddlewares[driverName] ?? [];
        final driverMiddlewares = _driverMiddlewares[driverName] ?? [];

        var driverLogEntry = await processDriverMiddlewares(
          entry: entry,
          driverName: driverName,
          globalMiddlewares: [],
          channelMiddlewares: channelMiddlewares,
          driverMiddlewares: driverMiddlewares,
        );

        if (driverLogEntry == null) continue;

        await driver.log(driverLogEntry);
      } catch (e, s) {
        errors[driver.runtimeType.toString()] = {
          'error': e.toString(),
          'stackTrace': s,
          'message': entry.message,
          'entry': entry.toJson(),
        };
      }
    }

    if (errors.isNotEmpty && !ignoreExceptions) {
      throw StackDriverException(
        'Failed to log message to one or more channels',
        errors: errors,
      );
    }
  }
}

/// Exception thrown when one or more drivers in a stack fail to log a message.
///
/// The [errors] map contains detailed information about each failure, including:
/// * The error message
/// * Stack trace
/// * Original log message
/// * Full log entry data
class StackDriverException implements Exception {
  /// A descriptive error message
  final String message;

  /// Detailed error information per failed driver
  final Map<String, dynamic> errors;

  /// Creates a new stack driver exception.
  StackDriverException(
    this.message, {
    this.errors = const {},
  });

  @override
  String toString() {
    if (errors.isEmpty) {
      return 'StackDriverException: $message';
    }
    return 'StackDriverException: $message\nChannel errors: $errors';
  }
}
