// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'console_options.dart';

class ConsoleOptionsMapper extends ClassMapperBase<ConsoleOptions> {
  ConsoleOptionsMapper._();

  static ConsoleOptionsMapper? _instance;
  static ConsoleOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConsoleOptionsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ConsoleOptions';

  @override
  final MappableFields<ConsoleOptions> fields = const {};

  static ConsoleOptions _instantiate(DecodingData data) {
    return ConsoleOptions();
  }

  @override
  final Function instantiate = _instantiate;

  static ConsoleOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ConsoleOptions>(map);
  }

  static ConsoleOptions fromJson(String json) {
    return ensureInitialized().decodeJson<ConsoleOptions>(json);
  }
}

mixin ConsoleOptionsMappable {
  String toJson() {
    return ConsoleOptionsMapper.ensureInitialized().encodeJson<ConsoleOptions>(
      this as ConsoleOptions,
    );
  }

  Map<String, dynamic> toMap() {
    return ConsoleOptionsMapper.ensureInitialized().encodeMap<ConsoleOptions>(
      this as ConsoleOptions,
    );
  }

  ConsoleOptionsCopyWith<ConsoleOptions, ConsoleOptions, ConsoleOptions>
  get copyWith => _ConsoleOptionsCopyWithImpl<ConsoleOptions, ConsoleOptions>(
    this as ConsoleOptions,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return ConsoleOptionsMapper.ensureInitialized().stringifyValue(
      this as ConsoleOptions,
    );
  }

  @override
  bool operator ==(Object other) {
    return ConsoleOptionsMapper.ensureInitialized().equalsValue(
      this as ConsoleOptions,
      other,
    );
  }

  @override
  int get hashCode {
    return ConsoleOptionsMapper.ensureInitialized().hashValue(
      this as ConsoleOptions,
    );
  }
}

extension ConsoleOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ConsoleOptions, $Out> {
  ConsoleOptionsCopyWith<$R, ConsoleOptions, $Out> get $asConsoleOptions =>
      $base.as((v, t, t2) => _ConsoleOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ConsoleOptionsCopyWith<$R, $In extends ConsoleOptions, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call();
  ConsoleOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _ConsoleOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ConsoleOptions, $Out>
    implements ConsoleOptionsCopyWith<$R, ConsoleOptions, $Out> {
  _ConsoleOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ConsoleOptions> $mapper =
      ConsoleOptionsMapper.ensureInitialized();
  @override
  $R call() => $apply(FieldCopyWithData({}));
  @override
  ConsoleOptions $make(CopyWithData data) => ConsoleOptions();

  @override
  ConsoleOptionsCopyWith<$R2, ConsoleOptions, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ConsoleOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

