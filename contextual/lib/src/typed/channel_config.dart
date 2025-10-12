import 'package:dart_mappable/dart_mappable.dart';
import '../format/message_formatter.dart';
import 'console_options.dart';
import 'daily_file_options.dart';
import 'webhook_options.dart';
import 'stack_options.dart';
import 'sampling_options.dart';

part 'channel_config.mapper.dart';

/// Typed channel configuration object hierarchy.
///
/// These types represent configuration/options for channels (not runtime channels).
/// The runtime logging channels are instances of `Channel<T extends LogDriver>`.
@MappableClass()
sealed class ChannelConfig with ChannelConfigMappable {
  final String? name;
  final LogMessageFormatter? formatter;
  const ChannelConfig({this.name, this.formatter});
}

@MappableClass()
class ConsoleChannel extends ChannelConfig with ConsoleChannelMappable {
  final ConsoleOptions options;
  const ConsoleChannel(this.options, {super.name, super.formatter});
}

@MappableClass()
class DailyFileChannel extends ChannelConfig with DailyFileChannelMappable {
  final DailyFileOptions options;
  const DailyFileChannel(this.options, {super.name, super.formatter});
}

@MappableClass()
class StackChannel extends ChannelConfig with StackChannelMappable {
  final StackOptions options;
  const StackChannel(this.options, {super.name, super.formatter});
}

@MappableClass()
class SamplingChannel extends ChannelConfig with SamplingChannelMappable {
  final SamplingOptions options;
  const SamplingChannel(this.options, {super.name, super.formatter});
}


@MappableClass()
class WebhookChannel extends ChannelConfig with WebhookChannelMappable {
  final WebhookOptions options;
  const WebhookChannel(this.options, {super.name, super.formatter});
}
