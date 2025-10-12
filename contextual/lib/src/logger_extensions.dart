import 'driver/driver.dart';
import 'logger.dart';
import 'sink.dart';

extension LoggerBatching on Logger {
  Future<Logger> batched([LogSinkConfig? config]) async {
    return await enableDriverBatching(config: config);
  }

  Future<Logger> unbatched() async {
    return await disableDriverBatching();
  }
}

extension LoggerChannelSelection on Logger {
  // Select a single channel in a fluent, darty way: logger['console'].info(...)
  Logger operator [](String channel) => this[channel];

  // Select a single channel with a named method.
  Logger channel(String channel) => this[channel];

  // Select multiple channels with an iterable.
  Logger channels(Iterable<String> names) {
    for (final n in names) {
      this[n];
    }
    return this;
  }
}

extension LoggerTypeSelection on Logger {
  // Target all channels whose driver is of type T. Optionally filter by channel name.
  Logger forDriver<T extends LogDriver>({String? name}) {
    return (this).forDriver<T>(name: name);
  }

  // Target channels whose driver types are in the provided list.
  Logger channelsByTypes(Iterable<Type> types) {
    return (this).forDrivers(types);
  }
}
