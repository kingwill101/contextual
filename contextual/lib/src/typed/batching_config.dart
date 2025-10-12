import 'package:dart_mappable/dart_mappable.dart';

part 'batching_config.mapper.dart';

@MappableClass()
class BatchingConfig with BatchingConfigMappable {
  final bool enabled;
  final int batchSize;
  final Duration flushInterval;
  final Duration autoCloseAfter;

  const BatchingConfig({
    required this.enabled,
    this.batchSize = 10,
    this.flushInterval = const Duration(milliseconds: 500),
    this.autoCloseAfter = const Duration(seconds: 2),
  });
}
