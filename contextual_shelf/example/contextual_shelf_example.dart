import 'dart:io';

import 'package:contextual/contextual.dart';
import 'package:contextual_shelf/src/default_log_writer.dart';
import 'package:contextual_shelf/src/http_logger.dart';
import 'package:contextual_shelf/src/log_non_get_requests.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() async {
  // Set up the logger with different channels
  final logger = Logger()
    ..environment('development') // Set the environment
    ..withContext({
      'app': 'ShelfApp',
    })
    // Console channel with PrettyLogFormatter
    ..addChannel('console', ConsoleLogDriver(), formatter: PrettyLogFormatter())
    // File channel with JsonLogFormatter
    ..addChannel(
      'file',
      DailyFileLogDriver(
        'logs/app.log',
        retentionDays: 7,
      ),
      formatter: JsonLogFormatter(),
    );

  final logProfile = LogNonGetRequests(); // Customize as needed
  final logWriter = DefaultLogWriter(logger);
  final httpLogger = HttpLogger(logProfile, logWriter);

  // Define the handler
  final handler =
      Pipeline().addMiddleware(httpLogger.middleware).addHandler(_echoRequest);

  // Start the server
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, 8080);
  final startMessage = 'Server started on port ${server.port}';
  logger.to(['console', 'file']).info(startMessage);
}

Response _echoRequest(Request request) {
  // Simulate an error for demonstration
  if (request.url.path == 'error') {
    throw Exception('Simulated exception');
  }

  return Response.ok('Request for "${request.url}"');
}

String getCurrentFileAndLine() {
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
