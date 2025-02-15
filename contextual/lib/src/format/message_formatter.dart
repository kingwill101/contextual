import 'package:contextual/src/format/formatter_settings.dart';
import '../record.dart';

/// Base interface for log message formatters.
///
/// Log formatters are responsible for converting [LogRecord] instances into
/// formatted strings suitable for output. They control how log messages appear
/// in the final output, including:
///
/// * Overall message structure
/// * Inclusion of metadata (timestamp, level, etc.)
/// * Formatting of context data
/// * Visual styling (colors, indentation, etc.)
///
/// The formatting behavior is controlled by [FormatterSettings], which allows
/// configuring which components are included in the output.
///
/// Built-in implementations:
/// * [JsonLogFormatter] - Structured JSON output
/// * [PlainTextLogFormatter] - Simple text with brackets
/// * [PrettyLogFormatter] - Colored terminal output
/// * [RawLogFormatter] - Unmodified message text
/// * [NullLogFormatter] - Discards all output
///
/// To implement a custom formatter:
/// 1. Extend this class
/// 2. Override [format] to convert records to strings
/// 3. Use [settings] to respect user preferences
/// 4. Handle all [LogRecord] fields appropriately
///
/// Example:
/// ```dart
/// class CustomFormatter extends LogMessageFormatter {
///   @override
///   String format(LogRecord record) {
///     final buffer = StringBuffer();
///     if (settings.includeTimestamp) {
///       buffer.write(record.time.toIso8601String());
///     }
///     buffer.write(record.message);
///     return buffer.toString();
///   }
/// }
/// ```
abstract class LogMessageFormatter {
  /// Configuration settings that control formatting behavior.
  final FormatterSettings settings;

  /// Creates a formatter with the specified settings.
  ///
  /// If [settings] is not provided, uses default settings.
  LogMessageFormatter({FormatterSettings? settings})
      : settings = settings ?? FormatterSettings();

  /// Converts a log record into a formatted string.
  ///
  /// This method must:
  /// * Handle all [LogRecord] fields appropriately
  /// * Respect the formatter's [settings]
  /// * Never return null
  /// * Never throw exceptions
  ///
  /// The returned string will be passed directly to the log driver
  /// for output.
  String format(LogRecord record);
}
