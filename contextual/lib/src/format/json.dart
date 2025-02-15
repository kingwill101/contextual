import 'dart:convert';

import 'package:contextual/src/context.dart';
import 'package:contextual/src/record.dart';
import 'package:contextual/src/util.dart';
import 'message_formatter.dart';

/// Formats log messages as structured JSON data.
///
/// This formatter produces machine-readable JSON output suitable for log aggregation
/// systems and automated processing. The output includes configurable fields like
/// timestamp, log level, message, and context data.
///
/// Features:
/// * Optional pretty printing with indentation
/// * Configurable field inclusion (timestamp, level, context, etc.)
/// * Support for hidden context data
/// * Message interpolation with context values
///
/// Example output:
/// ```json
/// {
///   "timestamp": "2024-02-15 10:30:45.123",
///   "level": "INFO",
///   "message": "User logged in",
///   "context": {
///     "userId": "12345",
///     "ip": "192.168.1.1"
///   }
/// }
/// ```
///
/// Use [prettyPrint] to enable formatted JSON output with indentation,
/// which is useful for debugging but less efficient for production use.
class JsonLogFormatter extends LogMessageFormatter {
  /// Creates a JSON formatter with optional pretty printing.
  ///
  /// If [prettyPrint] is true, the JSON output will be formatted with
  /// indentation and line breaks for better readability. Defaults to false
  /// for more compact output.
  JsonLogFormatter({
    super.settings,
    this.prettyPrint = false,
  });

  /// Whether to format the JSON output with indentation and line breaks.
  final bool prettyPrint;

  @override
  String format(LogRecord record) {
    final contextData = settings.includeHidden
        ? record.context.all()
        : record.context.visible();
    final logEntry = <String, dynamic>{};

    if (settings.includeTimestamp) {
      logEntry['timestamp'] = settings.timestampFormat.format(DateTime.now());
    }

    if (settings.includeLevel) {
      logEntry['level'] = record.level.toString();
    }

    if (settings.includePrefix && record.context.has('prefix')) {
      logEntry['prefix'] = record.context.get('prefix');
    }

    logEntry['message'] =
        interpolateMessage(record.message, Context.from(contextData));

    if (settings.includeContext) {
      logEntry['context'] = contextData;
    }

    return prettyPrint
        ? JsonEncoder.withIndent('  ').convert(logEntry)
        : jsonEncode(logEntry);
  }
}
