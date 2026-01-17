import 'package:contextual/contextual.dart';

/// This example demonstrates console logging with logfmt-style output and colors.
void main() async {
  final logger = await Logger.create(
    formatter: PrettyLogFormatter(),
    config: const LogConfig(channels: [ConsoleChannel(ConsoleOptions())]),
  );

  try {
    // Demonstrate all log levels with their respective colors
    logger.debug('Debug message in blue - for detailed information');
    logger.info('Info message in green - for general information');
    logger.notice('Notice message in cyan - for significant events');
    logger.warning('Warning message in yellow - for potential issues');
    logger.error('Error message in red - for error conditions');
    logger.critical('Critical message in bold red - for critical failures');

    // Add context to show structured data
    logger
        .withContext({
          'requestId': '123abc',
          'user': 'john_doe',
          'action': 'login',
        })
        .info('User action with context data');

    // Example with error and stack trace
    try {
      throw Exception('Database connection failed');
    } catch (e, stack) {
      logger.error('Error occurred during database operation', {
        'error': e.toString(),
      }, stack);
    }
  } finally {
    // While not strictly necessary for console-only logging,
    // it's good practice to clean up resources
    await logger.shutdown();
  }
}
