import 'dart:math' as math;

import 'package:contextual/src/driver/driver.dart';
import 'package:contextual/src/log_level.dart';

/// A log driver that samples log messages based on configured sampling rates per log level.
///
/// This driver wraps another [LogDriver] implementation and selectively forwards log messages
/// based on a configured sampling rate for each log level. This can be used to reduce the
/// volume of logs without completely disabling logging for certain levels.
class SamplingLogDriver extends LogDriver {
  final LogDriver wrappedDriver;
  final Map<String, double> samplingRates; // Sampling rates per log level
  final math.Random _random = math.Random();

  /// Constructs a new [SamplingLogDriver] that wraps the provided [wrappedDriver] and applies
  /// the specified [samplingRates] to log messages.
  ///
  /// The [samplingRates] map should contain the sampling rate (between 0.0 and 1.0) for each
  /// log level that should be sampled. Any log levels not specified in the map will be logged
  /// at 100% (no sampling).
  SamplingLogDriver(this.wrappedDriver, {required this.samplingRates})
      : super("sampling");

  @override

  /// Logs the provided formatted message, sampling the log based on the configured sampling rates.
  ///
  /// If a sampling rate is configured for the log level of the message, a random sample is taken
  /// and the message is only forwarded to the wrapped log driver if the sample is within the
  /// configured rate. Otherwise, the message is skipped and a message is printed indicating
  /// that the log was sampled out.
  Future<void> log(String formattedMessage) async {
    final Level = _extractLevel(formattedMessage);

    // If no sampling rate is specified for this level, default to 100% logging
    final sampleRate = samplingRates[Level] ?? 1.0;

    if (_random.nextDouble() < sampleRate) {
      await wrappedDriver
          .log(formattedMessage); // Forward log if within sample rate
    } else {
      print('[Sampled Out] Skipping log for level: $Level');
    }
  }

  String _extractLevel(String formattedMessage) {
    final regex = RegExp(r'\[(.*?)\]');
    final match = regex.firstMatch(formattedMessage);
    return match?.group(1)?.toLowerCase() ?? Level.info.toLowerCase();
  }
}
