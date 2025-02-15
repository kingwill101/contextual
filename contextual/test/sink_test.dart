import 'dart:async';
import 'package:test/test.dart';
import 'package:contextual/contextual.dart';

void main() {
  group('Logger Sink Tests', () {
    late Logger sinkLogger;
    late Logger nonSinkLogger;
    List<String> loggedMessages = [];
    late Completer<void> logCompleter;
    late int expectedMessageCount;

    setUp(() {
      loggedMessages = [];
      logCompleter = Completer<void>();
      expectedMessageCount = 0;

      // Create a test driver that captures messages
      final testDriver = TestLogDriver(
        onLog: (entry) async {
          loggedMessages.add(entry.message);
          if (loggedMessages.length >= expectedMessageCount &&
              !logCompleter.isCompleted) {
            logCompleter.complete();
          }
        },
      );

      // Create a sink logger with batching
      sinkLogger = Logger(
        sinkConfig: LogSinkConfig(
          batchSize: 3,
          flushInterval: Duration(milliseconds: 100),
          autoFlush: true,
        ),
      )..addChannel('sink', testDriver);

      // Create a non-sink logger for immediate logging
      nonSinkLogger = Logger()..addChannel('immediate', testDriver);
    });

    test('Sink logger batches non-critical messages', () async {
      expectedMessageCount = 3;

      // Log multiple messages
      sinkLogger.info('Info 1');
      sinkLogger.debug('Debug 1');

      // Wait a bit - messages should not be logged yet due to batching
      await Future.delayed(Duration(milliseconds: 50));

      // Add third message to trigger batch size flush
      sinkLogger.warning('Warning 1');

      // Wait for flush and message processing
      await Future.delayed(Duration(milliseconds: 150));
      await logCompleter.future;

      expect(loggedMessages, hasLength(3));
      expect(
          loggedMessages,
          containsAll([
            contains('Info 1'),
            contains('Debug 1'),
            contains('Warning 1'),
          ]));
    });

    test('Sink logger immediately flushes critical messages', () async {
      expectedMessageCount = 2;

      // Log a regular message
      sinkLogger.info('Info message');

      // Log emergency message - should flush immediately
      sinkLogger.emergency('Emergency message');

      // Wait for message processing
      await Future.delayed(Duration(milliseconds: 50));
      await logCompleter.future;

      expect(loggedMessages, hasLength(2));
      expect(
          loggedMessages,
          containsAll([
            contains('Info message'),
            contains('Emergency message'),
          ]));
    });

    test('Non-sink logger logs messages immediately', () async {
      expectedMessageCount = 2;

      // Log messages
      nonSinkLogger.info('Immediate info');
      nonSinkLogger.debug('Immediate debug');

      // Wait for message processing
      await Future.delayed(Duration(milliseconds: 50));
      await logCompleter.future;

      expect(loggedMessages, hasLength(2));
      expect(
          loggedMessages,
          containsAll([
            contains('Immediate info'),
            contains('Immediate debug'),
          ]));
    });

    test('Sink logger auto-flushes after interval', () async {
      expectedMessageCount = 2;

      // Log messages
      sinkLogger.info('Auto-flush 1');
      sinkLogger.debug('Auto-flush 2');

      // Wait for auto-flush interval and message processing
      await Future.delayed(Duration(milliseconds: 150));
      await logCompleter.future;

      expect(loggedMessages, hasLength(2));
      expect(
          loggedMessages,
          containsAll([
            contains('Auto-flush 1'),
            contains('Auto-flush 2'),
          ]));
    });

    tearDown(() async {
      // Clean up loggers
      await sinkLogger.shutdown();
      await nonSinkLogger.shutdown();
    });
  });
}

/// A test log driver that captures log messages
class TestLogDriver extends LogDriver {
  final Future<void> Function(LogEntry entry) onLog;

  TestLogDriver({required this.onLog}) : super('test');

  @override
  Future<void> log(LogEntry entry) => onLog(entry);
}
