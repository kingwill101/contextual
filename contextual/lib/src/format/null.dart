import 'package:contextual/src/record.dart';

import 'message_formatter.dart';

/// A formatter that discards all log messages by returning an empty string.
///
/// This formatter is useful for:
/// * Disabling logging output for specific channels
/// * Testing logging performance without output overhead
/// * Creating mock loggers that don't produce output
/// * Temporarily silencing log output
///
/// Example:
/// ```dart
/// final logger = Logger()
///   ..addChannel('console', ConsoleLogDriver())
///   ..addChannel('silent', ConsoleLogDriver(), formatter: NullLogFormatter());
///
/// // This will be logged to console
/// logger.to(['console']).info('Visible message');
///
/// // This will be silently discarded
/// logger.to(['silent']).info('Invisible message');
/// ```
///
/// Note that while messages are discarded, any performance impact from
/// log processing, context building, and driver execution still occurs.
class NullLogFormatter extends LogMessageFormatter {
  /// Creates a null formatter that discards all messages.
  ///
  /// The [settings] parameter is accepted but ignored since this formatter
  /// does not produce any output.
  NullLogFormatter({super.settings});

  @override
  String format(LogRecord record) {
    // Return an empty string to effectively discard the message
    return '';
  }
}
