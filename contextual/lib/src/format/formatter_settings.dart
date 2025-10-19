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
  /// Defaults to 'yyyy-MM-dd HH:mm:ss.SSS'.
  final DateFormat timestampFormat;

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
  }) : timestampFormat =
           timestampFormat ?? DateFormat('yyyy-MM-dd HH:mm:ss.SSS');
}
