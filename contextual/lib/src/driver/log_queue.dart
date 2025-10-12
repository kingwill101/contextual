import 'dart:async';
import 'dart:collection';
import 'package:contextual/src/log_entry.dart';

/// Configuration for a log queue
class LogQueueConfig {
  /// How often to flush the queue
  final Duration flushInterval;

  const LogQueueConfig({
    this.flushInterval = const Duration(milliseconds: 500),
  });
}

/// A queue for processing log messages with periodic flushing
class LogQueue {
  /// Queue configuration
  final LogQueueConfig config;

  /// Queue for pending log messages
  final Queue<LogEntry> _messageQueue = Queue<LogEntry>();

  /// Timer for flushing the queue
  Timer? _flushTimer;

  /// Whether the queue is currently processing messages
  bool _isProcessing = false;

  /// Whether the queue has been shut down
  bool _isShutdown = false;

  /// The function used to process batches of messages
  final Future<void> Function(List<LogEntry>) _processor;

  /// Creates a new log queue with the given configuration and processor
  LogQueue({
    required Future<void> Function(List<LogEntry>) processor,
    LogQueueConfig? config,
  })  : config = config ?? const LogQueueConfig(),
        _processor = processor {
    _initialize();
  }

  void _initialize() {
    // Set up periodic queue processing
    _flushTimer = Timer.periodic(config.flushInterval, (_) => flush());
  }

  /// Adds a message to the queue
  void add(LogEntry entry) {
    if (_isShutdown) {
      print("Warning: Attempting to add message to shutdown queue");
      return;
    }

    _messageQueue.add(entry);
  }

  /// Processes the queue using the stored processor function
  Future<void> flush() async {
    if (_isProcessing || _messageQueue.isEmpty || _isShutdown) return;

    _isProcessing = true;
    try {
      final messages = <LogEntry>[];
      while (_messageQueue.isNotEmpty) {
        messages.add(_messageQueue.removeFirst());
      }

      if (messages.isNotEmpty) {
        await _processor(messages);
      }
    } catch (e) {
      print('Failed to process messages: $e');
      // If processing fails, try to requeue the messages
      for (final message in _messageQueue) {
        _messageQueue.addFirst(message);
      }
    } finally {
      _isProcessing = false;
    }
  }

  /// Shuts down the queue and processes any remaining messages
  Future<void> shutdown() async {
    _isShutdown = true;
    _flushTimer?.cancel();
    _flushTimer = null;

    // Process any remaining messages
    await flush();
  }
}
