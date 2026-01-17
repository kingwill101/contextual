## [2.2.0] - 2026-01-16

### Added
- **Flexible per-log context**: Logging methods now accept any object; maps are treated as structured context and non-map values are stored under `context`.
- **Stack trace support**: Optional stack traces can be provided to log calls and are preserved on log records.
- **Logfmt helpers**: Shared logfmt formatting helpers for consistent key/value output and context flattening.
- **Default file formatter**: File channels default to `PlainTextLogFormatter` unless explicitly overridden.

### Changed
- **Plain formatter output**: `PlainTextLogFormatter` now emits logfmt-style key/value pairs with dotted-key flattening for nested maps.
- **Pretty formatter output**: `PrettyLogFormatter` now emits colored logfmt-style key/value output.
- **Timestamp default**: Formatter defaults now use RFC 3339 timestamps with timezone offset.
- **Examples & docs**: Updated to reflect the new context API, stack trace usage, and logfmt output.

## [2.1.0] - 2026-01-07

### Added
- **Hierarchical Named Loggers**: Support for creating loggers with names (e.g., `app.database`) that inherit levels, channels, formatters, and context from their parents.
- **Context Integration**: Automatically includes the logger's name in the log context as `logger: 'name'`.
- **LoggerManager**: A new utility class in `example/` for managing logger resources, subscriptions, and proper shutdown.
- **Public API**: Exposed `Logger.root` and added `Logger(name: ...)` factory for easy named logger creation.
- **Documentation**: Extensive updates to `README.md` and inline Dartdoc for better API discovery.

### Improved
- **Type-Safe Channel Selection**: Added `forDriver<T>()` and `forDrivers()` methods for selecting channels by their driver type.
- **Channel Management**: Enhanced `hasChannel`, `getChannel`, and `removeChannel` with better documentation.

## [2.0.0] - 2025-02-16

### Breaking Changes
- Removed map-based configs in favor of LogConfig and ChannelConfig hierarchy.
- Removed legacy factories and fromConfig constructors.
- Removed string-keyed driver registration and loader paths.

### Added
- Typed configuration via LogConfig with dart_mappable support.
- Typed channel declarations: ConsoleChannel, DailyFileChannel, WebhookChannel, StackChannel, SamplingChannel.
- Driver options classes: ConsoleOptions, DailyFileOptions, WebhookOptions, StackOptions, SamplingOptions.
- Logger.create(config: ...) convenience.
- Type-based selection: logger.forDriver<T>(), plus name-based operator[]
- Centralized middleware pipeline with defined order: global -> channel -> driver-type.
- Examples and migration guide updated; docs migrated to docs.page content.

### Changed
- DailyFileLogDriver.fromOptions replaces fromConfig; isolate-optimized constructor remains opt-in.
- README and docs updated to typed-first ergonomics and examples.

### Removed
- All legacy config files and references, including contextual/lib/src/config.dart.



### Added
- Support for custom type formatters
- Enhanced context management with scoped contexts
- New middleware capabilities:
  - Global context providers
  - Channel-specific middleware
  - Conditional middleware
- Batch logging improvements:
  - Configurable batch sizes
  - Auto-flush intervals
  - Priority-based flushing
- Advanced sampling features:
  - Per-level sampling rates
  - Conditional sampling rules
  - Sampling with context

### Changed
- Improved performance of context operations
- Enhanced formatter efficiency
- Better memory usage in high-volume scenarios
- Refined middleware API for better usability

### Fixed
- Context inheritance in nested loggers
- Memory usage in long-running batch operations
- Thread safety in concurrent formatter access
- Stack trace handling in error logging

## [1.1.0] - 2024-02-01

### Breaking Changes
- Renamed `LogLevel` to `Level` for more intuitive naming
- Renamed `addDriver` to `addChannel` for clarity
- Refactored package structure into a Dart workspace

### Added
- Per-channel formatters
- Channel-specific middleware
- Null formatter (`NullLogFormatter`)

### Changed
- Improved logger interface with `Level` enum
- Expanded built-in formatters
- Refined sink logic for better efficiency

### Fixed
- Cleaned up file paths and examples
- Standardized internal imports

## [1.0.0] - 2024-01-15

### Added
- Initial stable release
- Core logging functionality with context support
- Multiple output channels with different formatters
- Built-in log drivers:
  - Console driver with ANSI color support
  - File driver with daily rotation
  - Webhook driver for remote logging
  - Stack driver for combining multiple drivers
  - Sampling driver for high-volume logging
- Log formatters:
  - JSON formatter for structured output
  - Pretty formatter with color coding
  - Plain text formatter
  - Raw formatter for unmodified output
  - Null formatter for discarding output
- Middleware support for log processing
- Type-specific formatting
- Comprehensive error handling
- Performance monitoring features
- Log level filtering and control
- Context management with hidden fields
- Message interpolation
- Batch logging support
- Auto-flush capabilities

### Changed
- Improved error handling in drivers
- Enhanced performance in high-volume scenarios
- Better memory management in file operations

### Fixed
- Memory leaks in long-running operations
- Thread safety issues in concurrent logging
- File handle management in rotating logs

## [0.9.0] - 2024-01-01

### Added
- Beta release with core features
- Basic logging functionality
- Initial driver implementations
- Formatter support
- Context handling

### Changed
- Refined API based on beta testing
- Improved documentation
- Enhanced error handling

## [0.1.0] - 2023-12-15

### Added
- Initial development release
- Basic structure and interfaces
- Proof of concept implementation
