// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'log_config.dart';

class TypedLogConfigMapper extends ClassMapperBase<TypedLogConfig> {
  TypedLogConfigMapper._();

  static TypedLogConfigMapper? _instance;
  static TypedLogConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TypedLogConfigMapper._());
      FormatterSettingsTypedMapper.ensureInitialized();
      BatchingConfigMapper.ensureInitialized();
      TypedChannelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TypedLogConfig';

  static String? _$level(TypedLogConfig v) => v.level;
  static const Field<TypedLogConfig, String> _f$level = Field(
    'level',
    _$level,
    opt: true,
  );
  static String? _$formatter(TypedLogConfig v) => v.formatter;
  static const Field<TypedLogConfig, String> _f$formatter = Field(
    'formatter',
    _$formatter,
    opt: true,
  );
  static FormatterSettingsTyped? _$formatterSettings(TypedLogConfig v) =>
      v.formatterSettings;
  static const Field<TypedLogConfig, FormatterSettingsTyped>
  _f$formatterSettings = Field(
    'formatterSettings',
    _$formatterSettings,
    opt: true,
  );
  static String _$environment(TypedLogConfig v) => v.environment;
  static const Field<TypedLogConfig, String> _f$environment = Field(
    'environment',
    _$environment,
    opt: true,
    def: 'production',
  );
  static BatchingConfig? _$batching(TypedLogConfig v) => v.batching;
  static const Field<TypedLogConfig, BatchingConfig> _f$batching = Field(
    'batching',
    _$batching,
    opt: true,
  );
  static Map<String, dynamic>? _$context(TypedLogConfig v) => v.context;
  static const Field<TypedLogConfig, Map<String, dynamic>> _f$context = Field(
    'context',
    _$context,
    opt: true,
  );
  static List<TypedChannel> _$channels(TypedLogConfig v) => v.channels;
  static const Field<TypedLogConfig, List<TypedChannel>> _f$channels = Field(
    'channels',
    _$channels,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<TypedLogConfig> fields = const {
    #level: _f$level,
    #formatter: _f$formatter,
    #formatterSettings: _f$formatterSettings,
    #environment: _f$environment,
    #batching: _f$batching,
    #context: _f$context,
    #channels: _f$channels,
  };

  static TypedLogConfig _instantiate(DecodingData data) {
    return TypedLogConfig(
      level: data.dec(_f$level),
      formatter: data.dec(_f$formatter),
      formatterSettings: data.dec(_f$formatterSettings),
      environment: data.dec(_f$environment),
      batching: data.dec(_f$batching),
      context: data.dec(_f$context),
      channels: data.dec(_f$channels),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static TypedLogConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TypedLogConfig>(map);
  }

  static TypedLogConfig fromJson(String json) {
    return ensureInitialized().decodeJson<TypedLogConfig>(json);
  }
}

mixin TypedLogConfigMappable {
  String toJson() {
    return TypedLogConfigMapper.ensureInitialized().encodeJson<TypedLogConfig>(
      this as TypedLogConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return TypedLogConfigMapper.ensureInitialized().encodeMap<TypedLogConfig>(
      this as TypedLogConfig,
    );
  }

  TypedLogConfigCopyWith<TypedLogConfig, TypedLogConfig, TypedLogConfig>
  get copyWith => _TypedLogConfigCopyWithImpl<TypedLogConfig, TypedLogConfig>(
    this as TypedLogConfig,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return TypedLogConfigMapper.ensureInitialized().stringifyValue(
      this as TypedLogConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return TypedLogConfigMapper.ensureInitialized().equalsValue(
      this as TypedLogConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return TypedLogConfigMapper.ensureInitialized().hashValue(
      this as TypedLogConfig,
    );
  }
}

extension TypedLogConfigValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TypedLogConfig, $Out> {
  TypedLogConfigCopyWith<$R, TypedLogConfig, $Out> get $asTypedLogConfig =>
      $base.as((v, t, t2) => _TypedLogConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class TypedLogConfigCopyWith<$R, $In extends TypedLogConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  FormatterSettingsTypedCopyWith<
    $R,
    FormatterSettingsTyped,
    FormatterSettingsTyped
  >?
  get formatterSettings;
  BatchingConfigCopyWith<$R, BatchingConfig, BatchingConfig>? get batching;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get context;
  ListCopyWith<$R, TypedChannel, ObjectCopyWith<$R, TypedChannel, TypedChannel>>
  get channels;
  $R call({
    String? level,
    String? formatter,
    FormatterSettingsTyped? formatterSettings,
    String? environment,
    BatchingConfig? batching,
    Map<String, dynamic>? context,
    List<TypedChannel>? channels,
  });
  TypedLogConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _TypedLogConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TypedLogConfig, $Out>
    implements TypedLogConfigCopyWith<$R, TypedLogConfig, $Out> {
  _TypedLogConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TypedLogConfig> $mapper =
      TypedLogConfigMapper.ensureInitialized();
  @override
  FormatterSettingsTypedCopyWith<
    $R,
    FormatterSettingsTyped,
    FormatterSettingsTyped
  >?
  get formatterSettings => $value.formatterSettings?.copyWith.$chain(
    (v) => call(formatterSettings: v),
  );
  @override
  BatchingConfigCopyWith<$R, BatchingConfig, BatchingConfig>? get batching =>
      $value.batching?.copyWith.$chain((v) => call(batching: v));
  @override
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get context => $value.context != null
      ? MapCopyWith(
          $value.context!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(context: v),
        )
      : null;
  @override
  ListCopyWith<$R, TypedChannel, ObjectCopyWith<$R, TypedChannel, TypedChannel>>
  get channels => ListCopyWith(
    $value.channels,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(channels: v),
  );
  @override
  $R call({
    Object? level = $none,
    Object? formatter = $none,
    Object? formatterSettings = $none,
    String? environment,
    Object? batching = $none,
    Object? context = $none,
    List<TypedChannel>? channels,
  }) => $apply(
    FieldCopyWithData({
      if (level != $none) #level: level,
      if (formatter != $none) #formatter: formatter,
      if (formatterSettings != $none) #formatterSettings: formatterSettings,
      if (environment != null) #environment: environment,
      if (batching != $none) #batching: batching,
      if (context != $none) #context: context,
      if (channels != null) #channels: channels,
    }),
  );
  @override
  TypedLogConfig $make(CopyWithData data) => TypedLogConfig(
    level: data.get(#level, or: $value.level),
    formatter: data.get(#formatter, or: $value.formatter),
    formatterSettings: data.get(
      #formatterSettings,
      or: $value.formatterSettings,
    ),
    environment: data.get(#environment, or: $value.environment),
    batching: data.get(#batching, or: $value.batching),
    context: data.get(#context, or: $value.context),
    channels: data.get(#channels, or: $value.channels),
  );

  @override
  TypedLogConfigCopyWith<$R2, TypedLogConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _TypedLogConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

