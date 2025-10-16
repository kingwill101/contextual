import 'dart:async';
import 'dart:convert';
import 'package:contextual/contextual.dart';

/// Custom driver that sends logs to a TCP socket
class TcpLogDriver extends LogDriver {
  final String host;
  final int port;
  final Duration? timeout;
  bool _isConnected = false;

  TcpLogDriver(this.host, this.port, {this.timeout}) : super('tcp');

  @override
  Future<void> log(LogEntry entry) async {
    if (!_isConnected) {
      // In a real implementation, establish TCP connection here
      _isConnected = true;
    }

    // Convert entry to JSON for transmission
    final data = jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'level': entry.record.level.toString(),
      'message': entry.message,
      'context': entry.record.context,
    });

    // In a real implementation, send data over TCP socket
    print('TCP Driver would send: $data');
  }
}

/// Custom driver that aggregates logs and sends them in batches
class AggregatingLogDriver extends LogDriver {
  final LogDriver targetDriver;
  final int batchSize;
  final Duration flushInterval;
  final List<LogEntry> _buffer = [];
  Timer? _flushTimer;

  AggregatingLogDriver(
    this.targetDriver, {
    this.batchSize = 10,
    this.flushInterval = const Duration(seconds: 5),
  }) : super('aggregating') {
    _flushTimer = Timer.periodic(flushInterval, (_) => _flush());
  }

  @override
  Future<void> log(LogEntry entry) async {
    _buffer.add(entry);

    if (_buffer.length >= batchSize) {
      await _flush();
    }
  }

  Future<void> _flush() async {
    if (_buffer.isEmpty) return;

    final entries = List<LogEntry>.from(_buffer);
    _buffer.clear();

    // Process each entry in the batch
    for (final entry in entries) {
      await targetDriver.log(entry);
    }
  }

  Future<void> shutdown() async {
    _flushTimer?.cancel();
    await _flush();
  }
}

/// Custom driver that filters logs based on custom rules
class FilteringLogDriver extends LogDriver {
  final LogDriver targetDriver;
  final bool Function(LogEntry entry) filter;

  FilteringLogDriver(this.targetDriver, this.filter) : super('filtering');

  @override
  Future<void> log(LogEntry entry) async {
    if (filter(entry)) {
      await targetDriver.log(entry);
    }
  }
}

/// This example demonstrates how to create and use custom log drivers.
void main() async {
  // Create logger with custom TCP driver
  final tcpLogger = Logger()
    ..addChannel(
      'tcp',
      TcpLogDriver('localhost', 9000),
      formatter: JsonLogFormatter(),
    );

  // Log some messages to TCP
  tcpLogger.info('Connected to TCP server');
  tcpLogger.error(
    'Connection lost',
    Context({'reason': 'timeout', 'attempts': 3}),
  );

  // Create logger with custom aggregating driver
  final aggregatingLogger = Logger()
    ..addChannel(
      'aggregated',
      AggregatingLogDriver(
        ConsoleLogDriver(),
        batchSize: 5,
        flushInterval: Duration(seconds: 2),
      ),
      formatter: PrettyLogFormatter(),
    );

  // Log messages that will be aggregated
  for (var i = 0; i < 10; i++) {
    aggregatingLogger.info('Message $i', Context({'index': i}));
  }

  // Create logger with custom filtering driver
  final filteringLogger = Logger()
    ..addChannel(
      'filtered',
      FilteringLogDriver(ConsoleLogDriver(), (entry) {
        // Only log errors and messages containing 'important'
        return entry.record.level.index >= Level.error.index ||
            entry.message.toLowerCase().contains('important');
      }),
      formatter: PlainTextLogFormatter(),
    );

  // Log messages - some will be filtered out
  filteringLogger.info('Regular message'); // Filtered out
  filteringLogger.info('Important update'); // Logged
  filteringLogger.error('Error message'); // Logged
  filteringLogger.warning('Warning message'); // Filtered out

  // Cleanup
  await tcpLogger.shutdown();
  await aggregatingLogger.shutdown();
  await filteringLogger.shutdown();
}
