import 'package:test/test.dart';
import 'package:contextual/contextual.dart';

void main() {
  group('Logger with Listener', () {
    test('should use listener and bypass sink', () {
      final logger = Logger(formatter: RawLogFormatter());
      Level? receivedLevel;
      String? receivedMessage;
      DateTime? receivedTime;

      logger.setListener((level, message, time) {
        receivedLevel = level;
        receivedMessage = message;
        receivedTime = time;
      });

      logger.info('Test message');

      expect(receivedLevel, equals(Level.info));
      expect(receivedMessage, equals('Test message'));
      expect(receivedTime, isNotNull);
    });
  });
}
