## [0.1.0] - 2025-02-15

### Added
- Initial stable release
- Shelf middleware integration with contextual logging
- Request/response logging features:
  - Timing information
  - Memory usage tracking
  - Process ID logging
  - Status code monitoring
- Header sanitization with configurable rules
- Built-in log profiles:
  - LogNonGetRequests for filtering GET requests
  - Custom profile support
- Performance monitoring:
  - Request duration tracking
  - Memory usage monitoring
  - Process statistics
- Error handling:
  - Automatic error catching
  - Stack trace logging
  - Error context preservation
- Sanitization features:
  - Header cleaning
  - Sensitive data masking
  - Custom sanitization rules

### Changed
- Improved performance in high-traffic scenarios
- Enhanced error handling robustness
- Better memory management

### Fixed
- Memory leaks in long-running servers
- Header sanitization edge cases
- Performance bottlenecks in logging pipeline

## [0.9.0] - 2024-02-01

### Added
- Beta release with core functionality
- Basic Shelf integration
- Initial request logging
- Simple header sanitization

### Changed
- Refined middleware API
- Improved documentation
- Enhanced error handling

## [0.1.0] - 2024-01-15

### Added
- Initial development release
- Basic middleware structure
- Proof of concept implementation

