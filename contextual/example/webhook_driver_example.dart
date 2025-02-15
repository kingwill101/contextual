import 'package:contextual/contextual.dart';

/// This example demonstrates logging to external services via webhooks.
/// It shows how to configure and use the webhook driver for remote logging.
void main() async {
  final logger = Logger()
    ..addChannel(
      'webhook',
      WebhookLogDriver(
        Uri.parse('https://webhook.example.com/logs'),
      ),
      formatter: JsonLogFormatter(), // Use JSON for webhook payloads
    );

  // Basic webhook logging
  logger.info('System startup completed');

  // Log with structured data
  logger.withContext({
    'environment': 'production',
    'region': 'us-east-1',
    'instance': 'web-server-01',
  }).info('Server health check passed');

  // Log error conditions
  try {
    throw Exception('Service unavailable');
  } catch (e, stack) {
    logger.withContext({
      'error': {
        'type': e.runtimeType.toString(),
        'message': e.toString(),
        'stack': stack.toString(),
      },
      'service': 'api',
      'endpoint': '/users',
      'method': 'POST',
    }).error('API request failed');
  }

  // Log performance metrics
  logger.info({
    'metric': 'performance',
    'type': 'response_time',
    'value': 235.5,
    'unit': 'ms',
    'timestamp': DateTime.now().toIso8601String(),
  });

  // Multiple webhooks example
  final multiLogger = Logger()
    ..addChannel(
      'slack',
      WebhookLogDriver(
        Uri.parse('https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'),
      ),
      formatter: PlainTextLogFormatter(), // Plain text for Slack
    )
    ..addChannel(
      'datadog',
      WebhookLogDriver(
        Uri.parse('https://http-intake.logs.datadoghq.com/v1/input'),
      ),
      formatter: JsonLogFormatter(), // JSON for Datadog
    );

  // Log to both Slack and Datadog
  multiLogger.withContext({
    'alert_level': 'high',
    'component': 'payment_service',
  }).alert('Payment processing system is down');

  await logger.shutdown();
  await multiLogger.shutdown();
}
