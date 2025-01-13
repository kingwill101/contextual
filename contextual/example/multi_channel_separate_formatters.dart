import 'package:contextual/contextual.dart';

class CustomFormat1 extends LogMessageFormatter {
  @override
  String format(Level level, String message, Context context) {
    return '##Custom Format 1: $message##';
  }
}

class CustomFormat2 extends LogMessageFormatter {
  @override
  String format(Level level, String message, Context context) {
    return '@@Custom Format 2: $message@@'.split('').reversed.join();
  }
}

Future<void> main() async {
  final logger = Logger(defaultChannelEnabled: false);

  logger.setListener((a, v, vv) {
    print(v);
  });

  logger
      .addChannel("channel1", ConsoleLogDriver(), formatter: CustomFormat1())
      .addChannel("channel2", ConsoleLogDriver(), formatter: CustomFormat2());
  logger.to(['channel1']).info('11111111111');
  logger.to(['channel2']).info('22222222222');
  await logger.shutdown();
}
