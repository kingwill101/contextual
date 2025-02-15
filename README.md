# Contextual Logging Ecosystem

A collection of Dart packages that provide powerful, flexible, and structured logging capabilities.


[![Build Status](https://github.com/yourusername/contextual/workflows/Dart/badge.svg)](https://github.com/yourusername/contextual/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Packages

### [contextual](contextual/)
[![Pub Version](https://img.shields.io/pub/v/contextual)](https://pub.dev/packages/contextual)

The core logging package that provides structured, multi-channel logging with context support.

```dart
final logger = Logger()
  ..addChannel('console', ConsoleLogDriver())
  ..info('Hello, World!', Context({'user': 'alice'}));
```

Key features:
- Multiple output channels
- Structured logging with context
- Flexible formatting options
- Error handling and stack traces
- Performance monitoring

### [contextual_shelf](contextual_shelf/)
[![Pub Version](https://img.shields.io/pub/v/contextual_shelf)](https://pub.dev/packages/contextual_shelf)

Shelf middleware for HTTP request logging and monitoring.

```dart
final httpLogger = HttpLogger(logProfile, logWriter);
final handler = Pipeline()
  .addMiddleware(httpLogger.middleware)
  .addHandler(myHandler);
```

Key features:
- Request/response logging
- Performance metrics
- Header sanitization
- Custom request filtering
- Multiple output formats

## Getting Started

1. Add the desired packages to your `pubspec.yaml`:
```yaml
dependencies:
  contextual: ^1.0.0
  contextual_shelf: ^1.0.0  # If using Shelf
```

2. Import and use:
```dart
import 'package:contextual/contextual.dart';

final logger = Logger()
  ..addChannel(
    'console',
    ConsoleLogDriver(),
    formatter: PrettyLogFormatter(),
  );

logger.info('Application started');
```

## Examples

Each package contains detailed examples in its `example` directory:

- [Basic Logging Examples](contextual/example/)
- [Shelf Integration Examples](contextual_shelf/example/)

## Documentation

- [API Reference](https://pub.dev/documentation/contextual/latest/)
- [Contextual Package](contextual/README.md)
- [Contextual Shelf Package](contextual_shelf/README.md)

## Features

- 📝 **Structured Logging**: Rich, structured log entries with context
- 🎨 **Multiple Formats**: JSON, pretty-printed, and plain text output
- 🔄 **Flexible Routing**: Send different logs to different destinations
- 🔍 **Context Support**: Add structured data to your logs
- 🚀 **Performance**: Efficient logging with minimal overhead
- 🛠️ **Extensible**: Easy to add custom drivers and formatters

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development

1. Clone the repository:
```bash
git clone https://github.com/kingwill101/contextual.git
cd contextual
```

2. Get dependencies:
```bash
dart pub get
```

3. Run tests:
```bash
dart test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 