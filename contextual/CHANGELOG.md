## 1.1.0

### Breaking Changes

- Renamed LogLevel to Level for more intuitive and concise naming.
- Renamed addDriver(...) to addChannel(...) to emphasize the concept of channels as individual logging destinations.
- Refactored the package structure into a Dart workspace, moving source files under a contextual/ folder. If you import
  files directly, please update your references to the new file paths.

### New Features

- Per-Channel Formatters: You can now assign a unique formatter to each logging channel.
- Channel-Specific Middleware: Middlewares can be applied specifically to a channel without affecting others.
- Null Formatter (NullLogFormatter): A new formatter that emits an empty string, essentially discarding message content.

### Enhancements

- Improved Logger Interface: Replaced string-based log levels with the Level enum for type safety and cleaner API usage.
- Expanded Formatters: Bundled built-in formatters (plain, json, pretty, raw, null) and made them easily discoverable.
- Refined Sink Logic: Sink-based logging is more efficient, with clearer batch and flush operations.

### Fixes

- Cleaned Up old file paths and examples, ensuring they reflect the new structure.
- Consistent Imports: Standardized internal imports to prevent confusion in IDEs and package managers.

## 1.0.0

- Initial version.
