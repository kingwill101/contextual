import 'package:contextual/contextual.dart';

void main() async {
  final logger = Logger()
    ..addChannel('file', DailyFileLogDriver('logs/app2.log'));

  logger.info('This is an informational message.');
  logger.error('This is an error message.');

  await logger.shutdown();
}
