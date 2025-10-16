import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:contextual/src/driver/driver.dart';
import 'package:contextual/src/driver/log_queue.dart';
import 'package:contextual/src/log_entry.dart';
import '../typed/daily_file_options.dart';

/// A [LogDriver] that writes log messages to daily rotating log files.
///
/// This driver creates a new log file each day and automatically manages log file
/// retention. Log files are named using the pattern `{baseFilePath}-YYYY-MM-DD.log`.
///
/// Features:
/// * Daily log file rotation
/// * Automatic cleanup of old log files
/// * Configurable retention period
/// * Creates log directories if they don't exist
/// * Message queuing with periodic batch writes
/// * Automatic file cleanup
/// * Optional isolate-optimized mode
///
/// Example:
/// ```dart
/// // Standard file driver
/// final driver = DailyFileLogDriver(
///   'logs/app',
///   retentionDays: 30,
///   flushInterval: Duration(seconds: 1),
/// );
///
/// // Isolate-optimized driver
/// final isoDriver = DailyFileLogDriver.withIsolateOptimization(
///   'logs/app',
///   retentionDays: 30,
///   flushInterval: Duration(seconds: 1),
/// );
///
/// // Using configuration
/// final configDriver = DailyFileLogDriver.fromConfig({
///   'path': 'logs/app',
///   'days': 30,
///   'flush_interval': 1000,
///   'use_isolate': true
/// });
/// ```
///
/// The above example creates log files like:
/// * logs/app-2024-02-15.log
/// * logs/app-2024-02-14.log
/// * etc.
abstract class DailyFileLogDriver extends LogDriver {
  final String baseFilePath;
  final int retentionDays;
  final Duration flushInterval;
  late final LogQueue _logQueue;
  Timer? _cleanupTimer;
  String? _currentFilePath;
  File? _currentFile;
  DateTime? _currentDay;
  IOSink? _currentSink;

  factory DailyFileLogDriver(
    String baseFilePath, {
    int? retentionDays,
    Duration? flushInterval,
  }) = StandardDailyFileLogDriver;

  factory DailyFileLogDriver.withIsolateOptimization(
    String baseFilePath, {
    int? retentionDays,
    Duration? flushInterval,
  }) = IsolateDailyFileLogDriver;

  /// Typed options constructor for v2
  factory DailyFileLogDriver.fromOptions(
    DailyFileOptions options, {
    bool useIsolate = false,
  }) {
    return useIsolate
        ? DailyFileLogDriver.withIsolateOptimization(
            options.path,
            retentionDays: options.retentionDays,
            flushInterval: options.flushInterval,
          )
        : DailyFileLogDriver(
            options.path,
            retentionDays: options.retentionDays,
            flushInterval: options.flushInterval,
          );
  }

  /// Protected constructor for implementations
  DailyFileLogDriver._(
    this.baseFilePath, {
    required this.retentionDays,
    required this.flushInterval,
  }) : super("file") {
    _logQueue = LogQueue(
      config: LogQueueConfig(flushInterval: flushInterval),
      processor: processLogEntries,
    );
    _initialize();
  }

  void _initialize() {
    // Set up periodic cleanup
    _cleanupTimer = Timer.periodic(Duration(hours: 1), (_) {
      _cleanupOldFiles();
    });
  }

  /// Removes log files that are older than [retentionDays].
  void _cleanupOldFiles() {
    final logDir = File(baseFilePath).parent;
    if (!logDir.existsSync()) return;

    final now = DateTime.now();
    final files = logDir.listSync().whereType<File>();

    for (final file in files) {
      final filename = file.path.split(Platform.pathSeparator).last;
      final regex = RegExp(r'^(.+)-(\d{4}-\d{2}-\d{2})\.log$');
      final match = regex.firstMatch(filename);

      if (match != null) {
        final datePart = match.group(2);
        if (datePart != null) {
          final fileDate = DateTime.tryParse(datePart);
          if (fileDate != null) {
            final difference = now.difference(fileDate).inDays;
            if (difference >= retentionDays) {
              try {
                file.deleteSync();
              } catch (e) {
                // Silently ignore deletion errors
              }
            }
          }
        }
      }
    }
  }

  /// Gets the current file path based on the date
  String _getCurrentFilePath() {
    final now = DateTime.now();
    final dateSuffix = now.toIso8601String().split('T').first;
    return '$baseFilePath-$dateSuffix.log';
  }

  /// Checks if we need to rotate to a new file
  bool _shouldRotateFile() {
    if (_currentDay == null || _currentFilePath == null) return true;

    final now = DateTime.now();
    return now.year != _currentDay!.year ||
        now.month != _currentDay!.month ||
        now.day != _currentDay!.day;
  }

  @override
  Future<void> log(LogEntry entry) async {
    if (isShuttingDown) {
      print("Warning: Attempting to log while driver is shutting down");
      return;
    }

    _logQueue.add(entry);
  }

  /// Ensures the current sink is ready for writing
  void _ensureCurrentSink() {
    final filePath = _getCurrentFilePath();
    if (_currentFilePath != filePath || _shouldRotateFile()) {
      _currentSink?.close();
      _currentSink = null;
      _currentFile = File(filePath);
      if (!_currentFile!.existsSync()) {
        _currentFile!.createSync(recursive: true);
      }
      _currentFilePath = filePath;
      _currentDay = DateTime.now();
      _currentSink = _currentFile!.openWrite(mode: FileMode.append);
    }
  }

