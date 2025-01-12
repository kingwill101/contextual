import 'context.dart';
import 'format/message_formatter.dart';
import 'format/plain.dart';
import 'logtype_formatter.dart';

/// Utility functions for log message formatting and interpolation.

/// Interpolates context values into a message string.
///
/// Takes a [message] string containing placeholders in the format `{key}` and
/// replaces them with corresponding values from the [context].
///
/// Example:
///
/// final context = Context({'name': 'John'});
/// final message = 'Hello {name}!';
/// final result = interpolateMessage(message, context); // 'Hello John!'
///
///
/// If a context value is null, it will be replaced with the string 'null'.
///
/// Returns the interpolated message string.
String interpolateMessage(String message, Context context) {
  context.all().forEach((key, value) {
    message = message.replaceAll('{$key}', value?.toString() ?? 'null');
  });
  return message;
}

/// Formats a log message using the specified formatter and type formatters.
///
/// Takes a [level] string indicating the log level, a [message] object containing
/// the log message, and a [context] object with additional logging context.
///
/// Optional parameters:
/// - [formatter]: A [LogMessageFormatter] to format the message (defaults to [PlainTextLogFormatter])
/// - [typeFormatters]: A map of Type to [LogTypeFormatter] for custom type formatting
///
/// If the message's runtime type matches a key in [typeFormatters], the corresponding
/// formatter will be used. Otherwise, falls back to the default [formatter].
///
/// Returns the formatted log message as a string.
String formatMessage(String level, Object message, Context context,
    {LogMessageFormatter? formatter,
    Map<Type, LogTypeFormatter> typeFormatters = const {}}) {
  formatter ??= PlainTextLogFormatter();
  final typeFormatter = typeFormatters[message.runtimeType];
  if (typeFormatter != null) {
    return typeFormatter.format(level, message, context);
  }
  return formatter.format(level, message.toString(), context);
}
