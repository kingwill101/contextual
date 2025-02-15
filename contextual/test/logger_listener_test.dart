import 'package:contextual/contextual.dart';
import 'package:test/test.dart';

void main() {
  group('Logger with Listener', () {
    test('should use listener and bypass sink', () async {
      final logger = Logger(formatter: RawLogFormatter());
      Level? receivedLevel;
      String? receivedMessage;
      DateTime? receivedTime;

      logger.setListener((entry) {
        receivedLevel = entry.record.level;
        receivedMessage = entry.message;
        receivedTime = entry.record.time;
      });

      logger.info('Test message');

      await Future.delayed(Duration(seconds: 1), () {
        expect(receivedLevel, equals(Level.info));
        expect(receivedMessage, equals('Test message'));
        expect(receivedTime, isNotNull);
      });
    });
  });
}
