import 'dart:convert';

import '../context.dart';
import 'message_formatter.dart';
import '../util.dart';

/// Formats log messages as JSON.
class JsonLogFormatter extends LogMessageFormatter {
  JsonLogFormatter({
    super.settings,
    this.prettyPrint = false,
  });

  /// Whether to format the JSON output with indentation and line breaks.
  final bool prettyPrint;

  @override
  String format(String level, String message, Context context) {
    final contextData =
        settings.includeHidden ? context.all() : context.visible();
    final logEntry = <String, dynamic>{};

    if (settings.includeTimestamp) {
      logEntry['timestamp'] = settings.timestampFormat.format(DateTime.now());
    }

    if (settings.includeLevel) {
      logEntry['level'] = level;
    }

    if (settings.includePrefix && context.has('prefix')) {
      logEntry['prefix'] = context.get('prefix');
    }

    logEntry['message'] =
        interpolateMessage(message, Context.from(contextData));

    if (settings.includeContext) {
      logEntry['context'] = contextData;
    }

    return prettyPrint
        ? JsonEncoder.withIndent('  ').convert(logEntry)
        : jsonEncode(logEntry);
  }
}
