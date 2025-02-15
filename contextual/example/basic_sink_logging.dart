import 'package:contextual/contextual.dart';

/// This example demonstrates basic sink logging with batching and auto-flush behavior.
void main() async {
  final logger = Logger(
    sinkConfig: LogSinkConfig(
      batchSize: 10, // Batch up to 10 messages
      flushInterval: Duration(seconds: 1), // Flush every second
      autoFlush: true, // Enable automatic flushing
    ),
  )..addChannel('file', DailyFileLogDriver('logs/app.log'));

  // Regular logs will be batched until batch size or flush interval
  logger.info('This will be batched');
  logger.debug('This will be batched too');
  logger.notice('Another batched message');

  // Emergency/Critical logs trigger immediate flush
  logger.emergency('This will flush immediately');

  // Add some context to the logs
  logger.withContext({
    'batch': 1,
    'timestamp': DateTime.now().toIso8601String(),
  }).info('Batched message with context');

  // Wait for auto-flush or call shutdown to ensure all messages are written
  await logger.shutdown();
}
