import 'dart:convert';

final _logfmtKeyChar = RegExp(r'[A-Za-z0-9_.:-]');

String formatLogfmtKey(String key) {
  if (key.isEmpty) {
    return 'context';
  }
  final buffer = StringBuffer();
  for (final rune in key.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_logfmtKeyChar.hasMatch(char) ? char : '_');
  }
  return buffer.toString();
}

String formatLogfmtValue(Object? value) {
  final raw = _stringifyLogfmtValue(value);
  if (_needsLogfmtQuoting(raw)) {
    return '"${_escapeLogfmt(raw)}"';
  }
  return raw;
}

Map<String, dynamic> flattenLogfmtContext(
  Map<String, dynamic> context, {
  String prefix = '',
}) {
  final flattened = <String, dynamic>{};

  void addEntry(String key, dynamic value) {
    final fullKey = prefix.isEmpty ? key : '$prefix$key';
    if (value is Map) {
      value.forEach((nestedKey, nestedValue) {
        final nestedKeyString = nestedKey?.toString() ?? '';
        final combinedKey = fullKey.isEmpty
            ? nestedKeyString
            : '$fullKey.$nestedKeyString';
        flattened.addAll(
          flattenLogfmtContext(<String, dynamic>{combinedKey: nestedValue}),
        );
      });
      return;
    }
    flattened[fullKey] = value;
  }

  context.forEach((key, value) {
    addEntry(key, value);
  });

  return flattened;
}

String _stringifyLogfmtValue(Object? value) {
  if (value == null) return 'null';
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  if (value is DateTime) return value.toIso8601String();
  if (value is Map || value is Iterable) {
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }
  return value.toString();
}

bool _needsLogfmtQuoting(String value) {
  if (value.isEmpty) return true;
  for (var i = 0; i < value.length; i++) {
    final code = value.codeUnitAt(i);
    if (code == 0x20 || code == 0x09 || code == 0x0A || code == 0x0D) {
      return true;
    }
    if (code == 0x22 || code == 0x5C || code == 0x3D) {
      return true;
    }
  }
  return false;
}

String _escapeLogfmt(String value) {
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    switch (rune) {
      case 0x22:
        buffer.write(r'\"');
        break;
      case 0x5C:
        buffer.write(r'\\');
        break;
      case 0x0A:
        buffer.write(r'\n');
        break;
      case 0x0D:
        buffer.write(r'\r');
        break;
      case 0x09:
        buffer.write(r'\t');
        break;
      default:
        buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}
