import 'package:contextual/contextual.dart';

class CustomFormat1 extends LogMessageFormatter {
  @override
  String format(LogRecord record) {
    // Access the level, message, and context from the record
    final level = record.level;
    final message = record.message;

    // Implement your custom formatting logic
    return '[CustomFormat1] [$level] $message';
  }
}

class CustomFormat2 extends LogMessageFormatter {
  @override
  String format(LogRecord record) {
    final level = record.level;
    final message = record.message;
    return '[CustomFormat2] [$level] $message';
  }
}

/// This example demonstrates using multiple channels with different formatters.
/// - Console output uses pretty formatting with colors
/// - File output uses JSON formatting for structured logging
/// - Webhook output uses plain text formatting
void main() async {
  final logger = Logger()
    // Console channel with pretty formatting for human readability
    ..addChannel(
      'console',
      ConsoleLogDriver(),
      formatter: PrettyLogFormatter(),
    )
    // File channel with JSON formatting for machine processing
    ..addChannel(
      'file',
      DailyFileLogDriver('logs/app.log'),
      formatter:
          JsonLogFormatter(prettyPrint: true), // Pretty print for readability
    )
    // Webhook channel with plain text for simple HTTP posting
    ..addChannel(
      'webhook',
      WebhookLogDriver(Uri.parse('https://webhook.example.com/logs')),
      formatter: PlainTextLogFormatter(),
    );

  // Log to all channels - each using its own formatter
  logger.info('This message uses different formats per channel');

  // Add context to demonstrate structured data handling
  logger.withContext({
    'requestId': 'req-123',
    'user': 'jane_doe',
    'action': 'checkout',
    'amount': 99.99,
  }).info('Processing checkout');

  // Target specific channels
  logger['console'].debug('Console only - with pretty colors');
  logger['file'].info('File only - in JSON format');
  logger['webhook'].warning('Webhook only - plain text');

  // Log an error to console and file, but not webhook
  logger['console'].error('System alert - high CPU usage');
  logger['file'].error('System alert - high CPU usage');

  await logger.shutdown();
}
