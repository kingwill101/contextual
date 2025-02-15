import 'dart:convert';
import 'package:contextual/contextual.dart';

/// Custom formatter that outputs logs in XML format
class XmlLogFormatter extends LogMessageFormatter {
  @override
  String format(LogRecord record) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<log>');
    buffer.writeln(
        '  <timestamp>${DateTime.now().toIso8601String()}</timestamp>');
    buffer.writeln('  <level>${record.level}</level>');
    buffer.writeln('  <message>${_escapeXml(record.message)}</message>');

    final contextData = record.context.all();
    if (contextData.isNotEmpty) {
      buffer.writeln('  <context>');
      for (final entry in contextData.entries) {
        buffer.writeln(
            '    <${entry.key}>${_escapeXml(entry.value.toString())}</${entry.key}>');
      }
      buffer.writeln('  </context>');
    }

    buffer.writeln('</log>');
    return buffer.toString();
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

/// Custom formatter that outputs logs in CSV format
class CsvLogFormatter extends LogMessageFormatter {
  final String separator;
  final List<String> columns;

  CsvLogFormatter({
    this.separator = ',',
    this.columns = const ['timestamp', 'level', 'message', 'context'],
  });

  @override
  String format(LogRecord record) {
    final values = <String>[];
    final contextData = record.context.all();

    for (final column in columns) {
      switch (column) {
        case 'timestamp':
          values.add(DateTime.now().toIso8601String());
          break;
        case 'level':
          values.add(record.level.toString());
          break;
        case 'message':
          values.add(_escapeCsv(record.message));
          break;
        case 'context':
          values.add(_escapeCsv(jsonEncode(contextData)));
          break;
      }
    }

    return values.join(separator);
  }

  String _escapeCsv(String text) {
    if (text.contains(separator) || text.contains('"') || text.contains('\n')) {
      return '"${text.replaceAll('"', '""')}"';
    }
    return text;
  }
}

/// Custom formatter that outputs logs in a custom metrics format
class MetricsLogFormatter extends LogMessageFormatter {
  @override
  String format(LogRecord record) {
    final contextData = record.context.all();
    if (!contextData.containsKey('metric')) {
      return ''; // Skip non-metric logs
    }

    final metric = contextData['metric'];
    final value = contextData['value'] ?? 0;
    final tags = Map<String, dynamic>.from(contextData)
      ..remove('metric')
      ..remove('value');

    final tagString = tags.entries.map((e) => '${e.key}=${e.value}').join(',');

    return '$metric{$tagString} $value ${DateTime.now().millisecondsSinceEpoch}';
  }
}

/// This example demonstrates how to create and use custom log formatters.
void main() async {
  // Create logger with XML formatter
  final xmlLogger = Logger(
    formatter: XmlLogFormatter(),
  )..addChannel('console', ConsoleLogDriver());

  // Log with XML formatting
  xmlLogger.info(
      'User login successful',
      Context({
        'userId': '12345',
        'role': 'admin',
        'ip': '192.168.1.1',
      }));

  // Create logger with CSV formatter
  final csvLogger = Logger(
    formatter: CsvLogFormatter(
      separator: '|',
      columns: ['timestamp', 'level', 'message'],
    ),
  )..addChannel('file', DailyFileLogDriver('logs/audit.log'));

  // Log with CSV formatting
  csvLogger.info(
      'Configuration changed',
      Context({
        'component': 'database',
        'setting': 'max_connections',
        'old_value': 100,
        'new_value': 200,
      }));

  // Create logger with metrics formatter
  final metricsLogger = Logger(
    formatter: MetricsLogFormatter(),
  )..addChannel('statsd', ConsoleLogDriver());

  // Log metrics
  metricsLogger.info(
      'System metrics',
      Context({
        'metric': 'system.cpu.usage',
        'value': 45.2,
        'host': 'web-01',
        'datacenter': 'us-east',
      }));

  metricsLogger.info(
      'Application metrics',
      Context({
        'metric': 'app.requests.total',
        'value': 1234,
        'endpoint': '/api/users',
        'method': 'GET',
      }));

  // Multiple formatters example
  final multiLogger = Logger()
    ..addChannel(
      'xml',
      ConsoleLogDriver(),
      formatter: XmlLogFormatter(),
    )
    ..addChannel(
      'csv',
      DailyFileLogDriver('logs/audit.log'),
      formatter: CsvLogFormatter(),
    )
    ..addChannel(
      'metrics',
      WebhookLogDriver(Uri.parse('https://metrics.example.com')),
      formatter: MetricsLogFormatter(),
    );

  // Log to all channels - each using its own formatter
  multiLogger.info(
      'System status update',
      Context({
        'metric': 'system.status',
        'value': 1,
        'status': 'healthy',
        'uptime': '5d 12h',
      }));

  // Cleanup
  await xmlLogger.shutdown();
  await csvLogger.shutdown();
  await metricsLogger.shutdown();
  await multiLogger.shutdown();
}
