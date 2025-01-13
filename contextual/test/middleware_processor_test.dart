import 'dart:async';

import 'package:contextual/src/types.dart';
import 'package:test/test.dart';
import 'package:contextual/src/middleware.dart';
import 'package:contextual/src/middleware_processor.dart';
import 'package:contextual/src/log_level.dart';

class ModifyMiddleware extends DriverMiddleware {
  final String appendText;

  ModifyMiddleware(this.appendText);

  @override
  @override
  FutureOr<DriverMiddlewareResult> handle(
      String driverName, LogEntry entry) async {
    final modifiedMessage = '${entry.value}$appendText';
    return DriverMiddlewareResult.modify(MapEntry(entry.key, modifiedMessage));
  }
}

class StopMiddleware extends DriverMiddleware {
  final String keyword;

  StopMiddleware(this.keyword);

  @override
  FutureOr<DriverMiddlewareResult> handle(
      String driverName, LogEntry entry) async {
    if (entry.value.contains(keyword)) {
      return DriverMiddlewareResult.stop();
    }
    return DriverMiddlewareResult.proceed();
  }
}

void main() {
  group('Middleware Processor', () {
    test('applies middlewares in correct order and handles actions', () async {
      final entry = MapEntry(Level.info, 'Initial message');

      final globalMiddleware = [
        ModifyMiddleware(' [Global]'),
      ];

      final channelMiddleware = [
        ModifyMiddleware(' [Channel]'),
      ];

      final driverMiddleware = [
        ModifyMiddleware(' [Driver]'),
      ];

      final result = await processDriverMiddlewares(
        logEntry: entry,
        driverName: 'testDriver',
        globalMiddlewares: globalMiddleware,
        channelMiddlewares: channelMiddleware,
        driverMiddlewares: driverMiddleware,
      );

      expect(
          result?.value, equals('Initial message [Global] [Channel] [Driver]'));
    });

    test('middleware can stop processing the log entry', () async {
      final entry = MapEntry(Level.info, 'Sensitive data');

      final stopMiddleware = [
        StopMiddleware('Sensitive'),
      ];

      final result = await processDriverMiddlewares(
        logEntry: entry,
        driverName: 'testDriver',
        globalMiddlewares: stopMiddleware,
      );

      expect(result, isNull); // Log entry should be discarded
    });

    test('modifications by middlewares are cumulative', () async {
      final entry = MapEntry(Level.info, 'Original message');

      final middlewares = [
        ModifyMiddleware(' [First]'),
        ModifyMiddleware(' [Second]'),
      ];

      final result = await processDriverMiddlewares(
        logEntry: entry,
        driverName: 'testDriver',
        globalMiddlewares: middlewares,
      );

      expect(result?.value, equals('Original message [First] [Second]'));
    });

    test('middleware processing stops after stop action', () async {
      final entry = MapEntry(Level.info, 'Message to stop');

      final middlewares = [
        ModifyMiddleware(' [Before Stop]'),
        StopMiddleware('stop'),
        ModifyMiddleware(' [After Stop]'),
      ];

      final result = await processDriverMiddlewares(
        logEntry: entry,
        driverName: 'testDriver',
        globalMiddlewares: middlewares,
      );

      expect(result, isNull); // Log entry should be discarded
    });

    test(
        'driver-specific middlewares are applied after global and channel middlewares',
        () async {
      final entry = MapEntry(Level.info, 'Initial message');

      final globalMiddleware = [
        ModifyMiddleware(' [Global]'),
      ];

      final channelMiddleware = [
        ModifyMiddleware(' [Channel]'),
      ];

      final driverMiddleware = [
        ModifyMiddleware(' [Driver]'),
      ];

      final result = await processDriverMiddlewares(
        logEntry: entry,
        driverName: 'testDriver',
        globalMiddlewares: globalMiddleware,
        channelMiddlewares: channelMiddleware,
        driverMiddlewares: driverMiddleware,
      );

      expect(
          result?.value, equals('Initial message [Global] [Channel] [Driver]'));
    });

    test('middleware can handle async operations', () async {
      final entry = MapEntry(Level.info, 'Initial message');

      final asyncMiddleware = [
        AsyncModifyMiddleware(' [Async]'),
      ];

      final result = await processDriverMiddlewares(
        logEntry: entry,
        driverName: 'testDriver',
        globalMiddlewares: asyncMiddleware,
      );

      expect(result?.value, equals('Initial message [Async]'));
    });
  });
}

/// A middleware that simulates an asynchronous modify action.
class AsyncModifyMiddleware extends DriverMiddleware {
  final String appendText;

  AsyncModifyMiddleware(this.appendText);

  @override
  FutureOr<DriverMiddlewareResult> handle(
      String driverName, LogEntry entry) async {
    await Future.delayed(Duration(milliseconds: 50)); // Simulate async delay
    final modifiedMessage = '${entry.value}$appendText';
    return DriverMiddlewareResult.modify(MapEntry(entry.key, modifiedMessage));
  }
}
