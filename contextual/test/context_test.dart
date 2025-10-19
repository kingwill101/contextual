import 'package:test/test.dart';
import 'package:contextual/src/context.dart';

void main() {
  group('Context', () {
    late Context context;

    setUp(() {
      context = Context();
    });

    group('when()', () {
      test('executes true callback when condition is true', () {
        var executed = false;
        context.when(
          () => true,
          (ctx) => executed = true,
          (ctx) => executed = false,
        );
        expect(executed, isTrue);
      });

      test('executes false callback when condition is false', () {
        var executed = false;
        context.when(
          () => false,
          (ctx) => executed = true,
          (ctx) => executed = false,
        );
        expect(executed, isFalse);
      });
    });

    group('unless()', () {
      test('executes callback when condition is false', () {
        var executed = false;
        context.unless(() => false, (ctx) => executed = true, null);
        expect(executed, isTrue);
      });

      test('executes optional callback when condition is true', () {
        var executed = false;
        context.unless(
          () => true,
          (ctx) => executed = false,
          (ctx) => executed = true,
        );
        expect(executed, isTrue);
      });
    });

    group('data operations', () {
      test('only() returns map with specified keys', () {
        context.add('key1', 'value1');
        context.add('key2', 'value2');
        context.add('key3', 'value3');

        final result = context.only(['key1', 'key2', 'key4']);
        expect(result, equals({'key1': 'value1', 'key2': 'value2'}));
      });

      test('addIf() adds value only if key does not exist', () {
        context.add('key1', 'value1');
        context.addIf('key1', 'value2');
        context.addIf('key2', 'value2');

        expect(context.get('key1'), equals('value1'));
        expect(context.get('key2'), equals('value2'));
      });
    });

    group('stack operations', () {
      test('push() and pop() manage stack correctly', () {
        context.push('stack', 1);
        context.push('stack', 2);

        expect(context.pop('stack'), equals(2));
        expect(context.pop('stack'), equals(1));
        expect(context.pop('stack'), isNull);
      });

      test('stackContains() checks for value presence', () {
        context.push('stack', 'value1');
        context.push('stack', 'value2');

        expect(context.stackContains('stack', 'value1'), isTrue);
        expect(context.stackContains('stack', 'value3'), isFalse);
      });
    });

    group('hidden data operations', () {
      test('hidden data is separate from visible data', () {
        context.add('key1', 'visible');
        context.addHidden('key1', 'hidden');

        expect(context.get('key1'), equals('visible'));
        expect(context.getHidden('key1'), equals('hidden'));
      });

      test('allHidden() returns only hidden data', () {
        context.add('key1', 'visible');
        context.addHidden('key2', 'hidden');

        expect(context.allHidden(), equals({'key2': 'hidden'}));
      });
    });

    test('from() creates context from map', () {
      final map = {'key1': 'value1', 'key2': 'value2'};
      final newContext = Context.from(map);

      expect(newContext.get('key1'), equals('value1'));
      expect(newContext.get('key2'), equals('value2'));
    });
  });
}
