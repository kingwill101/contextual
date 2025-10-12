// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'webhook_options.dart';

class WebhookOptionsMapper extends ClassMapperBase<WebhookOptions> {
  WebhookOptionsMapper._();

  static WebhookOptionsMapper? _instance;
  static WebhookOptionsMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WebhookOptionsMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'WebhookOptions';

  static Uri _$url(WebhookOptions v) => v.url;
  static const Field<WebhookOptions, Uri> _f$url = Field('url', _$url);
  static Map<String, String>? _$headers(WebhookOptions v) => v.headers;
  static const Field<WebhookOptions, Map<String, String>> _f$headers = Field(
    'headers',
    _$headers,
    opt: true,
  );
  static Duration _$timeout(WebhookOptions v) => v.timeout;
  static const Field<WebhookOptions, Duration> _f$timeout = Field(
    'timeout',
    _$timeout,
    opt: true,
    def: const Duration(seconds: 5),
  );
  static bool _$keepAlive(WebhookOptions v) => v.keepAlive;
  static const Field<WebhookOptions, bool> _f$keepAlive = Field(
    'keepAlive',
    _$keepAlive,
    opt: true,
    def: true,
  );

  @override
  final MappableFields<WebhookOptions> fields = const {
    #url: _f$url,
    #headers: _f$headers,
    #timeout: _f$timeout,
    #keepAlive: _f$keepAlive,
  };

  static WebhookOptions _instantiate(DecodingData data) {
    return WebhookOptions(
      url: data.dec(_f$url),
      headers: data.dec(_f$headers),
      timeout: data.dec(_f$timeout),
      keepAlive: data.dec(_f$keepAlive),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static WebhookOptions fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WebhookOptions>(map);
  }

  static WebhookOptions fromJson(String json) {
    return ensureInitialized().decodeJson<WebhookOptions>(json);
  }
}

mixin WebhookOptionsMappable {
  String toJson() {
    return WebhookOptionsMapper.ensureInitialized().encodeJson<WebhookOptions>(
      this as WebhookOptions,
    );
  }

  Map<String, dynamic> toMap() {
    return WebhookOptionsMapper.ensureInitialized().encodeMap<WebhookOptions>(
      this as WebhookOptions,
    );
  }

  WebhookOptionsCopyWith<WebhookOptions, WebhookOptions, WebhookOptions>
  get copyWith => _WebhookOptionsCopyWithImpl<WebhookOptions, WebhookOptions>(
    this as WebhookOptions,
    $identity,
    $identity,
  );
  @override
  String toString() {
    return WebhookOptionsMapper.ensureInitialized().stringifyValue(
      this as WebhookOptions,
    );
  }

  @override
  bool operator ==(Object other) {
    return WebhookOptionsMapper.ensureInitialized().equalsValue(
      this as WebhookOptions,
      other,
    );
  }

  @override
  int get hashCode {
    return WebhookOptionsMapper.ensureInitialized().hashValue(
      this as WebhookOptions,
    );
  }
}

extension WebhookOptionsValueCopy<$R, $Out>
    on ObjectCopyWith<$R, WebhookOptions, $Out> {
  WebhookOptionsCopyWith<$R, WebhookOptions, $Out> get $asWebhookOptions =>
      $base.as((v, t, t2) => _WebhookOptionsCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class WebhookOptionsCopyWith<$R, $In extends WebhookOptions, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get headers;
  $R call({
    Uri? url,
    Map<String, String>? headers,
    Duration? timeout,
    bool? keepAlive,
  });
  WebhookOptionsCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _WebhookOptionsCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WebhookOptions, $Out>
    implements WebhookOptionsCopyWith<$R, WebhookOptions, $Out> {
  _WebhookOptionsCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WebhookOptions> $mapper =
      WebhookOptionsMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>?
  get headers => $value.headers != null
      ? MapCopyWith(
          $value.headers!,
          (v, t) => ObjectCopyWith(v, $identity, t),
          (v) => call(headers: v),
        )
      : null;
  @override
  $R call({
    Uri? url,
    Object? headers = $none,
    Duration? timeout,
    bool? keepAlive,
  }) => $apply(
    FieldCopyWithData({
      if (url != null) #url: url,
      if (headers != $none) #headers: headers,
      if (timeout != null) #timeout: timeout,
      if (keepAlive != null) #keepAlive: keepAlive,
    }),
  );
  @override
  WebhookOptions $make(CopyWithData data) => WebhookOptions(
    url: data.get(#url, or: $value.url),
    headers: data.get(#headers, or: $value.headers),
    timeout: data.get(#timeout, or: $value.timeout),
    keepAlive: data.get(#keepAlive, or: $value.keepAlive),
  );

  @override
  WebhookOptionsCopyWith<$R2, WebhookOptions, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _WebhookOptionsCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

