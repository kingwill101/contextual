import 'package:contextual/src/context.dart';

/// An abstract interface for a logger that provides methods for logging messages
/// at different severity levels.
abstract class LoggerInterface {
  /// Logs a message at the emergency level.
  ///
  /// Emergency level indicates system is unusable.
  void emergency(Object message, [Context context]);

  /// Logs a message at the alert level.
  ///
  /// Alert level indicates action must be taken immediately.
  void alert(Object message, [Context context]);

  /// Logs a message at the critical level.
  ///
  /// Critical level indicates critical conditions.
  void critical(Object message, [Context context]);

  /// Logs a message at the error level.
  ///
  /// Error level indicates error conditions.
  void error(Object message, [Context context]);

  /// Logs a message at the warning level.
  ///
  /// Warning level indicates warning conditions.
  void warning(Object message, [Context context]);

  /// Logs a message at the notice level.
  ///
  /// Notice level indicates normal but significant conditions.
  void notice(Object message, [Context context]);

  /// Logs a message at the info level.
  ///
  /// Info level indicates informational messages.
  void info(Object message, [Context context]);

  /// Logs a message at the debug level.
  ///
  /// Debug level indicates debug-level messages.
  void debug(Object message, [Context context]);

  /// Logs a message at the specified level.
  ///
  /// [level] The log level to use
  /// [message] The message to log
  /// [context] Optional context information
  void log(String level, Object message, [Context context]);
}
