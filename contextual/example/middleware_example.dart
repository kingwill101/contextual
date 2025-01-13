import 'package:contextual/contextual.dart';
import 'package:contextual/src/types.dart';

class UppercaseMiddleware extends DriverMiddleware {
  @override
  DriverMiddlewareResult handle(String driverName, LogEntry entry) {
    final modifiedMessage = entry.value.toUpperCase();
    return DriverMiddlewareResult.modify(MapEntry(entry.key, modifiedMessage));
  }
}

void main() async {
  final logger = Logger()
    ..addChannel('console', ConsoleLogDriver())
    ..addLogMiddleware(UppercaseMiddleware());

  logger.info('This message will be converted to uppercase.');
  logger.error('This error message will also be uppercase.');

  await logger.shutdown();
}
