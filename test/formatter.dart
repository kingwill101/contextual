import 'dart:convert';

import 'package:contextual/contextual.dart';
import 'package:test/test.dart';

void main() {
  group('PlainTextLogFormatter', () {
    late PlainTextLogFormatter formatter;

    setUp(() {
      formatter = PlainTextLogFormatter();
    });

    test('should be instantiated', () {
      expect(formatter, isA<PlainTextLogFormatter>());
    });

    test('should implement LogMessageFormatter', () {
      expect(formatter, isA<LogMessageFormatter>());
    });

    test('should format log messages in plain text', () {
      final context = Context.from({'key': 'value'});
      final formattedMessage =
          formatter.format('INFO', 'Test message', context);
      expect(formattedMessage, contains('INFO'));
      expect(formattedMessage, contains('Test message'));
      expect(formattedMessage, contains('Context:'));
      expect(formattedMessage, contains('key: value'));
    });
  });

  group("Jsonformatter", () {
    late JsonLogFormatter formatter;
    setUp(() {
      formatter = JsonLogFormatter();
    });
    test('should be instantiated', () {
      expect(formatter, isA<JsonLogFormatter>());
    });
    test('should implement LogMessageFormatter', () {
      expect(formatter, isA<LogMessageFormatter>());
    });
    test('should format log messages in json', () {
      final context = Context.from({'key': 'value'});
      final formattedMessage =
          formatter.format('INFO', 'Test message', context);
      //assert valid json
      expect(formattedMessage, isA<String>());
      expect(formattedMessage, isNotEmpty);
      final json = jsonDecode(formattedMessage);
      expect(json, isA<Map<String, dynamic>>());
      expect(json['level'], equals('INFO'));
      expect(json['message'], equals('Test message'));
      expect(json['context'], isA<Map<String, dynamic>>());
      expect(json['context']['key'], equals('value'));
    });
  });

  group('RawLogFormatter', () {
    late RawLogFormatter formatter;

    setUp(() {
      formatter = RawLogFormatter();
    });

    test('should return message as-is', () {
      final context = Context();
      final message = 'Raw message';
      final formattedMessage = formatter.format('INFO', message, context);
      expect(formattedMessage, equals(message));
    });
  });
}
