import 'dart:async';
import 'package:contextual/src/abstract_logger.dart';
import 'package:contextual/src/config.dart';
import 'package:contextual/src/context.dart';
import 'package:contextual/src/context_middleware.dart';
import 'package:contextual/src/driver/console.dart';
import 'package:contextual/src/driver/daily.dart';
import 'package:contextual/src/driver/driver.dart';
import 'package:contextual/src/driver/stack.dart';
import 'package:contextual/src/driver/webhook.dart';
import 'package:contextual/src/format/formatter_settings.dart';
import 'package:contextual/src/format/message_formatter.dart';
import 'package:contextual/src/format/plain.dart';
import 'package:contextual/src/log_level.dart';
import 'package:contextual/src/logtype_formatter.dart';
import 'package:contextual/src/middleware.dart';
import 'package:contextual/src/middleware_processor.dart';
import 'package:contextual/src/sink.dart';

/// A function type representing a log listener callback.
///
/// The callback is invoked whenever a log message is emitted, and receives the
/// log level, the log message, and the timestamp of the log entry.
///
/// This can be used to implement custom logging sinks or integrations.
typedef LogListener = void Function(
    String level, String message, DateTime time);

/// A configurable logging system with support for multiple output channels.
///
/// Uses a modular architecture with drivers for different output destinations,
/// middleware for transforms, formatters for message styling, and rich context.
///
/// Supports several built-in drivers:
/// - `console` for terminal output with optional colors
/// - `daily` for rotating file logs
/// - `stack` for in-memory buffers
/// - `webhook` for HTTP endpoints like Slack
///
/// Example:
/// ```dart
/// final logger = Logger()
///   ..environment('development')
///   ..addDriver('file', DailyFileLogDriver('app.log'))
///   ..withContext({'app': 'MyApp'});
///
/// await logger.info('Application started');
/// ```
/// This logger supports asynchronous logging with batching and automatic flushing
/// through the use of a [LogSink]. The sink options can be configured to control
/// how logs are processed and delivered.
///
/// Example:
/// ```dart
/// final logger = Logger(
///   sinkConfig: LogSinkConfig(
///     batchSize: 50,  // Flush after 50 logs
///     flushInterval: Duration(seconds: 5),  // Or every 5 seconds
///     maxRetries: 3,  // Retry failed operations
///     autoFlush: true  // Enable automatic flushing
///   )
/// );
/// ```
class Logger extends AbstractLogger {
  /// Map of channel names to their corresponding log drivers
  /// Each channel represents a distinct logging destination
  final Map<String, LogDriver> _channels = {};

  /// Driver-specific middlewares mapped by driver name
  /// Each driver can have its own middleware chain for processing logs
  final Map<String, List<DriverMiddleware>> _driverMiddlewares = {};

  /// Global middlewares applied to all drivers
  /// These run before any driver-specific middlewares
  final List<DriverMiddleware> _globalMiddlewares = [];

  /// Middleware for modifying context data
  /// Executed before each log operation to enrich context
  final List<ContextMiddleware> _contextMiddlewares = [];

  /// How log messages are converted to strings.
  LogMessageFormatter _formatter;

  /// Shared context that applies to all log entries
  /// Maintains application-wide contextual information
  final Context _sharedContext = Context();

  /// Factory for creating log drivers
  /// Handles instantiation of built-in and custom drivers
  final LogDriverFactory _driverFactory = LogDriverFactory();

  /// Type-specific formatters for custom log message formatting
  /// Enables specialized formatting for different object types
  final Map<Type, LogTypeFormatter> _typeFormatters = {};

  /// Current environment (e.g., development, production)
  /// Used for environment-specific logging configuration
  String _environment;

  /// Logger configuration
  /// Contains channel definitions and default settings
  LogConfig? _config;

  /// Log sink for batching and async processing of logs
  /// Provides buffering and asynchronous writing capabilities
  late LogSink _logSink;

  /// Currently targeted channels for logging
  /// Used for temporary channel selection in logging operations
  Set<String>? _targetChannels;

