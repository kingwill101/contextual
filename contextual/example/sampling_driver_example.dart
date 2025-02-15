import 'package:contextual/contextual.dart';

/// This example demonstrates log sampling with different rates per log level.
/// It shows how to reduce log volume while maintaining important information.
void main() async {
  // Create a console driver for output
  final consoleDriver = ConsoleLogDriver();

  // Create a sampling driver that wraps the console driver
  final samplingDriver = SamplingLogDriver(
    consoleDriver,
    samplingRates: {
      Level.error: 1.0, // Log all errors
      Level.warning: 0.5, // Log 50% of warnings
      Level.info: 0.2, // Log 20% of info messages
      Level.debug: 0.1, // Log 10% of debug messages
    },
  );

  // Create a logger with the sampling driver
  final logger = Logger()
    ..addChannel(
      'sampled',
      samplingDriver,
      formatter: PrettyLogFormatter(),
    );

  // Demonstrate sampling with multiple messages
  for (var i = 0; i < 100; i++) {
    // Debug messages - expect ~10 to be logged
    logger.debug(
        'Debug message $i',
        Context({
          'iteration': i,
          'type': 'debug_loop',
        }));

    // Info messages - expect ~20 to be logged
    logger.info(
        'Info message $i',
        Context({
          'iteration': i,
          'type': 'info_loop',
        }));

    // Warning messages - expect ~50 to be logged
    logger.warning(
        'Warning message $i',
        Context({
          'iteration': i,
          'type': 'warning_loop',
        }));

    // Error messages - all 100 will be logged
    logger.error(
        'Error message $i',
        Context({
          'iteration': i,
          'type': 'error_loop',
        }));
  }

  // Example with multiple sampling drivers
  final multiLogger = Logger()
    ..addChannel(
      'metrics',
      SamplingLogDriver(
        ConsoleLogDriver(),
        samplingRates: {
          Level.debug: 0.01, // Log 1% of debug
          Level.info: 0.05, // Log 5% of info
          Level.warning: 0.2, // Log 20% of warnings
          Level.error: 1.0, // Log all errors
        },
      ),
      formatter: JsonLogFormatter(),
    )
    ..addChannel(
      'alerts',
      SamplingLogDriver(
        WebhookLogDriver(Uri.parse('https://alerts.example.com')),
        samplingRates: {
          Level.critical: 1.0, // Log all critical
          Level.alert: 1.0, // Log all alerts
          Level.emergency: 1.0, // Log all emergency
        },
      ),
      formatter: PlainTextLogFormatter(),
    );

  // Log high-volume metrics - most will be sampled out
  for (var i = 0; i < 1000; i++) {
    multiLogger.to(['metrics']).debug(
        'Metric update',
        Context({
          'metric': 'cpu_usage',
          'value': 45 + (i % 10),
          'timestamp': DateTime.now().toIso8601String(),
        }));
  }

  // Critical alerts - all will be logged
  multiLogger.to(['alerts']).critical(
      'System overload',
      Context({
        'component': 'database',
        'metrics': {
          'connections': 1500,
          'query_time': 2500,
          'memory_usage': '95%',
        },
      }));

  // Cleanup
  await logger.shutdown();
  await multiLogger.shutdown();
}
