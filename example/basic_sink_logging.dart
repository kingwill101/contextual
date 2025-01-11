import 'package:contextual/contextual.dart';
import 'package:contextual/src/driver/daily.dart';

void main() async {
  final logger = Logger()
    ..addDriver('file', DailyFileLogDriver('logs/app2.log'));

  logger.info('This is an informational message.');
  logger.error('This is an error message.');

  await logger.shutdown();
}
