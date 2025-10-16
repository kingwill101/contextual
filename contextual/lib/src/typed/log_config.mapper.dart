// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'log_config.dart';

class LogConfigMapper extends ClassMapperBase<LogConfig> {
  LogConfigMapper._();

  static LogConfigMapper? _instance;
  static LogConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = LogConfigMapper._());
      FormatterSettingsMapper.ensureInitialized();
      BatchingConfigMapper.ensureInitialized();
      ChannelConfigMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'LogConfig';

  static String? _$level(LogConfig v) => v.level;
  static const Field<LogConfig, String> _f$level = Field(
    'level',
    _$level,
    opt: true,
  );
  static String? _$formatter(LogConfig v) => v.formatter;
  static const Field<LogConfig, String> _f$formatter = Field(
    'formatter',
    _$formatter,
    opt: true,
  );
  static FormatterSettings? _$formatterSettings(LogConfig v) =>
      v.formatterSettings;
  static const Field<LogConfig, FormatterSettings> _f$formatterSettings = Field(
    'formatterSettings',
    _$formatterSettings,
    opt: true,
  );
  static String _$environment(LogConfig v) => v.environment;
  static const Field<LogConfig, String> _f$environment = Field(
    'environment',
    _$environment,
    opt: true,
    def: 'production',
  );
  static BatchingConfig? _$batching(LogConfig v) => v.batching;
  static const Field<LogConfig, BatchingConfig> _f$batching = Field(
    'batching',
    _$batching,
    opt: true,
  );
  static Map<String, dynamic>? _$context(LogConfig v) => v.context;
  static const Field<LogConfig, Map<String, dynamic>> _f$context = Field(
    'context',
    _$context,
    opt: true,
  );
  static List<ChannelConfig> _$channels(LogConfig v) => v.channels;
  static const Field<LogConfig, List<ChannelConfig>> _f$channels = Field(
    'channels',
    _$channels,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<LogConfig> fields = const {
    #level: _f$level,
    #formatter: _f$formatter,
    #formatterSettings: _f$formatterSettings,
    #environment: _f$environment,
    #batching: _f$batching,
    #context: _f$context,
    #channels: _f$channels,
  };

  static LogConfig _instantiate(DecodingData data) {
    return LogConfig(
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

  static LogConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<LogConfig>(map);
  }

  static LogConfig fromJson(String json) {
    return ensureInitialized().decodeJson<LogConfig>(json);
  }
}

mixin LogConfigMappable {
  String toJson() {
    return LogConfigMapper.ensureInitialized().encodeJson<LogConfig>(
      this as LogConfig,
    );
  }

  Map<String, dynamic> toMap() {
    return LogConfigMapper.ensureInitialized().encodeMap<LogConfig>(
      this as LogConfig,
    );
  }

  LogConfigCopyWith<LogConfig, LogConfig, LogConfig> get copyWith =>
      _LogConfigCopyWithImpl<LogConfig, LogConfig>(
        this as LogConfig,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return LogConfigMapper.ensureInitialized().stringifyValue(
      this as LogConfig,
    );
  }

  @override
  bool operator ==(Object other) {
    return LogConfigMapper.ensureInitialized().equalsValue(
      this as LogConfig,
      other,
    );
  }

  @override
  int get hashCode {
    return LogConfigMapper.ensureInitialized().hashValue(this as LogConfig);
  }
}

extension LogConfigValueCopy<$R, $Out> on ObjectCopyWith<$R, LogConfig, $Out> {
  LogConfigCopyWith<$R, LogConfig, $Out> get $asLogConfig =>
      $base.as((v, t, t2) => _LogConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class LogConfigCopyWith<$R, $In extends LogConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  FormatterSettingsCopyWith<$R, FormatterSettings, FormatterSettings>?
  get formatterSettings;
  BatchingConfigCopyWith<$R, BatchingConfig, BatchingConfig>? get batching;
  MapCopyWith<$R, String, dynamic, ObjectCopyWith<$R, dynamic, dynamic>>?
  get context;
  ListCopyWith<
    $R,
    ChannelConfig,
    ObjectCopyWith<$R, ChannelConfig, ChannelConfig>
  >
  get channels;
  $R call({
    String? level,
    String? formatter,
    FormatterSettings? formatterSettings,
    String? environment,
    BatchingConfig? batching,
    Map<String, dynamic>? context,
    List<ChannelConfig>? channels,
  });
  LogConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _LogConfigCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, LogConfig, $Out>
    implements LogConfigCopyWith<$R, LogConfig, $Out> {
  _LogConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<LogConfig> $mapper =
      LogConfigMapper.ensureInitialized();
  @override
  FormatterSettingsCopyWith<$R, FormatterSettings, FormatterSettings>?
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
  ListCopyWith<
    $R,
    ChannelConfig,
    ObjectCopyWith<$R, ChannelConfig, ChannelConfig>
  >
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
    List<ChannelConfig>? channels,
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
  LogConfig $make(CopyWithData data) => LogConfig(
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
  LogConfigCopyWith<$R2, LogConfig, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _LogConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

