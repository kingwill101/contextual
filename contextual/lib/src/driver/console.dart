import 'driver.dart';

/// A [LogDriver] implementation that logs messages to the console.
class ConsoleLogDriver extends LogDriver {
  ConsoleLogDriver() : super("console");

  /// Logs the provided [formattedMessage] to the console.
  ///
  /// This method is part of the [ConsoleLogDriver] implementation of the [LogDriver] interface.
  @override
  Future<void> log(String formattedMessage) async {
    print(formattedMessage);
  }
}
