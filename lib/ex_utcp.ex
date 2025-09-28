defmodule ExUtcp do
  @moduledoc """
  Elixir implementation of the Universal Tool Calling Protocol (UTCP).

  UTCP is a modern, flexible, and scalable standard for defining and interacting
  with tools across a wide variety of communication protocols. It is designed to
  be easy to use, interoperable, and extensible, making it a powerful choice for
  building and consuming tool-based services.

  ## Features

  * Built-in transports for HTTP, CLI, Server-Sent Events, streaming HTTP,
    GraphQL, MCP, WebSocket, gRPC, TCP, UDP, and WebRTC
  * Variable substitution via environment variables or `.env` files
  * In-memory repository for storing providers and tools discovered at runtime
  * Utilities such as `OpenApiConverter` to convert OpenAPI definitions into UTCP manuals
  * Example programs demonstrating the client usage

  ## Getting Started

  ```elixir
  alias ExUtcp.{Client, Config}

  # Create a client configuration
  config = Config.new(providers_file_path: "providers.json")

  # Create a UTCP client
  {:ok, client} = Client.start_link(config)

  # Search for tools
  {:ok, tools} = Client.search_tools(client, "", 10)

  # Call a tool
  {:ok, result} = Client.call_tool(client, "provider.tool_name", %{"arg" => "value"})
  ```

  ## Architecture

  The library is organized into several main components:

  * `ExUtcp.Client` - Main client interface
  * `ExUtcp.Config` - Configuration management
  * `ExUtcp.Providers` - Provider implementations for different protocols
  * `ExUtcp.Transports` - Transport layer implementations
  * `ExUtcp.Tools` - Tool definitions and management
  * `ExUtcp.Repository` - Tool and provider storage
  """

  @doc """
  Returns the version of the ExUtcp library.
  """
  def version do
    Application.spec(:ex_utcp, :vsn)
    |> to_string()
  end
end
