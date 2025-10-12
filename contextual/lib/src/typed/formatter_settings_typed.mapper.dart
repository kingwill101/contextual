// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'formatter_settings_typed.dart';

class FormatterSettingsTypedMapper
    extends ClassMapperBase<FormatterSettingsTyped> {
  FormatterSettingsTypedMapper._();

  static FormatterSettingsTypedMapper? _instance;
  static FormatterSettingsTypedMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FormatterSettingsTypedMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FormatterSettingsTyped';

  static bool _$includeInterpolation(FormatterSettingsTyped v) =>
      v.includeInterpolation;
  static const Field<FormatterSettingsTyped, bool> _f$includeInterpolation =
      Field(
        'includeInterpolation',
        _$includeInterpolation,
        opt: true,
        def: true,
      );

  @override
  final MappableFields<FormatterSettingsTyped> fields = const {
    #includeInterpolation: _f$includeInterpolation,
  };

  static FormatterSettingsTyped _instantiate(DecodingData data) {
    return FormatterSettingsTyped(
      includeInterpolation: data.dec(_f$includeInterpolation),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static FormatterSettingsTyped fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FormatterSettingsTyped>(map);
  }

  static FormatterSettingsTyped fromJson(String json) {
    return ensureInitialized().decodeJson<FormatterSettingsTyped>(json);
  }
}

mixin FormatterSettingsTypedMappable {
  String toJson() {
    return FormatterSettingsTypedMapper.ensureInitialized()
        .encodeJson<FormatterSettingsTyped>(this as FormatterSettingsTyped);
  }

  Map<String, dynamic> toMap() {
    return FormatterSettingsTypedMapper.ensureInitialized()
        .encodeMap<FormatterSettingsTyped>(this as FormatterSettingsTyped);
  }

  FormatterSettingsTypedCopyWith<
    FormatterSettingsTyped,
    FormatterSettingsTyped,
    FormatterSettingsTyped
  >
  get copyWith =>
      _FormatterSettingsTypedCopyWithImpl<
        FormatterSettingsTyped,
        FormatterSettingsTyped
      >(this as FormatterSettingsTyped, $identity, $identity);
  @override
  String toString() {
    return FormatterSettingsTypedMapper.ensureInitialized().stringifyValue(
      this as FormatterSettingsTyped,
    );
  }

  @override
  bool operator ==(Object other) {
    return FormatterSettingsTypedMapper.ensureInitialized().equalsValue(
      this as FormatterSettingsTyped,
      other,
    );
  }

  @override
  int get hashCode {
    return FormatterSettingsTypedMapper.ensureInitialized().hashValue(
      this as FormatterSettingsTyped,
    );
  }
}

extension FormatterSettingsTypedValueCopy<$R, $Out>
    on ObjectCopyWith<$R, FormatterSettingsTyped, $Out> {
  FormatterSettingsTypedCopyWith<$R, FormatterSettingsTyped, $Out>
  get $asFormatterSettingsTyped => $base.as(
    (v, t, t2) => _FormatterSettingsTypedCopyWithImpl<$R, $Out>(v, t, t2),
  );
}

abstract class FormatterSettingsTypedCopyWith<
  $R,
  $In extends FormatterSettingsTyped,
  $Out
>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({bool? includeInterpolation});
  FormatterSettingsTypedCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FormatterSettingsTypedCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, FormatterSettingsTyped, $Out>
    implements
        FormatterSettingsTypedCopyWith<$R, FormatterSettingsTyped, $Out> {
  _FormatterSettingsTypedCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FormatterSettingsTyped> $mapper =
      FormatterSettingsTypedMapper.ensureInitialized();
  @override
  $R call({bool? includeInterpolation}) => $apply(
    FieldCopyWithData({
      if (includeInterpolation != null)
        #includeInterpolation: includeInterpolation,
    }),
  );
  @override
  FormatterSettingsTyped $make(CopyWithData data) => FormatterSettingsTyped(
    includeInterpolation: data.get(
      #includeInterpolation,
      or: $value.includeInterpolation,
    ),
  );

  @override
  FormatterSettingsTypedCopyWith<$R2, FormatterSettingsTyped, $Out2>
  $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _FormatterSettingsTypedCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

