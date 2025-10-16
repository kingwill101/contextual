// sample.dart
import 'package:contextual/contextual.dart';

void main() async {
  // Logger configuration
  final config = LogConfig(
    channels: const [
      ConsoleChannel(ConsoleOptions(), name: 'sampled_console'),
      StackChannel(
        StackOptions(channels: ['sampled_console']),
        name: 'stacked',
      ),
      SamplingChannel(
        SamplingOptions(
          rates: {Level.info: 0.5, Level.debug: 0.1},
          wrappedChannel: 'stacked',
        ),
        name: 'sampled',
      ),
    ],
  );

  final logger = await Logger.create(config: config);

  for (var i = 0; i < 100; i++) {
    logger['sampled'].info('This is an info message.');
  }
}
