import '../context.dart';
import 'formatter_settings.dart';

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

  String format(String level, String message, Context context);
}