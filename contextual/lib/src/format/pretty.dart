import 'package:ansicolor/ansicolor.dart';
import 'package:contextual/src/log_level.dart';
import 'package:contextual/src/record.dart';
import 'package:contextual/src/util.dart';

import 'message_formatter.dart';

/// A formatter that outputs log messages with ANSI colors for terminal display.
///
/// This formatter produces human-readable output with color-coded components
/// for improved readability in terminal environments. Each log level has its
/// own color scheme:
///
/// * DEBUG - Blue
/// * INFO - Green
/// * NOTICE - Cyan
/// * WARNING - Yellow
/// * ERROR - Red
/// * ALERT/EMERGENCY - Bold Red
///
/// The output format is:
/// ```
/// [2024-02-15 10:30:45.123] [INFO] [prefix] Message | Context: {key: value}
/// ```
///
/// Components:
/// * Timestamp - Gray
/// * Log Level - Level-specific color
/// * Prefix - Cyan (if present)
/// * Message - Default terminal color
/// * Context - Magenta (if present)
///
/// Note: This formatter requires a terminal that supports ANSI color codes.
/// Colors may not display correctly in all environments.
class PrettyLogFormatter extends LogMessageFormatter {
  /// Creates a pretty formatter with the default color scheme.
  ///
  /// Uses [FormatterSettings] to control which components are included
  /// in the output.
  PrettyLogFormatter({super.settings});

  @override
  String format(LogRecord record) {
    // Define ANSI color pens for different log levels
    AnsiPen levelPen;
    switch (record.level) {
      case Level.debug:
        levelPen = AnsiPen()..blue();
        break;
      case Level.info:
        levelPen = AnsiPen()..green();
        break;
      case Level.notice:
        levelPen = AnsiPen()..cyan();
        break;
      case Level.warning:
        levelPen = AnsiPen()..yellow();
        break;
      case Level.error:
        levelPen = AnsiPen()..red();
        break;
      case Level.alert:
      case Level.emergency:
        levelPen = AnsiPen()..red(bold: true);
        break;
      default:
        levelPen = AnsiPen()..white();
    }

    StringBuffer buffer = StringBuffer();

    // Add timestamp in gray
    if (settings.includeTimestamp) {
      final now = DateTime.now();
      final timestamp = settings.timestampFormat.format(now);
      buffer.write((AnsiPen()..gray())('[$timestamp] '));
    }

    // Add log level in level-specific color
    if (settings.includeLevel) {
      buffer.write(levelPen('[${record.level}] '));
    }

    // Add prefix in cyan if present
    if (settings.includePrefix && record.context.has('prefix')) {
      final prefix = record.context.get('prefix');
      buffer.write((AnsiPen()..cyan())('[$prefix] '));
    }

    // Add the main message
    final formattedMessage = interpolateMessage(record.message, record.context);
    buffer.write(formattedMessage);

    // Add context data in magenta if present
    final contextData = settings.includeHidden
        ? record.context.all()
        : record.context.visible();
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
