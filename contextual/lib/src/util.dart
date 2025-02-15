import 'package:gato/gato.dart' as gato;

import 'context.dart';

/// Interpolates context values into a message string, supporting dot notation.
///
/// Takes a [message] string containing placeholders in the format `{some.key}`
/// and replaces them with corresponding values from the [context] using the
/// `.dot(key, defaultValue)` extension on maps.
///
/// If a context value is `null` or the key doesn't exist, it will not be replaced.
///
/// Example:
///
/// final context = Context({
///   'user': {
///     'name': 'Alice',
///     'details': {
///       'email': 'alice@example.com',
///     },
///   }
/// });
///
/// // "Name is {user.name} and email is {user.details.email}"
/// final message = 'Name is {user.name} and email is {user.details.email}';
/// final result = interpolateMessage(message, context);
/// // 'Name is Alice and email is alice@example.com'
///
/// Returns the interpolated message string.
String interpolateMessage(String message, Context context) {
  // This regex captures anything between { and }
  // (including dots, letters, underscores, digits, etc.).
  final placeholderPattern = RegExp(r'\{([^}]+)\}');

  // Find all matches (placeholders) in the message
  final matches = placeholderPattern.allMatches(message).toList();

  for (var match in matches) {
    final rawKey = match.group(1)!;
    // Use `.dot(rawKey, 'null')` to safely access nested data
    final value = context.all().dot(rawKey)?.toString();

    if (value == null) continue;
    if (!message.contains('{$rawKey}')) continue;
    // Replace all occurrences of the placeholder with the resolved value
    message = message.replaceAll('{$rawKey}', value);
  }

  return message;
}

extension MapExtension on Map<String, dynamic> {
  T? dot<T>(String key, [T? defaultValue]) {
    final val = gato.get(this, key) ?? defaultValue;
    return val;
  }
}
