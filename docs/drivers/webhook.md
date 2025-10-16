# Webhook Driver

Send logs to remote services over HTTP. The Webhook driver posts structured JSON log entries to an external endpoint (e.g., your logging service, Slack-compatible hooks, or a custom collector).

## Features

- HTTP/HTTPS delivery of structured JSON logs
- Optional custom request headers (e.g., Authorization)
- Configurable request timeout
- Optional keep-alive for connection reuse
- Works with any formatter (Pretty, Plain, JSON)
- Composable with other outputs via the Stack driver
- Plays nicely with middleware enrichment and sampling

---

## When to use Webhook logging

- Centralized logging pipelines (e.g., an internal log collector or SaaS)
- Aggregation across multiple services/instances
- Shipping specific events to external systems (alerts, webhooks, audit trails)

For high-volume, latency-sensitive or offline-prone environments, consider pairing with file-based logging for durability and using sampling.

---

## Basic usage (typed configuration)

Use the typed `WebhookChannel` with `WebhookOptions` for compile-time safety and clarity.

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

- Give the channel a name (e.g., `remote`) so you can target it later.
- The payload posted to your endpoint is a structured JSON representation of the log entry (message, level, timestamp, optional context).

---

## Adding headers (authentication, metadata)

Include custom headers (e.g., Authorization) via `WebhookOptions.headers`.

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

Tip: Keep secrets out of source control. Load tokens from environment variables or a secret manager.

---

## Timeouts and keep-alive

Tune the webhook to your environment:

- `timeout`: The maximum duration for an HTTP request.
- `keepAlive`: Reuse connections to reduce overhead for frequent logging.

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      WebhookChannel(
        WebhookOptions(
          url: Uri.parse('https://logs.example.com/ingest'),
          timeout: const Duration(seconds: 3), // tighter timeout for prod
          keepAlive: true,                      // reuse connections
        ),
        name: 'remote',
      ),
    ],
  ),
);
```

- Shorter timeouts reduce tail latencies but may drop logs if the endpoint is slow.
- Keep-alive improves throughput when sending many logs.

---

## Formatting guidance

Choose a formatter that matches your destination’s expectations:

- PrettyLogFormatter: Human-friendly, colorized (best for local debugging/proxying)
- PlainTextLogFormatter: Minimal overhead text
- JsonLogFormatter: Structured logs for ingestion and indexing (recommended for most webhook targets)

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

Network logging can fail. Build resilience into your pipeline:

- Use a Console channel as a fallback to surface errors locally
- Use a Stack channel to fan-out to multiple destinations
- Consider Sampling for noisy levels to reduce load

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      // Fallback console channel
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

      // Optional: one channel that fans out to both console and remote
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

If your endpoint is intermittently unavailable:
- Keep console/file logging as a fallback
- Alert on repeated webhook failures on the receiver side
- Consider a buffer/queue upstream of your HTTP endpoint

---

## Middleware enrichment

Add contextual fields globally (e.g., env, version, request ID) for better traceability downstream.

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
- For high-volume, consider:
  - Sampling to reduce noise for lower-severity levels
  - Combining with file logging (Daily File driver) for local durability
  - Using a Stack driver to fan-out to multiple destinations
- Monitor the receiver for errors/latency; alert on spikes and failures.
- Treat the webhook endpoint like an external dependency—code defensively.

---

## See also

- API Overview: /api/overview
- Driver Configuration: /api/drivers/configuration.md
- Daily File Driver (guide): /drivers/daily-file.md
- Console Driver (guide): /drivers/console.md
- Middleware (advanced): /advanced/middleware.md
- Batching & Shutdown: /advanced/batching-and-shutdown.md
- Shelf Integration: /advanced/shelf-integration.md