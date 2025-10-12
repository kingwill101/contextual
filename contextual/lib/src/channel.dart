import 'driver/driver.dart';
import 'format/message_formatter.dart';
import 'middleware.dart';

/// Runtime channel wrapper used by Logger.
///
/// Holds the logical channel name, the LogDriver, and optional
/// per-channel formatter and middlewares.
class Channel<T extends LogDriver> {
  final String name;
  final T driver;
  final LogMessageFormatter? formatter;
  final List<DriverMiddleware> middlewares;

  /// Create a new channel wrapper.
  const Channel({
    required this.name,
    required this.driver,
    this.formatter,
    this.middlewares = const [],
  });

  /// Return a copy of this channel with overrides.
  Channel<T> copyWith({
    String? name,
    T? driver,
    LogMessageFormatter? formatter,
    List<DriverMiddleware>? middlewares,
  }) => Channel<T>(
        name: name ?? this.name,
        driver: driver ?? this.driver,
        formatter: formatter ?? this.formatter,
        middlewares: middlewares ?? this.middlewares,
      );
}

