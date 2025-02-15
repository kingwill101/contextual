import 'package:contextual/contextual.dart';

void main() {
  // Initialize the logger with a RawLogFormatter
  final logger = Logger(formatter: RawLogFormatter());

  // Set up a listener to handle log messages
  logger.setListener((r) {
    print(
        '${r.message} ${r.record.level} ${r.record.message} ${r.record.time}');
  });

  // Log messages using the listener
  logger.info('This is an informational message in raw text format.');
  logger.error('This is an error message in raw text format.');
  logger.debug('This is a debug message in raw text format.');
  logger.warning('This is a warning message in raw text format.');
  logger.critical('This is a critical message in raw text format.');
  logger.notice('This is a notice message in raw text format.');
  logger.alert('This is an alert message in raw text format.');
  logger.emergency('This is an emergency message in raw text format.');
}
