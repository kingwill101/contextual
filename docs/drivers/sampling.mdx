# Sampling Driver

Reduce log volume without losing signal. The Sampling driver probabilistically drops logs based on per-level rates and forwards retained logs to another destination. It’s ideal for high‑volume services where debug/info logs can overwhelm storage or network bandwidth.

## Overview

- Wraps another channel/driver and decides whether to forward each log
- Per‑level sampling rates (0.0–1.0) to control volume for each severity
- Works with all other drivers (Console, Daily File, Webhook) and Stack
- Configurable via typed channels or the imperative API

---

## How it works

The driver inspects a log entry’s level and applies a sampling rate for that level:
- A rate of 1.0 keeps 100% of logs at that level.
- A rate of 0.5 keeps ~50%.
- A rate of 0.0 drops all logs at that level.

Retained logs are forwarded to the wrapped channel/driver; dropped logs are discarded.

Tip: Explicitly define rates for the levels you want to control. For critical levels, prefer explicit 1.0.

---

## Typed configuration (recommended)

Use the typed `SamplingChannel` with `SamplingOptions`. The `wrappedChannel` references the name of another channel in your config.

### Wrap a single destination (console)

```dart
import 'package:contextual/contextual.dart';

Future<void> main() async {
  final logger = await Logger.create(
    config: LogConfig(
      channels: const [
        // Destination to receive kept logs
        ConsoleChannel(
          ConsoleOptions(),
          name: 'console',
        ),

        // Sampled wrapper: routes to the 'console' channel
        SamplingChannel(
          SamplingOptions(
            rates: {
              Level.debug: 0.1, // keep ~10% of debug logs
              Level.info: 1.0,   // keep all info logs
              // add other levels as needed
            },
            wrappedChannel: 'console',
          ),
          name: 'console_sampled',
        ),
      ],
    ),
  );

  // Send noisy logs through the sampled channel:
  logger['console_sampled']?.debug('noisy diagnostic event');
  logger['console_sampled']?.info('operational event');
}
```

### Sample a Stack (fan‑out with volume control)

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: const [
      ConsoleChannel(ConsoleOptions(), name: 'console'),
      DailyFileChannel(DailyFileOptions(path: 'logs/app'), name: 'file'),

      // Fan-out to both console and file
      StackChannel(
        StackOptions(
          channels: ['console', 'file'],
          ignoreExceptions: true,
        ),
        name: 'stack',
      ),

      // Add a sampled variant of the stack
      SamplingChannel(
        SamplingOptions(
          rates: {
            Level.debug: 0.05, // keep ~5% of debug logs
            Level.info: 0.5,   // keep ~50% of info logs
            Level.warning: 1.0,
            Level.error: 1.0,
            Level.critical: 1.0,
          },
          wrappedChannel: 'stack',
        ),
        name: 'stack_sampled',
      ),
    ],
  ),
);

// Route high-volume logs via the sampled stack:
logger['stack_sampled']?.debug('debug burst event');
```

### Multiple sampled variants

Create different sampling profiles for different use cases:

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: const [
      ConsoleChannel(ConsoleOptions(), name: 'console'),

      // Lossy (aggressive) for very noisy telemetry
      SamplingChannel(
        SamplingOptions(
          rates: { Level.debug: 0.01, Level.info: 0.25 },
          wrappedChannel: 'console',
        ),
        name: 'console_lossy',
      ),

      // Lossless for anything important
      SamplingChannel(
        SamplingOptions(
          rates: { Level.debug: 1.0, Level.info: 1.0 },
          wrappedChannel: 'console',
        ),
        name: 'console_lossless',
      ),
    ],
  ),
);
```

---

## Imperative wiring (raw drivers)

You can also compose the driver programmatically.

```dart
final logger = await Logger.create();

// Destination to wrap
logger.addChannel('console', ConsoleLogDriver());

// Build a sampler that wraps the console driver
final wrapped = logger.getChannel('console')!.driver;

final sampler = SamplingLogDriver(
  wrappedDriver: wrapped,
  samplingRates: {
    Level.debug: 0.1,
    Level.info: 1.0,
  },
);

logger.addChannel('console_sampled', sampler);

// Use the sampled channel
logger['console_sampled']?.debug('noisy event');
```

---

## Environment‑driven rates

Adjust rates per environment without code changes:

```dart
double _rate(String key, double fallback) {
  // Pseudocode – read from env/flags/config service
  final v = const String.fromEnvironment(key, defaultValue: '');
  return double.tryParse(v) ?? fallback;
}

final logger = await Logger.create(
  config: LogConfig(
    channels: [
      ConsoleChannel(ConsoleOptions(), name: 'console'),
      SamplingChannel(
        SamplingOptions(
          rates: {
            Level.debug: _rate('SAMPLE_DEBUG', 0.05),
            Level.info: _rate('SAMPLE_INFO', 1.0),
          },
          wrappedChannel: 'console',
        ),
        name: 'console_sampled',
      ),
    ],
  ),
);
```

---

## Patterns and tips

- Wrap the destination you would otherwise log to directly (e.g., `console`, `file`, or a `stack` channel).
- Route noisy categories through a sampled variant by name (e.g., `logger['stack_sampled']?.debug(...)`).
- For critical paths, target the original unsampled channel (e.g., `logger['stack']?.error(...)`).

---

## Best practices

- Never sample error/critical levels unless you fully accept data loss for those events.
- Be explicit: define sampling rates for all levels you care about. Treat anything not explicitly defined as unsampled in your design and tests.
- Sample at the edge of noise: wrap only the channels or code paths producing high-volume logs.
- Prefer sampling on less important levels (debug, info). Keep warnings and above at 1.0.
- For audit/compliance logs, do not sample. Send to durable storage (e.g., Daily File) and ensure proper shutdown.
- Validate end‑to‑end: measure ingestion/storage before and after to confirm the reduction and no loss of essential signals.
- In tests, set all rates to 1.0 for deterministic assertions.

---

## See also

- API Overview: /api/overview
- Driver Configuration: /api/drivers/configuration.md
- Console Driver: /drivers/console.md
- Daily File Driver: /drivers/daily-file.md
- Webhook Driver: /drivers/webhook.md
- Stack Driver: /drivers/stack.md
- Batching & Shutdown: /advanced/batching-and-shutdown.md