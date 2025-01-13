import 'package:contextual/src/driver/driver.dart';
import 'package:universal_io/io.dart';

/// A [LogDriver] that writes log messages to a daily log file.
///
/// - [baseFilePath]: The base file path (e.g., 'logs/app') to which the
///    date suffix will be appended. The final file would look like
///    "logs/app-2025-01-15.log" for logs created on January 15, 2025.
/// - [retentionDays]: The number of days to keep log files. Older files
///    are automatically deleted during log operations.
class DailyFileLogDriver extends LogDriver {
  final String baseFilePath;
  final int retentionDays;

  DailyFileLogDriver(this.baseFilePath, {this.retentionDays = 14})
      : super("file") {
    // Optional: Initial cleanup on driver creation
    _cleanupOldFiles();
  }

  @override
  Future<void> log(String formattedMessage) async {
    // 1. Determine the current date's suffix (e.g., '2025-01-15')
    final dateSuffix = DateTime.now().toIso8601String().split('T').first;
    // 2. Create the full file path (e.g., 'logs/app-2025-01-15.log')
    final filePath = '$baseFilePath-$dateSuffix.log';
    final file = File(filePath);

    // 3. Create the file if it doesn't exist
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }

    // 4. Append the log message
    file.writeAsStringSync('$formattedMessage\n', mode: FileMode.append);

    // 5. (Optional) Trigger cleanup to remove old files
    _cleanupOldFiles();
  }

  /// Removes log files older than [retentionDays].
  ///
  /// This method checks all files matching the pattern
  /// `$baseFilePath-YYYY-MM-DD.log` in the same directory as [baseFilePath]
  /// and deletes those older than the retention period.
  void _cleanupOldFiles() {
    final logDir = File(baseFilePath).parent;
    if (!logDir.existsSync()) {
      return; // If the directory doesn't exist, nothing to do.
    }

    final now = DateTime.now();
    final files = logDir.listSync().whereType<File>();

    for (final file in files) {
      final filename = file.path.split(Platform.pathSeparator).last;

      // Check if the file matches our log pattern (e.g., app-2025-01-15.log).
      // You might need to adjust this regex based on your actual naming structure.
      final regex = RegExp(r'^(.+)-(\d{4}-\d{2}-\d{2})\.log$');
      final match = regex.firstMatch(filename);

      if (match != null) {
        // Extract the date part from the filename
        final datePart = match.group(2);
        if (datePart != null) {
          final fileDate = DateTime.tryParse(datePart);
          if (fileDate != null) {
            // Calculate how old this file is
            final difference = now.difference(fileDate).inDays;
            // Delete if older than retention
            if (difference >= retentionDays) {
              try {
                file.deleteSync();
                // (Optional) print or log that we removed an old file
              } catch (e) {
                // Handle file delete exception if needed
              }
            }
          }
        }
      }
    }
  }
}
