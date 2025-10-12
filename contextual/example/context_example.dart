import 'package:contextual/contextual.dart';

Future<void> main() async {
  final logger = Logger();
  logger.withContext({'app': 'MyApp', 'version': '1.0.0'});

  logger['console'].info('Application started.');

  for (var i = 0; i < 100; i++) {
    logger['console'].info('Processing item $i');
    await Future.delayed(Duration(milliseconds: 100));
  }
}
