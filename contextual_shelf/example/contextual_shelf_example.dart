import 'package:contextual/contextual.dart';
import 'package:contextual_shelf/contextual_shelf.dart';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;

/// Custom log profile that logs non-GET requests and API requests
class ApiLogProfile implements LogProfile {
  @override
  bool shouldLogRequest(shelf.Request request) {
    return request.method != 'GET' || request.url.path.startsWith('api/');
  }
}

/// This example demonstrates how to use contextual_shelf with a Shelf server.
/// It shows request logging, error handling, and custom log formatting.
void main() async {
  // Create a logger with multiple channels
  final logger = await Logger.create()
    ..addChannel('console', ConsoleLogDriver(), formatter: PrettyLogFormatter())
    ..addChannel(
      'file',
      DailyFileLogDriver('logs/server.log'),
      formatter: JsonLogFormatter(),
    );

  // Create a custom log writer with sanitization
  final logWriter = DefaultLogWriter(
    logger,
    sanitizer: Sanitizer(mask: '[REDACTED]'),
  );

  // Create a log profile that determines which requests to log
  final logProfile = ApiLogProfile();

  // Create the HTTP logger middleware
  final httpLogger = HttpLogger(logProfile, logWriter);

  // Create a handler pipeline with logging middleware
  final handler = const shelf.Pipeline()
      .addMiddleware(httpLogger.middleware)
      .addHandler(_handleRequest);

  // Start the server
  final server = await io.serve(handler, 'localhost', 8080);
  print('Server running on port ${server.port}');

  // Log server startup
  logger.info(
    'Server started',
    Context({'port': server.port, 'address': server.address.host}),
  );
}

/// Example request handler that demonstrates different scenarios
Future<shelf.Response> _handleRequest(shelf.Request request) async {
  try {
    switch (request.url.path) {
      case 'api/users':
        // Simulate successful API request
        return shelf.Response.ok(
          '{"status": "success", "data": ["user1", "user2"]}',
          headers: {'content-type': 'application/json'},
        );

      case 'api/error':
        // Simulate error condition
        throw Exception('Simulated API error');

      case 'api/slow':
        // Simulate slow request
        await Future.delayed(Duration(seconds: 2));
        return shelf.Response.ok('Slow response');

      case 'api/auth':
        // Simulate authenticated request
        final auth = request.headers['authorization'];
        if (auth == null) {
          return shelf.Response.unauthorized('No authorization provided');
        }
        return shelf.Response.ok('Authenticated');

      default:
        // Handle static content or other routes
        return shelf.Response.ok('Hello from Shelf!');
    }
  } catch (e, _) {
    // Errors will be logged by the middleware
    return shelf.Response.internalServerError(
      body: 'Internal Server Error $getCurrentFileAndLine',
    );
  }
}

String get getCurrentFileAndLine {
  // Generate a current stack trace.
  final stackTrace = StackTrace.current.toString();

  // The stack trace is a multi-line string; each line looks something like:
  //   #0      MyClass.myMethod (file:///path/to/file.dart:42:16)
  // We can split on newlines and parse the line that describes this method call.
  final traceLines = stackTrace.split('\n');

  // The first frame (#0) usually corresponds to the current line in Dart.
  // Adjust the index if you need a different call site.
  final frame = traceLines.isNotEmpty ? traceLines[1] : '';

  // A quick (naive) pattern match to find parentheses and extract file info.
  // You might want to refine this or use a regex for more robust parsing.
  final fileInfoStart = frame.indexOf('(');
  final fileInfoEnd = frame.indexOf(')');

  if (fileInfoStart != -1 && fileInfoEnd != -1 && fileInfoStart < fileInfoEnd) {
    final fileInfo = frame.substring(fileInfoStart + 1, fileInfoEnd);
    return fileInfo; // something like "file:///path/to/file.dart:42:16"
  }

  // If parsing fails for some reason, return the raw frame or an empty string.
  return frame;
}
