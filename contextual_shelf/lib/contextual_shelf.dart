/// A powerful logging middleware for Shelf applications that integrates with the
/// contextual logging package to provide structured, configurable logging.
///
/// This package provides a flexible logging system for Shelf web servers with features
/// for request/response logging, error tracking, performance monitoring, and
/// sensitive data sanitization.
///
/// Key features:
/// * Structured logging with multiple output channels
/// * Request/response timing and performance metrics
/// * Memory usage tracking
/// * Error handling and logging
/// * Sensitive data sanitization
/// * Configurable request filtering
/// * Support for multiple log formats (JSON, pretty, plain text)
///
/// Basic usage:
/// ```dart
/// import 'package:contextual/contextual.dart';
/// import 'package:contextual_shelf/contextual_shelf.dart';
/// import 'package:shelf/shelf.dart' as shelf;
///
/// void main() async {
///   // Create a logger with console and file output
///   final logger = Logger()
///     ..addChannel(
///       'console',
///       ConsoleLogDriver(),
///       formatter: PrettyLogFormatter(),
///     )
///     ..addChannel(
///       'file',
///       DailyFileLogDriver('logs/server.log'),
///       formatter: JsonLogFormatter(),
///     );
///
///   // Set up the logging middleware
///   final logWriter = DefaultLogWriter(
///     logger,
///     sanitizer: Sanitizer(mask: '[REDACTED]'),
///   );
///   final logProfile = LogNonGetRequests();
///   final httpLogger = HttpLogger(logProfile, logWriter);
///
///   // Add the middleware to your Shelf pipeline
///   final handler = const shelf.Pipeline()
///     .addMiddleware(httpLogger.middleware)
///     .addHandler(myHandler);
///
///   await shelf.serve(handler, 'localhost', 8080);
/// }
/// ```
///
/// Custom request filtering:
/// ```dart
/// class ApiLogProfile implements LogProfile {
///   @override
///   bool shouldLogRequest(shelf.Request request) {
///     return request.method != 'GET' || request.url.path.startsWith('api/');
///   }
/// }
/// ```
///
/// The package provides several key components:
///
/// * [HttpLogger]: The main middleware class that integrates with Shelf.
///   Handles request timing, error catching, and log routing.
///
/// * [LogWriter]: Interface for writing log entries. The [DefaultLogWriter]
///   implementation provides structured logging with context and sanitization.
///
/// * [LogProfile]: Interface for determining which requests to log.
///   [LogNonGetRequests] is provided as a common implementation.
///
/// * [Sanitizer]: Utility for cleaning sensitive data from logs.
///   Configurable with custom masking rules.
///
/// See also:
/// * [Logger] from the contextual package for core logging functionality
/// * [shelf.Pipeline] for integrating middleware into your Shelf application
/// * The example directory for more detailed usage examples

export 'src/default_log_writer.dart';
export 'src/http_logger.dart';
export 'src/log_profile.dart';
export 'src/log_writer.dart';
export 'src/sanitizer.dart';
export 'src/log_non_get_requests.dart';
