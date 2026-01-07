import 'package:contextual/contextual.dart';

/// This example demonstrates named loggers with hierarchical levels and context.
/// Named loggers allow you to create logger hierarchies similar to the standard
/// logging package, with automatic inheritance of configuration and logger names
/// included in log contexts.
void main() async {
  // Create a root logger with a base level
  final root = Logger.root;
  root.setLevel(Level.info);
  root.addChannel('console', ConsoleLogDriver());

  // Create named loggers with specific levels
  final app = Logger(name: 'app', level: Level.debug);
  final database = Logger(name: 'app.database', level: Level.warning);
  final api = Logger(name: 'app.api'); // Inherits level from app

  // Add channels at different levels
  app.addChannel('file', DailyFileLogDriver('logs/app.log'));
  database.addChannel('db-errors', DailyFileLogDriver('logs/db-errors.log'));

  print('=== Logger Hierarchy ===');
  print('Root level: ${root.getLevel()}');
  print('App level: ${app.getLevel()}');
  print('Database level: ${database.getLevel()}');
  print('API level: ${api.getLevel()} (inherited from app)');
  print('');

  print('=== Logging with Context ===');

  // Root logger - name appears as 'root' in context
  root.info('Application starting');
  // Context will include: {logger: 'root', ...}

  // App logger - name appears as 'app' in context
  app.debug('Initializing application components');
  app.info('Application initialized successfully');
  // Context will include: {logger: 'app', ...}

  // Database logger - name appears as 'app.database' in context
  database.warning('Database connection pool low');
  database.error(
    'Failed to execute query',
    Context({'query': 'SELECT * FROM users', 'error': 'timeout'}),
  );
  // Context will include: {logger: 'app.database', 'query': '...', 'error': '...'}

  // API logger - inherits level from app, name appears as 'app.api'
  api.info('API server listening on port 8080');
  api.debug('Received request: GET /users'); // Won't log due to inherited level
  // Context will include: {logger: 'app.api', ...}

  print('');
  print('=== Inheritance Demonstration ===');

  // Create a deep hierarchy
  final cache = Logger(name: 'app.database.cache');
  final redis = Logger(name: 'app.database.cache.redis', level: Level.info);

  print('Cache logger level: ${cache.getLevel()} (inherited from database)');
  print('Redis logger level: ${redis.getLevel()} (explicitly set)');

  cache.warning('Cache miss rate high');
  redis.info('Redis connection established');
  redis.debug('Redis ping successful');

  print('');
  print('=== Context Inspection ===');
  print(
    'Notice how logger names appear in the context of each log message above.',
  );
  print(
    'The console output shows: [LEVEL] message | Context: {logger: name, ...}',
  );
  print('');

  // Generate some final logs to demonstrate context inclusion
  root.info('System health check');
  app.info('User authentication successful');
  database.warning('Slow query detected');
  api.info('API request processed');

  // Wait for async logging to complete
  await Future.delayed(Duration(milliseconds: 200));

  print('');
  print('=== Example Complete ===');
  print(
    'Logger names are automatically included in log contexts for traceability.',
  );
  // Note: In a real application, you would call await logger.shutdown();
  // to ensure all logs are flushed and resources are cleaned up.
}
