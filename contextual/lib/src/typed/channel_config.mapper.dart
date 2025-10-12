// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'channel_config.dart';

class ChannelConfigMapper extends ClassMapperBase<ChannelConfig> {
  ChannelConfigMapper._();

  static ChannelConfigMapper? _instance;
  static ChannelConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ChannelConfigMapper._());
      ConsoleChannelMapper.ensureInitialized();
      DailyFileChannelMapper.ensureInitialized();
      StackChannelMapper.ensureInitialized();
      SamplingChannelMapper.ensureInitialized();
      WebhookChannelMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ChannelConfig';

  static String? _$name(ChannelConfig v) => v.name;
  static const Field<ChannelConfig, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static LogMessageFormatter? _$formatter(ChannelConfig v) => v.formatter;
  static const Field<ChannelConfig, LogMessageFormatter> _f$formatter = Field(
    'formatter',
    _$formatter,
    opt: true,
  );

  @override
  final MappableFields<ChannelConfig> fields = const {
    #name: _f$name,
    #formatter: _f$formatter,
  };

  static ChannelConfig _instantiate(DecodingData data) {
    throw MapperException.missingConstructor('ChannelConfig');
  }

  @override
  final Function instantiate = _instantiate;

  static ChannelConfig fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ChannelConfig>(map);
  }

  static ChannelConfig fromJson(String json) {
    return ensureInitialized().decodeJson<ChannelConfig>(json);
  }
}

mixin ChannelConfigMappable {
  String toJson();
  Map<String, dynamic> toMap();
  ChannelConfigCopyWith<ChannelConfig, ChannelConfig, ChannelConfig>
  get copyWith;
}

abstract class ChannelConfigCopyWith<$R, $In extends ChannelConfig, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, LogMessageFormatter? formatter});
  ChannelConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class ConsoleChannelMapper extends ClassMapperBase<ConsoleChannel> {
  ConsoleChannelMapper._();

  static ConsoleChannelMapper? _instance;
  static ConsoleChannelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConsoleChannelMapper._());
      ChannelConfigMapper.ensureInitialized();
      ConsoleOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ConsoleChannel';

  static ConsoleOptions _$options(ConsoleChannel v) => v.options;
  static const Field<ConsoleChannel, ConsoleOptions> _f$options = Field(
    'options',
    _$options,
  );
  static String? _$name(ConsoleChannel v) => v.name;
  static const Field<ConsoleChannel, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static LogMessageFormatter? _$formatter(ConsoleChannel v) => v.formatter;
  static const Field<ConsoleChannel, LogMessageFormatter> _f$formatter = Field(
    'formatter',
    _$formatter,
    opt: true,
  );

  @override
  final MappableFields<ConsoleChannel> fields = const {
    #options: _f$options,
    #name: _f$name,
    #formatter: _f$formatter,
  };

  static ConsoleChannel _instantiate(DecodingData data) {
    return ConsoleChannel(
      data.dec(_f$options),
      name: data.dec(_f$name),
      formatter: data.dec(_f$formatter),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ConsoleChannel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ConsoleChannel>(map);
  }

  static ConsoleChannel fromJson(String json) {
    return ensureInitialized().decodeJson<ConsoleChannel>(json);
  }
}

mixin ConsoleChannelMappable {
  String toJson() {
    return ConsoleChannelMapper.ensureInitialized().encodeJson<ConsoleChannel>(
      this as ConsoleChannel,
    );
  }

  Map<String, dynamic> toMap() {
    return ConsoleChannelMapper.ensureInitialized().encodeMap<ConsoleChannel>(
      this as ConsoleChannel,
    );
  }

  ConsoleChannelCopyWith<ConsoleChannel, ConsoleChannel, ConsoleChannel>
  get copyWith => _ConsoleChannelCopyWithImpl<ConsoleChannel, ConsoleChannel>(
    this as ConsoleChannel,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ConsoleChannelMapper.ensureInitialized().stringifyValue(
      this as ConsoleChannel,
    );
  }

  @override
  bool operator ==(Object other) {
    return ConsoleChannelMapper.ensureInitialized().equalsValue(
      this as ConsoleChannel,
      other,
    );
  }

  @override
  int get hashCode {
    return ConsoleChannelMapper.ensureInitialized().hashValue(
      this as ConsoleChannel,
    );
  }
}

