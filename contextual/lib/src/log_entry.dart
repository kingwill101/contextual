import 'package:contextual/src/record.dart';

/// Represents a complete log entry with both raw data and formatted output.
///
/// A log entry combines a [LogRecord], which contains the raw logging data
/// (timestamp, level, message, context), with its formatted string representation
/// ready for output. This separation allows the same log record to be formatted
/// differently for different outputs while maintaining the original data.
///
/// This class is used internally by log drivers to process and output logs.
/// The [record] contains all the raw data, while [message] contains the
/// pre-formatted string for the specific output channel.
///
/// Example:
/// ```dart
/// final record = LogRecord(
///   time: DateTime.now(),
///   level: Level.info,
///   message: "User logged in",
///   context: Context({'userId': '123'})
/// );
///
/// // Create entries with different formatting for different outputs
/// final jsonEntry = LogEntry(record, '{"level":"INFO","message":"User logged in"}');
/// final textEntry = LogEntry(record, '[INFO] User logged in');
/// ```
class LogEntry {
  /// The raw log record containing all logging data.
  final LogRecord record;

  /// The pre-formatted message ready for output.
  ///
  /// This string has already been processed by a [LogMessageFormatter]
  /// and is ready to be written to the output destination.
  final String message;

  /// Creates a new log entry with the given record and formatted message.
  ///
  /// The [record] parameter contains the raw logging data.
  /// The [message] parameter contains the formatted string for output.
  LogEntry(this.record, this.message);

  /// Creates a copy of this entry with optional field updates.
  ///
  /// This is useful when middleware needs to modify either the raw data
  /// or the formatted message without affecting the original entry.
  LogEntry copyWith({LogRecord? record, String? message}) {
    return LogEntry(record ?? this.record, message ?? this.message);
  }

  /// Converts the log entry to a JSON-compatible map.
  ///
  /// The resulting map includes both the raw record data and the
  /// formatted message. This is useful for serialization or when
  /// passing log entries between systems.
  Map<String, dynamic> toJson() => {
    'record': record.toJson(),
    'message': message,
  };
}
