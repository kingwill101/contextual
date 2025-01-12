import 'package:contextual/contextual.dart';

void main() async {
  final logger = Logger(formatter: JsonLogFormatter());

  logger.info('This is an informational message in json text format.');
  logger.error('This is an error message in json text format.');
  logger.debug('This is a debug message in json text format.');
  logger.warning('This is a warning message in json text format.');
  logger.critical('This is a critical message in json text format.');
  logger.notice('This is a notice message in json text format.');
  logger.alert('This is an alert message in json text format.');
  logger.emergency('This is an emergency message in json text format.');

  await logger.shutdown();
}
