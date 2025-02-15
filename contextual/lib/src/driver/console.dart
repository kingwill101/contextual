import 'package:contextual/src/log_entry.dart';

import 'driver.dart';

/// A [LogDriver] implementation that logs messages to the console.
class ConsoleLogDriver extends LogDriver {
  ConsoleLogDriver() : super("console");

  /// Logs the provided [entry] to the console by printing its message.
  ///
  /// This is a simple implementation that writes directly to stdout using [print].
  @override
  Future<void> log(LogEntry entry) async {
    print(entry.message);
  }
}