extension ConsoleChannelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ConsoleChannel, $Out> {
  ConsoleChannelCopyWith<$R, ConsoleChannel, $Out> get $asConsoleChannel =>
      $base.as((v, t, t2) => _ConsoleChannelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ConsoleChannelCopyWith<$R, $In extends ConsoleChannel, $Out>
    implements ChannelConfigCopyWith<$R, $In, $Out> {
  ConsoleOptionsCopyWith<$R, ConsoleOptions, ConsoleOptions> get options;
  @override
  $R call({
    ConsoleOptions? options,
    String? name,
    LogMessageFormatter? formatter,
  });
  ConsoleChannelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ConsoleChannelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ConsoleChannel, $Out>
    implements ConsoleChannelCopyWith<$R, ConsoleChannel, $Out> {
  _ConsoleChannelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ConsoleChannel> $mapper =
      ConsoleChannelMapper.ensureInitialized();
  @override
  ConsoleOptionsCopyWith<$R, ConsoleOptions, ConsoleOptions> get options =>
      $value.options.copyWith.$chain((v) => call(options: v));
  @override
  $R call({
    ConsoleOptions? options,
    Object? name = $none,
    Object? formatter = $none,
  }) => $apply(
    FieldCopyWithData({
      if (options != null) #options: options,
      if (name != $none) #name: name,
      if (formatter != $none) #formatter: formatter,
    }),
  );
  @override
  ConsoleChannel $make(CopyWithData data) => ConsoleChannel(
    data.get(#options, or: $value.options),
    name: data.get(#name, or: $value.name),
    formatter: data.get(#formatter, or: $value.formatter),
  );

  @override
  ConsoleChannelCopyWith<$R2, ConsoleChannel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ConsoleChannelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DailyFileChannelMapper extends ClassMapperBase<DailyFileChannel> {
  DailyFileChannelMapper._();

  static DailyFileChannelMapper? _instance;
  static DailyFileChannelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DailyFileChannelMapper._());
      ChannelConfigMapper.ensureInitialized();
      DailyFileOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DailyFileChannel';

  static DailyFileOptions _$options(DailyFileChannel v) => v.options;
  static const Field<DailyFileChannel, DailyFileOptions> _f$options = Field(
    'options',
    _$options,
  );
  static String? _$name(DailyFileChannel v) => v.name;
  static const Field<DailyFileChannel, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static LogMessageFormatter? _$formatter(DailyFileChannel v) => v.formatter;
  static const Field<DailyFileChannel, LogMessageFormatter> _f$formatter =
      Field('formatter', _$formatter, opt: true);

  @override
  final MappableFields<DailyFileChannel> fields = const {
    #options: _f$options,
    #name: _f$name,
    #formatter: _f$formatter,
  };

  static DailyFileChannel _instantiate(DecodingData data) {
    return DailyFileChannel(
      data.dec(_f$options),
      name: data.dec(_f$name),
      formatter: data.dec(_f$formatter),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DailyFileChannel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DailyFileChannel>(map);
  }

  static DailyFileChannel fromJson(String json) {
    return ensureInitialized().decodeJson<DailyFileChannel>(json);
  }
}

mixin DailyFileChannelMappable {
  String toJson() {
    return DailyFileChannelMapper.ensureInitialized()
        .encodeJson<DailyFileChannel>(this as DailyFileChannel);
  }

  Map<String, dynamic> toMap() {
    return DailyFileChannelMapper.ensureInitialized()
        .encodeMap<DailyFileChannel>(this as DailyFileChannel);
  }

  DailyFileChannelCopyWith<DailyFileChannel, DailyFileChannel, DailyFileChannel>
  get copyWith =>
      _DailyFileChannelCopyWithImpl<DailyFileChannel, DailyFileChannel>(
        this as DailyFileChannel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DailyFileChannelMapper.ensureInitialized().stringifyValue(
      this as DailyFileChannel,
    );
  }

  @override
  bool operator ==(Object other) {
    return DailyFileChannelMapper.ensureInitialized().equalsValue(
      this as DailyFileChannel,
      other,
    );
  }

  @override
  int get hashCode {
    return DailyFileChannelMapper.ensureInitialized().hashValue(
      this as DailyFileChannel,
    );
  }
}

extension DailyFileChannelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DailyFileChannel, $Out> {
  DailyFileChannelCopyWith<$R, DailyFileChannel, $Out>
  get $asDailyFileChannel =>
      $base.as((v, t, t2) => _DailyFileChannelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DailyFileChannelCopyWith<$R, $In extends DailyFileChannel, $Out>
    implements ChannelConfigCopyWith<$R, $In, $Out> {
  DailyFileOptionsCopyWith<$R, DailyFileOptions, DailyFileOptions> get options;
  @override
  $R call({
    DailyFileOptions? options,
    String? name,
    LogMessageFormatter? formatter,
  });
  DailyFileChannelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DailyFileChannelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DailyFileChannel, $Out>
    implements DailyFileChannelCopyWith<$R, DailyFileChannel, $Out> {
  _DailyFileChannelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DailyFileChannel> $mapper =
      DailyFileChannelMapper.ensureInitialized();
  @override
  DailyFileOptionsCopyWith<$R, DailyFileOptions, DailyFileOptions>
  get options => $value.options.copyWith.$chain((v) => call(options: v));
  @override
  $R call({
    DailyFileOptions? options,
    Object? name = $none,
    Object? formatter = $none,
  }) => $apply(
    FieldCopyWithData({
      if (options != null) #options: options,
      if (name != $none) #name: name,
      if (formatter != $none) #formatter: formatter,
    }),
  );
  @override
  DailyFileChannel $make(CopyWithData data) => DailyFileChannel(
    data.get(#options, or: $value.options),
    name: data.get(#name, or: $value.name),
    formatter: data.get(#formatter, or: $value.formatter),
  );

  @override
  DailyFileChannelCopyWith<$R2, DailyFileChannel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DailyFileChannelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class StackChannelMapper extends ClassMapperBase<StackChannel> {
  StackChannelMapper._();

  static StackChannelMapper? _instance;
  static StackChannelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = StackChannelMapper._());
      ChannelConfigMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'StackChannel';

  static StackOptions _$options(StackChannel v) => v.options;
  static const Field<StackChannel, StackOptions> _f$options = Field(
    'options',
    _$options,
  );
  static String? _$name(StackChannel v) => v.name;
  static const Field<StackChannel, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static LogMessageFormatter? _$formatter(StackChannel v) => v.formatter;
  static const Field<StackChannel, LogMessageFormatter> _f$formatter = Field(
    'formatter',
    _$formatter,
    opt: true,
  );

  @override
  final MappableFields<StackChannel> fields = const {
    #options: _f$options,
    #name: _f$name,
    #formatter: _f$formatter,
  };

  static StackChannel _instantiate(DecodingData data) {
    return StackChannel(
      data.dec(_f$options),
      name: data.dec(_f$name),
      formatter: data.dec(_f$formatter),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static StackChannel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<StackChannel>(map);
  }

  static StackChannel fromJson(String json) {
    return ensureInitialized().decodeJson<StackChannel>(json);
  }
}

mixin StackChannelMappable {
  String toJson() {
    return StackChannelMapper.ensureInitialized().encodeJson<StackChannel>(
      this as StackChannel,
    );
  }

  Map<String, dynamic> toMap() {
    return StackChannelMapper.ensureInitialized().encodeMap<StackChannel>(
      this as StackChannel,
    );
  }

  StackChannelCopyWith<StackChannel, StackChannel, StackChannel> get copyWith =>
      _StackChannelCopyWithImpl<StackChannel, StackChannel>(
        this as StackChannel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return StackChannelMapper.ensureInitialized().stringifyValue(
      this as StackChannel,
    );
  }

  @override
  bool operator ==(Object other) {
    return StackChannelMapper.ensureInitialized().equalsValue(
      this as StackChannel,
      other,
    );
  }

  @override
  int get hashCode {
    return StackChannelMapper.ensureInitialized().hashValue(
      this as StackChannel,
    );
  }
}

extension StackChannelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, StackChannel, $Out> {
  StackChannelCopyWith<$R, StackChannel, $Out> get $asStackChannel =>
      $base.as((v, t, t2) => _StackChannelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class StackChannelCopyWith<$R, $In extends StackChannel, $Out>
    implements ChannelConfigCopyWith<$R, $In, $Out> {
  @override
  $R call({
    StackOptions? options,
    String? name,
    LogMessageFormatter? formatter,
  });
  StackChannelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _StackChannelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, StackChannel, $Out>
    implements StackChannelCopyWith<$R, StackChannel, $Out> {
  _StackChannelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<StackChannel> $mapper =
      StackChannelMapper.ensureInitialized();
  @override
  $R call({
    StackOptions? options,
    Object? name = $none,
    Object? formatter = $none,
  }) => $apply(
    FieldCopyWithData({
      if (options != null) #options: options,
      if (name != $none) #name: name,
      if (formatter != $none) #formatter: formatter,
    }),
  );
  @override
  StackChannel $make(CopyWithData data) => StackChannel(
    data.get(#options, or: $value.options),
    name: data.get(#name, or: $value.name),
    formatter: data.get(#formatter, or: $value.formatter),
  );

  @override
  StackChannelCopyWith<$R2, StackChannel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _StackChannelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class SamplingChannelMapper extends ClassMapperBase<SamplingChannel> {
  SamplingChannelMapper._();

  static SamplingChannelMapper? _instance;
  static SamplingChannelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SamplingChannelMapper._());
      ChannelConfigMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'SamplingChannel';

  static SamplingOptions _$options(SamplingChannel v) => v.options;
  static const Field<SamplingChannel, SamplingOptions> _f$options = Field(
    'options',
    _$options,
  );
  static String? _$name(SamplingChannel v) => v.name;
  static const Field<SamplingChannel, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static LogMessageFormatter? _$formatter(SamplingChannel v) => v.formatter;
  static const Field<SamplingChannel, LogMessageFormatter> _f$formatter = Field(
    'formatter',
    _$formatter,
    opt: true,
  );

  @override
  final MappableFields<SamplingChannel> fields = const {
    #options: _f$options,
    #name: _f$name,
    #formatter: _f$formatter,
  };

  static SamplingChannel _instantiate(DecodingData data) {
    return SamplingChannel(
      data.dec(_f$options),
      name: data.dec(_f$name),
      formatter: data.dec(_f$formatter),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static SamplingChannel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<SamplingChannel>(map);
  }

  static SamplingChannel fromJson(String json) {
    return ensureInitialized().decodeJson<SamplingChannel>(json);
  }
}

mixin SamplingChannelMappable {
  String toJson() {
    return SamplingChannelMapper.ensureInitialized()
        .encodeJson<SamplingChannel>(this as SamplingChannel);
  }

  Map<String, dynamic> toMap() {
    return SamplingChannelMapper.ensureInitialized().encodeMap<SamplingChannel>(
      this as SamplingChannel,
    );
  }

  SamplingChannelCopyWith<SamplingChannel, SamplingChannel, SamplingChannel>
  get copyWith =>
      _SamplingChannelCopyWithImpl<SamplingChannel, SamplingChannel>(
        this as SamplingChannel,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return SamplingChannelMapper.ensureInitialized().stringifyValue(
      this as SamplingChannel,
    );
  }

  @override
  bool operator ==(Object other) {
    return SamplingChannelMapper.ensureInitialized().equalsValue(
      this as SamplingChannel,
      other,
    );
  }

  @override
  int get hashCode {
    return SamplingChannelMapper.ensureInitialized().hashValue(
      this as SamplingChannel,
    );
  }
}

extension SamplingChannelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, SamplingChannel, $Out> {
  SamplingChannelCopyWith<$R, SamplingChannel, $Out> get $asSamplingChannel =>
      $base.as((v, t, t2) => _SamplingChannelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class SamplingChannelCopyWith<$R, $In extends SamplingChannel, $Out>
    implements ChannelConfigCopyWith<$R, $In, $Out> {
  @override
  $R call({
    SamplingOptions? options,
    String? name,
    LogMessageFormatter? formatter,
  });
  SamplingChannelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _SamplingChannelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, SamplingChannel, $Out>
    implements SamplingChannelCopyWith<$R, SamplingChannel, $Out> {
  _SamplingChannelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<SamplingChannel> $mapper =
      SamplingChannelMapper.ensureInitialized();
  @override
  $R call({
    SamplingOptions? options,
    Object? name = $none,
    Object? formatter = $none,
  }) => $apply(
    FieldCopyWithData({
      if (options != null) #options: options,
      if (name != $none) #name: name,
      if (formatter != $none) #formatter: formatter,
    }),
  );
  @override
  SamplingChannel $make(CopyWithData data) => SamplingChannel(
    data.get(#options, or: $value.options),
    name: data.get(#name, or: $value.name),
    formatter: data.get(#formatter, or: $value.formatter),
  );

  @override
  SamplingChannelCopyWith<$R2, SamplingChannel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _SamplingChannelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class WebhookChannelMapper extends ClassMapperBase<WebhookChannel> {
  WebhookChannelMapper._();

  static WebhookChannelMapper? _instance;
  static WebhookChannelMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WebhookChannelMapper._());
      ChannelConfigMapper.ensureInitialized();
      WebhookOptionsMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'WebhookChannel';

  static WebhookOptions _$options(WebhookChannel v) => v.options;
  static const Field<WebhookChannel, WebhookOptions> _f$options = Field(
    'options',
    _$options,
  );
  static String? _$name(WebhookChannel v) => v.name;
  static const Field<WebhookChannel, String> _f$name = Field(
    'name',
    _$name,
    opt: true,
  );
  static LogMessageFormatter? _$formatter(WebhookChannel v) => v.formatter;
  static const Field<WebhookChannel, LogMessageFormatter> _f$formatter = Field(
    'formatter',
    _$formatter,
    opt: true,
  );

  @override
  final MappableFields<WebhookChannel> fields = const {
    #options: _f$options,
    #name: _f$name,
    #formatter: _f$formatter,
  };

  static WebhookChannel _instantiate(DecodingData data) {
    return WebhookChannel(
      data.dec(_f$options),
      name: data.dec(_f$name),
      formatter: data.dec(_f$formatter),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static WebhookChannel fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WebhookChannel>(map);
  }

  static WebhookChannel fromJson(String json) {
    return ensureInitialized().decodeJson<WebhookChannel>(json);
  }
}

mixin WebhookChannelMappable {
  String toJson() {
    return WebhookChannelMapper.ensureInitialized().encodeJson<WebhookChannel>(
      this as WebhookChannel,
    );
  }

  Map<String, dynamic> toMap() {
    return WebhookChannelMapper.ensureInitialized().encodeMap<WebhookChannel>(
      this as WebhookChannel,
    );
  }

  WebhookChannelCopyWith<WebhookChannel, WebhookChannel, WebhookChannel>
  get copyWith => _WebhookChannelCopyWithImpl<WebhookChannel, WebhookChannel>(
    this as WebhookChannel,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return WebhookChannelMapper.ensureInitialized().stringifyValue(
      this as WebhookChannel,
    );
  }

  @override
  bool operator ==(Object other) {
    return WebhookChannelMapper.ensureInitialized().equalsValue(
      this as WebhookChannel,
      other,
    );
  }

  @override
  int get hashCode {
    return WebhookChannelMapper.ensureInitialized().hashValue(
      this as WebhookChannel,
    );
  }
}

extension WebhookChannelValueCopy<$R, $Out>
    on ObjectCopyWith<$R, WebhookChannel, $Out> {
  WebhookChannelCopyWith<$R, WebhookChannel, $Out> get $asWebhookChannel =>
      $base.as((v, t, t2) => _WebhookChannelCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WebhookChannelCopyWith<$R, $In extends WebhookChannel, $Out>
    implements ChannelConfigCopyWith<$R, $In, $Out> {
  WebhookOptionsCopyWith<$R, WebhookOptions, WebhookOptions> get options;
  @override
  $R call({
    WebhookOptions? options,
    String? name,
    LogMessageFormatter? formatter,
  });
  WebhookChannelCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _WebhookChannelCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WebhookChannel, $Out>
    implements WebhookChannelCopyWith<$R, WebhookChannel, $Out> {
  _WebhookChannelCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WebhookChannel> $mapper =
      WebhookChannelMapper.ensureInitialized();
  @override
  WebhookOptionsCopyWith<$R, WebhookOptions, WebhookOptions> get options =>
      $value.options.copyWith.$chain((v) => call(options: v));
  @override
  $R call({
    WebhookOptions? options,
    Object? name = $none,
    Object? formatter = $none,
  }) => $apply(
    FieldCopyWithData({
      if (options != null) #options: options,
      if (name != $none) #name: name,
      if (formatter != $none) #formatter: formatter,
    }),
  );
  @override
  WebhookChannel $make(CopyWithData data) => WebhookChannel(
    data.get(#options, or: $value.options),
    name: data.get(#name, or: $value.name),
    formatter: data.get(#formatter, or: $value.formatter),
  );

  @override
  WebhookChannelCopyWith<$R2, WebhookChannel, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WebhookChannelCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

