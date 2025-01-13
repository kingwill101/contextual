import 'dart:convert';

import 'package:contextual/src/log_level.dart';

import 'package:contextual/src/context.dart';
import 'package:contextual/src/util.dart';
import 'message_formatter.dart';

/// Formats log messages as JSON.
class JsonLogFormatter extends LogMessageFormatter {
  JsonLogFormatter({
    super.settings,
    this.prettyPrint = false,
  });

  /// Whether to format the JSON output with indentation and line breaks.
  final bool prettyPrint;

  @override
  String format(Level level, String message, Context context) {
    final contextData =
        settings.includeHidden ? context.all() : context.visible();
    final logEntry = <String, dynamic>{};

    if (settings.includeTimestamp) {
      logEntry['timestamp'] = settings.timestampFormat.format(DateTime.now());
    }

    if (settings.includeLevel) {
      logEntry['level'] = level.toString();
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
