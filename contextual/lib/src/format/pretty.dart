import '../context.dart';
import 'message_formatter.dart';
import 'package:ansicolor/ansicolor.dart';

/// A formatter that outputs log messages in a colored, human-readable format.
class PrettyLogFormatter extends LogMessageFormatter {
  PrettyLogFormatter({super.settings});

  @override
  String format(String level, String message, Context context) {
    // Define ANSI color pens for different log levels
    AnsiPen levelPen;
    switch (level.toLowerCase()) {
      case 'debug':
        levelPen = AnsiPen()..blue();
        break;
      case 'info':
        levelPen = AnsiPen()..green();
        break;
      case 'notice':
        levelPen = AnsiPen()..cyan();
        break;
      case 'warning':
        levelPen = AnsiPen()..yellow();
        break;
      case 'error':
        levelPen = AnsiPen()..red();
        break;
      case 'critical':
      case 'alert':
      case 'emergency':
        levelPen = AnsiPen()..red(bold: true);
        break;
      default:
        levelPen = AnsiPen()..white();
    }

    // Set up the timestamp
    StringBuffer buffer = StringBuffer();
    if (settings.includeTimestamp) {
      final now = DateTime.now();
      final timestamp = settings.timestampFormat.format(now);
      buffer.write((AnsiPen()..gray())('$timestamp '));
    }

    // Include the log level
    if (settings.includeLevel) {
      buffer.write(levelPen('[$level] '));
    }

    // Include prefix if enabled and present
    if (settings.includePrefix && context.has('prefix')) {
      final prefix = context.get('prefix');
      buffer.write((AnsiPen()..cyan())('[$prefix] '));
    }

    // Add the log message
    buffer.write(message);

    // Include context data if available
    final contextData =
        settings.includeHidden ? context.all() : context.visible();
    if (settings.includeContext && contextData.isNotEmpty) {
      buffer.write(' ');
      buffer.write((AnsiPen()..magenta())('| Context: '));
      final magentaPen = AnsiPen()..magenta();
      final entries = contextData.entries
          .map((entry) => '${magentaPen(entry.key)}: ${entry.value}')
          .join(', ');
      buffer.write('{$entries}');
    }

    return buffer.toString();
  }
}