  /// Write the entries to the file - implemented by subclasses
  Future<void> writeEntries(List<LogEntry> entries);

  Future<void> processLogEntries(List<LogEntry> entries) async {
    _ensureCurrentSink();
    await writeEntries(entries);
  }

  @override
  Future<void> performShutdown() async {
    _cleanupTimer?.cancel();
    await _logQueue.shutdown();
    await _currentSink?.flush();
    await _currentSink?.close();
    _currentSink = null;
  }
}

/// Standard implementation of [DailyFileLogDriver] using direct file writes
class StandardDailyFileLogDriver extends DailyFileLogDriver {
  StandardDailyFileLogDriver(
    super.baseFilePath, {
    int? retentionDays,
    Duration? flushInterval,
  }) : super._(
         retentionDays: retentionDays ?? 14,
         flushInterval: flushInterval ?? const Duration(milliseconds: 500),
       );

  @override
  Future<void> writeEntries(List<LogEntry> entries) async {
    final messages = entries.map((e) => e.message).join('\n');
    _currentSink!.writeln(messages);
    await _currentSink!.flush();
  }
}

/// Isolate-optimized implementation of [DailyFileLogDriver] using IOSink
class IsolateDailyFileLogDriver extends DailyFileLogDriver {
  Isolate? _isolate;
  SendPort? _sendPort;
  ReceivePort? _receivePort;

  IsolateDailyFileLogDriver(
    super.baseFilePath, {
    int? retentionDays,
    Duration? flushInterval,
  }) : super._(
         retentionDays: retentionDays ?? 14,
         flushInterval: flushInterval ?? const Duration(milliseconds: 500),
       ) {
    _initializeIsolate();
  }

  Future<void> _initializeIsolate() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      _isolateFunction,
      _IsolateSetup(
        _receivePort!.sendPort,
        baseFilePath,
        retentionDays,
        flushInterval,
      ),
    );

    // Wait for the isolate to send its SendPort
    _sendPort = await _receivePort!.first as SendPort;
  }

  @override
  Future<void> writeEntries(List<LogEntry> entries) async {
    if (_sendPort == null) {
      // Fall back to standard processing if isolate isn't ready
      for (final entry in entries) {
        _currentSink!.writeln(entry.message);
      }
      await _currentSink!.flush();
      return;
    }

    // Send the entries to the isolate
    _sendPort!.send(entries);
  }

  @override
  Future<void> performShutdown() async {
    await super.performShutdown();
    _isolate?.kill();
    _receivePort?.close();
    _isolate = null;
    _sendPort = null;
    _receivePort = null;
  }

  /// The isolate entry point function
  static void _isolateFunction(_IsolateSetup setup) {
    final receivePort = ReceivePort();
    setup.sendPort.send(receivePort.sendPort);

    File? currentFile;
    IOSink? currentSink;
    String? currentFilePath;
    DateTime? currentDay;

    String getCurrentFilePath(String baseFilePath) {
      final now = DateTime.now();
      final dateSuffix = now.toIso8601String().split('T').first;
      return '$baseFilePath-$dateSuffix.log';
    }

    bool shouldRotateFile(DateTime? currentDay) {
      if (currentDay == null) return true;
      final now = DateTime.now();
      return now.year != currentDay.year ||
          now.month != currentDay.month ||
          now.day != currentDay.day;
    }

    void ensureCurrentSink(String baseFilePath) {
      final filePath = getCurrentFilePath(baseFilePath);
      if (currentFilePath != filePath || shouldRotateFile(currentDay)) {
        currentSink?.close();
        currentSink = null;
        currentFile = File(filePath);
        if (!currentFile!.existsSync()) {
          currentFile!.createSync(recursive: true);
        }
        currentFilePath = filePath;
        currentDay = DateTime.now();
        currentSink = currentFile!.openWrite(mode: FileMode.append);
      }
    }

    // Listen for log entries
    receivePort.listen((message) {
      if (message is List<LogEntry>) {
        ensureCurrentSink(setup.baseFilePath);
        for (final entry in message) {
          currentSink!.writeln(entry.message);
        }
        currentSink!.flush();
      }
    });

    // Set up periodic cleanup
    Timer.periodic(Duration(hours: 1), (_) {
      final logDir = File(setup.baseFilePath).parent;
      if (!logDir.existsSync()) return;

      final now = DateTime.now();
      final files = logDir.listSync().whereType<File>();

      for (final file in files) {
        final filename = file.path.split(Platform.pathSeparator).last;
        final regex = RegExp(r'^(.+)-(\d{4}-\d{2}-\d{2})\.log$');
        final match = regex.firstMatch(filename);

        if (match != null) {
          final datePart = match.group(2);
          if (datePart != null) {
            final fileDate = DateTime.tryParse(datePart);
            if (fileDate != null) {
              final difference = now.difference(fileDate).inDays;
              if (difference >= setup.retentionDays) {
                try {
                  file.deleteSync();
                } catch (e) {
                  // Silently ignore deletion errors
                }
              }
            }
          }
        }
      }
    });
  }
}

/// Configuration data for the isolate
class _IsolateSetup {
  final SendPort sendPort;
  final String baseFilePath;
  final int retentionDays;
  final Duration flushInterval;

  _IsolateSetup(
    this.sendPort,
    this.baseFilePath,
    this.retentionDays,
    this.flushInterval,
  );
}
