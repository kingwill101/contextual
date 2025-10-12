# Daily File Driver

The `DailyFileLogDriver` is a powerful logging driver that writes log messages to daily rotating log files. It automatically manages file rotation, cleanup of old files, and provides optimized writing capabilities.

## Features

- Daily log file rotation
- Automatic cleanup of old log files
- Configurable retention period
- Creates log directories if they don't exist
- Message queuing with periodic batch writes
- Automatic file cleanup
- Optional isolate-optimized mode for high-performance logging

## Basic Usage

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

// Logs will be written to files like:
// - logs/app-2024-02-15.log
// - logs/app-2024-02-14.log
// etc.
```

## Configuration Options

### Standard Implementation

```dart
final driver = DailyFileLogDriver(
  'logs/app',
  retentionDays: 30, // Default: 14 days
  flushInterval: Duration(seconds: 1), // Default: 500ms
);
```

### Isolate-Optimized Implementation

```dart
final driver = DailyFileLogDriver.withIsolateOptimization(
  'logs/app',
  retentionDays: 30,
  flushInterval: Duration(seconds: 1),
);
```

## Parameters

- `baseFilePath`: Base path for log files (required)
  - Example: `'logs/app'` will create files like `logs/app-2024-02-15.log`
  - Directories will be created automatically if they don't exist

- `retentionDays`: Number of days to keep log files (optional)
  - Default: 14 days
  - Files older than this will be automatically deleted
  - Set to 0 to disable cleanup

- `flushInterval`: How often to flush queued messages (optional)
  - Default: 500 milliseconds
  - Affects batching behavior and write performance
  - Lower values mean more frequent writes but higher I/O
  - Higher values mean better performance but more memory usage

## File Management

### File Rotation

Files are automatically rotated at midnight (local time). The driver:
1. Detects day boundary crossings
2. Closes the current file
3. Opens a new file with the new date
4. Continues logging to the new file

```dart
// At 23:59:59 writing to: logs/app-2024-02-14.log
logger.info('Last message of the day');

// At 00:00:00 automatically switches to: logs/app-2024-02-15.log
logger.info('First message of the new day');
```

### File Cleanup

Old log files are automatically cleaned up based on the `retentionDays` setting:

```dart
// These files exist:
// logs/app-2024-02-15.log (today)
// logs/app-2024-02-14.log (1 day old)
// logs/app-2024-02-01.log (14 days old)
// logs/app-2024-01-15.log (30 days old)

final driver = DailyFileLogDriver(
  'logs/app',
  retentionDays: 14, // Keep files for 14 days
);

// After cleanup:
// logs/app-2024-02-15.log (kept)
// logs/app-2024-02-14.log (kept)
// logs/app-2024-02-01.log (kept)
// logs/app-2024-01-15.log (deleted - too old)
```

## Performance Optimization

### Standard vs Isolate-Optimized

The driver comes in two variants:

1. **Standard Implementation** (`DailyFileLogDriver`)
   - Uses direct file writes
   - Good for most use cases
   - Simpler implementation
   - Example:
     ```dart
     final driver = DailyFileLogDriver('logs/app');
     ```

2. **Isolate-Optimized** (`DailyFileLogDriver.withIsolateOptimization`)
   - Uses `IOSink` for buffered writing
   - Better performance for high-volume logging
   - More efficient memory usage
   - Example:
     ```dart
     final driver = DailyFileLogDriver.withIsolateOptimization('logs/app');
     ```

### Message Batching

Both implementations use message batching through the `LogQueue`:

```dart
final driver = DailyFileLogDriver(
  'logs/app',
  flushInterval: Duration(milliseconds: 100), // More frequent writes
);

// vs

final driver = DailyFileLogDriver(
  'logs/app',
  flushInterval: Duration(seconds: 2), // More batching, fewer writes
);
```

## Error Handling

The driver handles various error conditions gracefully:

- Directory creation failures
- File permission issues
- Disk space problems
- File system errors

Example with error handling:

```dart
final logger = await Logger.create()
  ..addChannel(
    'file',
    DailyFileLogDriver('logs/app'),
  )
  ..addChannel(
    'console',
    ConsoleLogDriver(), // Fallback for logging errors
  );

try {
  // Your application code
} catch (e) {
  logger.error('Failed to write to log file', Context({
    'error': e.toString(),
  }));
}
```

## Resource Cleanup

Always properly shut down the logger to ensure all messages are written and resources are cleaned up:

```dart
final logger = await Logger.create()
  ..addChannel('file', DailyFileLogDriver('logs/app'));

// ... use logger ...

// Before application exit:
await logger.shutdown();
```

## Best Practices

1. **Use Appropriate Flush Intervals**
   ```dart
   // Development: More frequent flushes for immediate feedback
   final devDriver = DailyFileLogDriver(
     'logs/app',
     flushInterval: Duration(milliseconds: 100),
   );

   // Production: Longer intervals for better performance
   final prodDriver = DailyFileLogDriver(
     'logs/app',
     flushInterval: Duration(seconds: 2),
   );
   ```

2. **Set Reasonable Retention Periods**
   ```dart
   // High-volume logs: Shorter retention
   final highVolumeDriver = DailyFileLogDriver(
     'logs/audit',
     retentionDays: 7,
   );

   // Important logs: Longer retention
   final auditDriver = DailyFileLogDriver(
     'logs/audit',
     retentionDays: 90,
   );
   ```

3. **Use with Other Drivers**
   ```dart
   final logger = await Logger.create()
     ..addChannel(
       'file',
       DailyFileLogDriver('logs/app'),
     )
     ..addChannel(
       'console',
       ConsoleLogDriver(),
     )
     ..addChannel(
       'webhook',
       WebhookLogDriver(Uri.parse('https://logs.example.com')),
     );
   ```

4. **Monitor Disk Usage**
   ```dart
   logger.addMiddleware(() {
     final logDir = Directory('logs');
     final usage = logDir.statSync().size;
     if (usage > 1024 * 1024 * 1024) { // 1GB
       print('Warning: High log directory usage');
     }
     return {};
   });
   ```

## Next Steps

- [Driver Configuration](configuration)
- [Middleware Guide](../../advanced/middleware) 