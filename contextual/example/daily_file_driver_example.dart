import 'package:contextual/contextual.dart';

/// This example demonstrates daily file logging with rotation and retention.
/// Logs are automatically rotated daily and old logs are cleaned up.
void main() async {
  final logger = Logger()
    ..addChannel(
      'file',
      DailyFileLogDriver(
        'logs/app', // Base path for log files
        retentionDays: 30, // Keep logs for 30 days
      ),
      formatter: JsonLogFormatter(
          prettyPrint: true), // Use JSON for structured logging
    );

  // Basic file logging
  logger.info('Application started');

  // Log with context data
  logger.withContext({
    'server': 'web-01',
    'environment': 'production',
    'version': '1.2.3',
  }).info('Server initialization complete');

  // Simulate multiple days of logging
  final now = DateTime.now();

  // Yesterday's logs
  logger.withContext({
    'date': now.subtract(Duration(days: 1)).toIso8601String(),
    'status': 'historical',
  }).info('This log entry is from yesterday');

  // Today's logs with various levels
  logger.debug('Debug message for troubleshooting');
  logger.warning('System resources running low');
  logger.error(
      'Failed to process request',
      Context({
        'request_id': '123',
        'endpoint': '/api/users',
      }));

  // Log structured data
  logger.info({
    'event': 'backup_completed',
    'duration': 125.45,
    'files_processed': 1250,
    'total_size': '2.5GB',
    'timestamp': DateTime.now().toIso8601String(),
  });

  // Example of how logs are organized:
  // logs/app-2024-02-15.log - Today's logs
  // logs/app-2024-02-14.log - Yesterday's logs
  // Logs older than retentionDays are automatically deleted

  await logger.shutdown();
}
