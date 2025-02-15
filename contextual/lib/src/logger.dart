import 'dart:async';

import 'package:contextual/src/driver/sample.dart';
import 'package:contextual/src/format/null.dart';
import 'package:contextual/src/log_entry.dart';
import 'package:contextual/src/record.dart';
import 'package:contextual/src/types.dart';
import 'package:contextual/src/util.dart';

import 'abstract_logger.dart';
import 'config.dart';
import 'context.dart';
import 'context_middleware.dart';
import 'driver/console.dart';
import 'driver/daily.dart';
import 'driver/driver.dart';
import 'driver/stack.dart';
import 'driver/webhook.dart';
import 'format/formatter_settings.dart';
import 'format/json.dart';
import 'format/message_formatter.dart';
import 'format/plain.dart';
import 'format/pretty.dart';
import 'format/raw.dart';
import 'log_level.dart';
import 'logtype_formatter.dart';
import 'middleware.dart';
import 'middleware_processor.dart';
import 'sink.dart';

/// A function type representing a log listener callback.
///
/// The callback is invoked whenever a log message is emitted, and receives the
/// log level, the log message, and the timestamp of the log entry.
///
/// This can be used to implement custom logging sinks or integrations.
typedef LogListener = void Function(LogEntry entry);

/// A configurable logging system with support for multiple output channels.
///
/// Uses a modular architecture with drivers for different output destinations,
/// middleware for transforms, formatters for message styling, and rich context.
///
/// Supports several built-in drivers:
/// - `console` for terminal output with optional colors
/// - `daily` for rotating file logs
/// - `stack` for combining multiple drivers
/// - `webhook` for HTTP endpoints like Slack
///
/// Example:
///
/// final logger = Logger()
///   ..environment('development')
///   ..addChannel('file', DailyFileLogDriver('app.log'))
///   ..withContext({'app': 'MyApp'});
///
/// logger.info('Application started');
///
///
/// This logger supports asynchronous logging with batching and automatic flushing
/// through the use of a [LogSink]. The sink options can be configured to control
/// how logs are processed and delivered.
///
/// Example:
///
/// final logger = Logger(
///   sinkConfig: LogSinkConfig(
///     batchSize: 50,  // Flush after 50 logs
///     flushInterval: Duration(seconds: 5),  // Or every 5 seconds
///     maxRetries: 3,  // Retry failed operations
///     autoFlush: true  // Enable or disable automatic flushing
///   )
/// );
///
class Logger extends AbstractLogger {
  /// Map of channel names to their corresponding log drivers.
  /// Each channel represents a distinct logging destination.
  final Map<String, LogDriver> _channels = {};

  /// Driver-specific middlewares mapped by driver name.
  /// Each driver can have its own middleware chain for processing logs.
  final Map<String, List<DriverMiddleware>> _driverMiddlewares = {};

  /// Channel-specific middlewares mapped by channel name.
  /// Each channel can have its own middleware chain for processing logs.
  final Map<String, List<DriverMiddleware>> _channelMiddlewares = {};

  /// Global middlewares applied to all drivers.
  /// These run before any driver-specific middlewares.
  final List<DriverMiddleware> _globalMiddlewares = [];

  /// Middleware for modifying context data.
  /// Executed before each log operation to enrich context.
  final List<ContextMiddleware> _contextMiddlewares = [];

  /// How log messages are converted to strings.
  LogMessageFormatter _formatter;

  /// Shared context that applies to all log entries.
  /// Maintains application-wide contextual information.
  final Context _sharedContext = Context();

  /// Factory for creating log drivers.
  /// Handles instantiation of built-in and custom drivers.
  final LogDriverFactory _driverFactory = LogDriverFactory();

  /// Type-specific formatters for custom log message formatting.
  /// Enables specialized formatting for different object types.
  final Map<Type, LogTypeFormatter> _typeFormatters = {};

  /// Current environment (e.g., development, production).
  /// Used for environment-specific logging configuration.
  String _environment;

  /// Logger configuration.
  /// Contains channel definitions and default settings.
  LogConfig? _config;

