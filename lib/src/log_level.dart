/// Defines the different log levels that can be used in the application.
///
/// The log levels are ordered from most severe to least severe:
/// - [emergency]: Indicates a system is unusable.
/// - [alert]: Indicates an action must be taken immediately.
/// - [critical]: Indicates a critical condition.
/// - [error]: Indicates an error condition.
/// - [warning]: Indicates a warning condition.
/// - [notice]: Indicates a normal but significant condition.
/// - [info]: Indicates an informational message.
/// - [debug]: Indicates a debug-level message.
///
/// The [contains] method can be used to check if a given log level string is valid.
enum LogLevel {
  emergency('emergency'),
  alert('alert'),
  critical('critical'),
  error('error'),
  warning('warning'),
  notice('notice'),
  info('info'),
  debug('debug');

  final String value;
  const LogLevel(this.value);

  static const List<LogLevel> levels = [
    emergency,
    alert,
    critical,
    error,
    warning,
    notice,
    info,
    debug
  ];

  static bool contains(String level) {
    return levels.any((logLevel) => logLevel.value == level);
  }
}
