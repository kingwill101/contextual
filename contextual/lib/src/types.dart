import 'package:contextual/src/driver/driver.dart';
import 'package:contextual/src/format/message_formatter.dart';
import 'package:contextual/src/log_level.dart';

typedef MiddlewareResult = MapEntry<String, Future<void> Function()>;
typedef LogEntry = MapEntry<Level, String>;
typedef LogDriverBuilder = LogDriver Function(Map<String, dynamic>);
typedef LogMessageFormatterBuilder = LogMessageFormatter Function();
