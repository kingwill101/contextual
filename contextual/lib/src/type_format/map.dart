import 'package:contextual/src/log_level.dart';

import '../context.dart';
import '../logtype_formatter.dart';

/// Formats [Map] objects with optional key/value type-specific formatting.
///
/// Uses nested type formatters to format individual map entries based on their
/// value types. This allows for specialized formatting of complex nested data
/// structures.
///
/// Example:
/// ```dart
/// final formatter = MapFormatter({
///   String: StringFormatter(),
///   int: NumberFormatter(),
///   DateTime: DateTimeFormatter()
/// });
///
/// logger.addTypeFormatter(formatter);
/// logger.info({'user': 'admin', 'count': 42});
/// ```
class MapFormatter extends LogTypeFormatter<Map> {
  /// Type-specific formatters for map values keyed by their type
  final Map<Type, LogTypeFormatter> _valueFormatters;

  /// Whether to format keys in addition to values
  final bool _formatKeys;

  /// Whether to sort entries by key before formatting
  final bool _sorted;

  /// Creates a formatter for Map objects with optional value formatters.
  ///
  /// Parameters:
  /// - [valueFormatters]: Formatters to use for specific value types
  /// - [formatKeys]: Whether to apply formatters to keys (defaults to false)
  /// - [sorted]: Whether to sort entries by key (defaults to true)
  const MapFormatter({
    Map<Type, LogTypeFormatter>? valueFormatters,
    bool formatKeys = false,
    bool sorted = true,
  })  : _valueFormatters = valueFormatters ?? const {},
        _formatKeys = formatKeys,
        _sorted = sorted;

  @override
  String format(Level level, Map message, Context context) {
    final buffer = StringBuffer();
    buffer.write('{');

    final entries = _sorted
        ? Map.fromEntries(message.entries.toList()
          ..sort((a, b) => a.key.toString().compareTo(b.key.toString())))
        : message;

    var first = true;
    for (final entry in entries.entries) {
      if (!first) buffer.write(', ');
      first = false;

      // Format the key if requested
      final key = _formatKeys
          ? _formatValue(level, entry.key, context)
          : entry.key.toString();

      // Format the value using type-specific formatter if available
      final value = _formatValue(level, entry.value, context);

      buffer.write('"$key": ${entry.value is Map ? "\"$value\"" : value}');
    }

    buffer.write('}');
    return buffer.toString();
  }

  /// Formats a single value using the appropriate type formatter.
  String _formatValue(Level level, dynamic value, Context context) {
    if (value == null) return 'null';

    final formatter = _valueFormatters[value.runtimeType];
    if (formatter != null) {
      return formatter.format(level, value, context);
    }

    // Handle nested maps recursively
    if (value is Map) {
      return format(level, value, context);
    }

    return value.toString();
  }
}
