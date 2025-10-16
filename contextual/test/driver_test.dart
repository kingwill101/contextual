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
      stackDriver = StackLogDriver([
        testDriver1,
        testDriver2,
      ], ignoreExceptions: true);

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

  group('Typed driver selection and construction', () {
    test('Logger.forDriverType selects by type', () async {
      final logger = await Logger.create(
        config: const LogConfig(
          channels: [
            ConsoleChannel(ConsoleOptions(), name: 'consoleA'),
            ConsoleChannel(ConsoleOptions(), name: 'consoleB'),
          ],
        ),
      );

      // Should select both console channels
      logger.forDriver<ConsoleLogDriver>().info('hello');
    });

    test('DailyFileLogDriver.fromOptions constructs correctly', () async {
      final driver = DailyFileLogDriver.fromOptions(
        const DailyFileOptions(path: 'logs/app', retentionDays: 1),
      );
      expect(driver, isA<DailyFileLogDriver>());
    });

    test('WebhookLogDriver.fromOptions constructs correctly', () async {
      final driver = WebhookLogDriver.fromOptions(
        WebhookOptions(url: Uri.parse('https://example.com/hook')),
      );
      expect(driver, isA<WebhookLogDriver>());
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
