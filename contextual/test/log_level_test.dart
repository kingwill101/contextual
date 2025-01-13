import 'package:test/test.dart';
import 'package:contextual/src/log_level.dart';

void main() {
  group('Level', () {
    test('should contain all log levels', () {
      expect(Level.levels.length, equals(8));
    });
  });
}
