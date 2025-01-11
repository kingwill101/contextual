import 'package:contextual/contextual.dart';

void main() async {
  final logger = Logger(formatter: PrettyLogFormatter());

  logger.info('This is a pretty formatted informational message.');
  logger.error('This is a pretty formatted error message.');

  await logger.shutdown();
}
