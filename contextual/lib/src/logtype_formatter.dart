import 'package:contextual/src/context.dart';
import 'package:contextual/src/log_level.dart';

/// Interface for type-specific formatting
abstract class LogTypeFormatter<T> {
  const LogTypeFormatter();

  /// Formats the given log [level], [message], and [context] for the specific [T] type.
  String format(Level level, T message, Context context);
}
