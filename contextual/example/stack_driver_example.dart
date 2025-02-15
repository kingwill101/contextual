import 'package:contextual/contextual.dart';

/// This example demonstrates using the stack log driver for error tracking
/// and debugging. The stack driver maintains a circular buffer of recent logs
/// and can dump them when errors occur.
void main() async {
  // Create a console driver for output
  final consoleDriver = ConsoleLogDriver();
  final fileDriver = DailyFileLogDriver('logs/app.log');

  // Create a stack driver that combines both drivers
  final stackDriver = StackLogDriver(
    [consoleDriver, fileDriver],
    ignoreExceptions: true, // Continue if one driver fails
  );

  // Create a logger with the stack driver
  final logger = Logger()
    ..addChannel(
      'stack',
      stackDriver,
      formatter: JsonLogFormatter(),
    );

  // Add some regular logs
  logger.info('Application starting');
  logger.debug('Initializing components');

  // Simulate normal operation with some warnings
  for (var i = 0; i < 5; i++) {
    logger.info(
        'Processing batch $i',
        Context({
          'batch_id': i,
          'items': 100,
        }));

    if (i % 2 == 0) {
      logger.warning(
          'Slow processing detected',
          Context({
            'batch_id': i,
            'duration_ms': 1500 + i * 100,
          }));
    }
  }

  // Simulate an error condition
  try {
    throw Exception('Database connection lost');
  } catch (e, stack) {
    // This will be logged to both console and file
    logger.error(
        'Critical error occurred',
        Context({
          'error': e.toString(),
          'stack': stack.toString(),
          'component': 'database',
        }));
  }

  // Continue with more logs
  logger.info('Attempting recovery');
  logger.debug('Reconnecting to database');

  // Simulate another error
  try {
    throw StateError('Invalid application state');
  } catch (e, stack) {
    // Log the error to both drivers
    logger.critical(
        'Application state error',
        Context({
          'error': e.toString(),
          'stack': stack.toString(),
        }));
  }

  // Example of using multiple stack drivers
  final multiLogger = Logger()
    ..addChannel(
      'production',
      StackLogDriver(
        [
          ConsoleLogDriver(),
          DailyFileLogDriver('logs/prod.log'),
        ],
      ),
      formatter: JsonLogFormatter(),
    )
    ..addChannel(
      'monitoring',
      StackLogDriver(
        [
          WebhookLogDriver(Uri.parse('https://alerts.example.com')),
          DailyFileLogDriver('logs/alerts.log'),
        ],
      ),
      formatter: PlainTextLogFormatter(),
    );

  // Log to production stack
  multiLogger.to(['production']).info(
      'Production system healthy',
      Context({
        'uptime': '5d 12h',
        'memory': '2.5GB',
      }));

  // Log to monitoring stack
  multiLogger.to(['monitoring']).alert(
      'High memory usage detected',
      Context({
        'memory_used': '7.5GB',
        'threshold': '7GB',
      }));

  // Cleanup
  await logger.shutdown();
  await multiLogger.shutdown();
}
