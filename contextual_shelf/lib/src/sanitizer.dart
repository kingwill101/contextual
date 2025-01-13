class Sanitizer {
  String mask;

  Sanitizer({this.mask = '****'});

  Map<String, dynamic> clean(Map<String, dynamic> input, List<String> keys) {
    if (keys.isEmpty) {
      return input;
    }

    keys = keys.map((key) => key.toLowerCase()).toList();

    input.forEach((key, value) {
      final normalizedKey = key.toLowerCase();
      if (keys.contains(normalizedKey)) {
        input[key] = value is Map ? {mask} : mask;
      } else if (value is Map) {
        input[key] = clean(value.cast(), keys);
      }
    });

    return input;
  }
}
