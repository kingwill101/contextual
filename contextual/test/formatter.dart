import 'dart:convert';

import 'package:contextual/contextual.dart';
import 'package:contextual/src/type_format/map.dart';
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
      final formattedMessage = formatter.format(
        LogRecord(
          time: DateTime.now(),
          level: Level.info,
          message: "Test message",
          context: context,
        ),
      );
      expect(formattedMessage, contains(Level.info));
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
      final formattedMessage = formatter.format(
        LogRecord(
          time: DateTime.now(),
          level: Level.info,
          message: "Test message",
          context: context,
        ),
      );
      //assert valid json
      expect(formattedMessage, isA<String>());
      expect(formattedMessage, isNotEmpty);
      final json = jsonDecode(formattedMessage);
      expect(json, isA<Map<String, dynamic>>());
      expect(json['level'], equals(Level.info));
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
      final formattedMessage = formatter.format(
        LogRecord(
          time: DateTime.now(),
          level: Level.info,
          message: "Test message",
          context: context,
        ),
      );
      expect(formattedMessage, equals(message));
    });
  });

  group('MapFormatter with Custom Formatters', () {
    late MapFormatter formatter;

    setUp(() {
      formatter = MapFormatter(
        valueFormatters: {
          String: StringFormatter(),
          int: IntFormatter(),
          DateTime: DateTimeFormatter(),
          User: UserFormatter(),
          Location: LocationFormatter(),
        },
        sorted: false,
      );
    });

    test('should format map with custom formatters', () {
      final context = Context.from({'key': 'value'});
      final complexMapMessage = {
        'user': User('Alice', 30),
        'timestamp': DateTime.parse('2023-10-01T12:34:56Z'),
        'location': (latitude: 40.7128, longitude: -74.0060),
        'details': {
          'ip': '192.168.1.1',
          'devices': ['laptop', 'mobile'],
        },
        'success': true,
        'attempts': 3,
      };
      final formattedMessage = formatter.format(
        Level.info,
        complexMapMessage,
        context,
      );

      // Assert the formatted message
      expect(formattedMessage, isA<String>());
      expect(formattedMessage, isNotEmpty);

      // expect(formattedMessage, equals(expectedMessage));
      expect(formattedMessage, contains('{"name": "Alice", "age": 30}'));

      expect(
        formattedMessage,
        contains('{"latitude": 40.7128, "longitude": -74.006}'),
      );
    });
  });
}

/// Formatter for String values
class StringFormatter extends LogTypeFormatter<String> {
  @override
  String format(Level level, String message, Context context) {
    return '"$message"';
  }
}

/// Formatter for int values
class IntFormatter extends LogTypeFormatter<int> {
  @override
  String format(Level level, int message, Context context) {
    return message.toString();
  }
}

/// Formatter for DateTime values
class DateTimeFormatter extends LogTypeFormatter<DateTime> {
  @override
  String format(Level level, DateTime message, Context context) {
    return message.toIso8601String();
  }
}

/// Custom class
class User {
  final String name;
  final int age;

  User(this.name, this.age);
}

/// Formatter for User class
class UserFormatter extends LogTypeFormatter<User> {
  @override
  String format(Level level, User user, Context context) {
    return '{"name": "${user.name}", "age": ${user.age}}';
  }
}

typedef Location = ({double latitude, double longitude});

/// Formatter for Location record
class LocationFormatter extends LogTypeFormatter<Location> {
  @override
  String format(Level level, Location location, Context context) {
    return '{"latitude": ${location.latitude}, "longitude": ${location.longitude}}';
  }
}
