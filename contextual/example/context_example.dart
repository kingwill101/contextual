import 'package:contextual/contextual.dart';

void main() async {
  final logger = Logger();
  logger.withContext({'app': 'MyApp', 'version': '1.0.0'});
  await logger.setListener((s, ss, d) => print('[$s] $ss'));
  logger.to(['console']).info('Application started.');
}
