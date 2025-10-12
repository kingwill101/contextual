import 'package:contextual/contextual.dart';
import 'package:test/test.dart';

class CollectDriver extends LogDriver {
  final List<String> messages = [];
  CollectDriver() : super('collect');
  @override
  Future<void> log(LogEntry entry) async {
    messages.add(entry.message);
  }
}

class AppendMiddleware implements DriverMiddleware {
  final String tag;
  AppendMiddleware(this.tag);
  @override
  Future<DriverMiddlewareResult> handle(LogEntry entry) async {
    return DriverMiddlewareResult.modify(
      LogEntry(entry.record, '${entry.message}[$tag]'),
    );
  }
}

void main() {
  test('Middleware order: global -> channel -> driver-type', () async {
    final logger = await Logger.create(formatter: RawLogFormatter());

    final collect = CollectDriver();

    logger
      ..addLogMiddleware(AppendMiddleware('G'))
      ..addDriverMiddleware<CollectDriver>(AppendMiddleware('D'))
      ..addChannel('collect', collect, middlewares: [AppendMiddleware('C')]);

    logger['collect'].info('x');

    await Future.delayed(Duration(milliseconds: 10));

    expect(collect.messages.length, 1);
    expect(collect.messages.first, 'x[G][C][D]');
  });
}
