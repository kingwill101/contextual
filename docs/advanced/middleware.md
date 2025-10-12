# Middleware
# Middleware

Middleware allows transforming or filtering log entries before they reach a driver.

## Global vs Driver Middleware

- Global middleware runs for every log entry and every driver.
- Driver middleware runs only for a specific driver type.

```dart
// Global
logger.addMiddleware(AddTimestamp());

// Driver-specific
logger.addDriverMiddleware<ConsoleLogDriver>(SensitiveDataFilter());
```

## Writing Driver Middleware

```dart
class SensitiveDataFilter implements DriverMiddleware {
  @override
  DriverMiddlewareResult handle(LogEntry entry) {
    final masked = entry.copyWith(message: _mask(entry.message));
    return DriverMiddlewareResult.modify(masked);
  }
}
```

## Ordering

- Global middleware executes first (in order of addition).
- Driver middleware executes after global middleware (in order of addition).

## Error Handling

If a middleware throws, the error is caught and logged as an internal warning, and processing continues unless a driver chooses to halt.

## Tips

- Prefer type-based registration: `addDriverMiddleware<ConsoleLogDriver>(...)`.
- Keep middleware side-effect free where possible.
- Use `DriverMiddlewareResult.stop()` to halt processing for a specific entry.


Middleware in Contextual provides a powerful way to transform, enrich, or filter log entries before they are processed by drivers. There are several types of middleware that can be used at different stages of the logging pipeline.

## Types of Middleware

### Context Middleware

Context middleware allows you to add or modify context data for all log entries:

```dart
logger.addMiddleware(() => {
  'timestamp': DateTime.now().toIso8601String(),
  'hostname': Platform.hostname,
  'process_id': Platform.pid,
});
```

### Driver Middleware

Driver middleware can transform or filter log entries before they reach specific drivers:

```dart
class SensitiveDataFilter implements DriverMiddleware {
  @override
  Future<LogEntry?> process(LogEntry entry) async {
    // Filter out sensitive data from the message
    var filtered = entry.message.replaceAll(
      RegExp(r'\b\d{4}-\d{4}-\d{4}-\d{4}\b'),
      '[REDACTED]'
    );
    
    return LogEntry(
      entry.record,
      filtered,
    );
  }
}

logger.addLogMiddleware(SensitiveDataFilter());
```

### Channel-Specific Middleware

Middleware can be applied to specific channels:

```dart
logger.addChannel(
  'webhook',
  WebhookLogDriver(Uri.parse('https://logs.example.com')),
  middlewares: [
    RateLimitMiddleware(maxRequestsPerMinute: 60),
    RetryMiddleware(maxRetries: 3),
  ],
);
```

## Common Use Cases

### Request Tracking

Add request IDs to all logs within a web application:

```dart
class RequestTracker implements DriverMiddleware {
  final _requestIds = AsyncLocal<String>();
  
  void setRequestId(String id) {
    _requestIds.value = id;
  }
  
  @override
  Future<LogEntry?> process(LogEntry entry) async {
    if (_requestIds.value == null) return entry;
    
    final newContext = Context({
      ...entry.record.context.all(),
      'request_id': _requestIds.value,
    });
    
    return LogEntry(
      LogRecord(
        time: entry.record.time,
        level: entry.record.level,
        message: entry.record.message,
        context: newContext,
        stackTrace: entry.record.stackTrace,
      ),
      entry.formattedMessage,
    );
  }
}

final requestTracker = RequestTracker();
logger.addLogMiddleware(requestTracker);

// In your request handler:
app.use((Request request, Response response) {
  requestTracker.setRequestId(generateRequestId());
  // ... handle request
});
```

### Error Enhancement

Add stack traces and additional context to error logs:

```dart
class ErrorEnhancer implements DriverMiddleware {
  @override
  Future<LogEntry?> process(LogEntry entry) async {
    if (entry.record.level < Level.error) return entry;
    
    final enhanced = Context({
      ...entry.record.context.all(),
      'stack_trace': entry.record.stackTrace.toString(),
      'error_time': DateTime.now().toIso8601String(),
    });
    
    return LogEntry(
      LogRecord(
        time: entry.record.time,
        level: entry.record.level,
        message: entry.record.message,
        context: enhanced,
        stackTrace: entry.record.stackTrace,
      ),
      entry.formattedMessage,
    );
  }
}

logger.addLogMiddleware(ErrorEnhancer());
```

### Log Sampling

Implement probabilistic logging for high-volume environments:

```dart
class SamplingMiddleware implements DriverMiddleware {
  final double sampleRate;
  final Random _random = Random();
  
  SamplingMiddleware({this.sampleRate = 0.1}); // 10% sample rate
  
  @override
  Future<LogEntry?> process(LogEntry entry) async {
    // Always log errors and above
    if (entry.record.level >= Level.error) return entry;
    
    // Sample other logs based on rate
    return _random.nextDouble() < sampleRate ? entry : null;
  }
}

logger.addLogMiddleware(SamplingMiddleware(
  sampleRate: 0.01, // 1% sample rate
));
```

### Performance Monitoring

Track and log slow operations:

```dart
class PerformanceMonitor implements DriverMiddleware {
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
  Future<LogEntry?> process(LogEntry entry) async {
    // Pass through all logs, this middleware only generates new ones
    return entry;
  }
}

final perfMonitor = PerformanceMonitor(
  threshold: Duration(milliseconds: 200),
);
logger.addLogMiddleware(perfMonitor);

// Usage:
perfMonitor.startOperation('db-query-1');
await database.query(...);
perfMonitor.endOperation('db-query-1');
```

### Environment-Based Filtering

Filter logs based on the environment:

```dart
class EnvironmentFilter implements DriverMiddleware {
  final String environment;
  final Set<Level> allowedLevels;
  
  EnvironmentFilter({
    required this.environment,
    required this.allowedLevels,
  });
  
  @override
  Future<LogEntry?> process(LogEntry entry) async {
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

logger.addLogMiddleware(EnvironmentFilter(
  environment: 'production',
  allowedLevels: {
    Level.warning,
    Level.error,
    Level.critical,
    Level.alert,
    Level.emergency,
  },
));
```

## Best Practices

1. **Order Matters**
   ```dart
   // Correct order: sensitive data is filtered before being sent to external service
   logger.addLogMiddleware(SensitiveDataFilter());
   logger.addLogMiddleware(ExternalServiceMiddleware());
   
   // Incorrect order: sensitive data might be sent before being filtered
   logger.addLogMiddleware(ExternalServiceMiddleware());
   logger.addLogMiddleware(SensitiveDataFilter());
   ```

2. **Keep Middleware Focused**
   ```dart
   // Good: Single responsibility
   logger.addLogMiddleware(SensitiveDataFilter());
   logger.addLogMiddleware(PerformanceMonitor());
   
   // Bad: Too many responsibilities
   logger.addLogMiddleware(CombinedMiddleware()); // Does filtering, monitoring, etc.
   ```

3. **Handle Errors Gracefully**
   ```dart
   class SafeMiddleware implements DriverMiddleware {
     @override
     Future<LogEntry?> process(LogEntry entry) async {
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
   class AsyncMiddleware implements DriverMiddleware {
     @override
     Future<LogEntry?> process(LogEntry entry) async {
       // Avoid long-running operations that could block logging
       final result = await someQuickOperation();
       return entry;
     }
   }
   ```

## Next Steps

- [Driver Configuration](../api/drivers/configuration)
- [API Overview](../api/overview)
- [Getting Started](../getting-started) 