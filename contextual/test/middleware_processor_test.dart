import 'dart:async';

import 'package:contextual/src/log_entry.dart';
import 'package:contextual/src/log_level.dart';
import 'package:contextual/src/middleware.dart';
import 'package:contextual/src/middleware_processor.dart';
import 'package:contextual/src/record.dart';
import 'package:test/test.dart';

class ModifyMiddleware extends DriverMiddleware {
  final String appendText;

  ModifyMiddleware(this.appendText);

  @override
  FutureOr<DriverMiddlewareResult> handle(LogEntry entry) async {
    final modifiedMessage = '${entry.message}$appendText';

    // Create a new LogEntry with the modified message
    final modifiedEntry = LogEntry(entry.record, modifiedMessage);

    return DriverMiddlewareResult.modify(modifiedEntry);
  }
}

class StopMiddleware extends DriverMiddleware {
  final String keyword;

  StopMiddleware(this.keyword);

  @override
  FutureOr<DriverMiddlewareResult> handle(LogEntry entry) async {
    if (entry.message.contains(keyword)) {
      return DriverMiddlewareResult.stop();
    }
    return DriverMiddlewareResult.proceed();
  }
}

/// A middleware that simulates an asynchronous modify action.
class AsyncModifyMiddleware extends DriverMiddleware {
  final String appendText;

  AsyncModifyMiddleware(this.appendText);

  @override
  FutureOr<DriverMiddlewareResult> handle(LogEntry entry) async {
    await Future.delayed(Duration(milliseconds: 50)); // Simulate async delay
    return DriverMiddlewareResult.modify(
      entry.copyWith(message: '${entry.message}$appendText'),
    );
  }
}

void main() {
  group('Middleware Processor', () {
    test('applies middlewares in correct order and handles actions', () async {
      // Create a LogRecord
      final record = LogRecord(
        time: DateTime.now(),
        level: Level.info,
        message: 'Initial message',
      );

      // Create a LogEntry with the formatted message
      final entry = LogEntry(record, 'Initial message');

      final globalMiddleware = [ModifyMiddleware(' [Global]')];

      final channelMiddleware = [ModifyMiddleware(' [Channel]')];

      final driverMiddleware = [ModifyMiddleware(' [Driver]')];

      final result = await processDriverMiddlewares(
        entry: entry,
        globalMiddlewares: globalMiddleware,
        channelMiddlewares: channelMiddleware,
        driverMiddlewares: driverMiddleware,
      );

      expect(
        result?.message,
        equals('Initial message [Global] [Channel] [Driver]'),
      );
    });

    test('middleware can stop processing the log entry', () async {
      final entry = LogEntry(
        LogRecord(
          level: Level.info,
          message: 'Sensitive data',
          time: DateTime.now(),
        ),
        'Sensitive data',
      );

      final stopMiddleware = [StopMiddleware('Sensitive')];

      final result = await processDriverMiddlewares(
        entry: entry,
        globalMiddlewares: stopMiddleware,
      );

      expect(result, isNull); // Log entry should be discarded
    });

    test('modifications by middlewares are cumulative', () async {
      final entry = LogEntry(
        LogRecord(
          level: Level.info,
          message: 'Original message',
          time: DateTime.now(),
        ),
        'Original message',
      );

      final middlewares = [
        ModifyMiddleware(' [First]'),
        ModifyMiddleware(' [Second]'),
      ];

      final result = await processDriverMiddlewares(
        entry: entry,
        globalMiddlewares: middlewares,
      );

      expect(result?.message, equals('Original message [First] [Second]'));
    });

    test('middleware processing stops after stop action', () async {
      final entry = LogEntry(
        LogRecord(
          level: Level.info,
          message: 'Message to stop',
          time: DateTime.now(),
        ),
        'Message to stop',
      );

      final middlewares = [
        ModifyMiddleware(' [Before Stop]'),
        StopMiddleware('stop'),
        ModifyMiddleware(' [After Stop]'),
      ];

      final result = await processDriverMiddlewares(
        entry: entry,
        globalMiddlewares: middlewares,
      );

      expect(result, isNull); // Log entry should be discarded
    });

    test(
      'driver-specific middlewares are applied after global and channel middlewares',
      () async {
        final entry = LogEntry(
          LogRecord(
            level: Level.info,
            message: 'Initial message',
            time: DateTime.now(),
          ),
          'Initial message',
        );

        final globalMiddleware = [ModifyMiddleware(' [Global]')];

        final channelMiddleware = [ModifyMiddleware(' [Channel]')];

        final driverMiddleware = [ModifyMiddleware(' [Driver]')];

        final result = await processDriverMiddlewares(
          entry: entry,
          globalMiddlewares: globalMiddleware,
          channelMiddlewares: channelMiddleware,
          driverMiddlewares: driverMiddleware,
        );

        expect(
          result?.message,
          equals('Initial message [Global] [Channel] [Driver]'),
        );
      },
    );

    test('middleware can handle async operations', () async {
      final entry = LogEntry(
        LogRecord(
          level: Level.info,
          message: 'Initial message',
          time: DateTime.now(),
        ),
        'Initial message',
      );

      final asyncMiddleware = [AsyncModifyMiddleware(' [Async]')];

      final result = await processDriverMiddlewares(
        entry: entry,
        globalMiddlewares: asyncMiddleware,
      );

      expect(result?.message, equals('Initial message [Async]'));
    });
  });
}
