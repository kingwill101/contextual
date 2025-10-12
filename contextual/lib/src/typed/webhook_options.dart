import 'package:dart_mappable/dart_mappable.dart';

part 'webhook_options.mapper.dart';

@MappableClass()
class WebhookOptions with WebhookOptionsMappable {
  final Uri url;
  final Map<String, String>? headers;
  final Duration timeout;
  final bool keepAlive;

  const WebhookOptions({
    required this.url,
    this.headers,
    this.timeout = const Duration(seconds: 5),
    this.keepAlive = true,
  });
}
