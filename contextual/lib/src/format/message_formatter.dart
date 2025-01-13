import 'package:contextual/src/context.dart';
import 'package:contextual/src/format/formatter_settings.dart';
import 'package:contextual/src/log_level.dart';

/// Defines the interface for formatting log messages.
///
/// Implementations of this interface can format log messages with additional context
/// information.
/// The [settings] property provides access to the [FormatterSettings] object, which
/// can be used to configure the formatting behavior.
/// see [JsonLogFormatter] for json .
/// see [PlainTextLogFormatter] for plain text .
/// see [PrettyLogFormatter] for pretty text  .
abstract class LogMessageFormatter {
  final FormatterSettings settings;

  LogMessageFormatter({FormatterSettings? settings})
      : settings = settings ?? FormatterSettings();

  String format(Level level, String message, Context context);
}
