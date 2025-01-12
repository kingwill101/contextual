import 'package:contextual/contextual.dart';

void main() {
  final config = LogConfig.fromJson({
    'channels': {
      'console': {
        'driver': 'console',
      },
    },
  });

  final logger = Logger(config: config);

  logger.info('This message is logged to the console.');
  logger.error('This error is logged to the console.');
}
