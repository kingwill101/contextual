import 'package:contextual/contextual.dart';

/// Basic example demonstrating named loggers with levels and context.
void main() async {
  // Create named loggers with different levels
  final app = Logger(name: 'app', level: Level.info);
  final database = Logger(name: 'app.database', level: Level.warning);
  final api = Logger(name: 'app.api'); // Inherits level from app

  // Add console output
  app.addChannel('console', ConsoleLogDriver());

  print('Logger levels:');
  print('app: ${app.getLevel()}');
  print('database: ${database.getLevel()}');
  print('api: ${api.getLevel()} (inherited)');
  print('');

  // Log messages - notice how logger names appear in context
  app.info('Application started');
  database.warning('Database connection slow');
  api.info('API request received');
  api.debug('Debug info (won\'t show due to inherited level)');

  // Wait for async logging
  await Future.delayed(Duration(milliseconds: 100));

  // Note: In a real application, you would call await app.shutdown();
  // to ensure all logs are flushed and resources are cleaned up.
  // For this example, we skip shutdown.
}
