[![pub package](https://img.shields.io/pub/v/contextual.svg)](https://pub.dev/packages/contextual)
[![Build Status](https://github.com/kingwill101/contextual/workflows/dart/badge.svg)](https://github.com/kingwill101/contextual/actions)




# Contextual

A structured logging library for Dart

![Screenshot](screenshot.png)


## Features
- 🪵 **Multiple Log Levels** - From debug to emergency following RFC 5424
- 🎨 **Flexible Formatting** - JSON, plain text, and colored output
- 📊 **Rich Context Support** - Add structured data to your logs
- 🔄 **Middleware** - Transform and filter log messages
- 📤 **Multiple Outputs** - Console, files, webhooks, and more
- 🎯 **Type-specific Formatting** - Custom formatting for your data types
- ⚡ **Async & Batching** - Efficient log processing



## Installation

Add `contextual` to your `pubspec.yaml`:

```yaml
dependencies:
  contextual: ^1.0.0
```


## Quick Start

```dart
import 'package:contextual/contextual.dart';

void main() {
  // Create a logger
  final logger = Logger()
    ..withContext({'app': 'MyApp'});

  // Basic logging
  logger.info('Application started');
  logger.debug('Configuration loaded');
  logger.error('Something went wrong');

  // Logging with context
  logger.warning(
    'Database connection failed',
    Context({
      'host': 'localhost',
      'port': 5432,
      'attempts': 3
    })
  );
}
``` 

See the [example](example) folder for detailed examples.

### Configuration

Load configuration from JSON:

```dart
final config = LogConfig.fromJson({
  'channels': {
    'console': {
      'driver': 'console',
      'env': 'development'
    },
    'file': {
      'driver': 'daily',
      'path': 'logs/app.log',
      'days': 7,
      'env': 'production'
    },
    'slack': {
      'driver': 'webhook',
      'webhookUrl': 'https://hooks.slack.com/...',
      'username': 'Logger',
      'emoji': ':warning:',
      'env': 'production'
    }
  },
  'defaults': {
    'formatter': 'json'
  }
});

final logger = Logger(config: config);
```

If no configuration is provided, a default configuration will be used. The default configuration logs using the `console` driver and formats logs using the `plain` formatter.

### Logging Patterns

Contextual supports two patterns for handling log output:

#### 1. Sink-based Pattern (Default)

The default pattern uses drivers and middleware for flexible output handling:


The logger uses a sink to handle asynchronous logging with options for batching and automatic flushing. You can configure the sink using the `LogSinkConfig` class:

```dart
final logger = Logger(
  sinkConfig: LogSinkConfig(
    batchSize: 50,  // Number of logs to batch before flushing
    flushInterval: Duration(seconds: 5),  // Time interval for automatic flushing
    maxRetries: 3,  // Number of retry attempts for failed log operations
    autoFlush: true  // Enable or disable automatic flushing
  )
);


```
Note to ensure all logs are delivered before shutting down the logger. You can use the `shutdown()` method: 

```dart
await logger.shutdown();
```


#### 2. Listener Pattern

For simpler use cases, you can use a listener similar to the logging package:

```dart
final logger = Logger();

// Set up a simple listener
logger.setListener((level, message, time) {
  print('[$time] $level: $message');
});

// All logs now go to the listener
logger.info('This goes to the listener');
```

The listener pattern is simpler but doesn't support:
- Multiple output destinations
- Driver-specific middleware
- Asynchronous batching

Choose the pattern that best fits your needs:
- Use the sink pattern for production systems needing multiple outputs
- Use the listener pattern for simple logging during development

### Log Levels

Supports standard RFC 5424 severity levels:

```dart
logger.emergency('System is unusable');
logger.alert('Action must be taken immediately');
logger.critical('Critical conditions');
logger.error('Error conditions');
logger.warning('Warning conditions');
logger.notice('Normal but significant condition');
logger.info('Informational messages');
logger.debug('Debug-level messages');
```


### Formatters

Choose from built-in formatters or create your own:

```dart
// Pretty printed with colors (great for development)
logger.formatter(PrettyLogFormatter());

// JSON output (great for production)
logger.formatter(JsonLogFormatter());

// Plain text
logger.formatter(PlainTextLogFormatter());

// without any formatting
logger.formatter(RawLogFormatter());

// Custom formatter
class MyFormatter extends LogMessageFormatter {
  @override
  String format(String level, String message, Context context) {
    // Your custom formatting logic
  }
}
```

### Type-specific Formatting

Create custom formatters for your data types:

```dart
class User {
  final String name;
  final String email;

  User(this.name, this.email);
}

class UserFormatter extends LogTypeFormatter<User> {
  @override
  String format(String level, User user, Context context) {
    return '{"name": "${user.name}", "email": "${user.email}"}';
  }
}

// Register the formatter
logger.addTypeFormatter(UserFormatter());

// Now User objects will be formatted automatically
final user = User('John Doe', 'john@example.com');
logger.info(user);
```

### Output Destinations

Configure multiple output destinations:

```dart
logger
  // Console output
  .addDriver('console', ConsoleLogDriver())

  // Daily rotating file
  .addDriver('file', DailyFileLogDriver(
    'logs/app.log',
    retentionDays: 7
  ))

  // Webhook (e.g., Slack)
  .addDriver('slack', WebhookLogDriver(
    Uri.parse('https://hooks.slack.com/...'),
    username: 'Logger Bot',
    emoji: ':robot:'
  ));

// Log to specific destinations
logger.to(['console', 'file']).info('This goes to console and file');
```

### Context

Add structured data to your logs:

```dart
// Global context for all logs
logger.withContext({
  'environment': 'production',
  'version': '1.0.0'
});

// Per-log context
logger.info(
  'User logged in',
  Context({
    'userId': '123',
    'ipAddress': '192.168.1.1'
  })
);
```


### Middleware

Transform or filter logs:
```dart
// Add sensitive data filter
logger.addLogMiddleware(SensitiveDataMiddleware());

// Add request ID to all logs
logger.addMiddleware(() => {
  'requestId': generateRequestId()
});

// Driver-specific middleware
logger.addDriverMiddleware(
  'slack',
  ErrorOnlyMiddleware()
);
```

## Advanced Usage

### Batch Processing

Configure batching behavior:

```dart
final logger = Logger(
  sinkConfig: LogSinkConfig(
    batchSize: 50,  // Flush after 50 logs
    flushInterval: Duration(seconds: 5),  // Or every 5 seconds
    maxRetries: 3,  // Retry failed operations
    autoFlush: true  // Enable automatic flushing
  )
);
```

### Custom Drivers

Implement your own log destinations:

```dart
class CustomLogDriver implements LogDriver {
  @override
  Future<void> log(String formattedMessage) async {
    // Your custom logging logic
  }
}
```

## Channels

Channels are named logging destinations that can be configured independently. Each channel represents a different way to handle log messages:

```dart
// Configure multiple channels
final logger = Logger(
  config: LogConfig.fromJson({
    'channels': {
      // Console output for development
      'console': {
        'driver': 'console',
        'env': 'development'
      },
      // Daily rotating file for production logs
      'daily': {
        'driver': 'daily',
        'path': 'logs/app.log',
        'days': 7,
        'env': 'production'
      },
      // Emergency channel that combines multiple drivers
      'emergency': {
        'driver': 'stack',
        'channels': ['slack', 'daily'],
        'env': 'all'
      },
      // Slack notifications for critical issues
      'slack': {
        'driver': 'webhook',
        'webhookUrl': 'https://hooks.slack.com/...',
        'username': 'Emergency Bot',
        'emoji': ':rotating_light:',
        'env': 'production'
      }
    }
  })
);

// Log to specific channels
logger.to(['console', 'daily']).info('Regular log message');
logger.to(['emergency']).critical('Critical system failure!');

// Default behavior logs to all channels for the current environment
logger.error('This goes to all active channels');
```

### Environment-based Channel Selection

Channels can be configured to only be active in specific environments:

```dart
final logger = Logger(environment: 'production')
  ..addDriver('console', ConsoleLogDriver()) // No env specified, always active
  ..addDriver('daily', DailyFileLogDriver('logs/app.log')) // Production only
  ..addDriver('debug', ConsoleLogDriver()); // Development only

// In production: logs to 'console' and 'daily'
// In development: logs to 'console' and 'debug'

```

### Stack Channels

Stack channels allow you to create a single channel that forwards logs to multiple other channels. This is useful when you want to send the same logs to multiple destinations with different formatting and filtering:

```dart
final config = LogConfig.fromJson({
  'channels': {
    // Individual channels
    'file': {
      'driver': 'daily',
      'path': 'logs/app.log'
    },
    'slack': {
      'driver': 'webhook',
      'webhookUrl': 'https://hooks.slack.com/...'
    },

    // Stack channel that combines both
    'production': {
      'driver': 'stack',
      'channels': ['file', 'slack'], // Will forward to both channels
      'ignore_exceptions': true
    }
  }
});

// Now you can log to both channels with one call
logger.to(['production']).error('Critical failure');

// Add different formatting for each destination
logger.addDriverMiddleware('file', new JsonFormatter());
logger.addDriverMiddleware('slack', new PrettyFormatter());
```

Stack channels are particularly useful for:
- Sending critical logs to multiple destinations
- Applying different formatting per destination
- Creating backup logging channels
- Setting up monitoring and notification systems

Each channel in a stack maintains its own middleware chain, allowing for independent processing of logs for each destination.

## Understanding Middleware

Contextual uses a two-stage middleware system to provide flexible log processing:

### Context Middleware

Context middleware runs first and can add/modify the context data before any formatting happens:

```dart
// Add request ID and timestamp to all logs
logger.addMiddleware(() => {
  'requestId': generateRequestId(),
  'timestamp': DateTime.now().toIso8601String()
});

// Add dynamic user info when available
logger.addMiddleware(() {
  if (currentUser != null) {
    return {'userId': currentUser.id};
  }
  return {};
});

// Now these fields are automatically added
logger.info('User action'); // Includes requestId, timestamp, and userId
```

### Driver Middleware

Driver middleware processes log entries before they reach specific log drivers. Each driver in a channel can have its own middleware chain:

```dart
// Filter sensitive data from all logs
class SensitiveDataMiddleware implements DriverMiddleware {
  @override
  DriverMiddlewareResult handle(String driverName, MapEntry<String, String> entry) {
    // driverName indicates which driver is receiving the log entry
    var message = entry.value;
    message = message.replaceAll(RegExp(r'password=[\w\d]+'), 'password=***');
    return DriverMiddlewareResult.modify(MapEntry(entry.key, message));
  }
}

// Only allow errors to reach certain drivers
class ErrorOnlyMiddleware implements DriverMiddleware {
  @override
  DriverMiddlewareResult handle(String driverName, MapEntry<String, String> entry) {
    final errorLevels = ['emergency', 'alert', 'critical', 'error'];
    if (!errorLevels.contains(entry.key.toLowerCase())) {
      return DriverMiddlewareResult.stop();
    }
    return DriverMiddlewareResult.proceed();
  }
}

// Add middlewares
logger
  // Global middleware applied to all drivers
  .addLogMiddleware(SensitiveDataMiddleware())
  // Driver-specific middleware only applied to webhook driver
  .addDriverMiddleware('webhook', ErrorOnlyMiddleware());

// Middleware execution flow:
// 1. Context middleware runs first
// 2. Log is formatted
// 3. Global driver middlewares process the log
// 4. Driver-specific middlewares process the log
// 5. Log is sent to the driver

```

## Asynchronous Logging and Shutdown

The logger uses asynchronous processing and batching to improve performance. This means you must properly shut down the logger to ensure all logs are delivered:

When using asynchronous drivers (like WebhookLogDriver) or batch processing, it's important to properly shut down the logger to ensure all logs are delivered:

```dart
void main() async {
  final logger = Logger(
    sinkConfig: LogSinkConfig(
      batchSize: 50, // Buffer up to 50 logs
      flushInterval: Duration(seconds: 5) // Or flush every 5 seconds
    )
  );

  try {
    // Your application code
    logger.info('Application starting');
    await runApp();
    logger.info('Application shutting down');
  } finally {
    // Ensure all logs are delivered before exiting
    await logger.shutdown();
  }
}

// In a web application
class MyApp {
  final Logger logger;

  Future<void> stop() async {
    logger.notice('Stopping application');
    await stopServices();
    await logger.shutdown();
  }
}
```

The `shutdown()` method:
- Flushes any buffered log messages
- Waits for all async log operations to complete
- Ensures webhook requests are sent
- Closes file handles and other resources

Always call `shutdown()` before your application exits to prevent log message loss.


## Contributing

Contributions are welcome!  Just open an issue or pull request on GitHub.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.