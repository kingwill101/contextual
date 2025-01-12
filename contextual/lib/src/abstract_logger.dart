import 'context.dart';
import 'log_level.dart';
import 'logger_interface.dart';

/// An abstract logger class that implements the [LoggerInterface] and provides
/// default implementations for the various log levels.
///
/// This class is intended to be extended by concrete logger implementations
/// that provide the actual logging functionality.
abstract class AbstractLogger implements LoggerInterface {
  @override

  /// Logs an emergency-level message with the provided [message] and optional [context].
  ///
  /// Emergency-level messages indicate a critical system failure or other severe issue that requires immediate attention.
  void emergency(Object message, [Context? context]) {
    log(LogLevel.emergency.value, message, context ?? Context());
  }

  @override

  /// Logs an alert-level message with the provided [message] and optional [context].
  ///
  /// Alert-level messages indicate a serious issue that requires immediate attention, but may not be as critical as an emergency.
  void alert(Object message, [Context? context]) {
    log(LogLevel.alert.value, message, context ?? Context());
  }

  @override

  /// Logs a critical-level message with the provided [message] and optional [context].
  ///
  /// Critical-level messages indicate a serious issue that requires immediate attention, but may not be as severe as an emergency.
  void critical(Object message, [Context? context]) {
    log(LogLevel.critical.value, message, context ?? Context());
  }

  @override

  /// Logs an error-level message with the provided [message] and optional [context].
  ///
  /// Error-level messages indicate a problem that requires attention, but may not be as severe as an alert or emergency.
  void error(Object message, [Context? context]) {
    log(LogLevel.error.value, message, context ?? Context());
  }

  @override

  /// Logs a warning-level message with the provided [message] and optional [context].
  ///
  /// Warning-level messages indicate a potential issue or problem that may require attention, but is not as severe as an error.
  void warning(Object message, [Context? context]) {
    log(LogLevel.warning.value, message, context ?? Context());
  }

  @override

  /// Logs a notice-level message with the provided [message] and optional [context].
  ///
  /// Notice-level messages indicate a normal, but significant, event or condition that may require attention.
  void notice(Object message, [Context? context]) {
    log(LogLevel.notice.value, message, context ?? Context());
  }

  @override

  /// Logs an informational-level message with the provided [message] and optional [context].
  ///
  /// Informational-level messages provide general information about the system's operation, but do not indicate any issues or errors.
  void info(Object message, [Context? context]) {
    log(LogLevel.info.value, message, context ?? Context());
  }

  @override

  /// Logs a debug-level message with the provided [message] and optional [context].
  ///
  /// Debug-level messages are used for detailed diagnostic information that is typically only useful during development or troubleshooting.
  void debug(Object message, [Context? context]) {
    log(LogLevel.debug.value, message, context ?? Context());
  }
}
