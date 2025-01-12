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
  final String driver;
  final String? path;
  final int? days;
  final List<String>? channels;
  final bool ignoreExceptions;
  final String env;
  final Uri? webhookUrl;
  final String? username;
  final String? emoji;

  ChannelConfig({
    required this.driver,
    this.path,
    this.days,
    this.channels,
    this.ignoreExceptions = false,
    this.env = 'all',
    this.webhookUrl,
    this.username,
    this.emoji,
  });

  /// Constructs a [ChannelConfig] instance from a JSON map.
  ///
  /// This factory method takes a JSON map and creates a new [ChannelConfig]
  /// instance based on the values in the map. It maps the JSON keys to the
  /// corresponding properties of the [ChannelConfig] class.
  factory ChannelConfig.fromJson(Map<String, dynamic> json) {
    return ChannelConfig(
      driver: json['driver'],
      path: json['path'],
      days: json['days'],
      channels: (json['channels'] as List?)?.map((e) => e.toString()).toList(),
      ignoreExceptions: json['ignoreExceptions'] ?? false,
      env: json['env'] ?? 'all',
      webhookUrl:
          json['webhookUrl'] != null ? Uri.parse(json['webhookUrl']) : null,
      username: json['username'],
      emoji: json['emoji'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driver': driver,
      if (path != null) 'path': path,
      if (days != null) 'days': days,
      if (channels != null) 'channels': channels,
      'ignoreExceptions': ignoreExceptions,
      'env': env,
      if (webhookUrl != null) 'webhookUrl': webhookUrl.toString(),
      if (username != null) 'username': username,
      if (emoji != null) 'emoji': emoji,
    };
  }
}