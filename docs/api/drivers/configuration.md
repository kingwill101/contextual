# Driver Configuration

This guide details how to configure each driver type in Contextual using the typed configuration API. Typed configurations provide compile-time safety and autocompletion.

## Console Driver

The console driver outputs logs to the terminal with optional color support.

```dart
final config = LogConfig(
  channels: const [
    ConsoleChannel(ConsoleOptions(), name: 'console'),
  ],
);
final logger = await Logger.create(config: config);
```

## Daily File Driver

The daily file driver writes logs to rotating daily files with automatic cleanup.

```dart
final config = LogConfig(
  channels: const [
    DailyFileChannel(
      DailyFileOptions(
        path: 'logs/app',
        retentionDays: 30,
        flushInterval: Duration(seconds: 1),
      ),
      name: 'file',
    ),
  ],
);
final logger = await Logger.create(config: config);
```

Configuration options:
- `path`: Base path for log files (required)
- `retentionDays`: Number of days to retain log files (default: 14)
- `flushInterval`: Flush interval in milliseconds (default: 500)

## Webhook Driver

The webhook driver sends logs to an HTTP endpoint.

```dart
final config = LogConfig(
  channels: const [
    WebhookChannel(
      WebhookOptions(
        url: Uri.parse('https://logs.example.com/ingest'),
        headers: {'Authorization': 'Bearer token123'},
        timeout: Duration(seconds: 5),
        keepAlive: true,
      ),
      name: 'webhook',
    ),
  ],
);
final logger = await Logger.create(config: config);
```

Configuration options:
- `url`: Webhook endpoint URL (required)
- `headers`: Optional HTTP headers to include with requests
- `timeout`: Request timeout (default: 5 seconds)
- `keepAlive`: Whether to keep connections alive (default: true)

## Stack Driver

The stack driver combines multiple drivers into one channel.

```dart
final config = LogConfig(
  channels: const [
    ConsoleChannel(ConsoleOptions(), name: 'console'),
    DailyFileChannel(DailyFileOptions(path: 'logs/app'), name: 'file'),
    StackChannel(
      StackOptions(
        channels: ['console', 'file'],
        ignoreExceptions: true,
      ),
      name: 'stack',
    ),
  ],
);
final logger = await Logger.create(config: config);
```

Configuration options:
- `channels`: List of channel names to stack (required)
- `ignoreExceptions`: Whether to continue if one driver fails (default: false)

## Sampling Driver

The sampling driver allows probabilistic logging based on log levels.

```dart
final config = LogConfig(
  channels: const [
    ConsoleChannel(ConsoleOptions(), name: 'console'),
    SamplingChannel(
      SamplingOptions(
        rates: {
          Level.debug: 0.1,   // Log 10% of debug messages
          Level.info: 0.5,    // Log 50% of info messages
          Level.warning: 1.0, // Log all warning messages
        },
        wrapped: ConsoleChannel(ConsoleOptions(), name: 'wrapped_console'),
      ),
      name: 'sampled',
    ),
  ],
);
final logger = await Logger.create(config: config);
```

Configuration options:
- `rates`: Map of log levels to sampling probabilities (0.0 - 1.0)
- `wrapped`: The channel to sample

## Full Configuration Example

```dart
final config = LogConfig(
  environment: 'production',
  level: 'info',
  formatter: JsonLogFormatter(),
  batching: BatchingConfig(
    enabled: true,
    batchSize: 50,
    flushInterval: Duration(seconds: 1),
  ),
  channels: const [
    ConsoleChannel(ConsoleOptions(), name: 'console'),
    DailyFileChannel(
      DailyFileOptions(path: 'logs/app', retentionDays: 30),
      name: 'file',
    ),
    WebhookChannel(
      WebhookOptions(url: Uri.parse('https://logs.example.com/ingest')),
      name: 'webhook',
    ),
    StackChannel(
      StackOptions(channels: ['file', 'webhook'], ignoreExceptions: true),
      name: 'emergency',
    ),
    SamplingChannel(
      SamplingOptions(
        rates: {Level.debug: 0.1, Level.info: 0.5},
        wrapped: ConsoleChannel(ConsoleOptions(), name: 'wrapped_console'),
      ),
      name: 'sampled',
    ),
  ],
);
final logger = await Logger.create(config: config);
```

## Loading Configuration

Typed configurations can be built in code or deserialized from JSON using `dart_mappable`:

```dart
// From JSON
final configJson = jsonDecode(jsonString);
final config = LogConfigMapper.fromJson(configJson);
final logger = await Logger.create(config: config);

// From file
final configFile = File('logging.json');
final configJson = jsonDecode(await configFile.readAsString());
final config = LogConfigMapper.fromJson(configJson);
final logger = await Logger.create(config: config);
```