  /// Creates a logger with the given configuration options.
  ///
  /// By default uses the production environment and plain text formatting.
  ///
  /// ```dart
  /// final logger = Logger(
  ///   environment: 'development',
  ///   formatter: JsonLogFormatter(),
  ///   sinkConfig: LogSinkConfig(batchSize: 50),
  /// );
  /// ```
  Logger(
      {LogConfig? config,
      String? environment,
      LogSinkConfig? sinkConfig,
      LogMessageFormatter? formatter,
      FormatterSettings? formatterSettings})
      : _formatter = formatter ?? PlainTextLogFormatter(),
        _environment = environment ?? "production" {
    _logSink = LogSink(
      batchSize: sinkConfig?.batchSize ?? 10,
      autoFlushInterval:
          sinkConfig?.flushInterval ?? const Duration(seconds: 1),
      autoCloseAfter: sinkConfig?.autoFlush == false
          ? Duration.zero
          : const Duration(seconds: 1),
    );
    _registerDefaultDrivers();
    _config = config;
    _loadConfig();
  }

  /// Optional listener for log entries
  LogListener? _listener;

  /// Sets a listener for log entries. When set, this bypasses the sink
  /// and directly sends logs to the listener.
  ///
  /// Only one listener can be active at a time. Setting a new listener
  /// replaces any existing one.
  Future<void> setListener(LogListener listener) async {
    _listener = listener;
    await _logSink.close();
  }

  /// Removes the current listener, reverting to sink-based logging.
  void clearListener() {
    _listener = null;
  }

  /// Sets the logger configuration and loads drivers.
  ///
  /// The configuration defines available channels and their settings.
  /// This method will initialize all channels that match the current environment.
  ///
  /// Parameters:
  /// - [config]: The configuration object containing channel definitions
  ///
  /// Returns the Logger instance for method chaining.
  Logger config(LogConfig config) {
    _config = config;
    _loadConfig();
    return this;
  }

  /// Sets the operating environment.
  ///
  /// The environment affects which channels are active based on their configuration.
  /// Common values include 'development', 'testing', and 'production'.
  ///
  /// Parameters:
  /// - [environment]: The environment name to set
  ///
  /// Returns the Logger instance for method chaining.
  Logger environment(String environment) {
    _environment = environment;
    return this;
  }

  /// Sets how log messages are formatted into strings.
  ///
  /// Applies to all channels unless they specify their own formatter.
  Logger formatter(LogMessageFormatter formatter) {
    _formatter = formatter;
    return this;
  }

  /// Adds a context middleware to modify or enrich the logging context data.
  ///
  /// Context middleware functions are executed in the order they are added before
  /// each log entry is processed. They can be used to add dynamic contextual
  /// information like timestamps, request IDs, user information, etc.
  ///
  /// Parameters:
  /// - [middleware]: A [ContextMiddleware] function that returns a map of context
  ///   data to be merged with the existing context.
  ///
  /// Returns the Logger instance to allow method chaining.
  ///
  /// Example:
  /// ```dart
  /// logger.addMiddleware(() => {
  ///   'timestamp': DateTime.now().toIso8601String(),
  ///   'requestId': generateRequestId(),
  ///   'userId': getCurrentUserId()
  /// });
  /// ```
  Logger addMiddleware(ContextMiddleware middleware) {
    _contextMiddlewares.add(middleware);
    return this;
  }

  /// Adds a global log middleware that applies to all drivers.
  ///
  /// Global middlewares can transform, filter, or enrich log entries
  /// before they are processed by any driver.
  ///
  /// Parameters:
  /// - [middleware]: The middleware instance to add
  ///
  /// Returns the Logger instance for method chaining.
  ///
  /// Example:
  /// ```dart
  /// logger.addLogMiddleware(new SensitiveDataFilter());
  /// ```
  /// Adds a middleware that applies to all drivers.
  ///
  /// Global middlewares run before any driver-specific middlewares and
  /// are applied to each driver's log entries independently.
  Logger addLogMiddleware(DriverMiddleware middleware) {
    _globalMiddlewares.add(middleware);
    return this;
  }

  /// Adds a middleware specific to a named driver.
  ///
  /// Driver-specific middlewares only affect logs sent to the specified driver.
  ///
  /// Parameters:
  /// - [driverName]: Name of the driver to add middleware for
  /// - [middleware]: The middleware instance to add
  ///
  /// Returns the Logger instance for method chaining.
  /// Adds a middleware that only applies to a specific driver.
  ///
  /// The [driverName] parameter specifies which driver the middleware applies to.
  /// Multiple middlewares for the same driver are executed in the order they were added.
  Logger addDriverMiddleware(String driverName, DriverMiddleware middleware) {
    _driverMiddlewares.putIfAbsent(driverName, () => []).add(middleware);
    return this;
  }

