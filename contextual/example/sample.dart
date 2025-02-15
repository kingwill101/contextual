// sample.dart
import 'package:contextual/contextual.dart';

void main() async {
  // Logger configuration
  final config = LogConfig.fromJson({
    'channels': {
      'stacked': {
        'driver': 'stack',
        'config': {
          'channels': ['sampled_console'],
        },
      },
      'sampled_console': {
        'driver': 'sampling',
        'config': {
          'sample_rates': {
            'info': 0.5, // 50% of 'info' level logs will be logged
            'debug': 0.1, // 10% of 'debug' level logs will be logged
          },
          'wrapped_driver': {
            'driver': 'daily',
          },
        }
      },
    },
  });

  // Initialize the logger with the configuration
  final logger = Logger(config: config, defaultChannelEnabled: false);

  for (var i = 0; i < 100; i++) {
    logger.to(['stacked']).info('This is an info message.');
  }
}
