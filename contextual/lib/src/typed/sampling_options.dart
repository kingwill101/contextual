import '../log_level.dart';

class SamplingOptions {
  final Map<Level, double> rates;
  final String wrappedChannel; // name of the channel/driver to wrap

  const SamplingOptions({required this.rates, required this.wrappedChannel});
}
