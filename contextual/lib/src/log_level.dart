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
enum Level {
  emergency,
  alert,
  critical,
  error,
  warning,
  notice,
  info,
  debug;

  @override
  String toString() {
    return toUpperCase();
  }

  static const List<Level> levels = [
    emergency,
    alert,
    critical,
    error,
    warning,
    notice,
    info,
    debug
  ];
}

extension LevelExtension on Level {
  bool operator <(Level other) {
    return Level.levels.indexOf(this) < Level.levels.indexOf(other);
  }

  String toUpperCase() {
    return name.toUpperCase();
  }

  String toLowerCase() {
    return name.toLowerCase();
  }
}
