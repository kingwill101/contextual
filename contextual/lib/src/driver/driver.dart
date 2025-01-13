import 'package:contextual/src/types.dart';

/// Defines an interface for a log driver that can be used to log messages.
///
/// Implementations of this interface are responsible for handling the actual
/// logging of messages, such as writing them to a file, sending them to a
/// remote logging service, or displaying them in the console.
abstract class LogDriver {
  final String name;

  LogDriver(this.name);

  /// Logs the provided [formattedMessage] using the driver's implementation
  Future<void> log(String formattedMessage);
}

/// Provides a factory for creating instances of [LogDriver] based on configuration.
///
/// The [LogDriverFactory] is responsible for registering different types of log drivers
/// and creating instances of them based on the provided configuration. This allows
/// the logging system to be easily extended with new log driver implementations
/// without modifying the core logging logic.
class LogDriverFactory {
  final Map<String, LogDriver Function(Map<String, dynamic>)>
      _registeredDrivers = {};

  /// Registers a new log driver implementation with the [LogDriverFactory].
  ///
  /// The [type] parameter specifies the unique identifier for the log driver
  /// implementation. The [builder] parameter is a function that takes a
  /// [Map<String, dynamic>] configuration and returns a new instance of the
  /// [LogDriver] implementation.
  ///
  /// This method allows the logging system to be extended with new log driver
  /// implementations without modifying the core logging logic.
  void registerDriver(String type, LogDriverBuilder builder) {
    _registeredDrivers[type] = builder;
  }

  /// Creates an instance of [LogDriver] based on the provided configuration.
  ///
  /// The [config] parameter is a [Map<String, dynamic>] that contains the
  /// configuration for the log driver to be created. The configuration should
  /// include a 'driver' key that specifies the type of log driver to create.
  ///
  /// If the specified log driver type is registered with the [LogDriverFactory],
  /// this method will create an instance of the corresponding log driver
  /// implementation and return it. If the specified log driver type is not
  /// registered, this method will throw an [ArgumentError].
  LogDriver createDriver(Map<String, dynamic> config) {
    final driverType = config['driver'];
    final builder = _registeredDrivers[driverType];
    if (builder != null) {
      return builder(config);
    }
    throw ArgumentError(
        'Unsupported driver type: $driverType supported types: ${_registeredDrivers.keys}');
  }

  /// Returns the map of registered log driver implementations.
  ///
  /// This property provides access to the internal map of registered log driver
  /// implementations, which can be useful for inspecting or modifying the
  /// available log driver types.
  List<String> get registeredDrivers => _registeredDrivers.keys.toList();
}
