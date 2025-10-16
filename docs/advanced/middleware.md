# Middleware

Middleware allows transforming or filtering log entries before they reach a driver.

## Single Middleware Pipeline

Contextual v2 uses a single middleware pipeline applied once per log entry, with a well-defined order: global → channel → driver-type.

This ensures consistent processing and avoids duplication.

## Global Middleware

Global middleware runs for every log entry across all channels.

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
    middlewares: [
      () => {'timestamp': DateTime.now().toIso8601String()},
    ],
  ),
);
```

## Channel Middleware

Channel middleware applies to specific channels.

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      ConsoleChannel(
        ConsoleOptions(),
        name: 'console',
        middlewares: [SensitiveDataFilter()],
      ),
    ],
  ),
);
```

## Driver-Type Middleware

Driver-type middleware applies to all channels of a specific driver type.

```dart
logger.addDriverMiddleware<ConsoleLogDriver>(RateLimitMiddleware());
```

## Writing Middleware

Implement [Middleware] for global or channel middleware, or [DriverMiddleware] for driver-specific.

```dart
class SensitiveDataFilter implements Middleware {
  @override
  LogEntry handle(LogEntry entry) {
    final masked = entry.copyWith(message: _mask(entry.message));
    return masked;
  }
}
```

## Ordering

Middleware executes in this order:
1. Global middleware (in order of addition)
2. Channel middleware (in order of addition)
3. Driver-type middleware (in order of addition)

## Error Handling

If middleware throws, the error is logged internally, and processing continues.

## Tips

- Prefer type-based registration for driver middleware.
- Keep middleware side-effect free.
- Use [MiddlewareResult.stop] to halt processing.

Middleware in Contextual provides a powerful way to transform, enrich, or filter log entries before they are processed by drivers. There are several types of middleware that can be used at different stages of the logging pipeline.

## Types of Middleware

### Context Middleware

Context middleware allows you to add or modify context data for all log entries:

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
    middlewares: [
      () => {
        'timestamp': DateTime.now().toIso8601String(),
        'hostname': Platform.hostname,
        'process_id': Platform.pid,
      },
    ],
  ),
);
```

### Driver Middleware

Driver middleware can transform or filter log entries before they reach specific drivers:

```dart
class SensitiveDataFilter implements DriverMiddleware {
  @override
  FutureOr<DriverMiddlewareResult> handle(LogEntry entry) {
    final filtered = entry.message.replaceAll(
      RegExp(r'\b\d{4}-\d{4}-\d{4}-\d{4}\b'),
      '[REDACTED]'
    );

    return DriverMiddlewareResult.modify(entry.copyWith(message: filtered));
  }
}

logger.addDriverMiddleware<ConsoleLogDriver>(SensitiveDataFilter());
```

### Channel-Specific Middleware

Middleware can be applied to specific channels:

```dart
final logger = await Logger.create(
  config: LogConfig(
    channels: [
      WebhookChannel(
        WebhookOptions(url: Uri.parse('https://logs.example.com')),
        name: 'webhook',
        middlewares: [
          RateLimitMiddleware(maxRequestsPerMinute: 60),
          RetryMiddleware(maxRetries: 3),
        ],
      ),
    ],
  ),
);
```

## Common Use Cases

### Request Tracking

Add request IDs to all logs within a web application:

```dart
class RequestTracker implements Middleware {
  final _requestIds = AsyncLocal<String>();

  void setRequestId(String id) {
    _requestIds.value = id;
  }

  @override
  LogEntry handle(LogEntry entry) {
    if (_requestIds.value == null) return entry;

    final newContext = Context({
      ...entry.record.context.all(),
      'request_id': _requestIds.value,
    });

    return entry.copyWith(context: newContext);
  }
}

final requestTracker = RequestTracker();

final logger = await Logger.create(
  config: LogConfig(
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
    middlewares: [requestTracker],
  ),
);

// In your request handler:
app.use((Request request, Response response) {
  requestTracker.setRequestId(generateRequestId());
  // ... handle request
});
```

### Error Enhancement

Add stack traces and additional context to error logs:

```dart
class ErrorEnhancer implements Middleware {
  @override
  LogEntry handle(LogEntry entry) {
    if (entry.record.level < Level.error) return entry;

    final enhanced = Context({
      ...entry.record.context.all(),
      'stack_trace': entry.record.stackTrace.toString(),
      'error_time': DateTime.now().toIso8601String(),
    });

    return entry.copyWith(context: enhanced);
  }
}

final logger = await Logger.create(
  config: LogConfig(
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
    middlewares: [ErrorEnhancer()],
  ),
);
```

### Log Sampling

Implement probabilistic logging for high-volume environments:

```dart
class SamplingMiddleware implements Middleware {
  final double sampleRate;
  final Random _random = Random();

