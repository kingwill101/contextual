# Contextual v2 Roadmap and Task Tracker
[//]: # (This roadmap reflects the v2 state; Docusaurus has been replaced by docs.page.)


This document tracks the v2 redesign focused on ergonomics, typed configuration, and typed lookups. We’re intentionally dropping backward compatibility to remove map-shaped configs and stringly-typed APIs.

## Guiding principles
- Typed over maps: compile-time safety, autocompletion, clear docs.
- Simple defaults: direct driver dispatch; opt-in batching without isolates.
- One middleware pipeline in one place.
- Fluent, darty ergonomics: operator[] and byType methods.

---

## Phase 1 — Typed config model and builders

Goal: Replace map-shaped configs with strongly-typed classes and builders using `dart_mappable` for (de)serialization.

- [ ] Add dependency
  - [ ] Add `dart_mappable` and `dart_mappable_builder` to pubspec
  - [ ] Add build_runner to dev_dependencies

- [ ] Define core config types under `lib/src/config/`
  - [ ] `BatchingConfig { enabled, batchSize, flushInterval, autoCloseAfter }`
  - [ ] `FormatterSettings` mappable (add `includeInterpolation`)
  - [ ] `LogConfig { level, formatter, formatterSettings, environment, batching, context, channels }`

- [ ] Define typed driver option classes (mappable)
  - [ ] `ConsoleOptions {}`
  - [ ] `DailyFileOptions { path:String, retentionDays:int=14, flushInterval:Duration=500ms }`
  - [ ] `WebhookOptions { url:Uri, headers:Map<String,String>?, timeout:Duration=5s, keepAlive:bool=true }`
  - [ ] `StackOptions { channels: List<Channel>, ignoreExceptions: bool=false }`
  - [ ] `SamplingOptions { rates: Map<Level,double>, wrapped: Channel }`

- [ ] Define typed channel declarations (no string names required)
  - [ ] `abstract class Channel { LogDriver driver; LogMessageFormatter? formatter; FormatterSettings? formatterSettings; String? name; }`
  - [ ] Concrete:
    - [ ] `ConsoleChannel(ConsoleOptions options, {String? name, ...})`
    - [ ] `DailyFileChannel(DailyFileOptions options, {String? name, ...})`
    - [ ] `WebhookChannel(WebhookOptions options, {String? name, ...})`
    - [ ] `StackChannel(StackOptions options, {String? name, ...})`
    - [ ] `SamplingChannel(SamplingOptions options, {String? name, ...})`

- [ ] Make all above `@MappableClass()` with generated `*.mapper.dart`

- [ ] Acceptance criteria
  - [ ] `LogConfigMapper.fromJson(json)` -> fully typed graph
  - [ ] `toJson()` round-trip preserves structure
  - [ ] No map/dynamic-based config APIs remain in public surface

---

## Phase 2 — Logger typed construction and config wiring

Goal: Create loggers directly from typed config; remove string driver keys and legacy map parsing.

- [x] `Logger.create({typedConfig: TypedLogConfig})` builds channels from typed config
- [x] DailyFileLogDriver.fromOptions(DailyFileOptions)
- [x] WebhookLogDriver.fromOptions(WebhookOptions)
- [x] Enable batching via `typedConfig.batching` automatically (`enableDriverBatching`)
- [x] Fluent ergonomics: `logger['name']`, `logger.forDriver<T>()`, `logger.batched()`
- [x] Type registry for O(1) type-based selection
- [x] Remove legacy map-based LogConfig and string driver factory paths
- [ ] Acceptance criteria
  - [x] Pure Dart-constructed `TypedLogConfig` initializes logger
  - [x] Type-based selectors work across multiple channels of the same type
  - [x] Tests pass with new API in place
  - [ ] Legacy config fully removed (Phase 8)

---

## Phase 3 — Typed lookups and fluent APIs

Goal: Eliminate stringly channel targeting across the library.

- [x] Channel registry keyed by type and optional name (via Logger.forDriver<T>() and operator[])
  - [ ] `Map<Type, List<ChannelRef>>`
  - [ ] `ChannelRef { String? name; Type driverType; LogDriver driver; }`

- [ ] Logger fluent selectors
  - [ ] `Logger forDriver<T extends LogDriver>({String? name})`
  - [ ] `Logger forDrivers<T1, T2, ...>()` or `logger.channelsByTypes([T1, T2])`
  - [ ] Keep `operator []` for name targeting, but prefer type-first APIs

- [ ] Acceptance criteria
  - [ ] `logger.forDriver<ConsoleLogDriver>().info('...')` works
  - [ ] Multiple drivers of the same type can be disambiguated with `name`

---

## Phase 4 — Single middleware pipeline

Goal: Apply middlewares once in `Logger` with a well-defined order.

- [x] Remove driver/stack-level middleware duplication (StackLogDriver simplified)
- [x] Order enforced: global -> channel -> driver-type (see middleware_processor.dart)
- [x] Document order and guarantees in README and docs/advanced/middleware.md
- [ ] Acceptance criteria
  - [ ] Tests validate order and single application

---

## Phase 5 — Message serialization and interpolation toggle

Goal: “Just works” defaults for objects and control over interpolation.

- [ ] Add `messageSerializer: String Function(Object, Context)` to `Logger`
  - [ ] Default: `toJson()` if available → JSON; else `toString()`
- [ ] Add `includeInterpolation` to `FormatterSettings`; plumb through Plain/Pretty/Json
- [ ] Acceptance criteria
  - [ ] Logging non-String payloads works without type formatters
  - [ ] Interpolation can be disabled globally/per-channel via settings

---

## Phase 6 — Batching defaults and non-isolate implementation

Goal: Simple and robust batching without requiring shutdown.

- [ ] Keep central batching (non-isolate) as the only default path
- [ ] Ensure `LogSinkConfig` derives from `BatchingConfig`
- [ ] Confirm `autoCloseAfter` idle drain works across drivers
- [ ] Acceptance criteria
  - [ ] Typical apps don’t need `shutdown()`; CLI guidance documented

---

## Phase 7 — Drivers polish

- [ ] Daily file
  - [ ] `DailyFileLogDriver.fromOptions(DailyFileOptions)`
  - [ ] Keep isolate-optimized driver as advanced/opt-in; not default

- [ ] Webhook
  - [ ] Persistent `HttpClient` per instance
  - [ ] Close in `performShutdown()`

- [ ] Sampling
  - [ ] Provide `SamplingMiddleware` (preferable)
  - [ ] Keep `SamplingLogDriver` for parity with typed options

- [ ] Acceptance criteria
  - [ ] Drivers constructed exclusively via typed options
  - [ ] Webhook resource lifecycle validated

---

## Phase 8 — Public API cleanup

- [x] Remove deprecated/legacy factory (string driver registration)
- [x] Remove deprecated `fromConfig` constructors
- [x] Remove `src/config.dart` and legacy config loaders
- [x] Ensure examples use type-first selectors and typed config

- [x] Acceptance criteria
  - [x] Public API surface contains no string driver keys or map options

---

## Phase 9 — Examples and Docs

- [x] Add typed config example (typed_config_example.dart)
- [x] Add typed stack/sampling example (typed_stack_sampling_example.dart)
- [x] Update existing examples to typed API and selectors
- [x] Document middleware order and batching ergonomics

- [x] Add migration guide (v1 → v2 mindset)

- [x] Acceptance criteria
  - [x] Examples compile and run

---

## Phase 11 — Docs platform migration

- [x] Replace Docusaurus with docs.page content
- [x] Update docs/README.md with docs.page instructions
- [x] Migrate getting-started and API pages to typed examples
- [x] Add migration guide and sidebar entry
- [ ] Remove Docusaurus scaffolding (package.json, docusaurus.config.ts) in a follow-up PR (tracked externally)


  - [x] Docs reflect the new APIs only

---

## Phase 10 — Tests and Release

- [ ] Tests
  - [ ] Config mapper round-trips (JSON ↔ typed)
  - [ ] Logger initialization from typed config
  - [ ] Type-based selection (with/without names)
  - [ ] Middleware order
  - [ ] Serializer default and interpolation toggle
  - [ ] Webhook client reuse

- [ ] Release
  - [ ] Bump major version to v2.0.0
  - [ ] CHANGELOG + highlights

---

## API sketches (for clarity)

Typed options

```dart
@MappableClass()
class DailyFileOptions with DailyFileOptionsMappable {
  final String path;
  final int retentionDays;
  final Duration flushInterval;
  const DailyFileOptions({
    required this.path,
    this.retentionDays = 14,
    this.flushInterval = const Duration(milliseconds: 500),
  });
}

@MappableClass()
class WebhookOptions with WebhookOptionsMappable {
  final Uri url;
  final Map<String, String>? headers;
  final Duration timeout;
  final bool keepAlive;
  const WebhookOptions({
    required this.url,
    this.headers,
    this.timeout = const Duration(seconds: 5),
    this.keepAlive = true,
  });
}
```

Channels

```dart
sealed class Channel {
  LogMessageFormatter? formatter;
  FormatterSettings? formatterSettings;
  String? name;
}

class DailyFileChannel extends Channel {
  final DailyFileOptions options;
  DailyFileChannel(this.options, {super.name, super.formatter, super.formatterSettings});
}

class WebhookChannel extends Channel {
  final WebhookOptions options;
  WebhookChannel(this.options, {super.name, super.formatter, super.formatterSettings});
}
```

Logger construction

```dart
final config = LogConfig(
  level: 'info',
  batching: BatchingConfig(enabled: true, batchSize: 50, flushInterval: Duration(milliseconds: 500)),
  channels: [
    ConsoleChannel(ConsoleOptions(), name: 'console', formatter: PrettyLogFormatter()),
    DailyFileChannel(DailyFileOptions(path: 'logs/app')),
    WebhookChannel(WebhookOptions(url: Uri.parse('https://hooks.slack.com/...'))),
  ],
);

final logger = await Logger.create(config: config);
```

Typed lookups

```dart
logger.forDriver<ConsoleLogDriver>().info('hello console');
logger.forDriver<DailyFileLogDriver>(name: 'archive').warning('rotate soon');
```

Middleware order

```text
global → channel → driver-type
```

---

## Open questions
- Do we want multiple channels of the same driver type without names? We’ll support this by returning a logger that targets all matching driver instances when `name` is omitted.
- Should we support a union-like `DriverOptions` type to allow ergonomic switching? For v2, we can keep concrete option classes per driver for clarity.
- JSON/YAML config case style: prefer camelCase; keep mappers strict to reduce guesswork.

---

## Tracking
Use this checklist to track progress across PRs. Each phase should land with tests and doc updates where applicable.
