import 'package:contextual/src/record.dart';

import 'message_formatter.dart';

/// A formatter that returns log messages exactly as provided, without any formatting.
///
/// This formatter performs no processing on the log message, returning it exactly
/// as it was passed to the logger. It ignores all formatting settings and context
/// data, making it useful for cases where:
///
/// * You want complete control over message formatting
/// * The messages are pre-formatted
/// * You're integrating with a system that handles its own formatting
/// * You need to avoid any potential formatting overhead
///
/// Example:
/// ```dart
/// final logger = Logger()
///   ..formatter(RawLogFormatter())
///   ..info('Pre-formatted message');  // Outputs exactly: Pre-formatted message
/// ```
///
/// Note that using this formatter means you lose:
/// * Timestamp information
/// * Log level indicators
/// * Context data
/// * Message interpolation
class RawLogFormatter extends LogMessageFormatter {
  /// Creates a raw formatter that performs no message processing.
  ///
  /// The [settings] parameter is accepted but ignored since this formatter
  /// does not perform any formatting.
  RawLogFormatter({super.settings});

  @override
  String format(LogRecord record) {
    // Return the message without any formatting
    return record.message;
  }
}
