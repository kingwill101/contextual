import 'package:contextual/contextual.dart';

/// This example demonstrates JSON formatting for structured logging.
/// The output is machine-readable and suitable for log aggregation systems.
void main() async {
  final logger = Logger(
    formatter: JsonLogFormatter(
      prettyPrint: true, // Enable pretty printing for readability
    ),
  )..addChannel('console', ConsoleLogDriver());

  // Basic message logging
  logger.info('Application initialized');

  // Logging with context data
  logger.withContext({
    'requestId': 'req-${DateTime.now().millisecondsSinceEpoch}',
    'user': 'alice',
    'role': 'admin',
  }).info('User session started');

  // Logging structured data
  logger.info({
    'event': 'payment_processed',
    'amount': 99.99,
    'currency': 'USD',
    'status': 'success',
    'timestamp': DateTime.now().toIso8601String(),
  });

  // Logging errors with stack traces
  try {
    throw Exception('Payment validation failed');
  } catch (e, stack) {
    logger.error({
      'error': e.toString(),
      'stackTrace': stack.toString(),
      'component': 'payment_processor',
      'severity': 'high',
    });
  }

  // Multiple context layers
  logger
      .withContext({'service': 'auth'}).withContext({'action': 'verify'}).info({
    'event': 'token_verification',
    'result': 'success',
    'method': 'oauth2',
  });

  await logger.shutdown();
}
