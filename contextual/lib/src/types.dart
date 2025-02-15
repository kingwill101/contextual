import 'package:contextual/src/driver/driver.dart';
import 'package:contextual/src/format/message_formatter.dart';

typedef MiddlewareResult = MapEntry<String, Future<void> Function()>;
typedef LogDriverBuilder = LogDriver Function(Map<String, dynamic>);
typedef LogMessageFormatterBuilder = LogMessageFormatter Function();
