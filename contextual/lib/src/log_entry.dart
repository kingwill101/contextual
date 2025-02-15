import 'package:contextual/src/record.dart';

/// Represents a log entry that includes the LogRecord and the final formatted message.
class LogEntry {
  final LogRecord record;
  final String message;

  LogEntry(this.record, this.message);

  LogEntry copyWith({
    LogRecord? record,
    String? message,
  }) {
    return LogEntry(
      record ?? this.record,
      message ?? this.message,
    );
  }
}
