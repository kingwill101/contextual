import 'dart:io';
import 'package:contextual/contextual.dart';

/// Middleware that adds request tracking information
class RequestTrackerMiddleware implements DriverMiddleware {
  @override
  DriverMiddlewareResult handle(String driverName, LogEntry entry) {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final modifiedEntry = entry.copyWith(
      message: '[Request: $requestId] ${entry.message}',
    );
    return DriverMiddlewareResult.modify(modifiedEntry);
  }
}

/// Middleware that filters out sensitive data
class SensitiveDataFilterMiddleware implements DriverMiddleware {
  final List<String> sensitiveKeys;
  final String maskValue;

  SensitiveDataFilterMiddleware({
    this.sensitiveKeys = const ['password', 'credit_card', 'ssn'],
    this.maskValue = '********',
  });

  @override
  DriverMiddlewareResult handle(String driverName, LogEntry entry) {
    // Get context data
    final contextData = entry.record.context.all();

    // Check if any sensitive keys are present
    bool hasSensitiveData = sensitiveKeys.any((key) =>
        entry.message.toLowerCase().contains(key) ||
        contextData.keys.any((k) => k.toLowerCase().contains(key)));

    if (hasSensitiveData) {
      // Create a new context with masked sensitive data
      final maskedContext = Map<String, dynamic>.from(contextData);
      for (final key in maskedContext.keys) {
        if (sensitiveKeys.any((sk) => key.toLowerCase().contains(sk))) {
          maskedContext[key] = maskValue;
        }
      }

      // Create a new message with masked sensitive data
      var maskedMessage = entry.message;
      for (final key in sensitiveKeys) {
        final regex = RegExp(r'$key\s*[:=]?\s*\S+', caseSensitive: false);
        maskedMessage = maskedMessage.replaceAll(regex, '$key: $maskValue');
      }

      // Create a new log entry with masked data
      final maskedEntry = entry.copyWith(
        message: maskedMessage,
        record: entry.record.clone()..context.addAll(maskedContext),
      );

      return DriverMiddlewareResult.modify(maskedEntry);
    }

    return DriverMiddlewareResult.proceed();
  }
}

/// Middleware that adds performance metrics
class PerformanceMiddleware implements DriverMiddleware {
  final Stopwatch _stopwatch = Stopwatch()..start();
  final Map<String, int> _operationCounts = {};
  final Duration samplingInterval;

  PerformanceMiddleware({
    this.samplingInterval = const Duration(seconds: 60),
  });

  @override
  DriverMiddlewareResult handle(String driverName, LogEntry entry) {
    // Update operation counts
    final operation = entry.record.context.all()['operation'] as String?;
    if (operation != null) {
      _operationCounts[operation] = (_operationCounts[operation] ?? 0) + 1;
    }

    // Add performance metrics periodically
    if (_stopwatch.elapsed >= samplingInterval) {
      final metrics = {
        'elapsed_time': _stopwatch.elapsed.inMilliseconds,
        'operations': Map<String, int>.from(_operationCounts),
        'memory': ProcessInfo.currentRss,
        'cpu_usage': _getCpuUsage(),
      };

      // Reset counters
      _stopwatch.reset();
      _operationCounts.clear();
      _stopwatch.start();

      // Create a new entry with metrics
      final metricsEntry = entry.copyWith(
        message: '${entry.message} | Performance Metrics: $metrics',
      );

      return DriverMiddlewareResult.modify(metricsEntry);
    }

    return DriverMiddlewareResult.proceed();
  }

  double _getCpuUsage() {
    try {
      // This is a simplified example. In a real implementation,
      // you would calculate actual CPU usage.
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}

/// Middleware that handles error reporting
class ErrorReportingMiddleware implements DriverMiddleware {
  final Uri? errorReportingEndpoint;
  final Set<Level> reportLevels;

  ErrorReportingMiddleware({
    this.errorReportingEndpoint,
    this.reportLevels = const {Level.error, Level.critical, Level.emergency},
  });

  @override
  DriverMiddlewareResult handle(String driverName, LogEntry entry) {
    if (reportLevels.contains(entry.record.level)) {
      // In a real implementation, you would send the error report
      // to your error reporting service
      _sendErrorReport(entry);
    }
    return DriverMiddlewareResult.proceed();
  }

  Future<void> _sendErrorReport(LogEntry entry) async {
    if (errorReportingEndpoint == null) return;

    try {
      // This is a placeholder. In a real implementation,
      // you would send the error report to your service.
      print('Would send error report to: $errorReportingEndpoint');
      print('Error data: ${entry.toJson()}');
    } catch (e) {
      // Handle error reporting failure
      print('Failed to send error report: $e');
    }
  }
}

void main() async {
  final logger = Logger()
    ..addChannel('console', ConsoleLogDriver())
    // Add global context middleware
    ..addMiddleware(() => {
          'app': 'MyApp',
          'version': '1.0.0',
          'environment': 'production',
          'hostname': Platform.localHostname,
          'pid': pid,
        })
    // Add driver-specific middleware
    ..addDriverMiddleware(
      'console',
      RequestTrackerMiddleware(),
    )
    ..addDriverMiddleware(
      'console',
      SensitiveDataFilterMiddleware(
        sensitiveKeys: ['password', 'credit_card', 'api_key'],
        maskValue: '[REDACTED]',
      ),
    )
    ..addDriverMiddleware(
      'console',
      PerformanceMiddleware(
        samplingInterval: Duration(seconds: 30),
      ),
    )
    ..addDriverMiddleware(
      'console',
      ErrorReportingMiddleware(
        errorReportingEndpoint: Uri.parse('https://errors.example.com/report'),
        reportLevels: {Level.error, Level.critical},
      ),
    );

  // Regular log - will include request ID and performance metrics
  logger.info(
      'Application started',
      Context({
        'operation': 'startup',
      }));

  // Log with sensitive data - will be masked
  logger.info(
      'User credentials updated',
      Context({
        'user': 'john_doe',
        'password': 'secret123',
        'api_key': 'abcd1234',
      }));

  // Simulate some operations
  for (var i = 0; i < 5; i++) {
    logger.info(
        'Processing request',
        Context({
          'operation': 'api_call',
          'endpoint': '/api/users',
          'method': 'GET',
        }));
    await Future.delayed(Duration(seconds: 1));
  }

  // Log error with context - will trigger error reporting
  try {
    throw Exception('Database connection failed');
  } catch (e, stack) {
    logger.error(
        'Failed to connect to database',
        Context({
          'error': e.toString(),
          'stack': stack.toString(),
          'database': 'users',
          'operation': 'db_connect',
        }));
  }

  // Log security event
  logger.critical(
      'Security breach detected',
      Context({
        'source_ip': '192.168.1.100',
        'target': '/admin',
        'user_agent': 'suspicious-bot/1.0',
        'operation': 'security_alert',
      }));

  await logger.shutdown();
}
