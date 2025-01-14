import 'dart:async';

import 'package:contextual/src/types.dart';

/// Interface for log entry middlewares
abstract class DriverMiddleware {
  /// Handle a log entry and return a result indicating how to proceed.
  FutureOr<DriverMiddlewareResult> handle(String driverName, LogEntry entry);
}

/// Represents the possible actions that a [DriverMiddleware] can take when handling a log entry.
/// - [proceed]: Indicates that the log entry should be processed without any modifications.
/// - [stop]: Indicates that the log entry processing should be stopped.
/// - [modify]: Indicates that the log entry should be modified.
enum DriverMiddlewareAction { proceed, stop, modify }

/// Represents the result of a log entry middleware operation.
/// This class provides different constructors to indicate whether the middleware should
/// proceed, stop, or modify the log entry.
class DriverMiddlewareResult {
  final DriverMiddlewareAction action;
  final LogEntry? modifiedEntry;

  /// Creates a [DriverMiddlewareResult] instance that indicates the log entry should be
  /// processed without any modifications.
  DriverMiddlewareResult.proceed()
      : action = DriverMiddlewareAction.proceed,
        modifiedEntry = null;

  /// Creates a [DriverMiddlewareResult] instance that indicates the log entry processing
  /// should be stopped.
  DriverMiddlewareResult.stop()
      : action = DriverMiddlewareAction.stop,
        modifiedEntry = null;

  /// Creates a [DriverMiddlewareResult] instance that indicates the log entry should be
  /// modified with the provided [newEntry].
  DriverMiddlewareResult.modify(LogEntry newEntry)
      : action = DriverMiddlewareAction.modify,
        modifiedEntry = newEntry;
}
