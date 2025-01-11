import 'package:contextual/src/context.dart';
import 'package:contextual/src/format/message_formatter.dart';

/// A [LogMessageFormatter] implementation that performs no formatting.
/// It returns the log message as-is.
class RawLogFormatter extends LogMessageFormatter {
  RawLogFormatter({super.settings});

  @override
  String format(String level, String message, Context context) {
    // Return the message without any formatting
    return message;
  }
}
