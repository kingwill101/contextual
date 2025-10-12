# Daily File Driver

The `DailyFileLogDriver` writes log entries to daily rotating files. It provides automatic file rotation and cleanup based on retention policies.

## Features

- Daily log file rotation
- Configurable retention period
- Automatic cleanup of old log files
- Optional isolate-based processing for improved performance
- Configurable flush intervals

## Usage

```dart
import 'package:contextual/contextual.dart';

void main() async {
  final logger = await Logger.create()
    ..addChannel('file', DailyFileLogDriver(
      'logs/app.log',
      retentionDays: 14,
      flushInterval: Duration(milliseconds: 500),
    ));

  // Your logging code here

  // Important: Always shutdown the logger when done
  await logger.shutdown();
}
```

## Resource Management

### Proper Shutdown

The daily file driver manages file handles and (when using isolate optimization) background processes. To ensure proper cleanup and prevent resource leaks, **always call `shutdown()` on your logger** when your application is terminating:

```dart
void main() async {
  final logger = await Logger.create()
    ..addChannel('file', DailyFileLogDriver('logs/app.log'));

  try {
    // Your application code
  } finally {
    // Ensures all pending logs are written and resources are cleaned up
    await logger.shutdown();
  }
}
```

Failing to shut down properly may result in:
- Lost log messages that haven't been flushed to disk
- Unclosed file handles
- Lingering isolates (if using isolate optimization)

### Configuration Options

The daily file driver supports several configuration options:

```dart
DailyFileLogDriver(
  'logs/app.log',
  retentionDays: 14,              // Number of days to keep log files
  flushInterval: Duration(milliseconds: 500),  // How often to flush to disk
  useIsolate: false,              // Whether to use isolate optimization
)
```

Or use typed options:

```dart
final driver = DailyFileLogDriver.fromOptions(
  const DailyFileOptions(path: 'logs/app', retentionDays: 14),
);
``` 