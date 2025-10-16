import 'package:contextual/contextual.dart';

/// This example demonstrates basic sink logging with batching and auto-flush behavior.
void main() async {
  final logger = Logger()..addChannel('file', ConsoleLogDriver());

  await logger.batched(
    LogSinkConfig(
      batchSize: 10, // Batch up to 10 messages
      flushInterval: Duration(seconds: 1), // Flush every second
      autoFlush: true, // Enable automatic flushing
    ),
  );

  // Regular logs will be batched until batch size or flush interval
  logger['file'].info('This will be batched');
  logger['file'].debug('This will be batched too');
  logger['file'].notice('Another batched message');

  // Emergency/Critical logs trigger immediate flush
  logger['file'].emergency('This will flush immediately');

  // Add some context to the logs
  logger
      .withContext({
        'batch': 1,
        'timestamp': DateTime.now().toIso8601String(),
      })['file']
      .info('Batched message with context');

  // Wait for auto-flush or call shutdown to ensure all messages are written
  // await logger.shutdown();
}
