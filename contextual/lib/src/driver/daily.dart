import 'package:contextual/src/driver/driver.dart';
import 'package:contextual/src/log_entry.dart';
import 'package:universal_io/io.dart';

/// A [LogDriver] that writes log messages to daily rotating log files.
///
/// This driver creates a new log file each day and automatically manages log file
/// retention. Log files are named using the pattern `{baseFilePath}-YYYY-MM-DD.log`.
///
/// Features:
/// * Daily log file rotation
/// * Automatic cleanup of old log files
/// * Configurable retention period
/// * Creates log directories if they don't exist
///
/// Example:
/// ```dart
/// final driver = DailyFileLogDriver(
///   'logs/app',
///   retentionDays: 30,
/// );
/// ```
///
/// The above example creates log files like:
/// * logs/app-2024-02-15.log
/// * logs/app-2024-02-14.log
/// * etc.
class DailyFileLogDriver extends LogDriver {
  /// Base path for log files, without date suffix or extension
  final String baseFilePath;

  /// Number of days to keep log files before deletion
  final int retentionDays;

  /// Creates a daily file log driver that writes to [baseFilePath]-YYYY-MM-DD.log
  ///
  /// The [retentionDays] parameter controls how long log files are kept before
  /// being automatically deleted. Defaults to 14 days.
  DailyFileLogDriver(this.baseFilePath, {this.retentionDays = 14})
      : super("file") {
    _cleanupOldFiles();
  }

  @override
  Future<void> log(LogEntry entry) async {
    final formattedMessage = entry.message.toString();
    final dateSuffix = DateTime.now().toIso8601String().split('T').first;
    final filePath = '$baseFilePath-$dateSuffix.log';
    final file = File(filePath);

    if (!await file.exists()) {
      await file.create(recursive: true);
    }

    await file.writeAsString('$formattedMessage\n', mode: FileMode.append);
    _cleanupOldFiles();
  }

  /// Removes log files that are older than [retentionDays].
  ///
  /// This method:
  /// 1. Scans the log directory for files matching the naming pattern
  /// 2. Extracts the date from each file name
  /// 3. Deletes files whose dates are older than [retentionDays]
  ///
  /// File deletion errors are silently ignored to prevent disruption of logging.
  void _cleanupOldFiles() {
    final logDir = File(baseFilePath).parent;
    if (!logDir.existsSync()) {
      return;
    }

    final now = DateTime.now();
    final files = logDir.listSync().whereType<File>();

    for (final file in files) {
      final filename = file.path.split(Platform.pathSeparator).last;
      final regex = RegExp(r'^(.+)-(\d{4}-\d{2}-\d{2})\.log$');
      final match = regex.firstMatch(filename);

      if (match != null) {
        final datePart = match.group(2);
        if (datePart != null) {
          final fileDate = DateTime.tryParse(datePart);
          if (fileDate != null) {
            final difference = now.difference(fileDate).inDays;
            if (difference >= retentionDays) {
              try {
                file.deleteSync();
              } catch (e) {
                // Silently ignore deletion errors
              }
            }
          }
        }
      }
    }
  }
}
