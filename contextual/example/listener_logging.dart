import 'package:contextual/contextual.dart';

Future<void> main() async {
  final logger = Logger();

  // Set up a simple listener
  logger.setListener((LogEntry entry) {
    print('[${entry.record.time}] ${entry.record.level}: ${entry.message}');
  });

  logger.info('This message is handled by the listener.');
  logger.error('This error is also handled by the listener.');
}
