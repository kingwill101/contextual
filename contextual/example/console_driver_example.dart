import 'package:contextual/contextual.dart';

/// This example demonstrates console logging with pretty formatting and colors.
void main() async {
  final logger = await Logger.create(
    formatter: PrettyLogFormatter(),
    typedConfig: const TypedLogConfig(
      channels: [ConsoleChannel(ConsoleOptions())],
    ),
  );

  try {
    // Demonstrate all log levels with their respective colors
    logger.debug('Debug message in blue - for detailed information');
    logger.info('Info message in green - for general information');
    logger.notice('Notice message in cyan - for significant events');
    logger.warning('Warning message in yellow - for potential issues');
    logger.error('Error message in red - for error conditions');
    logger.critical('Critical message in bold red - for critical failures');

    // Add context to show structured data with color-coded output
    logger.withContext({
      'requestId': '123abc',
      'user': 'john_doe',
      'action': 'login',
    }).info('User action with context data');

    // Example with error and stack trace
    try {
      throw Exception('Database connection failed');
    } catch (e, stack) {
      logger.withContext({
        'error': e.toString(),
        'stackTrace':
            stack.toString().split('\n')[0], // First line of stack trace
      }).error('Error occurred during database operation');
    }
  } finally {
    // While not strictly necessary for console-only logging,
    // it's good practice to clean up resources
    await logger.shutdown();
  }
}
