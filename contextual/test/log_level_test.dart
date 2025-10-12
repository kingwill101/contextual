import 'dart:async';
import 'package:contextual/contextual.dart';
import 'package:test/test.dart';

void main() {
  group('Level', () {
    test('should contain all log levels', () {
      expect(Level.levels.length, equals(8));
    });
  });

  group('Logger Level Filtering', () {
    late Logger logger;
    late List<String> loggedMessages;
    late StreamSubscription<LogEntry> logSubscription;

    setUp(() async {
      loggedMessages = [];
      logger = await Logger.create(formatter: RawLogFormatter());
      logSubscription = logger.onRecord.listen((entry) {
        loggedMessages.add(entry.message);
      });
    });

    tearDown(() async {
      await logger.shutdown();
      await logSubscription.cancel();
    });

    test('default level should be debug (allowing all logs)', () {
      expect(logger.getLevel(), equals(Level.debug));

      logger.emergency('emergency message');
      logger.alert('alert message');
      logger.critical('critical message');
      logger.error('error message');
      logger.warning('warning message');
      logger.notice('notice message');
      logger.info('info message');
      logger.debug('debug message');

      Future.delayed(Duration.zero, () {
        expect(loggedMessages.length, equals(8));
        expect(loggedMessages, contains('emergency message'));
        expect(loggedMessages, contains('debug message'));
      });
    });

    test('setting level to warning should only log warning and above', () {
      logger.setLevel(Level.warning);
      expect(logger.getLevel(), equals(Level.warning));

      logger.emergency('emergency message');
      logger.alert('alert message');
      logger.critical('critical message');
      logger.error('error message');
      logger.warning('warning message');
      logger.notice('notice message');
      logger.info('info message');
      logger.debug('debug message');

      Future.delayed(Duration.zero, () {
        expect(loggedMessages.length, equals(5));
        expect(loggedMessages, contains('emergency message'));
        expect(loggedMessages, contains('alert message'));
        expect(loggedMessages, contains('critical message'));
        expect(loggedMessages, contains('error message'));
        expect(loggedMessages, contains('warning message'));
        expect(loggedMessages, isNot(contains('notice message')));
        expect(loggedMessages, isNot(contains('info message')));
        expect(loggedMessages, isNot(contains('debug message')));
      });
    });

    test('setting level to error should only log error and above', () {
      logger.setLevel(Level.error);

      logger.emergency('emergency message');
      logger.alert('alert message');
      logger.critical('critical message');
      logger.error('error message');
      logger.warning('warning message');
      logger.notice('notice message');
      logger.info('info message');
      logger.debug('debug message');

      Future.delayed(Duration.zero, () {
        expect(loggedMessages.length, equals(4));
        expect(loggedMessages, contains('emergency message'));
        expect(loggedMessages, contains('alert message'));
        expect(loggedMessages, contains('critical message'));
        expect(loggedMessages, contains('error message'));
        expect(loggedMessages, isNot(contains('warning message')));
        expect(loggedMessages, isNot(contains('notice message')));
        expect(loggedMessages, isNot(contains('info message')));
        expect(loggedMessages, isNot(contains('debug message')));
      });
    });

    test('setting level to emergency should only log emergency', () {
      logger.setLevel(Level.emergency);

      logger.emergency('emergency message');
      logger.alert('alert message');
      logger.critical('critical message');
      logger.error('error message');
      logger.warning('warning message');
      logger.notice('notice message');
      logger.info('info message');
      logger.debug('debug message');

      Future.delayed(Duration.zero, () {
        expect(loggedMessages.length, equals(1));
        expect(loggedMessages, contains('emergency message'));
        expect(loggedMessages, isNot(contains('alert message')));
        expect(loggedMessages, isNot(contains('critical message')));
        expect(loggedMessages, isNot(contains('error message')));
        expect(loggedMessages, isNot(contains('warning message')));
        expect(loggedMessages, isNot(contains('notice message')));
        expect(loggedMessages, isNot(contains('info message')));
        expect(loggedMessages, isNot(contains('debug message')));
      });
    });

    test('changing levels should affect subsequent logs only', () async {
      logger.info('first info message');

      await Future.delayed(Duration.zero, () {
        expect(loggedMessages.length, equals(1));
        expect(loggedMessages, contains('first info message'));
      });

      logger.setLevel(Level.error);
      logger.info('second info message');

      await Future.delayed(Duration.zero, () {
        expect(loggedMessages.length, equals(1));
      });

      logger.error('error message');

      await Future.delayed(Duration.zero, () {
        expect(loggedMessages.length, equals(2));
        expect(loggedMessages, contains('first info message'));
        expect(loggedMessages, isNot(contains('second info message')));
        expect(loggedMessages, contains('error message'));
      });
    });
  });
}
