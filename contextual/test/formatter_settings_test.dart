import 'package:intl/intl.dart';
import 'package:test/test.dart';
import 'package:contextual/src/format/formatter_settings.dart';

void main() {
  group('FormatterSettings', () {
    test('should have default settings', () {
      final settings = FormatterSettings();
      expect(settings.includeTimestamp, isTrue);
      expect(settings.includeLevel, isTrue);
      expect(settings.includePrefix, isTrue);
      expect(settings.includeContext, isTrue);
      expect(settings.includeHidden, isFalse);
    });

    test('should allow custom timestamp format', () {
      final settings = FormatterSettings(
        timestampFormat: DateFormat('yyyy-MM-dd'),
      );
      expect(settings.timestampFormat.pattern, equals('yyyy-MM-dd'));
    });
  });
}