  /// Adds a new log driver with the specified name.
  ///
  /// Creates a new logging channel that can be targeted for log output.
  ///
  /// Parameters:
  /// - [name]: Unique name for the driver
  /// - [driver]: The driver instance to add
  ///
  /// Returns the Logger instance for method chaining.
  Logger addDriver(String name, LogDriver driver) {
    _channels[name] = driver;
    return this;
  }

  /// Adds a type-specific formatter for custom object logging.
  ///
  /// Allows specialized formatting for specific object types.
  ///
  /// Parameters:
  /// - [formatter]: The type formatter instance to add
  ///
  /// Returns the Logger instance for method chaining.
  Logger addTypeFormatter<T>(LogTypeFormatter<T> formatter) {
    _typeFormatters[T] = formatter;
    return this;
  }

  /// Creates a new log driver from configuration.
  ///
  /// Used internally to instantiate drivers from configuration objects.
  ///
  /// Parameters:
  /// - [config]: Configuration map for the driver
  ///
  /// Returns the constructed LogDriver instance.
  LogDriver buildChannel(Map<String, dynamic> config) {
    return _driverFactory.createDriver(config);
  }

  /// Selects specific channels for the next log operation.
  ///
  /// Allows targeting specific channels for the next log message.
  /// The selection is reset after the log operation.
  ///
  /// Parameters:
  /// - [channels]: List of channel names to target
  ///
  /// Returns the Logger instance for method chaining.
  ///
  /// Example:
  /// ```dart
  /// logger.to(['console', 'file']).info('Message');
  /// ```
  Logger to(List<String> channels) {
    _targetChannels = channels.toSet();
    return this;
  }

  /// Adds data to the shared context.
  ///
  /// The shared context is included in all log entries.
  ///
  /// Parameters:
  /// - [context]: Map of context data to add
  ///
  /// Returns the Logger instance for method chaining.
  Logger withContext(Map<String, dynamic> context) {
    _sharedContext.addAll(context);
    return this;
  }

  /// Clears all shared context data.
  ///
  /// Removes all data from the shared context, starting fresh.
  ///
  /// Returns the Logger instance for method chaining.
  Logger clearSharedContext() {
    _sharedContext.clear();
    return this;
  }

  /// Registers the default set of log drivers.
  ///
  /// Sets up the built-in drivers with their default configurations:
  /// - console: Terminal output with optional coloring
  /// - emergency: Daily rotating emergency log files
  /// - daily: Daily rotating general log files
  /// - webhook: HTTP webhook integration
  /// - stack: In-memory log stack
  void _registerDefaultDrivers() {
    _driverFactory.registerDriver('console', (config) => ConsoleLogDriver());
    _driverFactory.registerDriver('emergency',
        (config) => DailyFileLogDriver('logs/emergency.log', retentionDays: 1));
    _driverFactory.registerDriver(
        'daily',
        (config) => DailyFileLogDriver(
              config['path'] ?? 'logs/default.log',
              retentionDays: config['days'] ?? 14,
            ));
    _driverFactory.registerDriver(
        'webhook',
        (config) => WebhookLogDriver(
              Uri.parse(config['webhookUrl']),
              username: config['username'],
              emoji: config['emoji'],
            ));
    _driverFactory.registerDriver('stack', (config) {
      final channelsList = (config['channels'] as List).cast<String>();
      final drivers = channelsList
          .map((name) => _channels[name])
          .whereType<LogDriver>()
          .toList();
      return StackLogDriver(
        drivers,
        ignoreExceptions: config['ignoreExceptions'] ?? false,
      );
    });
  }

  /// Loads and configures drivers from the logger configuration.
  ///
  /// Processes the configuration object to set up all defined channels
  /// that match the current environment.
  void _loadConfig() {
    if (_config == null || _config!.channels.isEmpty) {
      // Add a default console log driver if no channels are configured
      addDriver('console', ConsoleLogDriver());
      return;
    }

    _config?.channels.forEach((name, channelConfig) {
      final mergedConfig = {..._config!.defaults, ...channelConfig.toJson()};
      if (channelConfig.env == 'all' || channelConfig.env == _environment) {
        final driver = _driverFactory.createDriver(mergedConfig);
        addDriver(name, driver);
      }
    });
  }

