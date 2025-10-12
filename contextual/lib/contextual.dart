/// A structured logging library with support for formatting, context, and multiple outputs.
///
/// The library supports two logging patterns:
///
/// 1. Sink-based logging with multiple drivers (default):
/// ```dart
/// final logger = Logger()
///   ..addChannel('console', ConsoleLogDriver())
///   ..addChannel('file', DailyFileLogDriver('app.log'));
/// ```
///
/// 2. Listener-based logging similar to the `logging` package:
/// ```dart
/// final logger = Logger();
/// logger.setListener((level, message, time) {
///   print('[$time] $level: $message');
/// });
/// ```
///
/// The listener pattern is simpler but doesn't support multiple outputs
/// or middleware. Use the sink-based pattern for more advanced features.
///
/// Features:
/// * Multiple standard log levels (debug through emergency)
/// * Built-in message formatters:
///   * [PlainTextLogFormatter] for simple text output
///   * [JsonLogFormatter] for machine-readable JSON
///   * [PrettyLogFormatter] for colored terminal output
///   * [RawLogFormamter] for colored terminal output
///   * Custom formatters through [LogMessageFormatter]
/// * Rich context support through [Context]
/// * Multiple output destinations:
///   * Console logging
///   * Daily rotating files
///   * Webhook endpoints (e.g., Slack)
///   * In-memory buffers
/// * Middleware for transforming logs
/// * Type-specific formatters for custom objects
/// * Asynchronous batch processing
///
/// Getting started:
/// ```dart
/// import 'package:contextual/contextual.dart';
///
/// void main() {
///   final logger = Logger()
///     ..environment('development')
///     ..formatter(PrettyLogFormatter())
///     ..withContext({'app': 'MyApp'});
///
///   // Basic logging
///   logger.info('Server started');
///
///   // With additional context
///   logger.error('Database error',
///     Context({'code': 500, 'db': 'users'}));
///
///   // Type-specific formatting
///   logger.debug(MyCustomObject());  // Uses registered formatter
/// }
/// ```
///
/// Key classes:
/// * [Logger] - The main entry point for logging
/// * [Context] - Holds contextual data for log entries
/// * [LogMessageFormatter] - Base class for message formatting
/// * [LogTypeFormatter] - For type-specific message formatting
/// * [LogDriver] - Interface for log output destinations
///
/// For detailed examples and configuration options, see the project's README.

library;


export 'src/context.dart';
export 'src/context_middleware.dart';
export 'src/driver/console.dart';
export 'src/driver/daily.dart';
export 'src/driver/driver.dart';
export 'src/driver/sample.dart';
export 'src/driver/stack.dart';
export 'src/driver/webhook.dart';
export 'src/format/formatter_settings.dart';
export 'src/format/json.dart';
export 'src/format/message_formatter.dart';
export 'src/format/plain.dart';
export 'src/format/pretty.dart';
export 'src/format/raw.dart';
export 'src/log_entry.dart';
export 'src/log_level.dart';
export 'src/logger.dart';
export 'src/logger_extensions.dart';
export 'src/typed/log_config.dart' show TypedLogConfig;
export 'src/typed/channel_config.dart' show ConsoleChannel, DailyFileChannel, WebhookChannel, StackChannel, SamplingChannel;
export 'src/typed/daily_file_options.dart' show DailyFileOptions;
export 'src/typed/console_options.dart' show ConsoleOptions;
export 'src/typed/webhook_options.dart' show WebhookOptions;
export 'src/typed/stack_options.dart' show StackOptions;
export 'src/typed/sampling_options.dart' show SamplingOptions;
export 'src/typed/batching_config.dart' show BatchingConfig;
export 'src/logtype_formatter.dart';
export 'src/middleware.dart';
export 'src/util.dart';
export 'src/sink.dart';
export 'src/record.dart';
