import 'package:test/test.dart';
import 'package:contextual/src/sink.dart';

void main() {
  group('LogSink Configuration', () {
    test('should respect batchSize', () async {
      final sink = LogSink(batchSize: 2);
      int logCount = 0;

      await sink.addLog('INFO', () async {
        logCount++;
      });

      expect(logCount, equals(0)); // Not flushed yet

      await sink.addLog('INFO', () async {
        logCount++;
      });

      expect(logCount, equals(2)); // Flushed after second log
    });

    test('should respect flushInterval', () async {
      final sink = LogSink(autoFlushInterval: Duration(milliseconds: 100));
      int logCount = 0;

      await sink.addLog('INFO', () async {
        logCount++;
      });

      await Future.delayed(Duration(milliseconds: 150));
      expect(logCount, equals(1)); // Flushed after interval
    });
  });
}
