// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'formatter_settings_typed.dart';

class FormatterSettingsMapper extends ClassMapperBase<FormatterSettings> {
  FormatterSettingsMapper._();

  static FormatterSettingsMapper? _instance;
  static FormatterSettingsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FormatterSettingsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FormatterSettings';

  static bool _$includeInterpolation(FormatterSettings v) =>
      v.includeInterpolation;
  static const Field<FormatterSettings, bool> _f$includeInterpolation = Field(
    'includeInterpolation',
    _$includeInterpolation,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<FormatterSettings> fields = const {
    #includeInterpolation: _f$includeInterpolation,
  };

  static FormatterSettings _instantiate(DecodingData data) {
    return FormatterSettings(
      includeInterpolation: data.dec(_f$includeInterpolation),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FormatterSettings fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FormatterSettings>(map);
  }

  static FormatterSettings fromJson(String json) {
    return ensureInitialized().decodeJson<FormatterSettings>(json);
  }
}

mixin FormatterSettingsMappable {
  String toJson() {
    return FormatterSettingsMapper.ensureInitialized()
        .encodeJson<FormatterSettings>(this as FormatterSettings);
  }

  Map<String, dynamic> toMap() {
    return FormatterSettingsMapper.ensureInitialized()
        .encodeMap<FormatterSettings>(this as FormatterSettings);
  }

  FormatterSettingsCopyWith<
    FormatterSettings,
    FormatterSettings,
    FormatterSettings
  >
  get copyWith =>
      _FormatterSettingsCopyWithImpl<FormatterSettings, FormatterSettings>(
        this as FormatterSettings,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FormatterSettingsMapper.ensureInitialized().stringifyValue(
      this as FormatterSettings,
    );
  }

  @override
  bool operator ==(Object other) {
    return FormatterSettingsMapper.ensureInitialized().equalsValue(
      this as FormatterSettings,
      other,
    );
  }

  @override
  int get hashCode {
    return FormatterSettingsMapper.ensureInitialized().hashValue(
      this as FormatterSettings,
    );
  }
}

extension FormatterSettingsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FormatterSettings, $Out> {
  FormatterSettingsCopyWith<$R, FormatterSettings, $Out>
  get $asFormatterSettings => $base.as(
    (v, t, t2) => _FormatterSettingsCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class FormatterSettingsCopyWith<
  $R,
  $In extends FormatterSettings,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({bool? includeInterpolation});
  FormatterSettingsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FormatterSettingsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FormatterSettings, $Out>
    implements FormatterSettingsCopyWith<$R, FormatterSettings, $Out> {
  _FormatterSettingsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FormatterSettings> $mapper =
      FormatterSettingsMapper.ensureInitialized();
  @override
  $R call({bool? includeInterpolation}) => $apply(
    FieldCopyWithData({
      if (includeInterpolation != null)
        #includeInterpolation: includeInterpolation,
    }),
  );
  @override
  FormatterSettings $make(CopyWithData data) => FormatterSettings(
    includeInterpolation: data.get(
      #includeInterpolation,
      or: $value.includeInterpolation,
    ),
  );

  @override
  FormatterSettingsCopyWith<$R2, FormatterSettings, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _FormatterSettingsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

