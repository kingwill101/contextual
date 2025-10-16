import 'package:contextual/contextual.dart';

Future<void> main() async {
  final config = LogConfig(
    level: 'debug',
    environment: 'development',
    batching: const BatchingConfig(enabled: true, batchSize: 50),
    channels: [
      ConsoleChannel(const ConsoleOptions(), name: 'consoleA'),
      ConsoleChannel(const ConsoleOptions(), name: 'consoleB'),
      DailyFileChannel(
        const DailyFileOptions(path: 'logs/app', retentionDays: 7),
        name: 'file',
      ),
      StackChannel(
        const StackOptions(
          channels: ['consoleA', 'file'],
          ignoreExceptions: true,
        ),
        name: 'stacked',
      ),
      SamplingChannel(
        SamplingOptions(rates: {Level.debug: 0.5}, wrappedChannel: 'stacked'),
        name: 'sampled',
      ),
    ],
  );

  final logger = await Logger.create(config: config);

  logger.forDriver<ConsoleLogDriver>().info('to all console drivers');
  logger['file'].warning('to file only');
  logger['stacked'].error('to consoleA+file via stack');
  logger['sampled'].debug('this debug may be sampled');
}
