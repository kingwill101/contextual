import 'dart:async';
import 'middleware.dart';
import 'log_entry.dart';

/// Processes a middleware chain for a specific driver and channel.
///
/// Returns `null` if processing should stop; otherwise, returns the potentially modified [LogEntry].
Future<LogEntry?> processDriverMiddlewares({
  required LogEntry entry,
  List<DriverMiddleware> globalMiddlewares = const [],
  List<DriverMiddleware> channelMiddlewares = const [],
  List<DriverMiddleware> driverMiddlewares = const [],
}) async {
  var currentEntry = entry;

  // Apply global middlewares first.
  for (var middleware in globalMiddlewares) {
    final result = await middleware.handle(currentEntry);
    if (result.action == DriverMiddlewareAction.stop) {
      return null; // Stop processing.
    } else if (result.action == DriverMiddlewareAction.modify) {
      currentEntry = result.modifiedEntry!;
    }
    // If action is proceed, continue without changes.
  }

  // Apply channel-specific middlewares next.
  for (var middleware in channelMiddlewares) {
    final result = await middleware.handle(currentEntry);
    if (result.action == DriverMiddlewareAction.stop) {
      return null;
    } else if (result.action == DriverMiddlewareAction.modify) {
      currentEntry = result.modifiedEntry!;
    }
  }

  // Apply driver-specific middlewares last.
  for (var middleware in driverMiddlewares) {
    final result = await middleware.handle(currentEntry);
    if (result.action == DriverMiddlewareAction.stop) {
      return null;
    } else if (result.action == DriverMiddlewareAction.modify) {
      currentEntry = result.modifiedEntry!;
    }
  }

  return currentEntry;
}
