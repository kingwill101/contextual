import 'package:test/test.dart';
import 'package:contextual/src/log_level.dart';

void main() {
  group('LogLevel', () {
    test('should contain all log levels', () {
      expect(LogLevel.levels.length, equals(8));
      expect(LogLevel.contains('info'), isTrue);
      expect(LogLevel.contains('invalid'), isFalse);
    });

    test('should have correct values', () {
      expect(LogLevel.info.value, equals('info'));
      expect(LogLevel.error.value, equals('error'));
    });
  });
}
