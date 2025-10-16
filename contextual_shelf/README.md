[![pub package](https://img.shields.io/pub/v/contextual_shelf.svg?label=contextual_shelf)](https://pub.dev/packages/contextual_shelf)
[![Dart](https://img.shields.io/badge/dart-%3E%3D3.6.0-blue.svg)](https://dart.dev/)
[![License](https://img.shields.io/badge/license-MIT-purple.svg)](LICENSE)
[![Build Status](https://github.com/kingwill101/contextual/workflows/Dart/badge.svg)](https://github.com/kingwill101/contextual/actions)
[![Buy Me A Coffee](https://img.shields.io/badge/Buy%20Me%20A%20Coffee-support-yellow.svg)](https://www.buymeacoffee.com/kingwill101)

If this package helps you, consider supporting development: https://www.buymeacoffee.com/kingwill101

# Contextual Shelf

A powerful logging middleware for [Shelf](https://pub.dev/packages/shelf) applications that provides structured, configurable logging through integration with the [contextual](https://pub.dev/packages/contextual) logging package.

## Features

- 📝 **Structured Logging**: Multiple output channels with different formatters
- ⏱️ **Performance Monitoring**: Request/response timing and memory usage tracking
- 🔒 **Security**: Sensitive data sanitization and header filtering
- 🎯 **Configurable**: Custom request filtering and log profiles
- 🎨 **Multiple Formats**: Support for JSON, pretty-printed, and plain text output
- 🔄 **Error Handling**: Comprehensive error tracking and reporting

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  contextual_shelf: ^1.0.0
```

## Usage

### Basic Setup

```dart
import 'package:contextual/contextual.dart';
import 'package:contextual_shelf/contextual_shelf.dart';
import 'package:shelf/shelf.dart' as shelf;

void main() async {
  // Create a logger with console and file output
  final logger = Logger()
    ..addChannel(
      'console',
      ConsoleLogDriver(),
      formatter: PrettyLogFormatter(),
    )
    ..addChannel(
      'file',
      DailyFileLogDriver('logs/server.log'),
      formatter: JsonLogFormatter(),
    );

  // Set up the logging middleware
  final logWriter = DefaultLogWriter(
    logger,
    sanitizer: Sanitizer(mask: '[REDACTED]'),
  );
  final logProfile = LogNonGetRequests();
  final httpLogger = HttpLogger(logProfile, logWriter);

  // Add the middleware to your Shelf pipeline
  final handler = const shelf.Pipeline()
    .addMiddleware(httpLogger.middleware)
    .addHandler(myHandler);

  await shelf.serve(handler, 'localhost', 8080);
}
```

### Custom Request Filtering

Create a custom log profile to control which requests are logged:

```dart
class ApiLogProfile implements LogProfile {
  @override
  bool shouldLogRequest(shelf.Request request) {
    return request.method != 'GET' || request.url.path.startsWith('api/');
  }
}
```

### Sensitive Data Handling

Configure the sanitizer to mask sensitive information:

```dart
final logWriter = DefaultLogWriter(
  logger,
  sanitizer: Sanitizer(
    mask: '[REDACTED]',
  ),
);
```

### Log Output Examples

#### Pretty-Printed Console Output
```
[2024-02-15 10:30:45.123] [INFO] POST /api/users [200] 45ms
[2024-02-15 10:30:46.456] [ERROR] GET /api/data [500] 123ms | Error: Database connection failed
```

#### JSON File Output
```json
{
  "timestamp": "2024-02-15T10:30:45.123Z",
  "level": "INFO",
  "method": "POST",
  "path": "/api/users",
  "status": 200,
  "duration_ms": 45,
  "headers": {
    "content-type": "application/json",
    "authorization": "[REDACTED]"
  }
}
```

## Advanced Usage

### Multiple Output Channels

Configure different formatters for different outputs:

```dart
final logger = Logger()
  ..addChannel(

### Selecting Channels and Middlewares

Contextual v2 favors type-based and name-based selection without arrays:

```dart
// Name-based
logger['console'].info('Console');

// Type-based
logger.forDriver<ConsoleLogDriver>().info('Console by type');

// Typed driver middleware registration
logger.addDriverMiddleware<ConsoleLogDriver>(MyMiddleware());
```

    'console',
    ConsoleLogDriver(),
    formatter: PrettyLogFormatter(),
  )
  ..addChannel(
    'file',
    DailyFileLogDriver('logs/app.log'),
    formatter: JsonLogFormatter(),
  )
  ..addChannel(
    'metrics',
    WebhookLogDriver(Uri.parse('https://metrics.example.com')),
    formatter: PlainTextLogFormatter(),
  );
```

### Error Handling

The middleware automatically catches and logs errors:

```dart
Future<shelf.Response> handler(shelf.Request request) async {
  try {
    // Your handler code
  } catch (e, stack) {
    // Error will be logged with full context
    return shelf.Response.internalServerError();
  }
}
```

### Performance Monitoring

Each log entry includes:
- Request duration
- Memory usage
- Process ID
- Timestamp

## API Reference

### Key Components

- `HttpLogger`: Main middleware class for Shelf integration
- `LogWriter`: Interface for writing log entries
- `LogProfile`: Interface for request filtering
- `Sanitizer`: Utility for cleaning sensitive data
- `DefaultLogWriter`: Standard implementation of LogWriter

### Built-in Log Profiles

- `LogNonGetRequests`: Logs all non-GET requests
- `ApiLogProfile`: Example profile for API request logging

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 