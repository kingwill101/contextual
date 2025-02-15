import 'dart:convert';

import 'package:contextual/contextual.dart';

/// Middleware that blocks sensitive logs containing passwords
class BlockSensitiveLogsMiddleware implements DriverMiddleware {
  @override
  DriverMiddlewareResult handle(String driverName, LogEntry entry) {
    if (entry.message.contains('password')) {
      print('[Middleware] Sensitive log detected. Blocking log.');
      return DriverMiddlewareResult.stop();
    }
    return DriverMiddlewareResult.proceed();
  }
}

/// Middleware that adds a specific tag for driver-targeted messages
class AddTagMiddleware implements DriverMiddleware {
  final String tag;

  AddTagMiddleware(this.tag);

  @override
  DriverMiddlewareResult handle(String driverName, LogEntry entry) {
    final modifiedMessage = '${entry.message} [$tag for $driverName]';

    // Create a new LogEntry with the modified message
    final modifiedEntry = entry.copyWith(message: modifiedMessage);

    return DriverMiddlewareResult.modify(modifiedEntry);
  }
}

/// Middleware to dynamically enrich logs with user information
class AddUserMiddleware implements DriverMiddleware {
  final String username;

  AddUserMiddleware(this.username);

  @override
  DriverMiddlewareResult handle(String driverName, LogEntry entry) {
    return DriverMiddlewareResult.modify(
        entry.copyWith(message: '${entry.message} | User: $username'));
  }
}

/// Formatter for structured data (JSON-style)
class StructuredMapFormatter extends LogTypeFormatter<Map<String, dynamic>> {
  @override
  String format(Level level, Map<String, dynamic> message, Context context) {
    final logData = {
      'level': level.toUpperCase(),
      'data': message,
      'context': context.all(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(logData);
  }
}

/// Formatter for exceptions
class ExceptionLogFormatter extends LogTypeFormatter<Exception> {
  @override
  String format(Level level, Exception exception, Context context) {
    return '[${level.toUpperCase()}] Exception: ${exception.toString()} at ${DateTime.now()} | Context: ${context.all()}';
  }
}

void main() async {
  // Configuration for multiple logging channels
  final logConfig = LogConfig(
    defaults: {'env': 'production'},
    channels: {
      'console': ChannelConfig(driver: 'console'),
      'file': ChannelConfig(
        driver: 'daily',
        config: {
          'path': 'logs/app.log',
          'days': 7,
        },
      ),
      'webhook': ChannelConfig(
        driver: 'webhook',
        config: {
          'webhookUrl':
              'https://webhook-test.com/b61f3ee766b6354bb67881df60708333',
          'username': 'LoggerBot',
          'emoji': ':robot:',
        },
      ),
    },
  );

  // Initialize LogManager with fluent configuration
  final logManager = Logger()
      .config(logConfig)
      .environment('production')
      .formatter(PrettyLogFormatter()) // JSON format for logs
      .addMiddleware(() =>
          {'app': 'MyApp', 'version': '1.2.0'}) // Global context middleware
      .addLogMiddleware(
          BlockSensitiveLogsMiddleware()) // Global sensitive log blocker
      .addLogMiddleware(AddUserMiddleware('john_doe')) // Enrich logs with user
      .addDriverMiddleware('console',
          AddTagMiddleware('DEBUG-CONSOLE')) // Add console-specific tags
      .addTypeFormatter<Map<String, dynamic>>(
          StructuredMapFormatter()) // JSON structure formatter
      .addTypeFormatter<Exception>(
          ExceptionLogFormatter()); // Exception formatter

  // Example 1: Logging simple messages
  logManager.info('Application started successfully.');
  // logManager.error('An unexpected error occurred during execution.');

  // // Example 2: Structured data logging
  logManager.info({
    'event': 'login',
    'user': 'john_doe',
    'status': 'success',
  });

  // Example 3: Logging an exception
  try {
    throw Exception('Database connection failed');
  } catch (e) {
    logManager.error(e);
  }

  // Example 4: Logging to specific channels (console and file)
  logManager
      .to(['console', 'file']).critical('Critical system failure detected!');

  // Example 5: Dynamic on-demand channel configuration
  final customChannel = logManager.buildChannel({
    'driver': 'daily',
    'path': 'logs/custom.log',
    'days': 5,
  });

  logManager.addChannel('custom', customChannel);
  logManager.to(['custom']).warning('Custom log channel warning.');

  // Example 6: Adding shared context and logging
  logManager
      .withContext({'requestId': 'abcd1234', 'operation': 'user-update'}).info(
          'User details updated successfully.');

  // Example 7: Logging stack configuration (console + webhook)
  logManager.to(['console', 'webhook']).alert('System is under heavy load.');

  // Shutdown to flush logs
  await logManager.shutdown();
  print("something");
}
