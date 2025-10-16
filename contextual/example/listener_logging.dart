import 'package:contextual/contextual.dart';

Future<void> main() async {
  final logger = Logger(formatter: JsonLogFormatter());
  // Listener mode is independent of batching. Driver batching affects only driver outputs.
  logger.setListener((entry) {
    print('[${entry.record.time}] ${entry.record.level}: ${entry.message}');
  });

  logger.info('This message is handled by the listener.');
  logger.error('This error is also handled by the listener.');
}