  /// Whether to use the sink for logging
  final bool useSink;

  /// Log sink for batching and async processing of logs.
  /// Only initialized if [useSink] is true.
  LogSink? _logSink;

  /// Currently targeted channels for logging.
  /// Used for temporary channel selection in logging operations.
  Set<String>? _targetChannels;

  /// Map to store per-channel formatters.
  final Map<String, LogMessageFormatter> _channelFormatters = {};

  /// Map to store registered formatter builders.
  final Map<String, LogMessageFormatterBuilder> _formatterFactory = {};

  /// The minimum log level to process. Messages below this level are ignored.
  Level _minimumLevel = Level.debug;

  /// Indicates whether the default `console` channel is enabled.
  final bool defaultChannelEnabled;

  /// Optional listener for log entries.
  LogListener? _listener;

  /// Sets the minimum log level. Messages below this level will be ignored.
  ///
  /// Example:
  /// ```dart
  /// logger.setLevel(Level.warning); // Only log warning and above
  /// ```
  void setLevel(Level level) {
    _minimumLevel = level;
  }

  /// Gets the current minimum log level.
  Level getLevel() => _minimumLevel;

  /// Registers a formatter with the specified name and builder function.
  ///
  /// This allows formatters to be referenced by name in configuration files.
  void registerFormatter(String name, LogMessageFormatterBuilder builder) {
    _formatterFactory[name] = builder;
  }

  /// Creates a logger with the given configuration options.
  ///
  /// By default uses the production environment and plain text formatting.
  ///
  /// Parameters:
  /// * [config] - Optional logging configuration
  /// * [environment] - Operating environment (default: "production")
  /// * [sinkConfig] - Configuration for the log sink if [useSink] is true
  /// * [formatter] - Message formatter (default: PlainTextLogFormatter)
  /// * [formatterSettings] - Settings for the formatter
  /// * [defaultChannelEnabled] - Whether to enable the default console channel
  /// * [useSink] - Whether to use the sink for logging (default: false)
  ///
  /// Example:
  /// ```dart
  /// final logger = Logger(
  ///   environment: 'development',
  ///   formatter: JsonLogFormatter(),
  ///   sinkConfig: LogSinkConfig(batchSize: 50),
  ///   useSink: true,
  /// );
  /// ```
  Logger(
      {LogConfig? config,
      String? environment,
      LogSinkConfig? sinkConfig,
      LogMessageFormatter? formatter,
      FormatterSettings? formatterSettings,
      this.defaultChannelEnabled = true,
      this.useSink = false})
      : _formatter = formatter ?? PlainTextLogFormatter(),
        _environment = environment ?? "production" {
    if (useSink) {
      _logSink = LogSink(
        batchSize: sinkConfig?.batchSize ?? 10,
        autoFlushInterval:
            sinkConfig?.flushInterval ?? const Duration(seconds: 1),
        autoCloseAfter: sinkConfig?.autoFlush == false
            ? Duration.zero
            : const Duration(seconds: 1),
      );
    }
    _registerDefaultDrivers();
    _registerBuiltInFormatters();
    _config = config;
    _loadConfig();
  }

  void _registerBuiltInFormatters() {
    registerFormatter('plain', () => PlainTextLogFormatter());
    registerFormatter('json', () => JsonLogFormatter());
    registerFormatter('pretty', () => PrettyLogFormatter());
    registerFormatter('raw', () => RawLogFormatter());
    registerFormatter('null', () => NullLogFormatter());
    // Register any other built-in or custom formatters here
  }

