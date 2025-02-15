import 'package:contextual/src/context.dart';
import 'package:contextual/src/log_level.dart';

/// Interface for type-specific log message formatting.
///
/// Type formatters allow specialized formatting for specific object types when
/// they are passed as log messages. This is useful for providing detailed,
/// type-appropriate string representations of objects in log output.
///
/// Common use cases:
/// * Formatting error objects with stack traces
/// * Converting complex objects to human-readable strings
/// * Customizing output for domain-specific types
/// * Handling collections and data structures
///
/// Example implementation:
/// ```dart
/// class UserFormatter extends LogTypeFormatter<User> {
///   @override
///   String format(Level level, User user, Context context) {
///     return 'User(id: ${user.id}, name: ${user.name})';
///   }
/// }
///
/// // Register the formatter
/// logger.addTypeFormatter(UserFormatter());
///
/// // Now User objects will be formatted automatically
/// final user = User(id: '123', name: 'Alice');
/// logger.info(user);  // Outputs: User(id: 123, name: Alice)
/// ```
///
/// Type formatters are tried before general message formatting. If no type
/// formatter is found for a message's type, it falls back to the channel's
/// standard formatter.
abstract class LogTypeFormatter<T> {
  /// Creates a type formatter.
  ///
  /// Implementations should be const constructors when possible to allow
  /// for efficient reuse.
  const LogTypeFormatter();

  /// Formats a message of type [T] into a string.
  ///
  /// Parameters:
  /// * [level] - The log level of the message being formatted
  /// * [message] - The object to format, guaranteed to be of type [T]
  /// * [context] - The current logging context
  ///
  /// The implementation should:
  /// * Handle null values appropriately
  /// * Never throw exceptions
  /// * Return a meaningful string representation
  /// * Consider the log level when formatting
  /// * Use context data if relevant
  String format(Level level, T message, Context context);
}
