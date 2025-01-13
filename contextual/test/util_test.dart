import 'package:contextual/src/log_level.dart';
import 'package:test/test.dart';
import 'package:contextual/src/util.dart';
import 'package:contextual/src/context.dart';
import 'package:contextual/src/logtype_formatter.dart';
import 'package:contextual/src/format/plain.dart';
import 'package:contextual/src/format/formatter_settings.dart';

void main() {
  group('interpolateMessage', () {
    late Context context;

    setUp(() {
      context = Context();
    });

    test('interpolates multiple placeholders', () {
      context.add('name', 'John');
      context.add('age', 30);
      final result =
          interpolateMessage('Hello {name}, you are {age} years old', context);
      expect(result, equals('Hello John, you are 30 years old'));
    });

    test('handles null values', () {
      context.add('key', null);
      final result = interpolateMessage('Value: {key}', context);
      expect(result, equals('Value: null'));
    });

    test('handles missing placeholders', () {
      context.add('name', 'John');
      final result = interpolateMessage('Hello {name} {missing}', context);
      expect(result, equals('Hello John {missing}'));
    });

    test('handles empty context', () {
      final result = interpolateMessage('Hello {name}!', context);
      expect(result, equals('Hello {name}!'));
    });
  });

  group('formatMessage', () {
    late Context context;

    setUp(() {
      context = Context();
    });

    test('uses custom type formatter when available', () {
      final customFormatter = CustomTypeFormatter();
      final message = CustomMessage('test');

      final result = formatMessage(
        Level.info,
        message,
        context,
        typeFormatters: {CustomMessage: customFormatter},
      );

      expect(result, equals('CUSTOM: test'));
    });

    test('falls back to default formatter when no type formatter matches', () {
      final message = 'test message';
      final formatter = PlainTextLogFormatter(
        settings: FormatterSettings(
          includeTimestamp: false,
          includeLevel: true,
          includePrefix: false,
          includeContext: false,
        ),
      );
      final result =
          formatMessage(Level.info, message, context, formatter: formatter);
      expect(result, equals('[INFO] test message'));
    });

    test('handles non-string objects using toString()', () {
      final message = CustomMessage('CUSTOM VALUE');
      final formatter = CustomTypeFormatter();
      final result = formatMessage(Level.info, message, context,
          typeFormatters: {CustomMessage: formatter});
      expect(result, equals("CUSTOM: CUSTOM VALUE"));
    });
  });
}

class CustomMessage {
  final String value;
  CustomMessage(this.value);
}

class CustomTypeFormatter extends LogTypeFormatter {
  @override
  String format(Level level, dynamic message, Context context) {
    return 'CUSTOM: ${(message as CustomMessage).value}';
  }
}
