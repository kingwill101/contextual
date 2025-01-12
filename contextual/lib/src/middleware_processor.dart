import 'middleware.dart';

/// Processes a middleware chain for a specific driver.
///
/// Returns null if the middleware chain indicates processing should stop,
/// otherwise returns the modified log entry.
Future<MapEntry<String, String>?> processDriverMiddlewares({
  required MapEntry<String, String> logEntry,
  required String driverName,
  List<DriverMiddleware> globalMiddlewares = const [],
  Map<String, List<DriverMiddleware>> driverMiddlewaresMap = const {},
}) async {
  var currentEntry = logEntry;

  // Apply global middlewares first
  for (var middleware in globalMiddlewares) {
    final result = middleware.handle(driverName, currentEntry);
    if (result.action == DriverMiddlewareAction.stop) {
      return null;
    } else if (result.action == DriverMiddlewareAction.modify) {
      currentEntry = result.modifiedEntry!;
    }
  }

  // Then apply driver-specific middlewares
  final driverMiddlewares = driverMiddlewaresMap[driverName] ?? [];
  for (var middleware in driverMiddlewares) {
    final result = middleware.handle(driverName, currentEntry);
    if (result.action == DriverMiddlewareAction.stop) {
      return null;
    } else if (result.action == DriverMiddlewareAction.modify) {
      currentEntry = result.modifiedEntry!;
    }
  }

  return currentEntry;
}
