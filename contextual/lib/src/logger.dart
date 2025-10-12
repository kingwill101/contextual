import 'dart:async';

import 'package:contextual/src/driver/sample.dart';
import 'package:contextual/src/format/null.dart';
import 'package:contextual/src/log_entry.dart';
import 'package:contextual/src/record.dart';
import 'package:contextual/src/types.dart';


import 'abstract_logger.dart';
import 'channel.dart';

import 'context.dart';
import 'context_middleware.dart';
import 'driver/console.dart';
import 'driver/daily.dart';
import 'driver/driver.dart';
import 'driver/stack.dart';
import 'driver/webhook.dart';
import 'format/formatter_settings.dart';
import 'format/json.dart';

import 'typed/typed_channel.dart' as typed_channels;
import 'typed/log_config.dart' show TypedLogConfig;
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
  final List<Channel<LogDriver>> _channels = [];

  

  /// Global middlewares applied to all drivers.
  /// These run before any driver-specific middlewares.
  final List<DriverMiddleware> _globalMiddlewares = [];
  /// Driver-specific middlewares mapped by driver type.
  final Map<Type, List<DriverMiddleware>> _driverTypeMiddlewares = {};


  /// Middleware for modifying context data.
  /// Executed before each log operation to enrich context.
  final List<ContextMiddleware> _contextMiddlewares = [];

  /// How log messages are converted to strings.
  LogMessageFormatter _formatter;

  /// Shared context that applies to all log entries.
  /// Maintains application-wide contextual information.
  final Context _sharedContext = Context();

  // Legacy driver factory removed in v2 (typed configuration path).

  /// Type-specific formatters for custom log message formatting.
  /// Enables specialized formatting for different object types.
  final Map<Type, LogTypeFormatter> _typeFormatters = {};


  /// Current environment (e.g., development, production). Used for typed config.
  // ignore: unused_field
  String _environment = 'production';

  /// Currently targeted channels for logging.
  /// Used for temporary channel selection in logging operations.
  Set<String>? _targetChannels;

  

  /// Map to store registered formatter builders.
  final Map<String, LogMessageFormatterBuilder> _formatterFactory = {};

  /// The minimum log level to process. Messages below this level are ignored.
  Level _minimumLevel = Level.debug;

  /// Indicates whether the default `console` channel is enabled.
  final bool defaultChannelEnabled;

  // Registry keyed by driver type and optional name for O(1) type-based selection
  final Map<Type, Map<String?, String>> _typeRegistry = {};

  final StreamController<LogEntry> _logController =
      StreamController<LogEntry>.broadcast();

  /// Exposes a broadcast stream of log entries.
  Stream<LogEntry> get onRecord => _logController.stream;

  /// The isolate-based log sink for batching logs (if enabled).
  Sink? _logSink;

  /// Whether to use isolate-based sink mode
  final bool _useIsolateSink;

  /// Configuration for the log sink
  final LogSinkConfig? _sinkConfig;

  /// Enables centralized batching for driver dispatch using LogSink.
  /// Returns this logger for chaining.
  Future<Logger> enableDriverBatching({LogSinkConfig? config}) async {
    _logSink ??= LogSink(config: config ?? _sinkConfig);
    return this;
  }

  /// Disables centralized batching and flushes any pending logs.
  /// Returns this logger for chaining.
  Future<Logger> disableDriverBatching() async {
    if (_logSink != null) {
      final sink = _logSink;
      _logSink = null;
      await sink!.close();
    }
    return this;
  }

  /// Creates a new logger with default settings.
  ///
  /// This is a convenience constructor that internally uses [create].
  /// For more control over the logger configuration, use [create] directly.
  factory Logger({
    String? environment,
    LogMessageFormatter? formatter,
    FormatterSettings? formatterSettings,
    bool defaultChannelEnabled = true,
  }) =>
      Logger._(
        environment: environment,
        formatter: formatter,
        formatterSettings: formatterSettings,
        defaultChannelEnabled: defaultChannelEnabled,
        useIsolate: false,
        useIsolateSink: false,
        sinkConfig: null,
      );

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
  /// * [formatter] - Message formatter (default: PlainTextLogFormatter)
  /// * [formatterSettings] - Settings for the formatter
  /// * [defaultChannelEnabled] - Whether to enable the default console channel
  /// * [useIsolate] - Whether to enable isolate-based processing (deprecated, use useIsolateSink)
  /// * [useIsolateSink] - Whether to enable isolate-based sink mode
  /// * [sinkConfig] - Configuration for the log sink when using isolate processing
  ///
  /// Example:
  /// ```dart
  /// final logger = await Logger.create(
  ///   environment: 'development',
  ///   formatter: JsonLogFormatter(),
  ///   defaultChannelEnabled: true,
  ///   useIsolateSink: true,
  ///   sinkConfig: LogSinkConfig(
  ///     batchSize: 50,
  ///     flushInterval: Duration(seconds: 5),
  ///     autoFlush: true,
  ///   ),
  /// );
  /// ```
  static Future<Logger> create({
    TypedLogConfig? typedConfig,
    String? environment,
    LogMessageFormatter? formatter,
    FormatterSettings? formatterSettings,
    bool defaultChannelEnabled = true,
    bool useIsolate = false,
    bool useIsolateSink = false,
    LogSinkConfig? sinkConfig,
  }) async {
    final logger = Logger._(
      environment: environment,
      formatter: formatter,
      formatterSettings: formatterSettings,
      defaultChannelEnabled: defaultChannelEnabled,
      useIsolate: useIsolate,
      useIsolateSink: useIsolateSink,
      sinkConfig: sinkConfig,
    );
    await logger._initialize();

    if (typedConfig != null) {
      logger.typedConfig(typedConfig);
      if (typedConfig.batching?.enabled == true) {
        await logger.enableDriverBatching(
          config: LogSinkConfig(
            batchSize: typedConfig.batching!.batchSize,
            flushInterval: typedConfig.batching!.flushInterval,
            autoFlush: true,
            maxRetries: 3,
            autoCloseAfter: typedConfig.batching!.autoCloseAfter,
          ),
        );
      }
    }

    return logger;
  }

  Logger._({
    String? environment,
    LogMessageFormatter? formatter,
    FormatterSettings? formatterSettings,
    required this.defaultChannelEnabled,
    required bool useIsolate,
    required bool useIsolateSink,
    LogSinkConfig? sinkConfig,
  })  : _formatter = formatter ?? PlainTextLogFormatter(),
        _environment = environment ?? "production",
        _useIsolateSink = useIsolateSink,
        _sinkConfig = sinkConfig {
    _registerDefaultDrivers();
    _registerBuiltInFormatters();
  }


  Future<void> _initialize() async {
    if (_useIsolateSink) {
      _logSink = LogSink(
        config: _sinkConfig,
      );
    } else {
      _logSink = null;
    }
  }

  void _registerBuiltInFormatters() {
    registerFormatter('plain', () => PlainTextLogFormatter());
    registerFormatter('json', () => JsonLogFormatter());
    registerFormatter('pretty', () => PrettyLogFormatter());
    registerFormatter('raw', () => RawLogFormatter());
    registerFormatter('null', () => NullLogFormatter());
    // Register any other built-in or custom formatters here
  }

  /// Legacy config removed in v2. Use typedConfig(TypedLogConfig) instead.
  @Deprecated('Removed in v2. Use typedConfig(TypedLogConfig) instead.')
  Logger legacyConfig(dynamic _) {
    return this;
  }

  // Overload: accept typed.LogConfig and enumerate typed channels directly
  Logger typedConfig(TypedLogConfig config) {
    // Clear existing
    _channels.clear();
    // Apply environment
    _environment = config.environment;
    // Level
    if (config.level != null) {
      final level = Level.values.firstWhere((l) => l.name == config.level,
          orElse: () => Level.debug);
      setLevel(level);
    }
    // Channels
    for (final ch in config.channels) {
      if (ch is typed_channels.ConsoleChannel) {
        addChannel(ch.name ?? 'console', ConsoleLogDriver(),
            formatter: ch.formatter);
      } else if (ch is typed_channels.DailyFileChannel) {
      } else if (ch is typed_channels.DailyFileChannel) {
        addChannel(
            ch.name ?? 'daily',
            DailyFileLogDriver.fromOptions(ch.options),
            formatter: ch.formatter);
      } else if (ch is typed_channels.StackChannel) {
        // Resolve channel names to existing drivers for the stack
        final drivers = ch.options.channels
            .map((n) => _channels.firstWhere(
                  (c) => c.name == n,
                  orElse: () => Channel(name: n, driver: ConsoleLogDriver()),
                ).driver)
            .whereType<LogDriver>()
            .toList();
        addChannel(
          ch.name ?? 'stack',
          StackLogDriver.fromOptions(drivers, ignoreExceptions: ch.options.ignoreExceptions),
          formatter: ch.formatter,
        );
      } else if (ch is typed_channels.SamplingChannel) {
        final wrapped = _channels.firstWhere(
          (c) => c.name == ch.options.wrappedChannel,
          orElse: () => Channel(name: ch.options.wrappedChannel, driver: ConsoleLogDriver()),
        ).driver;
        {
          addChannel(
            ch.name ?? 'sampling',
            SamplingLogDriver.fromOptions(wrapped, ch.options.rates),
            formatter: ch.formatter,
          );
        }
      } else if (ch is typed_channels.WebhookChannel) {
        addChannel(
            ch.name ?? 'webhook',
            WebhookLogDriver.fromOptions(ch.options),
            formatter: ch.formatter);
      }
    }
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
  void _registerType(String channelName, LogDriver driver) {
    final t = driver.runtimeType;
    final byName = _typeRegistry.putIfAbsent(t, () => {});
    byName[channelName] = channelName;
  }

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

  /// Adds a middleware specific to a driver type.
  ///
  /// Example:
  ///
  /// Example: logger.addDriverMiddleware&lt;ConsoleLogDriver&gt;(CustomMiddleware());
  ///
  /// Prefer this typed method over string-based registration.
  Logger addDriverMiddleware<T extends LogDriver>(
      DriverMiddleware middleware) {
    _driverTypeMiddlewares.putIfAbsent(T, () => []).add(middleware);
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
    _channels.removeWhere((c) => c.name == channelName);
    _channels.add(Channel<LogDriver>(
      name: channelName,
      driver: driver,
      formatter: formatter,
      middlewares: middlewares ?? const [],
    ));
    _registerType(channelName, driver);

    // formatter and middlewares are stored in the Channel object now

    return this;
  }

  /// Adds a type-specific formatter for custom object logging.
  ///
  /// Allows specialized formatting for specific object types.

  /// Utility: check if a channel exists by name.
  bool hasChannel(String name) => _channels.any((c) => c.name == name);

  /// Utility: get a channel by name (null if missing).
  Channel<LogDriver>? getChannel(String name) =>
      _channels.cast<Channel<LogDriver>?>().firstWhere(
            (c) => c?.name == name,
            orElse: () => null,
          );

  /// Utility: remove a channel by name. Returns true if removed.
  bool removeChannel(String name) {
    final before = _channels.length;
    _channels.removeWhere((c) => c.name == name);
    return _channels.length < before;
  }

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
    // Legacy path removed; default to console driver for safety in v2
    return ConsoleLogDriver();
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
  /// logger['console'].info('Message');
  /// logger['file'].info('Message');
  ///
  Logger operator [](String channelName) {
    _targetChannels = {channelName};
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
  void _registerDefaultDrivers() {}


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

    final selectedChannels = _targetChannels ?? _channels.map((c) => c.name).toSet();
    final uniqueDrivers = <String, Channel<LogDriver>>{};

    for (final channel in selectedChannels) {
      final channelObj = _channels.firstWhere(
        (c) => c.name == channel,
        orElse: () => Channel(name: channel, driver: ConsoleLogDriver()),
      );
      uniqueDrivers[channel] = channelObj;
    }

    // Create the log entry for stream subscribers
    final streamEntry = LogEntry(record, _formatRecord(record, 'default'));

    // Process stream entry through global middleware
    if (!_logController.isClosed) {
      processDriverMiddlewares(
        entry: streamEntry,
        globalMiddlewares: _globalMiddlewares,
      ).then((processedStreamEntry) {
        if (processedStreamEntry != null) {
          if (_logSink != null) {
            _logSink!.addLog(processedStreamEntry, (logEntry) async {
              if (!_logController.isClosed) {
                _logController.add(logEntry);
              }
            });
          } else {
            if (!_logController.isClosed) {
              _logController.add(processedStreamEntry);
            }
          }
        }
      });
    }

    // Process for each driver
    for (final entry in uniqueDrivers.entries) {
      final channelName = entry.key;
      final driver = entry.value.driver;

      // Middleware maps removed in v2; pipeline centralized in Logger

      String formattedMessage = _formatRecord(record, channelName);

      final typeMws = _driverTypeMiddlewares[driver.runtimeType] ?? const <DriverMiddleware>[];
      final combinedMws = <DriverMiddleware>[...typeMws];

      processDriverMiddlewares(
        entry: LogEntry(record, formattedMessage),
        globalMiddlewares: _globalMiddlewares,
        channelMiddlewares: _channels.firstWhere((c) => c.name == channelName, orElse: () => Channel(name: channelName, driver: ConsoleLogDriver())).middlewares,
        driverMiddlewares: combinedMws,
      ).then((modifiedEntry) async {
        if (modifiedEntry == null) return; // Log has been filtered out

        if (_logSink != null) {
          await _logSink!.addLog(modifiedEntry, (entry) async {
            await driver.log(entry);
          });
        } else {
          await driver.log(modifiedEntry);
        }
      });
    }
    _targetChannels = null;
  }

  // Type-based selection using registry
  Logger forDriver<T extends LogDriver>({String? name}) {
    final map = _typeRegistry[T];
    if (map == null || map.isEmpty) return this;
    if (name != null) {
      final channel = map[name];
      if (channel != null) {
        _targetChannels = {channel};
      }
      return this;
    }
    _targetChannels = map.values.toSet();
    return this;
  }

  Logger forDrivers(Iterable<Type> types) {
    final selected = <String>{};
    for (final t in types) {
      final map = _typeRegistry[t];
      if (map != null) selected.addAll(map.values);
    }
    if (selected.isNotEmpty) {
      _targetChannels = selected;
    }
    return this;
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
    final channel = _channels.firstWhere((c) => c.name == channelName, orElse: () => Channel(name: channelName, driver: ConsoleLogDriver()));
    final formatter = channel.formatter ?? _formatter;
    final typeFormatter = _typeFormatters[record.message.runtimeType];

    if (typeFormatter != null) {
      return typeFormatter.format(record.level, record.message, record.context);
    }

    return formatter.format(record);
  }

  /// Shuts down the logger and all its drivers.
  ///
  /// This method:
  /// 1. Notifies all drivers to begin shutdown
  /// 2. Waits for all drivers to complete their shutdown
  /// 3. Closes the log controller and sink
  ///
  /// Returns a Future that completes when all cleanup is done.
  Future<void> shutdown() async {
    // Notify all drivers to begin shutdown
    final shutdownFutures =
        _channels.map((channel) => channel.driver.notifyShutdown());

    // Wait for all drivers to complete shutdown
    await Future.wait(shutdownFutures);

    // Clean up logger resources
    if (_logSink != null) {
      final sink = _logSink;
      _logSink = null;
      await sink!.close();
    }

    await _logController.close();
  }

  /// Sets a listener for log entries.
  ///
  /// This is the legacy way to listen for log entries. For new code, prefer using
  /// the [onRecord] stream.
  ///
  /// The listener will be called for each log entry that passes the minimum level
  /// filter.
  void setListener(LogListener listener) {
    onRecord.listen(listener);
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
