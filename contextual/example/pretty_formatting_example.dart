import 'package:contextual/contextual.dart';

void main() async {
  final logger = Logger(formatter: PrettyLogFormatter());

  logger.withContext({"app": "pretty test"});
  logger.info('This is an informational message in pretty text format.');
  logger.error('This is an error message in pretty text format.');
  logger.debug('This is a debug message in pretty text format.');
  logger.warning('This is a warning message in pretty text format.');
  logger.critical('This is a critical message in pretty text format.');
  logger.notice('This is a notice message in pretty text format.');
  logger.alert('This is an alert message in pretty text format.');
  logger.emergency('This is an emergency message in pretty text format.');

  await logger.shutdown();
}
