import 'package:contextual/src/context.dart';
import 'package:contextual/src/log_level.dart';

/// Represents a log record containing all relevant data for a logging event.
class LogRecord {
  /// The time at which the log event occurred.
  final DateTime time;

  /// The log level of the event.
  final Level level;

  /// The log message.
  final String message;

  /// The context associated with the log event.
  /// Stores key-value pairs for additional metadata.
  final Context context;

  /// The program counter or stack trace at the time the record was constructed.
  final StackTrace? stackTrace;

  /// Creates a new [LogRecord] instance with the given parameters.
  LogRecord({
    required this.time,
    required this.level,
    required this.message,
    Context? context,
    this.stackTrace,
  }) : context = context ?? Context();

  /// Returns a copy of the record with no shared state.
  LogRecord clone() {
    return LogRecord(
      time: time,
      level: level,
      message: message,
      context: Context.from(context.all()),
      stackTrace: stackTrace,
    );
  }

  /// Converts the log record to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'level': level.name,
      'message': message,
      'context': context.all(),
      'stackTrace': stackTrace?.toString(),
    };
  }
}
