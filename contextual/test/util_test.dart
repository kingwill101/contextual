import 'package:test/test.dart';
import 'package:contextual/src/context.dart';
import 'package:contextual/src/util.dart';

void main() {
  group('interpolateMessage', () {
    late Context context;

    setUp(() {
      context = Context();
    });

    test('replaces single placeholder with context value', () {
      context.add('name', 'John');
      final result = interpolateMessage('Hello {name}!', context);
      expect(result, equals('Hello John!'));
    });

    test('replaces multiple placeholders with context values', () {
      context.add('first', 'John');
      context.add('last', 'Doe');
      final result = interpolateMessage('Name: {first} {last}', context);
      expect(result, equals('Name: John Doe'));
    });

    test('handles null values in context', () {
      context.add('key', null);
      final result = interpolateMessage('Value: {key}', context);
      expect(result, equals('Value: {key}'));
    });

    test('handles null values in context with default missing value', () {
      context.add('key', null);
      final result = interpolateMessage(
        'Value: {key}',
        context,
      );
      expect(result, equals('Value: {key}'));
    });

    test('leaves message unchanged when no placeholders match', () {
      context.add('name', 'John');
      final result = interpolateMessage('Hello {unknown}!', context);
      expect(result, equals('Hello {unknown}!'));
    });

    test('handles complex object interpolation', () {
      final complexObject = {
        'user': {
          'profile': {
            'name': 'John',
            'age': 30,
            'address': {'street': 'Main St', 'city': 'New York'}
          }
        }
      };
      context.add('data', complexObject);
      final result = interpolateMessage(
          'User {data.user.profile.name} is {data.user.profile.age} years old and lives in {data.user.profile.address.city}',
          context);
      expect(result, equals('User John is 30 years old and lives in New York'));
    });
  });

  group('MapExtension.dot', () {
    test('retrieves nested value using dot notation', () {
      final map = {
        'user': {
          'profile': {'name': 'John'}
        }
      };
      expect(map.dot<String>('user.profile.name'), equals('John'));
    });

    test('returns null for non-existent path', () {
      final map = {
        'user': {'name': 'John'}
      };
      expect(map.dot<String>('user.profile.age'), isNull);
    });

    test('returns default value for non-existent path', () {
      final map = {
        'user': {'name': 'John'}
      };
      expect(map.dot<int>('user.age', 25), equals(25));
    });

    test('handles empty path', () {
      final map = {'key': 'value'};
      expect(map.dot<String>(''), isNull);
    });
  });
}
