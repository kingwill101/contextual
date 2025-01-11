import 'package:contextual/contextual.dart';

void main() {
  final config = LogConfig.fromJson({
    'channels': {
      'stack': {
        'driver': 'stack',
        'channels': ['console', 'daily'],
        'ignoreExceptions': true,
      },
      'console': {
        'driver': 'console',
      },
      'daily': {
        'driver': 'daily',
        'path': 'logs/stacked.log',
      },
    },
  });

  final logger = Logger(config: config);

  logger.info('This message is logged to both console and daily file.');
  logger.error('This error is logged to both console and daily file.');
}