  /// Sets a listener for log entries. When set, this bypasses the sink
  /// and directly sends logs to the listener.
  ///
  /// Only one listener can be active at a time. Setting a new listener
  /// replaces any existing one.
  Future<void> setListener(LogListener listener) async {
    _listener = listener;
    await _logSink?.close();
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
  /// - [config]: The configuration object containing channel definitions.
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
  /// - [environment]: The environment name to set.
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
  ///
  /// logger.addMiddleware(() => {
  ///   'timestamp': DateTime.now().toIso8601String(),
  ///   'requestId': generateRequestId(),
  ///   'userId': getCurrentUserId()
  /// });
  ///
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
  /// - [middleware]: The middleware instance to add.
  ///
  /// Returns the Logger instance for method chaining.
  ///
  /// Example:
  ///
  /// logger.addLogMiddleware(SensitiveDataFilter());
  ///
  Logger addLogMiddleware(DriverMiddleware middleware) {
    _globalMiddlewares.add(middleware);
    return this;
  }

  /// Adds a middleware specific to a named driver.
  ///
  /// Driver-specific middlewares only affect logs sent to the specified driver type.
  ///
  /// Parameters:
  /// - [driverName]: Name of the driver type to add middleware for.
  /// - [middleware]: The middleware instance to add.
  ///
  /// Returns the Logger instance for method chaining.
  ///
  /// Example:
  ///
  /// logger.addDriverMiddleware('ConsoleLogDriver', CustomMiddleware());
  ///
  Logger addDriverMiddleware(String driverName, DriverMiddleware middleware) {
    _driverMiddlewares.putIfAbsent(driverName, () => []).add(middleware);
    return this;
  }

  /// Adds a new log channel with the specified name, driver, optional formatter, and optional middlewares.
  ///
  /// Creates a new logging channel that can be targeted for log output.
  ///
  /// Parameters:
  /// - [channelName]: Unique name for the channel.
  /// - [driver]: The driver instance to use.
  /// - [formatter]: An optional formatter for this channel.
  /// - [middlewares]: Optional list of middlewares specific to this channel.
  ///
  /// Returns the Logger instance for method chaining.
  Logger addChannel(String channelName, LogDriver driver,
      {LogMessageFormatter? formatter, List<DriverMiddleware>? middlewares}) {
    _channels[channelName] = driver;

    if (formatter != null) {
      _channelFormatters[channelName] = formatter;
    }

    if (middlewares != null) {
      _channelMiddlewares[channelName] = middlewares;
    }

    return this;
  }

  /// Adds a type-specific formatter for custom object logging.
  ///
  /// Allows specialized formatting for specific object types.
  ///
  /// Parameters:
  /// - [formatter]: The type formatter instance to add.
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
  /// - [config]: Configuration map for the driver.
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
  ///
  /// logger.to(['console', 'file']).info('Message');
  ///
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
  /// - 'sample': Sample log driver for testing
  /// - daily: Daily rotating general log files
  /// - webhook: HTTP webhook integration
  /// - stack: In-memory log stack
  // logger.dart
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
              Uri.parse(config['url']),
            ));

    // Register the 'sampling' driver
    _driverFactory.registerDriver('sampling', (config) {
      var rates = config['sample_rates'] as Map<String, dynamic>;
      Map<Level, double> samplingRates = {};
      for (final entry in rates.entries) {
        final level =
            Level.values.where((l) => l.name == entry.key).firstOrNull;
        if (level == null) {
          throw ArgumentError("Invalid log level level: $level");
        }
        samplingRates[level] = entry.value;
      }

      // Create the wrapped driver
      final wrappedDriverConfig = config.dot("wrapped_driver", {});
      if (wrappedDriverConfig == null) {
        throw ArgumentError(
            "Missing 'wrapped_driver' in 'sampling' driver configuration");
      }
      if (!wrappedDriverConfig.containsKey("driver")) {
        throw ArgumentError(
            "Missing 'driver' in 'wrapped_driver' configuration");
      }

      final wrappedDriver = _driverFactory
          .createDriver(wrappedDriverConfig as Map<String, dynamic>);

      // Return the SamplingLogDriver instance
      return SamplingLogDriver(
        wrappedDriver,
        samplingRates: samplingRates,
      );
    });

    _driverFactory.registerDriver('stack', (config) {
      final channelsList = (config['channels'] as List).cast<String>();
      final drivers = channelsList
          .map((name) => _channels[name])
          .whereType<LogDriver>()
          .toList();
      return StackLogDriver(
        drivers,
        ignoreExceptions: config['ignore_exceptions'] ?? false,
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
      defaultChannelEnabled ? addChannel('console', ConsoleLogDriver()) : {};
      return;
    }

    final stackChannels = _config!.channels.keys.where((channelKey) {
      return _config!.channels[channelKey]?.driver == 'stack';
    });

    final otherChannels = _config!.channels.keys.where((channelKey) {
      return !stackChannels.contains(channelKey);
    });

    for (final channelKey in otherChannels) {
      enumerateChannel(channelKey, _config!.channels[channelKey]!);
    }
    for (final channelKey in stackChannels) {
      enumerateChannel(channelKey, _config!.channels[channelKey]!);
    }
  }

  void enumerateChannel(String name, ChannelConfig channelConfig) {
    final mergedConfig = {..._config!.defaults, ...channelConfig.toJson()};
    final channelInfo = {
      'name': name,
      'driver': channelConfig.driver,
      'config': {...mergedConfig, ...channelConfig.config}
    };
    if (channelConfig.env == 'all' || channelConfig.env == _environment) {
      // Create the driver using the driver factory
      final driver = _driverFactory.createDriver(channelInfo);

      // Check if a formatter is specified in the config
      LogMessageFormatter? formatter;
      if (mergedConfig.containsKey('formatter')) {
        final formatterName = mergedConfig['formatter'];
        final formatterBuilder = _formatterFactory[formatterName];
        if (formatterBuilder != null) {
          formatter = formatterBuilder();
        } else {
          throw ArgumentError('Unsupported formatter: $formatterName');
        }
      }

      // Add the driver with the optional formatter
      addChannel(name, driver, formatter: formatter);
    }
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
  ///
  /// await logger.log('error', 'Database connection failed',
  ///   Context({'attempt': 3, 'database': 'users'}));
  ///
  @override
  void log(Level level, dynamic message, [Context? context]) {
    if (level < _minimumLevel) {
      return;
    }

    context ??= Context();
    final combinedContext = Context();
    combinedContext.addAll(_sharedContext.all());
    combinedContext.addAll(context.all());

    for (var middleware in _contextMiddlewares) {
      combinedContext.addAll(middleware());
    }

    final record = LogRecord(
      time: DateTime.now(),
      level: level,
      message: message.toString(),
      context: combinedContext,
      stackTrace: StackTrace.current,
    );

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
        driver.setMiddlewares(_driverMiddlewares, _channelMiddlewares);
      }

      String formattedMessage = _formatRecord(record, channelName);

      processDriverMiddlewares(
        entry: LogEntry(record, formattedMessage),
        driverName: channelName,
        globalMiddlewares: _globalMiddlewares,
        channelMiddlewares: _channelMiddlewares[channelName] ?? [],
        driverMiddlewares:
            _driverMiddlewares[driver.runtimeType.toString()] ?? [],
      ).then((modifiedMessage) async {
        if (modifiedMessage == null) return; // Log has been filtered out

        final logEntry = LogEntry(record, formattedMessage);

        if (_listener != null) {
          _listener!(logEntry);
        } else if (useSink && _logSink != null) {
          await _logSink!.addLog(logEntry, (entry) async {
            await driver.log(entry);
          });
        } else {
          await driver.log(logEntry);
        }
      });
    }

    _targetChannels = null;
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
  /// - [channelName]: The name of the channel being logged to
  ///
  /// Returns the formatted message string.
  String _formatRecord(LogRecord record, String channelName) {
    final formatter = _channelFormatters[channelName] ?? _formatter;
    final typeFormatter = _typeFormatters[record.message.runtimeType];

    if (typeFormatter != null) {
      return typeFormatter.format(record.level, record.message, record.context);
    }

    return formatter.format(record);
  }

  /// Shuts down the logger and flushes any pending logs.
  ///
  /// Ensures all queued logs are written before the application exits.
  /// If using a sink, waits for all pending logs to be processed.
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

    // Only close the sink if it's being used
    if (useSink && _logSink != null) {
      await _logSink!.close();
    }
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
  String format(Level level, Error error, Context context) {
    return '[$level] ${error.toString()} | StackTrace: ${StackTrace.current}';
  }
}