  /// Formats a message using the appropriate formatter.
  ///
  /// Selects between type-specific formatters and the default formatter
  /// based on the message type.
  ///
  /// Parameters:
  /// - [level]: Log level for the message
  /// - [message]: The message object to format
  /// - [context]: Current logging context
  ///
  /// Returns the formatted message string.
  String _formatMessage(String level, Object message, Context context) {
    final typeFormatter = _typeFormatters[message.runtimeType];
    if (typeFormatter != null) {
      return typeFormatter.format(level, message, context);
    }
    return _formatter.format(level, message.toString(), context);
  }

  /// Logs a message with the specified level and optional context.
  ///
  /// This is the core logging method that processes the message through
  /// the middleware chain and distributes it to the appropriate drivers.
  ///
  /// Parameters:
  /// - [level]: The log level (e.g., "info", "error", "debug")
  /// - [message]: The message or object to log
  /// - [context]: Optional additional context data specific to this log entry
  ///
  /// Throws ArgumentError if the log level is invalid.
  ///
  /// Example:
  /// ```dart
  /// await logger.log('error', 'Database connection failed',
  ///   Context({'attempt': 3, 'database': 'users'}));
  /// ```
  @override
  @override
  Future<void> log(String level, dynamic message, [Context? context]) async {
    if (!LogLevel.contains(level)) {
      throw ArgumentError('Invalid log level: $level');
    }

    context ??= Context();
    final combinedContext = Context();
    combinedContext.addAll(_sharedContext.all());
    combinedContext.addAll(context.all());

    for (var middleware in _contextMiddlewares) {
      combinedContext.addAll(middleware());
    }

    final formattedMessage = _formatMessage(level, message, combinedContext);
    final timestamp = DateTime.now();

    // If listener is set, use it instead of the sink
    if (_listener != null) {
      _listener!(level, formattedMessage, timestamp);
      return;
    }

    // Otherwise continue with existing sink-based logic
    final selectedChannels = _targetChannels ?? _channels.keys.toSet();
    final uniqueDrivers = <String, LogDriver>{};
    for (final channel in selectedChannels) {
      final driver = _channels[channel];
      if (driver != null) {
        uniqueDrivers[channel] = driver;
      }
    }

    for (final entry in uniqueDrivers.entries) {
      final channelName = entry.key;
      final driver = entry.value;

      if (driver is StackLogDriver) {
        driver.setMiddlewares(_driverMiddlewares);
      }

      var driverLogEntry = await processDriverMiddlewares(
          logEntry: MapEntry(level, formattedMessage),
          driverName: channelName,
          globalMiddlewares: _globalMiddlewares,
          driverMiddlewaresMap: _driverMiddlewares);

      if (driverLogEntry == null) continue;

      await _logSink.addLog(level, () async {
        await driver.log(driverLogEntry.value);
      });
    }

    _targetChannels = null;
  }

  /// Shuts down the logger and flushes any pending logs.
  ///
  /// Ensures all queued logs are written before the application exits.
  ///
  /// Returns a Future that completes when shutdown is finished.
  ///
  /// Example:
  /// ```dart
  /// await logger.info('Shutting down...');
  /// await logger.shutdown();
  /// ```
  Future<void> shutdown() async {
    // If a listener is set, there's no need to perform shutdown operations
    if (_listener != null) {
      return;
    }

    // Proceed with sink-based shutdown logic
    await _logSink.close();
  }
}

/// Formats [Error] objects with their stack traces for debugging.
class ErrorLogFormatter extends LogTypeFormatter<Error> {
  /// Formats an Error object with its stack trace.
  ///
  /// Creates a detailed log entry that includes both the error message
  /// and the current stack trace for debugging purposes.
  ///
  /// Parameters:
  /// - [level]: The log level (e.g., "error", "fatal")
  /// - [error]: The Error object to format
  /// - [context]: The logging context for additional information
  ///
  /// Returns a formatted string containing the error and stack trace.
  ///
  /// Example output:
  /// ```
  /// [error] DatabaseConnectionError: Connection refused | StackTrace: #0 main (file:///app.dart:10:5) ...
  /// ```
  @override
  String format(String level, Error error, Context context) {
    return '[$level] ${error.toString()} | StackTrace: ${StackTrace.current}';
  }
}
