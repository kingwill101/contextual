import 'package:contextual/contextual.dart';
import 'package:contextual_shelf/src/log_writer.dart';
import 'package:contextual_shelf/src/sanitizer.dart';
import 'package:shelf/shelf.dart';

class DefaultLogWriter implements LogWriter {
  final Logger logger;
  final Sanitizer sanitizer;

  DefaultLogWriter(this.logger, {Sanitizer? sanitizer})
      : sanitizer = sanitizer ?? Sanitizer();

  @override
  void logRequest(
    Request request,
    Response response,
    DateTime startTime,
    Duration elapsedTime, {
    int? memory,
    int? pid,
  }) {
    // Build the log message string
    final message = '${request.method} ${request.requestedUri} '
        '[${response.statusCode}] ${elapsedTime.inMilliseconds}ms';

    // Prepare additional data to include in context
    final contextData = {
      'timestamp': startTime.toIso8601String(),
      'headers': sanitizer.clean(request.headers, ['authorization']),
      'responseHeaders': sanitizer.clean(response.headers, []),
      'memory': memory,
      'pid': pid,
    };

    // Log the message with context
    logger.withContext(contextData).info(message);
  }

  @override
  void logError(
    Request request,
    Object error,
    StackTrace stackTrace,
    DateTime startTime,
    Duration elapsedTime, {
    int? memory,
    int? pid,
  }) {
    // Build the log message string
    final message = 'ERROR: ${request.method} ${request.requestedUri} '
        '${elapsedTime.inMilliseconds}ms';

    // Prepare additional data to include in context
    final contextData = {
      'timestamp': startTime.toIso8601String(),
      'headers': sanitizer.clean(request.headers, ['authorization']),
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
      'memory': memory,
      'pid': pid,
    };

    // Log the error message with context
    logger.withContext(contextData).error(message);
  }
}
