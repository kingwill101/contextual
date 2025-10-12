import 'package:dart_mappable/dart_mappable.dart';

part 'daily_file_options.mapper.dart';

@MappableClass()
class DailyFileOptions with DailyFileOptionsMappable {
  final String path;
  final int retentionDays;
  final Duration flushInterval;

  const DailyFileOptions({
    required this.path,
    this.retentionDays = 14,
    this.flushInterval = const Duration(milliseconds: 500),
  });
}
