# Changelog

All notable changes to this project will be documented in this file.

## [0.2.5] - 2024-12-19

### Added
- Comprehensive test suite with 260+ unit tests
- Mock-based unit testing with Mox for all transports
- Integration test tagging for proper test separation
- Testable modules for isolated unit testing
- Complete test coverage for all transport implementations

### Changed
- Enhanced test architecture with proper mock injection
- Improved test reliability and maintainability
- Updated gap analysis to reflect 100% testing coverage
- Enhanced documentation with protocol and library links
- Removed decorative formatting from documentation

### Fixed
- All test failures resolved (reduced from 75 to 0 failures)
- Proper GenServer lifecycle handling in unit tests
- Retry logic call count expectations in tests
- Mock verification and expectation management

## [0.2.4] - 2024-12-19

### Added
- Production-ready MCP (Model Context Protocol) transport implementation
- JSON-RPC 2.0 support for MCP communication
- MCP connection management with pooling and lifecycle management
- MCP authentication support for API Key, Basic, and OAuth2
- MCP error recovery with retry logic and exponential backoff
- MCP tool calling and streaming capabilities
- Comprehensive MCP testing suite with 26 tests
- MCP usage examples demonstrating all features

### Changed
- Enhanced MCP transport with production-ready features
- Updated MCP implementation to use real HTTP connections
- Improved error handling and retry mechanisms for MCP operations
- Enhanced connection pooling and lifecycle management

## [0.2.3] - 2025-09-29

### Added
- Production-ready GraphQL transport implementation with HTTP/HTTPS support
- GraphQL connection management with pooling and lifecycle management
- GraphQL authentication support for API Key, Basic, and OAuth2
- GraphQL error recovery with retry logic and exponential backoff
- GraphQL schema introspection for automatic tool discovery
- GraphQL query, mutation, and subscription support
- GraphQL streaming capabilities for real-time data
- Comprehensive GraphQL testing suite with 18 tests
- GraphQL usage examples demonstrating all features

### Changed
- Enhanced GraphQL transport with production-ready features
- Updated GraphQL implementation to use real HTTP connections
- Improved error handling and retry mechanisms for GraphQL operations
- Enhanced connection pooling and lifecycle management

## [0.2.2] - 2025-09-28
>>>>>>> fc29827 (updated readme)

### Added
- Production-ready gRPC transport implementation with Protocol Buffer integration
- gRPC connection management with pooling and lifecycle management
- gRPC authentication support for API Key, Basic, and OAuth2
- gRPC error recovery with retry logic and exponential backoff
- gNMI integration for network management operations
- gNMI Get, Set, and Subscribe operations with path validation
- Protocol Buffer code generation from .proto files
- Comprehensive gRPC testing suite with 82 tests
- gRPC production example demonstrating all features

### Changed
- Enhanced gRPC transport with production-ready features
- Updated gRPC implementation to use real Protocol Buffer integration
- Improved error handling and retry mechanisms for gRPC operations
- Enhanced connection pooling and lifecycle management


## [0.2.1]  - 2025-09-28

### Added
- Production-ready WebSocket transport implementation with real WebSockex integration
- WebSocket connection management with pooling and lifecycle management
- WebSocket error recovery with retry logic and exponential backoff
- WebSocket performance optimizations with connection reuse and message batching
- WebSocket connection behavior for testability
- Comprehensive WebSocket mock-based testing suite
- WebSocket testable module for isolated unit testing

### Changed
- Enhanced WebSocket transport with production-ready features
- Improved WebSocket testing with Mox mocks
- Updated WebSocket implementation to use real WebSocket connections
- Enhanced error handling and retry mechanisms for WebSocket operations


## [0.2.0] - 2025-09-28


### Added
- WebSocket transport implementation for real-time bidirectional communication
- WebSocket provider support with full configuration options
- WebSocket streaming functionality for real-time data streaming
- Comprehensive WebSocket test suite
- WebSocket client and server examples
- Enhanced provider type system with WebSocket-specific fields
- gRPC transport implementation for high-performance RPC calls
- gRPC provider support with Protocol Buffer integration
- gRPC streaming functionality for real-time data streaming
- Comprehensive gRPC test suite
- gRPC client example
- Protocol Buffer definition file (proto/utcp.proto)
- Enhanced provider type system with gRPC-specific fields

### Changed
- Updated client to support WebSocket and gRPC providers
- Enhanced provider parsing to handle WebSocket and gRPC configuration
- Extended type definitions for WebSocket and gRPC providers
- Updated gap analysis to reflect 33% transport coverage (4/12 types)

## [0.1.0] - 2025-09-27

### Added
- Initial release of ExUtcp library
- HTTP transport implementation
- CLI transport implementation
- Core UTCP client functionality
- Tool discovery and execution
- Provider management system
- Authentication support (API Key, Basic, OAuth2)
- Configuration management with variable substitution
- Comprehensive test suite
- Example applications and documentation
