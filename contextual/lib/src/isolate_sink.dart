import 'dart:async';
import 'dart:isolate';

import 'package:contextual/src/sink.dart';

import 'log_entry.dart';
import 'log_level.dart';

/// An isolate-based log sink that batches log entries and processes them in a separate isolate.
///
/// This class accumulates log entries into a batch and, when the batch size or flush interval is reached,
/// sends the batch to a dedicated isolate for asynchronous processing. An auto‑shutdown timer will close
/// the sink after a period of inactivity.
///
/// Example usage:
/// ```dart
/// // Define a top-level processor function (must be top-level or static)
/// Future<void> processBatch(List<LogEntry> batch) async {
///   for (var entry in batch) {
///     // Replace this with real processing logic (e.g. write to file, send to server, etc.)
///     print('Processing: ${entry.message}');
///   }
/// }
///
/// final sink = IsolateLogSink(
///   batchSize: 5,
///   autoFlushInterval: Duration(seconds: 2),
///   autoCloseAfter: Duration(seconds: 10),
///   processor: processBatch,
/// );
/// await sink.start();
/// sink.addLog(myLogEntry, myCallback);
/// // When finished with logging:
/// await sink.close();
/// ```
class IsolateLogSink implements Sink {
  @override
  final int batchSize;

  @override
  final Duration autoFlushInterval;

  @override
  final Duration autoCloseAfter;

  final LogBatchProcessor processor;

  final List<LogEntry> _batch = [];
  Isolate? _isolate;
  SendPort? _sendPort;
  late ReceivePort _receivePort;
  Timer? _flushTimer;
  Timer? _autoCloseTimer;
  bool _isFlushing = false;

  IsolateLogSink({required this.processor, LogSinkConfig? config})
    : batchSize = config?.batchSize ?? 10,
      autoFlushInterval = config?.flushInterval ?? const Duration(seconds: 1),
      autoCloseAfter = const Duration(seconds: 5);

  /// Starts the isolate and initializes the sink.
  ///
  /// This must be called before any logs can be processed.
  Future<void> start() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_isolateFunction, _receivePort.sendPort);

    // Wait for the isolate to send its SendPort
    _sendPort = await _receivePort.first as SendPort;
    _startFlushTimer();
  }

  @override
  Future<void> addLog(LogEntry entry, LogCallback logCallback) async {
    if (_sendPort == null) {
      throw StateError('IsolateLogSink not started. Call start() first.');
    }

    _batch.add(entry);
    _resetAutoCloseTimer();

    if (entry.record.level == Level.emergency ||
        entry.record.level == Level.critical ||
        _batch.length >= batchSize) {
      await _flushBatch();
    }
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(autoFlushInterval, (_) => _flushBatch());
  }

  void _resetAutoCloseTimer() {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(autoCloseAfter, () => close());
  }

  Future<void> _flushBatch() async {
    if (_isFlushing || _batch.isEmpty || _sendPort == null) return;

    _isFlushing = true;
    try {
      final batchToProcess = List<LogEntry>.from(_batch);
      _batch.clear();
      await processor(batchToProcess);
    } finally {
      _isFlushing = false;
    }
  }

  @override
  Future<void> close() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;

    await _flushBatch();

    _isolate?.kill();
    _isolate = null;
    _sendPort = null;
    _receivePort.close();
  }

  /// The isolate entry point function.
  static void _isolateFunction(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      if (message is List<LogEntry>) {
        // Process the batch of log entries
        // Implementation depends on your needs
      }
    });
  }
}
