import 'package:contextual/contextual.dart';

void main() async {
  final logger = Logger(formatter: PlainTextLogFormatter());

  logger.info('This is an informational message in plain text format.');
  logger.error('This is an error message in plain text format.');
  logger.debug('This is a debug message in plain text format.');
  logger.warning('This is a warning message in plain text format.');
  logger.critical('This is a critical message in plain text format.');
  logger.notice('This is a notice message in plain text format.');
  logger.alert('This is an alert message in plain text format.');
  logger.emergency('This is an emergency message in plain text format.');

  await logger.shutdown();
}
