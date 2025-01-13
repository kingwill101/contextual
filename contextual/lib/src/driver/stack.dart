import 'package:contextual/contextual.dart';

import 'package:contextual/src/middleware_processor.dart';

/// A driver that combines multiple channels into a single logging destination.
///
/// The [StackLogDriver] allows you to create a single channel that forwards logs
/// to multiple other channels. This is useful when you want to log the same messages
/// to multiple destinations without explicitly specifying them each time.
///
/// Example configuration:
///
/// final config = LogConfig.fromJson({
///   'channels': {
///     'production': {  // This is our stacked channel
///       'driver': 'stack',
///       'channels': ['file', 'slack'], // Forward to both channels
///       'ignore_exceptions': true
///     },
///     'file': {
///       'driver': 'daily',
///       'path': 'logs/app.log'
///     },
///     'slack': {
///       'driver': 'webhook',
///       'webhookUrl': 'https://hooks.slack.com/...'
///     }
///   }
/// });
///
/// // Now logs to 'production' will go to both file and slack
/// logger.to(['production']).info('This goes to both file and slack');
///
///
/// The stack driver maintains its own set of middleware chains for each underlying
/// channel, allowing fine-grained control over how logs are processed for each
/// destination.

class StackLogDriver extends LogDriver {
  final List<LogDriver> _drivers;
  final bool ignoreExceptions;
  Map<String, List<DriverMiddleware>> _driverMiddlewares = {};
  Map<String, List<DriverMiddleware>> _channelMiddlewares = {};

  StackLogDriver(this._drivers, {this.ignoreExceptions = false})
      : super("stack");

  void setMiddlewares(Map<String, List<DriverMiddleware>> driverMiddlewares,
      Map<String, List<DriverMiddleware>> channelMiddlewares) {
    _driverMiddlewares = driverMiddlewares;
    _channelMiddlewares = channelMiddlewares;
  }

  @override
  Future<void> log(String formattedMessage) async {
    Map<String, dynamic> errors = {};

    for (var driver in _drivers) {
      try {
        final driverName = driver.runtimeType.toString();

        // Gather middlewares for this driver
        final channelMiddlewares = _channelMiddlewares[driverName] ?? [];
        final driverMiddlewares = _driverMiddlewares[driverName] ?? [];

        var driverLogEntry = await processDriverMiddlewares(
          logEntry: MapEntry(Level.info, formattedMessage),
          driverName: driverName,
          globalMiddlewares: [],
          channelMiddlewares: channelMiddlewares,
          driverMiddlewares: driverMiddlewares,
        );

        if (driverLogEntry == null) continue;

        await driver.log(driverLogEntry.value);
      } catch (e) {
        errors[driver.runtimeType.toString()] = e.toString();
        if (!ignoreExceptions) {
          throw StackDriverException(
            'Failed to log message to one or more channels',
            errors: errors,
          );
        }
      }
    }

    if (errors.isNotEmpty && ignoreExceptions) {
      throw StackDriverException(
        'Failed to log message to one or more channels (ignored)',
        errors: errors,
      );
    }
  }
}

/// Exception thrown when logging fails in a stack driver.
class StackDriverException implements Exception {
  final String message;
  final Map<String, dynamic> errors;

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
