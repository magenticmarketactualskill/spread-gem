# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-12-12

### Added
- Initial release of SpreadGem
- Core `Client` class for connecting to SpreadJS servers
- `Store` class with hash-like interface for synchronized data
- `Connection` class for WebSocket management
- `Message` class for protocol serialization/deserialization
- Thread-safe operations using concurrent-ruby
- Support for nested object paths with `get_in`, `set_in`, `delete_in`
- Change callback system with `on_change`
- Automatic reconnection on connection loss
- Comprehensive error handling with custom error classes
- RSpec test suite with 100+ test cases
- Cucumber BDD feature tests
- Full API documentation with YARD
- README with examples and usage guide
- MIT License

### Features
- Real-time synchronization across multiple instances
- Ruby-idiomatic hash-like API
- Nested object support
- Change notifications
- Connection error handling
- State synchronization requests
- Ping/pong keep-alive

### Dependencies
- websocket-client-simple ~> 0.8
- json ~> 2.7
- concurrent-ruby ~> 1.2

### Development Dependencies
- rspec ~> 3.12
- cucumber ~> 9.0
- rake ~> 13.0
- bundler ~> 2.4
- yard ~> 0.9
- simplecov ~> 0.22

[Unreleased]: https://github.com/spreadjs/spread-gem/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/spreadjs/spread-gem/releases/tag/v0.1.0
