// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'batching_config.dart';

class BatchingConfigMapper extends ClassMapperBase<BatchingConfig> {
  BatchingConfigMapper._();

  static BatchingConfigMapper? _instance;
  static BatchingConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = BatchingConfigMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'BatchingConfig';

  static bool _$enabled(BatchingConfig v) => v.enabled;
  static const Field<BatchingConfig, bool> _f$enabled = Field(
    'enabled',
    _$enabled,
  );
  static int _$batchSize(BatchingConfig v) => v.batchSize;
  static const Field<BatchingConfig, int> _f$batchSize = Field(
    'batchSize',
    _$batchSize,
    opt: true,
    def: 10,
  );
  static Duration _$flushInterval(BatchingConfig v) => v.flushInterval;
  static const Field<BatchingConfig, Duration> _f$flushInterval = Field(
    'flushInterval',
    _$flushInterval,
    opt: true,
    def: const Duration(milliseconds: 500),
  );
  static Duration _$autoCloseAfter(BatchingConfig v) => v.autoCloseAfter;
  static const Field<BatchingConfig, Duration> _f$autoCloseAfter = Field(
    'autoCloseAfter',
    _$autoCloseAfter,
    opt: true,
    def: const Duration(seconds: 2),
  );

  @override
  final MappableFields<BatchingConfig> fields = const {
    #enabled: _f$enabled,
    #batchSize: _f$batchSize,
    #flushInterval: _f$flushInterval,
    #autoCloseAfter: _f$autoCloseAfter,
  };

  static BatchingConfig _instantiate(DecodingData data) {
    return BatchingConfig(
      enabled: data.dec(_f$enabled),
      batchSize: data.dec(_f$batchSize),
      flushInterval: data.dec(_f$flushInterval),
      autoCloseAfter: data.dec(_f$autoCloseAfter),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static BatchingConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<BatchingConfig>(map);
  }

  static BatchingConfig fromJson(String json) {
    return ensureInitialized().decodeJson<BatchingConfig>(json);
  }
}

mixin BatchingConfigMappable {
  String toJson() {
    return BatchingConfigMapper.ensureInitialized().encodeJson<BatchingConfig>(
      this as BatchingConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return BatchingConfigMapper.ensureInitialized().encodeMap<BatchingConfig>(
      this as BatchingConfig,
    );
  }

  BatchingConfigCopyWith<BatchingConfig, BatchingConfig, BatchingConfig>
  get copyWith => _BatchingConfigCopyWithImpl<BatchingConfig, BatchingConfig>(
    this as BatchingConfig,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return BatchingConfigMapper.ensureInitialized().stringifyValue(
      this as BatchingConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return BatchingConfigMapper.ensureInitialized().equalsValue(
      this as BatchingConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return BatchingConfigMapper.ensureInitialized().hashValue(
      this as BatchingConfig,
    );
  }
}

extension BatchingConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, BatchingConfig, $Out> {
  BatchingConfigCopyWith<$R, BatchingConfig, $Out> get $asBatchingConfig =>
      $base.as((v, t, t2) => _BatchingConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class BatchingConfigCopyWith<$R, $In extends BatchingConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    bool? enabled,
    int? batchSize,
    Duration? flushInterval,
    Duration? autoCloseAfter,
  });
  BatchingConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _BatchingConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, BatchingConfig, $Out>
    implements BatchingConfigCopyWith<$R, BatchingConfig, $Out> {
  _BatchingConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<BatchingConfig> $mapper =
      BatchingConfigMapper.ensureInitialized();
  @override
  $R call({
    bool? enabled,
    int? batchSize,
    Duration? flushInterval,
    Duration? autoCloseAfter,
  }) => $apply(
    FieldCopyWithData({
      if (enabled != null) #enabled: enabled,
      if (batchSize != null) #batchSize: batchSize,
      if (flushInterval != null) #flushInterval: flushInterval,
      if (autoCloseAfter != null) #autoCloseAfter: autoCloseAfter,
    }),
  );
  @override
  BatchingConfig $make(CopyWithData data) => BatchingConfig(
    enabled: data.get(#enabled, or: $value.enabled),
    batchSize: data.get(#batchSize, or: $value.batchSize),
    flushInterval: data.get(#flushInterval, or: $value.flushInterval),
    autoCloseAfter: data.get(#autoCloseAfter, or: $value.autoCloseAfter),
  );

  @override
  BatchingConfigCopyWith<$R2, BatchingConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _BatchingConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

