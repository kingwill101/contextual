/// A context object that stores and manages data for an application.
///
/// The `Context` class provides a way to store and retrieve data within an application.
/// It allows you to add key-value pairs to the context, and provides methods to
/// conditionally execute code based on the state of the context.
class Context {
  final Map<String, dynamic> _data = {};
  final Map<String, dynamic> _hiddenData = {};
  static final Context defaultInstance = Context();

  /// Constructs a new `Context` instance with an optional initial data map.
  Context([Map<String, dynamic>? initialData]) {
    if (initialData != null) {
      _data.addAll(initialData);
    }
  }

  /// Executes a callback based on the result of a condition.
  ///
  /// The `when` method takes a condition function, a callback to execute if the
  /// condition is true, and a callback to execute if the condition is false. It
  /// then calls the appropriate callback based on the result of the condition.
  ///
  /// This method is useful for conditionally executing code based on the state
  /// of the `Context` object.
  void when(
    bool Function() condition,
    void Function(Context) trueCallback,
    void Function(Context) falseCallback,
  ) {
    if (condition()) {
      trueCallback(this);
    } else {
      falseCallback(this);
    }
  }

  /// Executes a callback based on the negation of a condition.
  ///
  /// The `unless` method takes a condition function, a callback to execute if the
  /// condition is false, and an optional callback to execute if the condition is true.
  /// It then calls the appropriate callback based on the result of the condition.
  ///
  /// This method is useful for conditionally executing code based on the state
  /// of the `Context` object, where you want to execute a callback when a condition
  /// is false.
  void unless(
    bool Function() condition,
    void Function(Context) falseCallback,
    void Function(Context)? trueCallback,
  ) {
    if (!condition()) {
      falseCallback(this);
    } else {
      trueCallback?.call(this);
    }
  }

  /// Returns a new map containing only the key-value pairs from the `_data` map
  /// where the key is present in the provided `keys` list.
  Map<String, dynamic> only(List<String> keys) {
    return {
      for (var key in keys)
        if (_data.containsKey(key)) key: _data[key],
    };
  }

  /// Returns a new map containing only the key-value pairs from the `_hiddenData` map
  /// where the key is present in the provided `keys` list.
  Map<String, dynamic> onlyHidden(List<String> keys) {
    return {
      for (var key in keys)
        if (_hiddenData.containsKey(key)) key: _hiddenData[key],
    };
  }

  /// Adds a key-value pair to the context.
  ///
  /// If the key already exists in the context, the value will be overwritten.
  void add(String key, dynamic value) {
    _data[key] = value;
  }

  /// Adds the given [value] to the context under the specified [key] if the key does not already exist.
  ///
  /// If the [key] already exists in the context, the value will not be added and the existing value will be kept.
  void addIf(String key, dynamic value) {
    if (!has(key)) {
      add(key, value);
    }
  }

  /// Adds all the key-value pairs from the provided [values] map to the context's `_data` map.
  /// If a key already exists in the context, its value will be overwritten.
  void addAll(Map<String, dynamic> values) {
    _data.addAll(values);
  }

  // Get a value from the context
  /// Gets the value associated with the specified [key] from the context's `_data` map.
  ///
  /// If the [key] does not exist in the `_data` map, the [defaultValue] is returned instead.
  dynamic get(String key, [dynamic defaultValue]) => _data[key] ?? defaultValue;

  /// Checks if the context contains the specified [key].
  ///
  /// Returns `true` if the [key] exists in the `_data` map, `false` otherwise.
  bool has(String key) => _data.containsKey(key);

  /// Removes the key-value pair with the specified [key] from the context's `_data` map.
  ///
  /// Returns the value that was associated with the removed key, or `null` if the key did not exist.
  dynamic remove(String key) => _data.remove(key);

  /// Returns a new map that contains only the key-value pairs from the `_data` map.
  /// This provides access to the visible data in the context.
  Map<String, dynamic> visible() => {..._data};

  /// Returns a new map that merges the key-value pairs from the `_data` map and the `_hiddenData` map.
  /// This provides access to both the visible and hidden data in the context.
  Map<String, dynamic> all() => {
    ..._data,
    ..._hiddenData,
  }; // Merge visible + hidden

