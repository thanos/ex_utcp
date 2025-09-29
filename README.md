# ExUtcp

[![Hex.pm](https://img.shields.io/hexpm/v/ex_utcp.svg)](https://hex.pm/packages/ex_utcp)
[![Hex.pm](https://img.shields.io/hexpm/dt/ex_utcp.svg)](https://hex.pm/packages/ex_utcp)
[![Hex.pm](https://img.shields.io/hexpm/l/ex_utcp.svg)](https://hex.pm/packages/ex_utcp)

Elixir implementation of the Universal Tool Calling Protocol (UTCP).

## Introduction

The Universal Tool Calling Protocol (UTCP) is a modern, flexible, and scalable standard for defining and interacting with tools across a wide variety of communication protocols. It is designed to be easy to use, interoperable, and extensible, making it a powerful choice for building and consuming tool-based services.

In contrast to other protocols like MCP, UTCP places a strong emphasis on:

* **Scalability**: UTCP is designed to handle a large number of tools and providers without compromising performance.
* **Interoperability**: With support for a wide range of provider types (including HTTP, WebSockets, gRPC, and even CLI tools), UTCP can integrate with almost any existing service or infrastructure.
* **Ease of Use**: The protocol is built on simple, intuitive patterns.

## Features

* Built-in transports for HTTP, CLI, Server-Sent Events, streaming HTTP, GraphQL, MCP, WebSocket, gRPC, TCP, UDP, and WebRTC
* Variable substitution via environment variables or `.env` files
* In-memory repository for storing providers and tools discovered at runtime
* Utilities such as `OpenApiConverter` to convert OpenAPI definitions into UTCP manuals
* Example programs demonstrating the client usage

## Installation

Add `ex_utcp` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_utcp, "~> 0.1.0"}
  ]
end
```

## Getting Started

### Basic Usage

```elixir
alias ExUtcp.{Client, Config}

# Create a client configuration
config = Config.new(providers_file_path: "providers.json")

# Start a UTCP client
{:ok, client} = Client.start_link(config)

# Search for tools
{:ok, tools} = Client.search_tools(client, "", 10)

# Call a tool
{:ok, result} = Client.call_tool(client, "provider.tool_name", %{"arg" => "value"})
```

### Programmatic Provider Registration

```elixir
alias ExUtcp.{Client, Config, Providers}

# Create a client
config = Config.new()
{:ok, client} = Client.start_link(config)

# Create an HTTP provider
provider = Providers.new_http_provider([
  name: "my_api",
  url: "https://api.example.com/tools",
  http_method: "POST"
])

# Register the provider
{:ok, tools} = Client.register_tool_provider(client, provider)

# Call a discovered tool
{:ok, result} = Client.call_tool(client, "my_api.echo", %{"message" => "Hello!"})
```

### CLI Provider Example

```elixir
alias ExUtcp.{Client, Config, Providers}

# Create a client
config = Config.new()
{:ok, client} = Client.start_link(config)

# Create a CLI provider
provider = Providers.new_cli_provider([
  name: "my_script",
  command_name: "python my_script.py",
  working_dir: "/path/to/script"
])

# Register the provider
{:ok, tools} = Client.register_tool_provider(client, provider)

# Call a tool
{:ok, result} = Client.call_tool(client, "my_script.greet", %{"name" => "World"})
```

## Configuration

### Provider Configuration File

Create a `providers.json` file to define your providers:

```json
{
  "providers": [
    {
      "name": "http_api",
      "type": "http",
      "http_method": "POST",
      "url": "https://api.example.com/tools",
      "content_type": "application/json",
      "headers": {
        "User-Agent": "ExUtcp/0.1.0"
      },
      "auth": {
        "type": "api_key",
        "api_key": "${API_KEY}",
        "location": "header",
        "var_name": "Authorization"
      }
    },
    {
      "name": "cli_tool",
      "type": "cli",
      "command_name": "python my_tool.py",
      "working_dir": "/opt/tools",
      "env_vars": {
        "PYTHONPATH": "/opt/tools"
      }
    }
  ]
}
```

### Variable Substitution

UTCP supports variable substitution using `${VAR}` or `$VAR` syntax:

```elixir
# Load variables from .env file
{:ok, env_vars} = Config.load_from_env_file(".env")

config = Config.new(
  variables: env_vars,
  providers_file_path: "providers.json"
)
```

## Architecture

The library is organized into several main components:

* `ExUtcp.Client` - Main client interface
* `ExUtcp.Config` - Configuration management
* `ExUtcp.Providers` - Provider implementations for different protocols
* `ExUtcp.Transports` - Transport layer implementations
* `ExUtcp.Tools` - Tool definitions and management
* `ExUtcp.Repository` - Tool and provider storage

## Implementation Status

### Gap Analysis: Elixir UTCP vs Go UTCP

| Feature Category | Go Implementation | Elixir Implementation | Coverage |
|------------------|-------------------|----------------------|----------|
| **Core Client** | ✅ Complete | ✅ Complete | 100% |
| **Configuration** | ✅ Complete | ✅ Basic | 70% |
| **Transports** | ✅ 12 types | ✅ 3 types | 25% |
| **Providers** | ✅ 12 types | ✅ 3 types | 25% |
| **Authentication** | ✅ 3 types | ✅ 3 types | 100% |
| **Tool Management** | ✅ Complete | ✅ Complete | 100% |
| **Streaming** | ✅ Complete | ✅ Basic | 60% |
| **Search** | ✅ Advanced | ✅ Basic | 60% |
| **Performance** | ✅ Optimized | ✅ Basic | 30% |
| **Error Handling** | ✅ Robust | ✅ Basic | 70% |

### Priority Recommendations

#### **High Priority (Core Functionality)**
- [ ] **Implement Missing Transports**: WebSocket, gRPC, GraphQL, MCP
- [ ] **Add Streaming Support**: Complete `CallToolStream` implementation
- [ ] **OpenAPI Converter**: Automatic API discovery
- [ ] **Advanced Search**: Implement proper search strategies

#### **Medium Priority (Enhanced Features)**
- [ ] **Performance Optimizations**: Caching, connection pooling
- [ ] **Error Resilience**: Retry logic, circuit breakers
- [ ] **Monitoring**: Metrics and health checks
- [ ] **Batch Operations**: Multiple tool calls

#### **Low Priority (Nice to Have)**
- [ ] **WebRTC Support**: Peer-to-peer communication
- [ ] **Custom Variable Loaders**: Beyond .env files
- [ ] **Advanced Configuration**: Per-transport settings
- [ ] **Documentation**: API documentation generation

### Current Implementation Status

#### **✅ Completed Features**
- **HTTP Transport**: Full REST API integration with OpenAPI support
- **CLI Transport**: Command-line tool integration with argument formatting
- **WebSocket Transport**: Real-time communication (mock implementation)
- **Core Client**: GenServer-based client with full API compatibility
- **Configuration Management**: Variable substitution, environment loading
- **Tool Management**: Discovery, registration, search, and execution
- **Authentication**: API key, Basic, and OAuth2 support
- **Repository Pattern**: In-memory storage for providers and tools

#### **🔄 In Progress**
- **WebSocket Integration**: Real WebSocket connection implementation
- **Streaming Support**: Enhanced streaming capabilities

#### **📋 Planned**
- **gRPC Transport**: High-performance RPC calls
- **GraphQL Transport**: GraphQL API integration
- **MCP Transport**: Model Context Protocol integration
- **Performance Optimizations**: Connection pooling, caching
- **Advanced Search**: Sophisticated search algorithms

## Supported Transports

### ✅ **Implemented**
- **HTTP/HTTPS**: REST API integration with OpenAPI support
- **CLI**: Command-line tool integration
- **WebSocket**: Real-time communication (mock implementation)

### 🔄 **In Progress**
- **WebSocket**: Real WebSocket connection implementation

### 📋 **Planned**
- **gRPC**: High-performance RPC calls
- **GraphQL**: GraphQL API integration
- **TCP/UDP**: Low-level network protocols
- **WebRTC**: Peer-to-peer communication
- **MCP**: Model Context Protocol integration
- **Server-Sent Events**: Real-time streaming
- **Streamable HTTP**: HTTP streaming support

## Examples

Check the `examples/` directory for complete working examples:

- `http_client.exs` - HTTP provider example
- `cli_client.exs` - CLI provider example
- `websocket_client.exs` - WebSocket provider example
- `websocket_server.exs` - WebSocket server for testing
- `simple_example.exs` - Basic usage demonstration

## Testing

Run the test suite:

```bash
mix test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MPL-2.0 License - see the [LICENSE](LICENSE) file for details.

## Links

- [UTCP Website](https://www.utcp.io/)
- [Go Implementation](https://github.com/universal-tool-calling-protocol/go-utcp)
- [Hex Package](https://hex.pm/packages/ex_utcp)
