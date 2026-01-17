import '../context.dart';
import '../record.dart';
import '../util.dart';
import 'message_formatter.dart';
import 'logfmt.dart';

/// A formatter that outputs log messages in logfmt-style key/value pairs.
///
/// This formatter produces human-readable structured logs that are easy to
/// parse by log aggregation tools. It avoids ANSI colors and keeps output
/// on a single line, making it suitable for file logging and production use.
///
/// The output format is:
/// ```
/// time="2024-02-15T10:30:45.123-05:00" level=info msg="Message" key=value
/// ```
///
/// Components (all optional based on settings):
/// * `time` - Timestamp (settings.timestampFormat)
/// * `level` - Lowercase log level
/// * `prefix` - Optional prefix (if present in context)
/// * `msg` - Log message text
/// * Additional context key/value pairs
///
/// Example outputs:
/// ```
/// time="2024-02-15T10:30:45.123-05:00" level=info msg="User logged in"
/// time="2024-02-15T10:30:45.123-05:00" level=error msg="Login failed" prefix=auth attempts=3
/// ```
///
/// This formatter is ideal for:
/// * Log files
/// * System logs
/// * Environments without ANSI color support
/// * Machine parsing with simple text tools
class PlainTextLogFormatter extends LogMessageFormatter {
  /// Creates a plain text formatter with the specified settings.
  ///
  /// Uses [FormatterSettings] to control which components are included
  /// in the output.
  PlainTextLogFormatter({super.settings});

  @override
  String format(LogRecord record) {
    final contextData = settings.includeHidden
        ? record.context.all()
        : record.context.visible();

    final formattedMessage = interpolateMessage(
      record.message,
      Context.from(contextData),
    );

    final parts = <String>[];

    if (settings.includeTimestamp) {
      final timestamp = settings.formatTimestamp(record.time);
      parts.add('time=${formatLogfmtValue(timestamp)}');
    }

    if (settings.includeLevel) {
      parts.add('level=${formatLogfmtValue(record.level.name)}');
    }

    if (settings.includePrefix && record.context.has('prefix')) {
      parts.add('prefix=${formatLogfmtValue(record.context.get('prefix'))}');
    }

    parts.add('msg=${formatLogfmtValue(formattedMessage)}');

    if (settings.includeContext && contextData.isNotEmpty) {
      final contextEntries = Map<String, dynamic>.from(contextData);
      if (settings.includePrefix) {
        contextEntries.remove('prefix');
      }
      final flattened = flattenLogfmtContext(contextEntries);
      for (final entry in flattened.entries) {
        parts.add(
          '${formatLogfmtKey(entry.key)}=${formatLogfmtValue(entry.value)}',
        );
      }
    }

    if (record.stackTraceProvided && record.stackTrace != null) {
      parts.add(
        'stackTrace=${formatLogfmtValue(record.stackTrace.toString())}',
      );
    }

    return parts.join(' ');
  }
}
