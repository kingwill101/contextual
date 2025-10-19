import 'package:contextual/contextual.dart';

/// This example demonstrates pretty formatting with color-coded output.
/// Each log level has its own color scheme for better visual distinction.
void main() async {
  final logger = Logger(formatter: PrettyLogFormatter())
    ..addChannel('console', ConsoleLogDriver());

  // Set global context for all logs
  logger.withContext({"app": "MyApp", "environment": "development"});

  // Demonstrate all log levels with their respective colors
  logger.debug(
    'Detailed debugging information',
    Context({'detail': 'connection params'}),
  );
  logger.info(
    'General information about system operation',
    Context({'user': 'system'}),
  );
  logger.notice('Normal but significant events', Context({'event': 'startup'}));
  logger.warning('Warning conditions', Context({'issue': 'disk space low'}));
  logger.error('Error conditions', Context({'code': 500}));
  logger.critical('Critical conditions', Context({'service': 'database'}));
  logger.alert(
    'Action must be taken immediately',
    Context({'priority': 'high'}),
  );
  logger.emergency('System is unusable', Context({'status': 'offline'}));

  // Example with rich context data
  logger
      .withContext({
        'transaction': 'tx_123',
        'user': {
          'id': 'user_456',
          'role': 'admin',
          'permissions': ['read', 'write'],
        },
        'metadata': {'client': 'web', 'version': '2.0.0'},
      })
      .info('Complex data structure in pretty format');

  // Error with stack trace
  try {
    throw Exception('Something went wrong');
  } catch (e, stack) {
    logger
        .withContext({
          'error': {
            'message': e.toString(),
            'stack': stack.toString().split('\n').take(3).join('\n'),
            'time': DateTime.now().toIso8601String(),
          },
        })
        .error('Error occurred during operation');
  }

  await logger.shutdown();
}
