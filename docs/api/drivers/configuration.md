# Driver Configuration
# Driver Configuration

This page shows configuration patterns using typed configuration classes. JSON is supported but typed configs are preferred for ergonomics and compile-time safety.

## Console Driver

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel('console', ConsoleLogDriver(), formatter: PrettyLogFormatter());
```

### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: const [
    ConsoleChannel(ConsoleOptions(level: 'info'), name: 'console'),
  ],
);
final logger = await Logger.create(typedConfig: config);
```

## Daily File Driver

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel('file', DailyFileLogDriver('logs/app', retentionDays: 7));
```

### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: const [
    DailyFileChannel(
      DailyFileOptions(path: 'logs/app', retentionDays: 7, flushInterval: Duration(seconds: 1)),
      name: 'file',
    ),
  ],
);
final logger = await Logger.create(typedConfig: config);
```

## Webhook Driver

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel('webhook', WebhookLogDriver(Uri.parse('https://hooks.example.com')));
```

### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: const [
    WebhookChannel(
      WebhookOptions(url: Uri.parse('https://hooks.example.com'), headers: {'Authorization': 'Bearer ...'}),
      name: 'webhook',
    ),
  ],
);
final logger = await Logger.create(typedConfig: config);
```

## Stack Driver

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel('stack', StackLogDriver([ConsoleLogDriver(), DailyFileLogDriver('logs/app')]));
```

### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: const [
    StackChannel(
      StackOptions(children: [ConsoleOptions(), DailyFileOptions(path: 'logs/app')]),
      name: 'stack',
    ),
  ],
);
final logger = await Logger.create(typedConfig: config);
```

## Sampling Driver

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel('sample', SamplingLogDriver(rate: 0.2, child: ConsoleLogDriver()));
```

### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: const [
    SamplingChannel(SamplingOptions(rate: 0.2, child: ConsoleOptions()), name: 'sample'),
  ],
);
final logger = await Logger.create(typedConfig: config);
```

## Loading Configuration

- Prefer typed configuration via `TypedLogConfig`.
- Build configs in code or deserialize with your preferred serializer.


This guide details how to configure each driver type in Contextual using the typed configuration API. JSON snippets refer to TypedLogConfig JSON if used with dart_mappable.

## Console Driver

The console driver outputs logs to the terminal with optional color support.

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel(
    'console',
    ConsoleLogDriver(),
    formatter: PrettyLogFormatter(), // Optional: for colored output
  );
```

### JSON Configuration
### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: const [ConsoleChannel(ConsoleOptions(), name: 'console')],
);
final logger = await Logger.create(typedConfig: config);
```


```json
{
  "channels": {
    "console": {
      "driver": "console",
      "env": "all",
      "formatter": "pretty"
    }
  }
}
```

## Daily File Driver

The daily file driver writes logs to rotating daily files with automatic cleanup.

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel(
    'file',
### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: const [DailyFileChannel(DailyFileOptions(path: 'logs/app', retentionDays: 30), name: 'file')],
);
final logger = await Logger.create(typedConfig: config);
```

    DailyFileLogDriver(
      'logs/app.log',
      retentionDays: 30,
      flushInterval: Duration(seconds: 1),
    ),
  );
```

### JSON Configuration

```json
{
  "channels": {
    "file": {
      "driver": "daily",
      "env": "production",
      "config": {
        "path": "logs/app.log",
        "days": 30,
        "flush_interval": 1000
      }
    }
  }
}
```

Configuration options:
- `path`: Path to the log file (required)
- `days`: Number of days to retain log files (default: 14)
### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: [
    WebhookChannel(const WebhookOptions(url: Uri.parse('https://logs.example.com/ingest')), name: 'webhook'),
  ],
);
final logger = await Logger.create(typedConfig: config);
```

- `flush_interval`: Flush interval in milliseconds (default: 500)

## Webhook Driver

The webhook driver sends logs to an HTTP endpoint.

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel(
    'webhook',
    WebhookLogDriver(
      Uri.parse('https://logs.example.com/ingest'),
    ),
  );
```

### JSON Configuration

