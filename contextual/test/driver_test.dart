import 'package:contextual/contextual.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockLogDriver extends Mock implements TestDriver {}

void main() {
  group('StackLogDriver', () {
    late StackLogDriver stackDriver;
    late TestDriver testDriver1;
    late TestDriver testDriver2;

    setUp(() {
      testDriver1 = TestDriver();
      testDriver2 = TestDriver();
      stackDriver = StackLogDriver([testDriver1, testDriver2]);
    });

    test('should log to all drivers', () async {
      // Create a LogRecord and LogEntry
      final record = LogRecord(
        time: DateTime.now(),
        level: Level.info,
        message: 'Test message',
        context: Context(),
      );
      final entry = LogEntry(record, 'Test message');

      await stackDriver.log(entry);
      expect(testDriver1.logMessages, contains('Test message'));
      expect(testDriver2.logMessages, contains('Test message'));
    });

    test('should handle exceptions when ignoreExceptions is true', () async {
      stackDriver =
          StackLogDriver([testDriver1, testDriver2], ignoreExceptions: true);

      // Create a LogRecord and LogEntry
      final record = LogRecord(
        time: DateTime.now(),
        level: Level.info,
        message: 'Test message',
        context: Context(),
      );
      final entry = LogEntry(record, 'Test message');

      await stackDriver.log(entry);
      expect(testDriver1.logMessages, contains('Test message'));
      expect(testDriver2.logMessages, contains('Test message'));
    });
  });

  group('LogDriverFactory', () {
    late LogDriverFactory loggerFactory;

    setUp(() {
      loggerFactory = LogDriverFactory();
    });

    test('registerDriver adds driver builder to registry', () {
      loggerFactory.registerDriver('test', (config) => TestDriver());
      expect(loggerFactory.registeredDrivers, contains('test'));
    });

    test('createDriver throws ArgumentError for unregistered driver type', () {
      expect(
        () => loggerFactory.createDriver({'driver': 'unknown'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('createDriver passes configuration to builder', () {
      var configPassed = <String, dynamic>{};
      loggerFactory.registerDriver('test', (config) {
        configPassed = config;
        return TestDriver();
      });

      final testConfig = {
        'driver': 'test',
        'config': {
          'key': 'value',
        }
      };
      loggerFactory.createDriver(testConfig);
      expect(configPassed, equals(testConfig.dot("config")));
    });

    test('multiple drivers can be registered and created', () {
      loggerFactory.registerDriver('driver1', (config) => TestDriver());
      loggerFactory.registerDriver('driver2', (config) => TestDriver());

      expect(loggerFactory.registeredDrivers, contains('driver1'));
      expect(loggerFactory.registeredDrivers, contains('driver2'));
    });

    test('error message includes available driver types', () {
      loggerFactory.registerDriver('test1', (config) => TestDriver());
      loggerFactory.registerDriver('test2', (config) => TestDriver());

      try {
        loggerFactory.createDriver({'driver': 'unknown'});
        fail('Expected ArgumentError');
      } catch (e) {
        expect(e, isA<ArgumentError>());
        expect(e.toString(), contains('test1'));
        expect(e.toString(), contains('test2'));
      }
    });
  });
}

class TestDriver extends LogDriver {
  final List<String> logMessages = [];

  TestDriver() : super("test");

  @override
  @override
  Future<void> log(LogEntry entry) async {
    logMessages.add(entry.message);
  }
}
