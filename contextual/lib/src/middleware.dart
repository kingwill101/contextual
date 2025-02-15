import 'dart:async';

import 'package:contextual/src/log_entry.dart';

/// Interface for log entry middlewares.
abstract class DriverMiddleware {
  /// Handles a log entry and returns a result indicating how to proceed.
  ///
  /// - [driverName]: The name of the driver handling the log entry.
  /// - [entry]: The [LogEntry] to process.
  ///
  /// Returns a [DriverMiddlewareResult] indicating whether to proceed,
  /// stop processing, or modify the log entry.
  FutureOr<DriverMiddlewareResult> handle(
    String driverName,
    LogEntry entry,
  );
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
  DriverMiddlewareResult.modify(LogEntry this.modifiedEntry)
      : action = DriverMiddlewareAction.modify;
}
