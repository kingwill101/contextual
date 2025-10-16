# Webhook Driver

Send logs to remote services over HTTP. The Webhook driver posts structured JSON log entries to an external endpoint (e.g., your logging service, Slack-compatible hooks, or a custom collector).

## Overview

- HTTP/HTTPS delivery of structured JSON logs
- Optional custom request headers (e.g., Authorization)
- Configurable request timeout
- Optional keep-alive for connection reuse
- Works with any formatter (Pretty, Plain, JSON)
- Composable with other outputs via the Stack driver
- Plays nicely with middleware enrichment and sampling

---

## Options

Configure via `WebhookOptions` (used by the typed `WebhookChannel`):

- url: Uri (required)
  - Destination endpoint for POST requests with JSON payloads.
- headers?: Map<String, String>
  - Custom request headers (e.g., Authorization, X-Service).
- timeout?: Duration
  - Default: 5 seconds
  - Maximum duration for an HTTP request.
- keepAlive?: bool
  - Default: false
  - Enables connection reuse for frequent logging.

Example:

```dart
const options = WebhookOptions(
  url: Uri.parse('https://logs.example.com/ingest'),
  headers: {'Authorization': 'Bearer ${String.fromEnvironment("LOGS_TOKEN")}'},
  timeout: Duration(seconds: 4),
  keepAlive: true,
);
```

---

## Usage

### Typed configuration (recommended)

Use the typed `WebhookChannel` with `WebhookOptions` for compile‑time safety and clarity:

```dart
import 'package:contextual/contextual.dart';

Future<void> main() async {
  final logger = await Logger.create(
    config: LogConfig(
      channels: [
        WebhookChannel(
          WebhookOptions(
            url: Uri.parse('https://logs.example.com/ingest'),
          ),
          name: 'remote',
        ),
      ],
    ),
  );

  logger.info('Hello from Contextual (webhook)!');
}
```

- Name your channel (e.g., `remote`) to target it later.
- The payload is a structured JSON log entry (message, level, timestamp, and any context).

### Targeting the webhook output

- By name:
  ```dart
  logger['remote']?.info('Only goes to the remote webhook');
  ```

- By driver type:
  ```dart
  logger.forDriver<WebhookLogDriver>().warning('All webhook drivers receive this');
  ```

---

## Headers (authentication, metadata)

Include custom headers for authentication or routing:

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      WebhookChannel(
        WebhookOptions(
          url: Uri.parse('https://logs.example.com/ingest'),
          headers: {
            'Authorization': 'Bearer ${String.fromEnvironment("LOGS_TOKEN")}',
            'X-Service': 'payments',
          },
        ),
        name: 'remote',
      ),
    ],
  ),
);

logger.info('Payment processed', Context({
  'order_id': 'ord_123',
  'amount': 1999,
  'currency': 'USD',
}));
```

Tip: Keep secrets out of source control—load tokens from env vars or a secret manager.

---

## Timeouts and keep-alive

Tune for your environment:

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      WebhookChannel(
        WebhookOptions(
          url: Uri.parse('https://logs.example.com/ingest'),
          timeout: const Duration(seconds: 3), // reduce tail latency
          keepAlive: true,                      // reuse connections
        ),
        name: 'remote',
      ),
    ],
  ),
);
```

- Shorter timeouts reduce latency but may drop logs if the endpoint is slow.
- Keep-alive improves throughput for frequent logging.

---

## Formatting

Pick a formatter that matches your destination’s expectations:

- PrettyLogFormatter: Human-friendly, colorized (dev/proxying)
- PlainTextLogFormatter: Minimal overhead text
- JsonLogFormatter: Structured logs for ingestion and indexing (recommended)

Global (logger-wide) formatter:

```dart
final logger = await Logger.create(
  config: LogConfig(
    formatter: JsonLogFormatter(),
    channels: [
      WebhookChannel(
        WebhookOptions(url: Uri.parse('https://logs.example.com/ingest')),
        name: 'remote',
      ),
    ],
  ),
);
```

