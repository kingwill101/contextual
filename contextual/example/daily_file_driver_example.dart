import 'package:contextual/contextual.dart';

void main() {
  final config = LogConfig.fromJson({
    'channels': {
      'daily': {
        'driver': 'daily',
        'path': 'logs/daily.log',
        'days': 7, // Retain logs for 7 days
      },
    },
  });

  final logger = Logger(config: config);

  logger.info('This message is logged to a daily file.');
  logger.error('This error is logged to a daily file.');
}
