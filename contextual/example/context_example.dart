import 'package:contextual/contextual.dart';

void main() async {
  final logger = Logger();
  logger.withContext({'app': 'MyApp', 'version': '1.0.0'});
  await logger.setListener(
      (LogEntry entry) => print('[${entry.record.level}] ${entry.message}'));
  logger.to(['console']).info('Application started.');
}
