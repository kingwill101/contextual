import 'package:contextual/contextual.dart';

void main() async {
  final config = LogConfig(
    environment: 'development',
    batching: const BatchingConfig(enabled: true, batchSize: 50),
    channels: [
      ConsoleChannel(const ConsoleOptions(), name: 'console'),
      DailyFileChannel(
        const DailyFileOptions(path: 'logs/app', retentionDays: 7),
        name: 'file',
      ),
      WebhookChannel(
        WebhookOptions(url: Uri.parse('https://example.com/hook')),
        name: 'web',
      ),
    ],
  );

  final logger = await Logger.create(config: config);

  logger.info('hello world');
  logger.forDriver<ConsoleLogDriver>().debug('only console');
  logger['file'].warning('to file only');
}
