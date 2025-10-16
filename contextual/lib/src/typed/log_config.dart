import 'package:dart_mappable/dart_mappable.dart';
import 'batching_config.dart';
import 'formatter_settings_typed.dart';
import 'channel_config.dart';

part 'log_config.mapper.dart';

@MappableClass()
class LogConfig with LogConfigMappable {
  final String? level; // minimum level by name
  final String? formatter; // default formatter by name
  final FormatterSettings? formatterSettings;
  final String environment;
  final BatchingConfig? batching;
  final Map<String, dynamic>? context;
  final List<ChannelConfig> channels;

  const LogConfig({
    this.level,
    this.formatter,
    this.formatterSettings,
    this.environment = 'production',
    this.batching,
    this.context,
    this.channels = const [],
  });
}
