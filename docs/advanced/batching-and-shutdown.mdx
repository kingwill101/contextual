# Batching and Shutdown

Contextual provides optional batching to improve throughput for high-volume logging without forcing consumers to call shutdown() in typical applications.

## Defaults

- Batching is opt-in via `LogConfig.batching`. By default, drivers log synchronously.
- When batching is enabled, logs are queued to a central sink and flushed on a fixed interval and/or batch size.
- The sink automatically drains on process exit; explicit shutdown() is recommended for CLI/short-lived tasks.

## Enabling Batching

Configure batching through `LogConfig`:

```dart
final logger = await Logger.create(
  config: LogConfig(
    batching: BatchingConfig(
      enabled: true,
      batchSize: 50,
      flushInterval: const Duration(milliseconds: 500),
    ),
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
  ),
);
```

Disable batching by omitting or setting `enabled: false`:

```dart
final logger = await Logger.create(
  config: LogConfig(
    batching: BatchingConfig(enabled: false),
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
  ),
);
```

## Shutdown Guidance

- Long-running servers (Shelf, Flutter, etc.): shutdown() is optional; use it when you perform coordinated shutdown for other resources.
- Short-lived scripts/CLIs: call await logger.shutdown() to ensure buffers are flushed.

```dart
await logger.info('Finishing up...');
await logger.shutdown();
```

## Driver Lifecycle

Drivers may allocate resources (e.g. file handles, HTTP clients). Logger.shutdown() notifies drivers to close resources, then waits for completion before closing the sink.

## Batching Best Practices

- Default is unbatched for simplicity.
- Enable batching in high-throughput apps via `LogConfig.batching`; it generally does not require explicit shutdown in typical server apps.
- For short-lived CLIs or when using file drivers, call `await logger.shutdown()` to guarantee flush.

## Example: Batched Logging with Type-Targeting

```dart
final logger = await Logger.create(
  config: LogConfig(
    batching: BatchingConfig(
      enabled: true,
      batchSize: 100,
      flushInterval: const Duration(milliseconds: 500),
    ),
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
  ),
);

logger.forDriver<ConsoleLogDriver>().info('Fast batched logging');
```
