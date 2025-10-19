import 'dart:math' as math;

import 'package:contextual/src/driver/driver.dart';
import 'package:contextual/src/log_entry.dart';
import 'package:contextual/src/log_level.dart';

/// A log driver that samples log messages based on configured sampling rates.
///
/// This driver reduces log volume by randomly sampling messages at different rates
/// per log level. For example, you might want to log:
/// * 100% of ERROR messages
/// * 50% of WARNING messages
/// * 10% of DEBUG messages
///
/// Example:
/// ```dart
/// final driver = SamplingLogDriver(
///   ConsoleLogDriver(),
///   samplingRates: {
///     Level.error: 1.0,    // Log all errors
///     Level.warning: 0.5,  // Log 50% of warnings
///     Level.debug: 0.1,    // Log 10% of debug messages
///   },
/// );
/// ```
///
/// Log levels not specified in [samplingRates] are logged at 100% (no sampling).
/// Sampling rates should be between 0.0 (log nothing) and 1.0 (log everything).
class SamplingLogDriver extends LogDriver {
  /// The underlying driver that actually writes the logs
  final LogDriver wrappedDriver;

  /// Sampling rates per log level, between 0.0 and 1.0
  final Map<Level, double> samplingRates;

  /// Random number generator for sampling decisions
  final math.Random _random = math.Random();

  /// Creates a sampling log driver that wraps another driver.
  ///
  /// The [wrappedDriver] is the underlying driver that will receive sampled logs.
  /// The [samplingRates] map specifies the sampling rate for each log level.
  ///
  /// Sampling rates must be between 0.0 and 1.0, where:
  /// * 0.0 means never log messages at this level
  /// * 1.0 means always log messages at this level
  /// * 0.5 means log approximately half of the messages at this level
  SamplingLogDriver(this.wrappedDriver, {required this.samplingRates})
    : super("sampling");

  /// Construct from typed options and a resolved wrapped driver.
  static SamplingLogDriver fromOptions(
    LogDriver wrapped,
    Map<Level, double> rates,
  ) => SamplingLogDriver(wrapped, samplingRates: rates);

  @override
  /// Logs the provided formatted message, sampling the log based on the configured sampling rates.
  ///
  /// If a sampling rate is configured for the log level of the message, a random sample is taken
  /// and the message is only forwarded to the wrapped log driver if the sample is within the
  /// configured rate. Otherwise, the message is skipped and a message is printed indicating
  /// that the log was sampled out.
  Future<void> log(LogEntry entry) async {
    final level = entry.record.level;

    // If no sampling rate is specified for this level, default to 100% logging
    final sampleRate = samplingRates[level] ?? 1.0;

    if (_random.nextDouble() < sampleRate) {
      await wrappedDriver.log(entry); // Forward log if within sample rate
    }
  }
}
