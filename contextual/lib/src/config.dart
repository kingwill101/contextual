/// Represents the configuration for the logging system.
///
/// This class holds the configuration for the various logging channels,
/// as well as any default settings that should be applied across all channels.
/// The configuration can be loaded from a JSON representation using the
/// [LogConfig.fromJson] factory constructor.
class LogConfig {
  final Map<String, dynamic> defaults;
  final Map<String, ChannelConfig> channels;

  LogConfig({this.channels = const {}, this.defaults = const {}});

  /// Constructs a [LogConfig] instance from a JSON representation.
  ///
  /// The JSON representation should have a 'channels' key that maps to a
  /// dictionary of [ChannelConfig] instances, where the keys are the channel
  /// names. Optionally, the JSON may also have a 'defaults' key that maps to
  /// a dictionary of default configuration values to be applied across all
  /// channels.
  factory LogConfig.fromJson(Map<String, dynamic> json) {
    final channelsMap = (json['channels'] as Map<String, dynamic>?) ?? {};
    final channels = channelsMap
        .map((key, value) => MapEntry(key, ChannelConfig.fromJson(value)));
    return LogConfig(
      channels: channels,
      defaults: json['defaults'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'channels': channels.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

/// Represents the configuration for a single logging channel.
///
/// This class holds the configuration options for a specific logging channel,
/// such as the driver, path, days to retain logs, and other channel-specific
/// settings.
class ChannelConfig {
  final String name;
  final String driver;
  Map<String, dynamic> config = const {};
  final String env;
  final String? formatter;

  ChannelConfig({
    this.name = '',
    required this.driver,
    this.formatter,
    this.env = 'all',
    this.config = const {},
  });

  /// Constructs a [ChannelConfig] instance from a JSON map.
  ///
  /// This factory method takes a JSON map and creates a new [ChannelConfig]
  /// instance based on the values in the map. It maps the JSON keys to the
  /// corresponding properties of the [ChannelConfig] class.
  factory ChannelConfig.fromJson(Map<String, dynamic> json) {
    return ChannelConfig(
      driver: json['driver'],
      config: json['config'] ?? const {},
      formatter: json['formatter'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'driver': driver,
      'config': config,
      'env': env,
      if (formatter != null) 'formatter': formatter,
    };
  }
}
