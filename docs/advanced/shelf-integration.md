# Shelf Integration Tips

The `contextual_shelf` package provides an HttpLogger middleware that captures request/response metadata and logs via your configured drivers.

## Usage

```dart
import 'package:contextual/contextual.dart';
import 'package:contextual_shelf/contextual_shelf.dart';
import 'package:shelf/shelf.dart';

void main() async {
  final logger = await Logger.create()
    ..addChannel('console', ConsoleLogDriver());

  final httpLogger = HttpLogger(DefaultLogProfile(), DefaultLogWriter());

  final handler = const Pipeline()
      .addMiddleware(httpLogger.middleware)
      .addHandler((req) => Response.ok('ok'));

  // serve ...
}
```

## Tips

- Consider a typed channel dedicated to HTTP logging (e.g., name: 'http'), and select it via `logger.forDriver<ConsoleLogDriver>(name: 'http')` if needed.
- Combine with batching for high-throughput endpoints.
- Add driver middleware to redact sensitive headers or query parameters.
