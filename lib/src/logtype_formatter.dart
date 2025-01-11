import 'package:contextual/src/context.dart';

/// Interface for type-specific formatting
abstract class LogTypeFormatter<T> {
  const LogTypeFormatter();

  /// Formats the given log [level], [message], and [context] for the specific [T] type.
  String format(String level, T message, Context context);
}
