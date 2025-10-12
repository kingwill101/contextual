// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'daily_file_options.dart';

class DailyFileOptionsMapper extends ClassMapperBase<DailyFileOptions> {
  DailyFileOptionsMapper._();

  static DailyFileOptionsMapper? _instance;
  static DailyFileOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DailyFileOptionsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DailyFileOptions';

  static String _$path(DailyFileOptions v) => v.path;
  static const Field<DailyFileOptions, String> _f$path = Field('path', _$path);
  static int _$retentionDays(DailyFileOptions v) => v.retentionDays;
  static const Field<DailyFileOptions, int> _f$retentionDays = Field(
    'retentionDays',
    _$retentionDays,
    opt: true,
    def: 14,
  );
  static Duration _$flushInterval(DailyFileOptions v) => v.flushInterval;
  static const Field<DailyFileOptions, Duration> _f$flushInterval = Field(
    'flushInterval',
    _$flushInterval,
    opt: true,
    def: const Duration(milliseconds: 500),
  );

  @override
  final MappableFields<DailyFileOptions> fields = const {
    #path: _f$path,
    #retentionDays: _f$retentionDays,
    #flushInterval: _f$flushInterval,
  };

  static DailyFileOptions _instantiate(DecodingData data) {
    return DailyFileOptions(
      path: data.dec(_f$path),
      retentionDays: data.dec(_f$retentionDays),
      flushInterval: data.dec(_f$flushInterval),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DailyFileOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DailyFileOptions>(map);
  }

  static DailyFileOptions fromJson(String json) {
    return ensureInitialized().decodeJson<DailyFileOptions>(json);
  }
}

mixin DailyFileOptionsMappable {
  String toJson() {
    return DailyFileOptionsMapper.ensureInitialized()
        .encodeJson<DailyFileOptions>(this as DailyFileOptions);
  }

  Map<String, dynamic> toMap() {
    return DailyFileOptionsMapper.ensureInitialized()
        .encodeMap<DailyFileOptions>(this as DailyFileOptions);
  }

  DailyFileOptionsCopyWith<DailyFileOptions, DailyFileOptions, DailyFileOptions>
  get copyWith =>
      _DailyFileOptionsCopyWithImpl<DailyFileOptions, DailyFileOptions>(
        this as DailyFileOptions,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DailyFileOptionsMapper.ensureInitialized().stringifyValue(
      this as DailyFileOptions,
    );
  }

  @override
  bool operator ==(Object other) {
    return DailyFileOptionsMapper.ensureInitialized().equalsValue(
      this as DailyFileOptions,
      other,
    );
  }

  @override
  int get hashCode {
    return DailyFileOptionsMapper.ensureInitialized().hashValue(
      this as DailyFileOptions,
    );
  }
}

extension DailyFileOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DailyFileOptions, $Out> {
  DailyFileOptionsCopyWith<$R, DailyFileOptions, $Out>
  get $asDailyFileOptions =>
      $base.as((v, t, t2) => _DailyFileOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DailyFileOptionsCopyWith<$R, $In extends DailyFileOptions, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? path, int? retentionDays, Duration? flushInterval});
  DailyFileOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DailyFileOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DailyFileOptions, $Out>
    implements DailyFileOptionsCopyWith<$R, DailyFileOptions, $Out> {
  _DailyFileOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DailyFileOptions> $mapper =
      DailyFileOptionsMapper.ensureInitialized();
  @override
  $R call({String? path, int? retentionDays, Duration? flushInterval}) =>
      $apply(
        FieldCopyWithData({
          if (path != null) #path: path,
          if (retentionDays != null) #retentionDays: retentionDays,
          if (flushInterval != null) #flushInterval: flushInterval,
        }),
      );
  @override
  DailyFileOptions $make(CopyWithData data) => DailyFileOptions(
    path: data.get(#path, or: $value.path),
    retentionDays: data.get(#retentionDays, or: $value.retentionDays),
    flushInterval: data.get(#flushInterval, or: $value.flushInterval),
  );

  @override
  DailyFileOptionsCopyWith<$R2, DailyFileOptions, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _DailyFileOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

