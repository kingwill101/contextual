import 'package:test/test.dart';
import 'package:contextual/src/middleware.dart';
import 'package:contextual/src/middleware_processor.dart';

class TestMiddleware extends DriverMiddleware {
  @override
  DriverMiddlewareResult handle(
      String driverName, MapEntry<String, String> entry) {
    if (entry.value.contains('stop')) {
      return DriverMiddlewareResult.stop();
    }
    return DriverMiddlewareResult.modify(
        MapEntry(entry.key, entry.value.toUpperCase()));
  }
}

void main() {
  group('Middleware Processor', () {
    test('should modify message', () async {
      final entry = MapEntry('INFO', 'modify this message');
      final result = await processDriverMiddlewares(
        logEntry: entry,
        driverName: 'testDriver',
        globalMiddlewares: [TestMiddleware()],
        driverMiddlewaresMap: {},
      );
      expect(result?.value, equals('MODIFY THIS MESSAGE'));
    });

    test('should stop processing', () async {
      final entry = MapEntry('INFO', 'stop this message');
      final result = await processDriverMiddlewares(
        logEntry: entry,
        driverName: 'testDriver',
        globalMiddlewares: [TestMiddleware()],
        driverMiddlewaresMap: {},
      );
      expect(result, isNull);
    });
  });
}
