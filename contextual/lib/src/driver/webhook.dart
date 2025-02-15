import 'dart:convert';

import 'package:contextual/src/log_entry.dart';
import 'package:universal_io/io.dart';

import 'driver.dart';

/// A log driver that sends log messages to a webhook endpoint.
///
/// This driver sends log messages as JSON payloads to a specified HTTP endpoint.
/// Each log message is sent as a POST request with a JSON body containing the
/// formatted message.
///
/// The driver handles HTTP errors gracefully, printing error messages to stdout
/// when the webhook request fails. It ensures proper cleanup of HTTP resources
/// by closing the client connection after each request.
///
/// Example:
/// ```dart
/// final driver = WebhookLogDriver(Uri.parse('https://webhook.example.com/logs'));
/// await driver.log(LogEntry(...));
/// ```
class WebhookLogDriver extends LogDriver {
  final Uri endpoint;

  /// Creates a new webhook log driver that sends logs to [endpoint].
  ///
  /// The [endpoint] must be a valid HTTP or HTTPS URL that accepts POST requests
  /// with JSON payloads.
  WebhookLogDriver(this.endpoint) : super("webhook");

  @override
  Future<void> log(LogEntry entry) async {
    final formattedMessage = entry.toString();
    final body = jsonEncode({
      'entry': formattedMessage,
    });

    final client = HttpClient();

    try {
      final request = await client.postUrl(endpoint);
      request.headers.contentType = ContentType.json;
      request.write(body);
      final response = await request.close();
      await response.drain();

      if (response.statusCode != 200) {
        print(
            '[WebhookLogDriver Error] Failed to send log. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('[WebhookLogDriver Error] Exception occurred: $e');
    } finally {
      client.close();
    }
  }
}
