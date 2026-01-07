import 'dart:async';

import 'package:contextual/contextual.dart';
import 'logger_manager.dart';

/// Example demonstrating proper resource management with LoggerManager.
/// This shows how to use the LoggerManager utility class to automatically
/// handle cleanup of subscriptions and logger shutdown.
void main() async {
  // Create a logger manager to handle resource cleanup
  final manager = LoggerManager();

  try {
    print('=== Setting up loggers and listeners ===');

    // Get loggers through the manager (automatically configured with console output)
    final app = manager.getLogger('app', level: Level.info);
    final database = manager.getLogger('app.database', level: Level.warning);
    final api = manager.getLogger('app.api'); // Inherits level from app

    // Add listeners through the manager (automatically tracked for cleanup)
    manager.addListener(app, (entry) {
      print('📱 APP: ${entry.record.level} - ${entry.record.message}');
      print('   Logger: ${entry.record.context.all()['logger']}');
    });

    manager.addListener(database, (entry) {
      print('🗄️  DB: ${entry.record.level} - ${entry.record.message}');
      print('   Logger: ${entry.record.context.all()['logger']}');
    });

    manager.addListener(manager.root, (entry) {
      print('🏠 ROOT: ${entry.record.level} - ${entry.record.message}');
      print('   Logger: ${entry.record.context.all()['logger']}');
    });

    print('\n=== Logging activity ===');
    print(
      'Manager has ${manager.loggerCount} loggers and ${manager.subscriptionCount} listeners',
    );

    // Generate various log messages
    manager.root.info('System initialization started');
    app.info('Loading application configuration');
    app.debug('Debug message (filtered out by level)');
    database.warning('Database connection pool running low');
    database.error(
      'Query execution timeout',
      Context({
        'query': 'SELECT * FROM users WHERE active = ?',
        'timeout': '30s',
        'attempts': 3,
      }),
    );
    api.info('API server listening on port 8080');
    api.debug('Request processing details (filtered out)');

    // Wait for async operations to complete
    await Future.delayed(Duration(milliseconds: 200));

    print('\n=== Resource status ===');
    print('Active subscriptions: ${manager.subscriptionCount}');
    print('Managed loggers: ${manager.loggerCount}');
  } finally {
    print('\n=== Cleanup ===');
    print(
      'Disposing LoggerManager (this will cancel subscriptions and shutdown loggers)...',
    );

    // This single call handles all cleanup:
    // - Cancels all subscriptions
    // - Shuts down all loggers
    // - Closes stream controllers
    await manager.dispose();

    print('Manager disposed: ${manager.isDisposed}');
    print('Remaining subscriptions: ${manager.subscriptionCount}');
    print('Remaining loggers: ${manager.loggerCount}');
  }

  print('\n✅ All resources cleaned up. Program exits cleanly.');
}
