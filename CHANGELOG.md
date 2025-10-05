# Changelog

All notable changes to this project will be documented in this file.

## [0.3.1] - 2025-10-05

### Added
- WebRTC Transport: Peer-to-peer communication with WebRTC data channels
- ExWebRTC library integration for W3C WebRTC API implementation
- WebRTC connection management with signaling protocol
- ICE candidate handling with STUN/TURN server support
- WebRTC data channels for tool communication
- Peer-to-peer tool calling without server intermediary
- WebRTC signaling server client for SDP and ICE exchange
- NAT traversal with configurable ICE servers
- DTLS encryption for secure peer-to-peer communication
- WebRTC streaming support with data channel multiplexing
- 18 comprehensive WebRTC tests covering all transport features
- WebRTC examples and documentation with setup guide
- Sobelow security analysis tool integration

### Changed
- Updated Client module to include WebRTC transport in default transports
- Enhanced Providers module with WebRTC provider configuration
- Updated transport count from 7 to 8 transports
- Improved README with updated transport coverage

### Fixed
- WebRTC provider configuration with proper ICE server defaults
- Connection lifecycle management for WebRTC peers
- Data channel message handling and serialization

## [0.3.0] - 2025-10-04

### Added
- Monitoring and Metrics: Comprehensive monitoring system with telemetry integration
- Telemetry events for all UTCP operations (tool calls, searches, provider registration, connections)
- PromEx integration for Prometheus metrics collection and visualization
- Health check system for monitoring transport and component health
- Performance monitoring with operation timing and statistical analysis
- Metrics collection system with counters, gauges, histograms, and summaries
- System monitoring for memory usage, process counts, and scheduler utilization
- Performance alerts and threshold-based monitoring
- Custom metrics recording and aggregation
- Monitoring dashboard configuration with PromEx
- 15+ comprehensive monitoring tests covering all monitoring features
- Monitoring examples and documentation

### Changed
- Enhanced Client module with monitoring and performance measurement integration
- Added telemetry events to tool calls and search operations for performance tracking
- Improved error handling with performance metrics for failed operations
- Updated Client API with monitoring functions (get_monitoring_metrics, get_health_status, get_performance_summary)

### Fixed
- Performance measurement error handling with proper telemetry emission
- Health check system robustness with fallback mechanisms
- Metrics collection reliability with graceful degradation when services unavailable

## [0.2.9] - 2025-10-04

### Added
- Advanced Search: Comprehensive search system with multiple algorithms
- FuzzyCompare integration for advanced fuzzy string matching
- Haystack integration for full-text search capabilities
- TruffleHog integration for sensitive data detection in search results
- Search algorithms: exact, fuzzy, semantic, and combined search
- Search filters by provider, transport type, and tags
- Search result ranking and scoring system
- Security scanning for tools and providers with sensitive data detection
- Search suggestions and similar tool discovery
- 40+ comprehensive search tests covering all algorithms and features
- Advanced search examples and documentation

### Changed
- Enhanced Client module with advanced search functionality
- Improved search result structure with security warnings and match metadata
- Updated search options to include security scanning and filtering
- Enhanced tool and provider discovery with intelligent ranking

### Fixed
- Search result ranking algorithm for accurate relevance scoring
- Fuzzy search integration with proper similarity calculations
- Semantic search keyword extraction and matching
- Security scanning fallback mechanisms for robust operation

## [0.2.8] - 2025-10-04

### Added
- Test configuration for integration test exclusion by default
- Proper test tagging system with @tag :integration and @tag :unit
- TCP/UDP transport implementation with connection management and pooling
- TCP/UDP transport streaming support with proper metadata
- TCP/UDP transport retry logic with exponential backoff
- TCP/UDP transport connection behaviors and testable modules
- TCP/UDP transport integration tests for real network connections
- TCP/UDP transport mock tests with Mox integration
- TCP/UDP transport examples and documentation

### Changed
- Test helper configuration to exclude integration tests by default (mix test)
- Integration tests now require explicit inclusion (mix test --include integration)
- TCP connection tests properly tagged as integration tests
- Improved test isolation and reliability for unit tests
- Enhanced test documentation and organization

### Fixed
- Test suite reliability by separating unit tests from integration tests
- TCP/UDP mock test isolation issues with unique GenServer processes
- Test timeout issues in TCP/UDP mock tests
- Proper categorization of network-dependent tests as integration tests
- Test configuration to prevent flaky tests in CI/CD environments

## [0.2.7] - 2025-10-03

### Added
- OpenAPI Converter: Automatic API discovery and tool generation
- Support for OpenAPI 2.0 (Swagger) and OpenAPI 3.0 specifications
- JSON and YAML specification parsing
- URL and file-based specification loading
- Authentication scheme mapping (API Key, Basic, Bearer, OAuth2, OpenID Connect)
- Tool generation from OpenAPI operations
- Client integration for OpenAPI conversion
- 12 comprehensive OpenAPI Converter tests
- OpenAPI Converter examples and documentation

### Changed
- Updated gap analysis to reflect OpenAPI Converter completion
- Enhanced documentation with OpenAPI Converter usage examples
- Updated test count to 272+ tests

### Fixed
- Elixir type usage patterns in OpenAPI Converter
- Infinite recursion in schema parsing
- Content type handling for URL-based specifications
- Prefix duplication in tool name generation
- Argument error in security scheme parsing
- Authentication parameter mapping

## [0.2.6] - 2024-12-19

### Added
- Comprehensive streaming support across all transports
- Enhanced type system with stream_chunk, stream_result, stream_error, and stream_end types
- HTTP Server-Sent Events (SSE) streaming implementation
- Enhanced WebSocket streaming with proper metadata tracking
- Improved GraphQL streaming with subscription support
- Enhanced gRPC streaming with service-specific metadata
- Improved MCP streaming with JSON-RPC 2.0 support
- 21 comprehensive streaming unit tests
- Complete streaming examples for all transports
- Advanced stream processing patterns and utilities

### Changed
- HTTP transport now supports streaming (supports_streaming? returns true)
- All transport streaming implementations enhanced with rich metadata
- Stream result structures standardized across all transports
- Enhanced error handling and stream termination across all transports

### Fixed
- Stream processing consistency across all transports
- Metadata tracking and sequence numbering
- Error handling in streaming scenarios
- Type safety improvements for streaming operations

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
