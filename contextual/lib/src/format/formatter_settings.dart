import 'package:intl/intl.dart';

/// A class that holds configuration settings for log formatters.
///
/// This class allows customization of how log messages are formatted by controlling
/// which components are included in the output and how they are displayed.
///
/// Settings include:
/// * [includeTimestamp] - Whether to include timestamp in log output
/// * [includeLevel] - Whether to include log level (INFO, ERROR etc.)
/// * [includePrefix] - Whether to include the log prefix
/// * [includeContext] - Whether to include contextual information
/// * [includeHidden] - Whether to include contextual information marked as hidden
/// * [timestampFormat] - The format to use for timestamps
class FormatterSettings {
  /// Whether to include timestamp in log output. Defaults to true.
  final bool includeTimestamp;

  /// Whether to include log level (INFO, ERROR etc.). Defaults to true.
  final bool includeLevel;

  /// Whether to include the log prefix. Defaults to true.
  final bool includePrefix;

  /// Whether to include contextual information. Defaults to true.
  final bool includeContext;

  /// Whether to include hidden log messages. Defaults to false.
  final bool includeHidden;

  /// The format to use for timestamps.
  /// Defaults to RFC 3339 with offset (e.g. 2026-01-16T11:02:30.151-05:00).
  final DateFormat timestampFormat;

  final bool _useDefaultTimestampFormat;

  /// Creates a new [FormatterSettings] instance with the specified configuration.
  ///
  /// All boolean parameters default to their recommended values if not specified.
  /// The [timestampFormat] parameter defaults to 'yyyy-MM-dd HH:mm:ss.SSS' if not provided.
  FormatterSettings({
    this.includeTimestamp = true,
    this.includeLevel = true,
    this.includePrefix = true,
    this.includeContext = true,
    this.includeHidden = false,
    DateFormat? timestampFormat,
  }) : _useDefaultTimestampFormat = timestampFormat == null,
       timestampFormat =
           timestampFormat ?? DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");

  /// Formats the given [time] using the configured timestamp format.
  ///
  /// If no custom [timestampFormat] was provided, this returns an RFC 3339
  /// timestamp with offset (e.g. 2026-01-16T11:02:30.151-05:00).
  String formatTimestamp(DateTime time) {
    if (_useDefaultTimestampFormat) {
      return _formatRfc3339(time);
    }
    return timestampFormat.format(time);
  }

  static String _formatRfc3339(DateTime time) {
    final base = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(time);
    final offset = time.timeZoneOffset;
    final totalMinutes = offset.inMinutes.abs();
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    final sign = offset.inMinutes < 0 ? '-' : '+';
    return '$base$sign$hours:$minutes';
  }
}
