import 'dart:async';

import 'package:contextual/contextual.dart';

/// This example demonstrates proper resource management when using listeners
/// with named loggers. It shows how to avoid hanging by properly cleaning up
/// subscriptions and shutting down loggers.
void main() async {
  // Create named loggers
  final root = Logger.root;
  final app = Logger(name: 'app', level: Level.info);
  final database = Logger(name: 'app.database', level: Level.warning);

  // Add console output
  root.addChannel('console', ConsoleLogDriver());

  print('=== Setting up listeners ===');

  // Create a list to track all subscriptions for cleanup
  final subscriptions = <StreamSubscription<LogEntry>>[];

  try {
    // Set up listeners for different loggers
    subscriptions.addAll([
      root.onRecord.listen((entry) {
        print('ROOT: ${entry.record.level} - ${entry.record.message}');
        print('  Context: ${entry.record.context.all()}');
      }),

      app.onRecord.listen((entry) {
        print('APP: ${entry.record.level} - ${entry.record.message}');
        print('  Logger: ${entry.record.context.all()['logger']}');
      }),

      database.onRecord.listen((entry) {
        print('DB: ${entry.record.level} - ${entry.record.message}');
        print('  Logger: ${entry.record.context.all()['logger']}');
      }),
    ]);

    print('\n=== Logging with listeners active ===');

    // Generate some logs
    root.info('Application starting');
    app.info('Initializing components');
    app.debug('This debug message won\'t show due to level filtering');
    database.warning('Database connection slow');
    database.error('Query timeout', Context({'query': 'SELECT * FROM users'}));

    // Wait for async logging to complete
    await Future.delayed(Duration(milliseconds: 100));

    print('\n=== Cleanup ===');
  } finally {
    // CRITICAL: Always clean up subscriptions first
    print('Cancelling subscriptions...');
    for (final subscription in subscriptions) {
      subscription.cancel();
    }

    // CRITICAL: Always shutdown loggers to close streams and clean up resources
    print('Shutting down loggers...');
    await root.shutdown();
  }

  print('All resources cleaned up. Program will exit cleanly.');
}