Per-channel formatter:

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      WebhookChannel(
        WebhookOptions(url: Uri.parse('https://logs.example.com/ingest')),
        name: 'remote',
        formatter: JsonLogFormatter(),
      ),
    ],
  ),
);
```

---

## Error handling and resilience

Network logging can fail—design for resilience:

- Keep a `ConsoleChannel` as a fallback to surface errors locally
- Use a `StackChannel` to fan out to multiple destinations
- Consider `SamplingChannel` for noisy levels to reduce load

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      // Fallback console output
      ConsoleChannel(ConsoleOptions(), name: 'console'),

      // Primary remote logging
      WebhookChannel(
        WebhookOptions(
          url: Uri.parse('https://logs.example.com/ingest'),
          headers: {'Authorization': 'Bearer ${String.fromEnvironment("LOGS_TOKEN")}'},
          timeout: const Duration(seconds: 4),
          keepAlive: true,
        ),
        name: 'remote',
      ),

      // One channel that fans out to both console and remote
      StackChannel(
        StackOptions(
          channels: ['console', 'remote'],
          ignoreExceptions: true, // do not fail the entire stack if remote fails
        ),
        name: 'stack',
      ),
    ],
  ),
);

// Use the stack for important messages that should go both places:
logger['stack']?.error('Critical failure', Context({'order_id': 'ord_777'}));
```

If the endpoint is intermittently unavailable:
- Keep console/file logging as a local fallback
- Alert on repeated webhook failures on the receiver side
- Consider a buffer/queue upstream of your HTTP endpoint

---

## Sampling noisy logs

Reduce volume for lower-severity levels:

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      WebhookChannel(
        WebhookOptions(url: Uri.parse('https://logs.example.com/ingest')),
        name: 'remote',
      ),
      SamplingChannel(
        SamplingOptions(
          // Per-level sampling rates (0.0 to 1.0)
          rates: {
            Level.debug: 0.1, // keep 10% of debug logs
            Level.info: 1.0,   // keep all info logs
          },
          wrappedChannel: 'remote', // wrap the named webhook channel
        ),
        name: 'remote_sampled',
      ),
    ],
  ),
);

// Route specific logs to the sampled channel:
logger['remote_sampled']?.debug('This debug log may be sampled');
```

---

## Middleware enrichment

Add contextual fields globally (env, version, request ID) for better traceability downstream:

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      WebhookChannel(
        WebhookOptions(url: Uri.parse('https://logs.example.com/ingest')),
        name: 'remote',
      ),
    ],
    middlewares: [
      () => {
        'env': const String.fromEnvironment('APP_ENV', defaultValue: 'development'),
        'version': '2.0.0',
        'ts': DateTime.now().toIso8601String(),
      },
    ],
  ),
);

logger.info('Service started');
```

---

## Best practices

- Use HTTPS for all remote logging; never send sensitive data over HTTP.
- Authenticate with per-service tokens. Rotate regularly.
- Prefer `JsonLogFormatter` for machine-ingestible payloads.
- Set reasonable `timeout` values based on environment and endpoint SLAs.
- Enable `keepAlive` for high-throughput services to reduce connection overhead.
- Avoid logging secrets or PII. Redact sensitive fields at the source or via middleware.
- For high volume:
  - Sample noisy levels
  - Combine with file logging (Daily File driver) for durability
  - Use a Stack driver to fan-out to multiple destinations
- Monitor the receiver for errors/latency; alert on spikes and failures.
- Treat the webhook endpoint like an external dependency—code defensively.

---

## See also

- [API Overview](/api/overview)
- [Driver Configuration](configuration.md)
- [Console Driver](console.md)
- [Daily File Driver](daily-file.md)
- [Middleware (advanced)](../../advanced/middleware.md)
- [Batching & Shutdown](../../advanced/batching-and-shutdown.md)