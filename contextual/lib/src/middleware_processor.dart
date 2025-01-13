import 'package:contextual/src/middleware.dart';
import 'package:contextual/src/types.dart';

/// Processes a middleware chain for a specific driver and channel.
///
/// Returns null if the middleware chain indicates processing should stop,
/// otherwise returns the modified log entry.
Future<LogEntry?> processDriverMiddlewares({
  required LogEntry logEntry,
  required String driverName,
  List<DriverMiddleware> globalMiddlewares = const [],
  List<DriverMiddleware> channelMiddlewares = const [],
  List<DriverMiddleware> driverMiddlewares = const [],
}) async {
  var currentEntry = logEntry;

  // Apply global middlewares first
  for (var middleware in globalMiddlewares) {
    final result = await middleware.handle(driverName, currentEntry);
    if (result.action == DriverMiddlewareAction.stop) {
      return null;
    } else if (result.action == DriverMiddlewareAction.modify) {
      currentEntry = result.modifiedEntry!;
    }
  }

  // Apply channel-specific middlewares next
  for (var middleware in channelMiddlewares) {
    final result = await middleware.handle(driverName, currentEntry);
    if (result.action == DriverMiddlewareAction.stop) {
      return null;
    } else if (result.action == DriverMiddlewareAction.modify) {
      currentEntry = result.modifiedEntry!;
    }
  }

  // Then apply driver-specific middlewares
  for (var middleware in driverMiddlewares) {
    final result = await middleware.handle(driverName, currentEntry);
    if (result.action == DriverMiddlewareAction.stop) {
      return null;
    } else if (result.action == DriverMiddlewareAction.modify) {
      currentEntry = result.modifiedEntry!;
    }
  }

  return currentEntry;
}
