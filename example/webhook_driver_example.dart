import 'package:contextual/contextual.dart';

void main() {
  final config = LogConfig.fromJson({
    'channels': {
      'webhook': {
        'driver': 'webhook',
        'webhookUrl': 'https://hooks.example.com/webhook',
        'username': 'LoggerBot',
        'emoji': ':robot:',
      },
    },
  });

  final logger = Logger(config: config);

  logger.info('This message is sent to a webhook.');
  logger.error('This error is sent to a webhook.');
}
