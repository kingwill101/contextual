---
title: Getting Started
---

# Getting Started

Contextual is a powerful, flexible logging system for Dart that provides rich features for structured logging, multiple output channels, and extensive customization options.

## Installation

Add Contextual to your project by adding it to your `pubspec.yaml`:

```yaml
dependencies:
  contextual: ^latest_version
```

Or install it using the Dart package manager:

```bash
dart pub add contextual
```

## Basic Usage

Here's a simple example to get you started:

```dart
import 'package:contextual/contextual.dart';

void main() async {
  // Create a logger with console output
  final logger = await Logger.create(
  typedConfig: const TypedLogConfig(
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
  ),
)..addChannel('console', ConsoleLogDriver());

  // Log some messages
  logger.info('Hello from Contextual!');
  logger.warning('This is a warning message');
  logger.error('Something went wrong', Context({
    'error_code': 500,
    'request_id': 'abc123'
  }));

  // Important: If using file drivers, ensure proper shutdown
  await logger.shutdown();
}
```

## Important: Proper Shutdown

When using file-based drivers (like `DailyFileLogDriver`), it's crucial to properly shut down the logger before your application exits. This ensures all pending logs are written and resources are cleaned up:

```dart
final logger = await Logger.create(
  typedConfig: const TypedLogConfig(
    channels: [DailyFileChannel(DailyFileOptions(path: 'logs/app'))],
  ),
);

try {
  // Your application code
} finally {
  // Always shutdown the logger when using file drivers
  await logger.shutdown();
}

### Typed Configuration

You can also configure Contextual using typed configuration objects, which give you compile-time safety and autocompletion:

```dart
final config = TypedLogConfig(
  level: 'debug',
  environment: 'development',
  channels: const [
    ConsoleChannel(ConsoleOptions(), name: 'console'),
    DailyFileChannel(DailyFileOptions(path: 'logs/app', retentionDays: 7), name: 'file'),
  ],
);

final logger = await Logger.create(typedConfig: config);
```

}
```

Note: Console-only logging setups don't require explicit shutdown, but it's still good practice to include it.

## Features

### Multiple Output Channels

Contextual supports multiple output channels, allowing you to send logs to different destinations:

```dart
final logger = await Logger.create()
  ..addChannel('console', ConsoleLogDriver())
  ..addChannel('file', DailyFileLogDriver('logs/app.log'))
  ..addChannel('webhook', WebhookLogDriver(Uri.parse('https://your-webhook.com')));
```

### Daily Rotating File Logs

The `DailyFileLogDriver` automatically rotates log files daily and manages retention:

```dart
final logger = await Logger.create()
  ..addChannel(
    'file',
    DailyFileLogDriver(
      'logs/app',
      retentionDays: 30,
      flushInterval: Duration(seconds: 1),
    ),
  );
```

### Rich Context

Add context to your logs for better debugging and tracing:

```dart
logger.withContext({
  'environment': 'production',
  'version': '1.0.0',
})..info('Application started');

// Add request-specific context
logger.info(
  'Processing request',
  Context({
    'request_id': 'req123',
    'user_id': 'user456',
    'path': '/api/users'
  })
);
```

### Working with Channels

At runtime, channels are represented by a Channel<T extends LogDriver> wrapper that contains the name, driver, optional formatter, and per-channel middlewares.

- Name-based selection:
```dart
logger['console'].info('Only to console');
```
- Type-based selection:
```dart
logger.forDriver<ConsoleLogDriver>().info('All console drivers');
```
- Utilities:
```dart
logger.hasChannel('file');
final ch = logger.getChannel('file');
logger.removeChannel('webhook');
```
- Override a channel with a new formatter using copyWith:
```dart
final file = logger.getChannel('file');
if (file != null) {
  logger
    ..removeChannel('file')
    ..addChannel('file', file.driver, formatter: PrettyLogFormatter());
}
```


### Log Formatting

Customize how your logs are formatted:

```dart
final logger = await Logger.create(
  formatter: JsonLogFormatter(), // or PrettyLogFormatter(), PlainTextLogFormatter()
)..addChannel('console', ConsoleLogDriver());
```

### Log Levels

Contextual supports multiple log levels:

```dart
logger.debug('Debug message');
logger.info('Info message');
logger.notice('Notice message');
logger.warning('Warning message');
logger.error('Error message');
logger.critical('Critical message');
logger.alert('Alert message');
logger.emergency('Emergency message');
```

### Middleware Support

Add middleware to transform or filter logs:

```dart
logger.addMiddleware(() => {
  'timestamp': DateTime.now().toIso8601String(),
  'hostname': Platform.hostname,
});
```

## Next Steps

- Check out the [API Reference](api/overview) for detailed documentation
- Learn about [Advanced Features](advanced/middleware)
- See [Drivers](api/drivers/configuration) for configuration examples