```json
{
  "channels": {
    "webhook": {
      "driver": "webhook",
      "env": "production",
      "config": {
        "url": "https://logs.example.com/ingest",
        "headers": {
          "Authorization": "Bearer token123"
        }
### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: const [
    ConsoleChannel(ConsoleOptions(), name: 'console'),
    DailyFileChannel(DailyFileOptions(path: 'logs/app'), name: 'file'),
    StackChannel(StackOptions(channels: ['console', 'file'], ignoreExceptions: true), name: 'stack'),
  ],
);
final logger = await Logger.create(typedConfig: config);
```

      }
    }
  }
}
```

Configuration options:
- `url`: Webhook endpoint URL (required)
- `headers`: Optional HTTP headers to include with requests

## Stack Driver

The stack driver combines multiple drivers into one channel.

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel('console', ConsoleLogDriver())
  ..addChannel('file', DailyFileLogDriver('logs/app.log'))
  ..addChannel(
    'stack',
    StackLogDriver(
      [ConsoleLogDriver(), DailyFileLogDriver('logs/app.log')],
      ignoreExceptions: true,
    ),
  );
```

### Typed Configuration

```dart
final config = TypedLogConfig(
  channels: const [
    ConsoleChannel(ConsoleOptions(), name: 'console'),
    SamplingChannel(SamplingOptions(rates: {Level.debug: 0.1, Level.info: 0.5, Level.warning: 1.0}, wrappedChannel: 'console'), name: 'sampled'),
  ],
);
final logger = await Logger.create(typedConfig: config);
```

### JSON Configuration

```json
{
  "channels": {
    "stack": {
      "driver": "stack",
      "env": "production",
      "config": {
        "channels": ["console", "file"],
        "ignore_exceptions": true
      }
    }
  }
}
```

Configuration options:
- `channels`: Array of channel names to stack (required)
- `ignore_exceptions`: Whether to continue if one driver fails (default: false)

## Sampling Driver

The sampling driver allows probabilistic logging based on log levels.

### Programmatic Configuration

```dart
final logger = await Logger.create()
  ..addChannel(
    'sampled',
    SamplingLogDriver(
      ConsoleLogDriver(),
      samplingRates: {
        Level.debug: 0.1,   // Log 10% of debug messages
        Level.info: 0.5,    // Log 50% of info messages
        Level.warning: 1.0, // Log all warning messages
      },
    ),
  );
```

### JSON Configuration

```json
{
  "channels": {
    "sampled": {
      "driver": "sampling",
      "env": "production",
      "config": {
        "sample_rates": {
          "debug": 0.1,
          "info": 0.5,
          "warning": 1.0,
          "error": 1.0,
          "critical": 1.0
        },
        "wrapped_driver": {
          "driver": "console"
        }
      }
    }
  }
}
```

Configuration options:
- `sample_rates`: Map of log levels to sampling probabilities (0.0 - 1.0)
- `wrapped_driver`: Configuration for the driver to sample

## Full Configuration Example
### Typed Configuration (Full)

```dart
final config = TypedLogConfig(
  environment: 'production',
  channels: const [
    ConsoleChannel(ConsoleOptions(), name: 'console'),
    DailyFileChannel(DailyFileOptions(path: 'logs/app', retentionDays: 30), name: 'file'),
    WebhookChannel(WebhookOptions(url: Uri.parse('https://logs.example.com/ingest')), name: 'webhook'),
    StackChannel(StackOptions(channels: ['file', 'webhook'], ignoreExceptions: true), name: 'emergency'),
    SamplingChannel(SamplingOptions(rates: {Level.debug: 0.1, Level.info: 0.5}, wrappedChannel: 'console'), name: 'sampled'),
  ],
);
final logger = await Logger.create(typedConfig: config);
```


Here's a complete example combining multiple drivers:

```json
{
  "defaults": {
    "formatter": "json"
  },
  "channels": {
    "console": {
      "driver": "console",
      "env": "development",
      "formatter": "pretty"
    },
    "file": {
      "driver": "daily",
      "env": "production",
      "config": {
        "path": "logs/app.log",
        "days": 30
      }
    },
    "webhook": {
      "driver": "webhook",
      "env": "production",
      "config": {
        "url": "https://logs.example.com/ingest"
      }
    },
    "emergency": {
      "driver": "stack",
      "env": "production",
      "config": {
        "channels": ["file", "webhook"],
        "ignore_exceptions": true
      }
    },
    "sampled": {
      "driver": "sampling",
      "env": "production",
      "config": {
        "sample_rates": {
          "debug": 0.1,
          "info": 0.5
        },
        "wrapped_driver": {
          "driver": "console"
        }
      }
    }
  }
}
```

## Loading Configuration

Load the configuration in your application:

```dart
final config = LogConfig.fromJson(jsonConfig);
final logger = await Logger.create(config: config);
```

Or from a file:

```dart
final configFile = File('logging.json');
final configJson = jsonDecode(await configFile.readAsString());
final config = LogConfig.fromJson(configJson);
final logger = await Logger.create(config: config);
``` 