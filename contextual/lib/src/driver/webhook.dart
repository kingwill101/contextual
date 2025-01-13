import 'dart:convert';

import 'package:universal_io/io.dart';

import 'driver.dart';

/// A log driver that sends log messages to a webhook endpoint.
///
/// The [WebhookLogDriver] is an implementation of the [LogDriver] interface that sends
/// log messages to a specified webhook endpoint. It supports optional username and
/// emoji customization for the log messages.
class WebhookLogDriver extends LogDriver {
  final Uri endpoint;
  final String? username;
  final String? emoji;

  /// Constructs a new [WebhookLogDriver] instance with the specified [endpoint], and optional [username] and [emoji] parameters.
  ///
  /// The [endpoint] parameter is a required [Uri] that specifies the webhook endpoint to send log messages to.
  /// The [username] parameter is an optional [String] that specifies the username to include in the log message.
  /// The [emoji] parameter is an optional [String] that specifies the emoji to include in the log message.
  WebhookLogDriver(this.endpoint, {this.username, this.emoji})
      : super("webhook");

  @override
  Future<void> log(String formattedMessage) async {
    final body = jsonEncode({
      'text': formattedMessage,
      if (username != null) 'username': username,
      if (emoji != null) 'icon_emoji': emoji,
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