  SamplingMiddleware({this.sampleRate = 0.1}); // 10% sample rate

  @override
  LogEntry? handle(LogEntry entry) {
    // Always log errors and above
    if (entry.record.level >= Level.error) return entry;

    // Sample other logs based on rate
    return _random.nextDouble() < sampleRate ? entry : null;
  }
}

final logger = await Logger.create(
  config: LogConfig(
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
    middlewares: [SamplingMiddleware(sampleRate: 0.01)],
  ),
);
```

### Performance Monitoring

Track and log slow operations:

```dart
class PerformanceMonitor implements Middleware {
  final Duration threshold;
  final _operationStarts = <String, DateTime>{};

  PerformanceMonitor({
    this.threshold = const Duration(milliseconds: 100),
  });

  void startOperation(String operationId) {
    _operationStarts[operationId] = DateTime.now();
  }

  void endOperation(String operationId) {
    final start = _operationStarts.remove(operationId);
    if (start == null) return;

    final duration = DateTime.now().difference(start);
    if (duration > threshold) {
      logger.warning('Slow operation detected', Context({
        'operation_id': operationId,
        'duration_ms': duration.inMilliseconds,
        'threshold_ms': threshold.inMilliseconds,
      }));
    }
  }

  @override
  LogEntry handle(LogEntry entry) {
    // Pass through all logs, this middleware only generates new ones
    return entry;
  }
}

final perfMonitor = PerformanceMonitor(
  threshold: const Duration(milliseconds: 200),
);

final logger = await Logger.create(
  config: LogConfig(
    channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
    middlewares: [perfMonitor],
  ),
);

// Usage:
perfMonitor.startOperation('db-query-1');
await database.query(...);
perfMonitor.endOperation('db-query-1');
```

### Environment-Based Filtering

Filter logs based on the environment:

```dart
class EnvironmentFilter implements Middleware {
  final String environment;
  final Set<Level> allowedLevels;

  EnvironmentFilter({
    required this.environment,
    required this.allowedLevels,
  });

  @override
  LogEntry? handle(LogEntry entry) {
    switch (environment) {
      case 'production':
        return allowedLevels.contains(entry.record.level) ? entry : null;
      case 'development':
        return entry; // Log everything in development
      default:
        return entry;
    }
  }
}

final logger = await Logger.create(
  config: LogConfig(
    channels: [
      ConsoleChannel(ConsoleOptions(), name: 'console'),
    ],
    middlewares: [
      EnvironmentFilter(
        environment: 'production',
        allowedLevels: {
          Level.warning,
          Level.error,
          Level.critical,
          Level.alert,
          Level.emergency,
        },
      ),
    ],
  ),
);
```

## Best Practices

1. **Order Matters**
   ```dart
   // Correct order: sensitive data is filtered before being sent to external service
   final logger = await Logger.create(
     config: LogConfig(
       channels: [WebhookChannel(WebhookOptions(url: Uri.parse('...')), name: 'webhook')],
       middlewares: [SensitiveDataFilter(), ExternalServiceMiddleware()],
     ),
   );

   // Incorrect order: sensitive data might be sent before being filtered
   final logger = await Logger.create(
     config: LogConfig(
       channels: [WebhookChannel(WebhookOptions(url: Uri.parse('...')), name: 'webhook')],
       middlewares: [ExternalServiceMiddleware(), SensitiveDataFilter()],
     ),
   );
   ```

2. **Keep Middleware Focused**
   ```dart
   // Good: Single responsibility
   final logger = await Logger.create(
     config: LogConfig(
       channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
       middlewares: [SensitiveDataFilter(), PerformanceMonitor()],
     ),
   );

   // Bad: Too many responsibilities
   final logger = await Logger.create(
     config: LogConfig(
       channels: [ConsoleChannel(ConsoleOptions(), name: 'console')],
       middlewares: [CombinedMiddleware()], // Does filtering, monitoring, etc.
     ),
   );
   ```

3. **Handle Errors Gracefully**
   ```dart
   class SafeMiddleware implements Middleware {
     @override
     LogEntry handle(LogEntry entry) {
       try {
         // Your middleware logic
         return entry;
       } catch (e) {
         // Log the error but don't block the entry
         print('Middleware error: $e');
         return entry;
       }
     }
   }
   ```

4. **Use Async Operations Carefully**
   ```dart
   class AsyncMiddleware implements Middleware {
     @override
     LogEntry handle(LogEntry entry) async {
       // Avoid long-running operations that could block logging
       final result = await someQuickOperation();
       return entry;
     }
   }
   ```

## Next Steps

- [Driver Configuration](../api/drivers/configuration.md)
- [API Overview](../api/overview)
- [Getting Started](../getting-started.md)