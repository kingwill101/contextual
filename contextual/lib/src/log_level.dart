/// Defines the severity levels for log messages in descending order.
///
/// Log levels are ordered from most severe (emergency) to least severe (debug).
/// This ordering allows for:
/// * Filtering logs above or below a certain severity
/// * Comparing levels for conditional logging
/// * Consistent level-based formatting
///
/// The levels, from highest to lowest severity, are:
/// 1. [emergency] - System is unusable (e.g., complete system failure)
/// 2. [alert] - Action must be taken immediately (e.g., database corruption)
/// 3. [critical] - Critical conditions (e.g., hardware failure)
/// 4. [error] - Error conditions (e.g., API call failed)
/// 5. [warning] - Warning conditions (e.g., disk space low)
/// 6. [notice] - Normal but significant events (e.g., system startup)
/// 7. [info] - Informational messages (e.g., configuration details)
/// 8. [debug] - Debug-level messages (e.g., detailed flow tracing)
///
/// Example usage:
/// ```dart
/// // Simple logging
/// logger.error('Database connection failed');
///
/// // Level comparison
/// if (currentLevel < Level.error) {
///   // Handle less severe levels differently
/// }
///
/// // Level-based filtering
/// final isImportant = level <= Level.warning;
/// ```
///
/// The levels are based on RFC 5424 syslog severity levels.
enum Level {
  /// System is unusable
  emergency,

  /// Action must be taken immediately
  alert,

  /// Critical conditions
  critical,

  /// Error conditions
  error,

  /// Warning conditions
  warning,

  /// Normal but significant conditions
  notice,

  /// Informational messages
  info,

  /// Debug-level messages
  debug;

  @override
  String toString() {
    return toUpperCase();
  }

  /// The ordered list of all log levels from most to least severe.
  ///
  /// This list is used internally for level comparisons and can be
  /// used to iterate through levels in severity order.
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

/// Extension methods for working with log levels.
extension LevelExtension on Level {
  /// Compares two levels based on their severity.
  ///
  /// Returns true if this level is less severe than [other].
  /// For example: Level.info < Level.error is true because info
  /// is less severe than error.
  bool operator <(Level other) {
    return Level.levels.indexOf(this) < Level.levels.indexOf(other);
  }

  /// Converts the level name to uppercase.
  ///
  /// This is commonly used for log output formatting.
  /// Example: Level.info.toUpperCase() returns "INFO"
  String toUpperCase() {
    return name.toUpperCase();
  }

  /// Converts the level name to lowercase.
  ///
  /// This is useful for configuration and serialization.
  /// Example: Level.info.toLowerCase() returns "info"
  String toLowerCase() {
    return name.toLowerCase();
  }
}
