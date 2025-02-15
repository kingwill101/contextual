import '../record.dart';
import '../context.dart';
import 'message_formatter.dart';
import '../util.dart';

/// A formatter that outputs log messages in a simple, unformatted text format.
///
/// This formatter produces plain text output without any special formatting or
/// colors, making it suitable for file logging or environments where ANSI
/// colors aren't supported.
///
/// The output format is:
/// ```
/// [2024-02-15 10:30:45.123] [INFO] [prefix] Message | Context: {key: value}
/// ```
///
/// Components (all optional based on settings):
/// * Timestamp in brackets
/// * Log level in brackets
/// * Prefix in brackets (if present in context)
/// * Message text
/// * Context data after a pipe symbol (if present)
///
/// Example outputs:
/// ```
/// [2024-02-15 10:30:45.123] [INFO] User logged in
/// [2024-02-15 10:30:45.123] [ERROR] [auth] Login failed | Context: {attempts: 3}
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

    final formattedMessage =
        interpolateMessage(record.message, Context.from(contextData));

    StringBuffer buffer = StringBuffer();

    if (settings.includeTimestamp) {
      final timestamp = settings.timestampFormat.format(record.time);
      buffer.write('[$timestamp] ');
    }

    if (settings.includeLevel) {
      buffer.write('[${record.level}] ');
    }

    if (settings.includePrefix && record.context.has('prefix')) {
      buffer.write('[${record.context.get('prefix')}] ');
    }

    buffer.write(formattedMessage);

    if (settings.includeContext && contextData.isNotEmpty) {
      buffer.write(' | Context: ${contextData.toString()}');
    }

    return buffer.toString();
  }
}
