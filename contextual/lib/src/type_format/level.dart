import 'package:contextual/src/log_level.dart';

import '../context.dart';
import '../logtype_formatter.dart';

/// Formats [Level] objects by converting them to uppercase strings.
///
/// This formatter handles [Level] enum values and converts them to their
/// uppercase string representation for logging output.
///
/// Example:
///
/// final formatter = LevelFormatter();
///
/// logger.addTypeFormatter(formatter);
/// logger.info(Level.info); // Will output "INFO"
///
class LevelFormatter extends LogTypeFormatter<Level> {
  const LevelFormatter();

  @override
  String format(Level level, Level message, Context context) {
    return message.toUpperCase();
  }
}
