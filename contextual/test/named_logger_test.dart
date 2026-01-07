import 'package:contextual/contextual.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    // Clear logger registry before each test
    Logger.loggers.clear();
  });

  group('Named Logger Creation', () {
    test('root logger is accessible', () {
      final root = Logger.root;
      expect(root.name, equals(''));
      expect(root.parent, isNull);
    });

    test('creating named logger via constructor', () {
      final logger = Logger(name: 'test');
      expect(logger.name, equals('test'));
      expect(logger.parent, equals(Logger.root));
    });

    test('creating named logger via operator', () {
      final logger = Logger(name: 'test');
      expect(logger.name, equals('test'));
      expect(logger.parent, equals(Logger.root));
    });

    test('same name returns same logger instance', () {
      final logger1 = Logger(name: 'test');
      final logger2 = Logger(name: 'test');
      expect(logger1, same(logger2));
    });

    test('hierarchical logger creation', () {
      final app = Logger(name: 'app');
      final db = Logger(name: 'app.database');
      final api = Logger(name: 'app.api');

      expect(app.name, equals('app'));
      expect(db.name, equals('app.database'));
      expect(api.name, equals('app.api'));

      expect(app.parent, equals(Logger.root));
      expect(db.parent, equals(app));
      expect(api.parent, equals(app));
    });

    test('auto-creation of parent loggers', () {
      final db = Logger(name: 'app.database.connection');

      // Should have created all parent loggers
      expect(Logger.loggers.containsKey('app'), isTrue);
      expect(Logger.loggers.containsKey('app.database'), isTrue);
      expect(Logger.loggers.containsKey('app.database.connection'), isTrue);

      expect(Logger(name: 'app.database').parent, equals(Logger(name: 'app')));
      expect(db.parent, equals(Logger(name: 'app.database')));
    });
  });

  group('Configuration Inheritance', () {
    test('child inherits log level from parent', () {
      final parent = Logger(name: 'parent');
      parent.setLevel(Level.warning);

      final child = Logger(name: 'parent.child');

      expect(child.getLevel(), equals(Level.warning));
    });

    test('child can override parent log level', () {
      final parent = Logger(name: 'parent');
      parent.setLevel(Level.warning);

      final child = Logger(name: 'parent.child');
      child.setLevel(Level.debug);

      expect(child.getLevel(), equals(Level.debug));
    });

    test('child can set level in constructor', () {
      final parent = Logger(name: 'parent');
      parent.setLevel(Level.warning);

      final child = Logger(name: 'parent.child', level: Level.debug);

      expect(child.getLevel(), equals(Level.debug));
    });

    test('child inherits level if not set in constructor', () {
      final parent = Logger(name: 'parent');
      parent.setLevel(Level.warning);

      final child = Logger(name: 'parent.child');

      expect(child.getLevel(), equals(Level.warning));
    });

    test('child inherits formatter from parent', () {
      final parent = Logger(name: 'parent');
      parent.formatter(JsonLogFormatter());

      final child = Logger(name: 'parent.child');

      // Both should use the same formatter instance
      expect(child.currentFormatter, same(parent.currentFormatter));
    });

    test('child can override parent formatter', () {
      final parent = Logger(name: 'parent');
      parent.formatter(JsonLogFormatter());

      final child = Logger(name: 'parent.child');
      child.formatter(PrettyLogFormatter());

      expect(child.currentFormatter, isA<PrettyLogFormatter>());
      expect(parent.currentFormatter, isA<JsonLogFormatter>());
    });

    test('child inherits channels from parent', () {
      final parent = Logger(name: 'parent');
      parent.addChannel('console', ConsoleLogDriver());

      final child = Logger(name: 'parent.child');

      expect(child.hasChannel('console'), isTrue);
    });

    test('child can override parent channels', () {
      final parent = Logger(name: 'parent');
      parent.addChannel('console', ConsoleLogDriver());

      final child = Logger(name: 'parent.child');
      child.addChannel('console', DailyFileLogDriver('test.log'));

      expect(child.getChannel('console')?.driver, isA<DailyFileLogDriver>());
      expect(parent.getChannel('console')?.driver, isA<ConsoleLogDriver>());
    });

    test('child inherits type formatters from parent', () {
      final parent = Logger(name: 'parent');
      parent.addTypeFormatter<String>(StringLogFormatter());

      final child = Logger(name: 'parent.child');

      expect(child.allTypeFormatters.containsKey(String), isTrue);
    });

    test('child inherits context from parent', () {
      final parent = Logger(name: 'parent');
      parent.withContext({'parent': 'value'});

      final child = Logger(name: 'parent.child');

      expect(child.sharedContext.all()['parent'], equals('value'));
    });
  });

  group('Logging Behavior', () {
    test('child logger respects parent level', () {
      final parent = Logger(name: 'parent');
      parent.setLevel(Level.warning);

      final child = Logger(name: 'parent.child');

      // Should not log debug messages
      expect(() => child.debug('test'), returnsNormally);
      // But should log warning messages
      expect(() => child.warning('test'), returnsNormally);
    });

    test('child logger uses inherited channels', () {
      final parent = Logger(name: 'parent');
      final consoleDriver = ConsoleLogDriver();
      parent.addChannel('console', consoleDriver);

      final child = Logger(name: 'parent.child');

      expect(child.allChannels.length, equals(1));
      expect(child.allChannels.first.name, equals('console'));
    });

    test('logging through hierarchy works', () {
      final root = Logger.root;
      final app = Logger(name: 'app');
      final db = Logger(name: 'app.database');

      // Add channels at different levels
      root.addChannel('root', ConsoleLogDriver());
      app.addChannel('app', ConsoleLogDriver());
      db.addChannel('db', ConsoleLogDriver());

      expect(root.allChannels.length, equals(1));
      expect(app.allChannels.length, equals(2)); // root + app
      expect(db.allChannels.length, equals(3)); // root + app + db
    });

    test('logger name is included in log context', () async {
      final logger = Logger(name: 'test.logger');
      logger.addChannel('console', ConsoleLogDriver());

      LogEntry? capturedEntry;
      logger.onRecord.listen((entry) {
        capturedEntry = entry;
      });

      logger.info('test message');

      await Future.delayed(Duration.zero); // Allow async processing

      expect(capturedEntry, isNotNull);
      expect(
        capturedEntry!.record.context.all()['logger'],
        equals('test.logger'),
      );
    });

    test('root logger name is root in context', () async {
      final logger = Logger.root;
      logger.addChannel('console', ConsoleLogDriver());

      LogEntry? capturedEntry;
      logger.onRecord.listen((entry) {
        capturedEntry = entry;
      });

      logger.info('test message');

      await Future.delayed(Duration.zero); // Allow async processing

      expect(capturedEntry, isNotNull);
      expect(capturedEntry!.record.context.all()['logger'], equals('root'));
    });
  });

  group('Logger Registry', () {
    test('loggers are cached in registry', () {
      final logger1 = Logger(name: 'test');
      final logger2 = Logger(name: 'test');

      expect(Logger.loggers['test'], same(logger1));
      expect(Logger.loggers['test'], same(logger2));
    });

    test('registry contains all created loggers', () {
      Logger(name: 'a');
      Logger(name: 'a.b');
      Logger(name: 'a.c');
      Logger(name: 'x.y.z');

      expect(
        Logger.loggers.length,
        equals(7),
      ); // root + a + a.b + a.c + x + x.y + x.y.z
      expect(Logger.loggers.containsKey(''), isTrue); // root
      expect(Logger.loggers.containsKey('a'), isTrue);
      expect(Logger.loggers.containsKey('a.b'), isTrue);
      expect(Logger.loggers.containsKey('a.c'), isTrue);
      expect(Logger.loggers.containsKey('x'), isTrue);
      expect(Logger.loggers.containsKey('x.y'), isTrue);
      expect(Logger.loggers.containsKey('x.y.z'), isTrue);
    });
  });

  group('Edge Cases', () {
    test('empty name creates root logger', () {
      final logger = Logger(name: '');
      expect(logger, same(Logger.root));
    });

    test('deep hierarchy works', () {
      final deep = Logger(name: 'a.b.c.d.e.f');
      expect(deep.name, equals('a.b.c.d.e.f'));
      expect(deep.parent?.name, equals('a.b.c.d.e'));
    });

    test('multiple children of same parent', () {
      final parent = Logger(name: 'parent');
      final child1 = Logger(name: 'parent.child1');
      final child2 = Logger(name: 'parent.child2');

      expect(parent.children, contains(child1));
      expect(parent.children, contains(child2));
      expect(parent.children.length, equals(2));
    });
  });
}

class StringLogFormatter extends LogTypeFormatter<String> {
  @override
  String format(Level level, String message, Context context) {
    return 'formatted: $message';
  }
}
