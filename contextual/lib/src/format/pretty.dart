import 'package:ansicolor/ansicolor.dart';
import 'package:contextual/src/log_level.dart';
import 'package:contextual/src/record.dart';
import 'package:contextual/src/util.dart';

import 'logfmt.dart';
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
/// The output format is logfmt-style key/value pairs with colors:
/// ```
/// time="2024-02-15T10:30:45.123-05:00" level=info msg="Message" key=value
/// ```
///
/// Components:
/// * Keys - Gray
/// * Timestamp - Gray
/// * Log Level - Level-specific color
/// * Prefix - Cyan (if present)
/// * Message - Default terminal color
/// * Context Keys - Magenta (if present)
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

    final parts = <String>[];
    final keyPen = AnsiPen()..gray();

    // Add timestamp in gray
    if (settings.includeTimestamp) {
      final timestamp = settings.formatTimestamp(record.time);
      parts.add(
        '${keyPen('time')}=${(AnsiPen()..gray())(formatLogfmtValue(timestamp))}',
      );
    }

    // Add log level in level-specific color
    if (settings.includeLevel) {
      parts.add(
        '${keyPen('level')}=${levelPen(formatLogfmtValue(record.level.name))}',
      );
    }

    // Add prefix in cyan if present
    if (settings.includePrefix && record.context.has('prefix')) {
      final prefix = record.context.get('prefix');
      final prefixPen = AnsiPen()..cyan();
      parts.add('${keyPen('prefix')}=${prefixPen(formatLogfmtValue(prefix))}');
    }

    // Add the main message
    final formattedMessage = interpolateMessage(record.message, record.context);
    parts.add('${keyPen('msg')}=${formatLogfmtValue(formattedMessage)}');

    // Add context data in magenta if present
    final contextData = settings.includeHidden
        ? record.context.all()
        : record.context.visible();
    if (settings.includeContext && contextData.isNotEmpty) {
      final contextEntries = Map<String, dynamic>.from(contextData);
      if (settings.includePrefix) {
        contextEntries.remove('prefix');
      }
      final flattened = flattenLogfmtContext(contextEntries);
      final contextKeyPen = AnsiPen()..magenta();
      for (final entry in flattened.entries) {
        parts.add(
          '${contextKeyPen(formatLogfmtKey(entry.key))}=${formatLogfmtValue(entry.value)}',
        );
      }
    }

    if (record.stackTraceProvided && record.stackTrace != null) {
      final tracePen = AnsiPen()..red();
      parts.add(
        '${keyPen('stackTrace')}=${tracePen(formatLogfmtValue(record.stackTrace.toString()))}',
      );
    }

    return parts.join(' ');
  }
}
