import 'package:contextual/src/context.dart';
import 'package:contextual/src/format/message_formatter.dart';
import 'package:contextual/src/util.dart';

/// A [LogMessageFormatter] implementation that formats log messages in a plain text format.
class PlainTextLogFormatter extends LogMessageFormatter {
  PlainTextLogFormatter({
    super.settings,
  });

  @override
  String format(String level, String message, Context context) {
    final contextData =
        settings.includeHidden ? context.all() : context.visible();
    final formattedMessage =
        interpolateMessage(message, Context.from(contextData));

    StringBuffer buffer = StringBuffer();

    // Include timestamp if enabled
    if (settings.includeTimestamp) {
      final timestamp = settings.timestampFormat.format(DateTime.now());
      buffer.write('[$timestamp] ');
    }

    // Include log level if enabled
    if (settings.includeLevel) {
      buffer.write('[$level] ');
    }

    // Include prefix if enabled and present
    if (settings.includePrefix && context.has('prefix')) {
      buffer.write('[${context.get('prefix')}] ');
    }

    buffer.write(formattedMessage);

    // Include context data if enabled
    if (settings.includeContext && contextData.isNotEmpty) {
      buffer.write(' | Context: ${contextData.toString()}');
    }

    return buffer.toString();
  }
}