  /// Clears the data context, removing all key-value pairs.
  void clear() => _data.clear();

  /// Pushes the given [value] onto the context stack for the specified [key].
  /// If the stack for the given [key] does not exist, it will be created as an empty list.
  void push(String key, dynamic value) {
    if (_data[key] is! List) {
      _data[key] = [];
    }
    (_data[key] as List).add(value);
  }

  /// Removes and returns the last value from the context stack for the given [key].
  /// If the stack is empty or the key does not exist, returns `null`.
  dynamic pop(String key) {
    if (_data[key] is List && (_data[key] as List).isNotEmpty) {
      return (_data[key] as List).removeLast();
    }
    return null;
  }

  /// Checks if the context stack for the given [key] contains the specified [value].
  ///
  /// If [strict] is true, the check will be performed using strict equality (`===`).
  /// Otherwise, the check will use regular equality (`==`).
  bool stackContains(String key, dynamic value, {bool strict = false}) {
    if (_data[key] is List) {
      return (_data[key] as List).contains(value);
    }
    return false;
  }

  /// Adds a key-value pair to the hidden data context.
  ///
  /// The [key] is the identifier for the hidden data, and the [value] is the data to be stored.
  /// If the [key] already exists in the hidden data context, the value will be overwritten.
  void addHidden(String key, dynamic value) {
    _hiddenData[key] = value;
  }

  /// Gets a value from the hidden data context for the specified [key].
  ///
  /// If the [key] does not exist in the hidden data context, the [defaultValue] is returned.
  dynamic getHidden(String key, [dynamic defaultValue]) =>
      _hiddenData[key] ?? defaultValue;

  /// Removes the key-value pair associated with the specified [key] from the hidden data context.
  void forgetHidden(String key) {
    _hiddenData.remove(key);
  }

  /// Checks if the hidden data context contains the specified [key].
  ///
  /// Returns `true` if the [key] exists in the hidden data context, `false` otherwise.
  bool hasHidden(String key) => _hiddenData.containsKey(key);

  /// Returns a new map containing all the key-value pairs from the hidden context.
  Map<String, dynamic> allHidden() => {..._hiddenData};

  /// Pushes the given [value] onto the hidden context stack for the specified [key].
  /// If the stack for the given [key] does not exist, it will be created as an empty list.
  void pushHidden(String key, dynamic value) {
    if (_hiddenData[key] is! List) {
      _hiddenData[key] = [];
    }
    (_hiddenData[key] as List).add(value);
  }

  /// Removes and returns the last value from the hidden context stack for the
  /// given [key]. If the stack is empty or the key does not exist, returns `null`.
  dynamic popHidden(String key) {
    if (_hiddenData[key] is List && (_hiddenData[key] as List).isNotEmpty) {
      return (_hiddenData[key] as List).removeLast();
    }
    return null;
  }

  /// Checks if the hidden data stack for the given [key] contains the specified [value].
  ///
  /// If [strict] is true, the check will be performed using strict equality (`===`).
  /// Otherwise, the check will use regular equality (`==`).
  ///
  /// Returns `true` if the value is found in the stack, `false` otherwise.
  bool hiddenStackContains(String key, dynamic value, {bool strict = false}) {
    if (_hiddenData[key] is List) {
      return (_hiddenData[key] as List).contains(value);
    }
    return false;
  }

  @override
  /// Returns a string representation of the context, where each key-value pair
  /// is separated by a comma.
  String toString() =>
      _data.entries.map((e) => "${e.key}: ${e.value}").join(', ');

  /// Creates a new [Context] instance from the provided [contextData] map.
  ///
  /// The [contextData] map is iterated over, and each key-value pair is added to
  /// the new [Context] instance using the [add] method.
  ///
  /// Returns the newly created [Context] instance.
  static Context from(Map<String, dynamic> contextData) {
    final context = Context();
    contextData.forEach((key, value) {
      context.add(key, value);
    });
    return context;
  }
}
