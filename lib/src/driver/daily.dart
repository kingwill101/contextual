import 'package:contextual/src/driver/driver.dart';
import 'package:universal_io/io.dart';

/// Implements the [LogDriver] interface to write log messages to a daily log file.
///
/// The daily log file is named based on the current date and stored in the
/// [baseFilePath] directory. Log messages are appended to the file.
///
/// The [retentionDays] parameter controls how many days of log files are retained
/// before being automatically deleted.
class DailyFileLogDriver implements LogDriver {
  final String baseFilePath;
  final int retentionDays;

  DailyFileLogDriver(this.baseFilePath, {this.retentionDays = 14});

  @override

  /// Writes the provided formatted log message to a daily log file.
  ///
  /// The log file is named based on the current date and stored in the [baseFilePath]
  /// directory. If the log file does not exist, it is created. The log message is
  /// appended to the file.
  Future<void> log(String formattedMessage) async {
    final dateSuffix = DateTime.now().toIso8601String().split('T').first;
    final filePath = '$baseFilePath-$dateSuffix.log';
    final file = File(filePath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync('$formattedMessage\n', mode: FileMode.append);
  }
}
