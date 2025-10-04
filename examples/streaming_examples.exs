# ExUtcp Streaming Examples
# This file demonstrates comprehensive streaming support across all transports

# Start the ExUtcp application
Application.ensure_all_started(:ex_utcp)

# Create a client
{:ok, client} = ExUtcp.Client.start_link()

# =============================================================================
# HTTP Streaming with Server-Sent Events
# =============================================================================

IO.puts("=== HTTP Streaming Example ===")

# Create an HTTP provider that supports streaming
http_provider = ExUtcp.Providers.new_http_provider([
  name: "streaming_api",
  url: "https://api.example.com/stream",
  http_method: "POST",
  content_type: "application/json"
])

# Register the provider
case ExUtcp.Client.register_provider(client, http_provider) do
  {:ok, tools} ->
    IO.puts("Registered HTTP provider with #{length(tools)} tools")

    # Call a streaming tool
    case ExUtcp.Client.call_tool_stream(client, "streaming_api:stream_data", %{"query" => "test"}) do
      {:ok, %{type: :stream, data: stream, metadata: metadata}} ->
        IO.puts("HTTP Stream started with metadata: #{inspect(metadata)}")

        # Process the stream
        stream
        |> Enum.take(5)  # Take first 5 chunks
        |> Enum.each(fn chunk ->
          IO.puts("HTTP Chunk: #{inspect(chunk)}")
        end)

      {:error, reason} ->
        IO.puts("HTTP streaming failed: #{inspect(reason)}")
    end

  {:error, reason} ->
    IO.puts("Failed to register HTTP provider: #{inspect(reason)}")
end

# =============================================================================
# WebSocket Streaming
# =============================================================================

IO.puts("\n=== WebSocket Streaming Example ===")

# Create a WebSocket provider
websocket_provider = ExUtcp.Providers.new_websocket_provider([
  name: "realtime_api",
  url: "ws://localhost:8080/ws",
  keep_alive: true
])

# Register the provider
case ExUtcp.Client.register_provider(client, websocket_provider) do
  {:ok, tools} ->
    IO.puts("Registered WebSocket provider with #{length(tools)} tools")

    # Call a streaming tool
    case ExUtcp.Client.call_tool_stream(client, "realtime_api:subscribe", %{"channel" => "updates"}) do
      {:ok, %{type: :stream, data: stream, metadata: metadata}} ->
        IO.puts("WebSocket Stream started with metadata: #{inspect(metadata)}")

        # Process the stream
        stream
        |> Enum.take(3)  # Take first 3 chunks
        |> Enum.each(fn chunk ->
          IO.puts("WebSocket Chunk: #{inspect(chunk)}")
        end)

      {:error, reason} ->
        IO.puts("WebSocket streaming failed: #{inspect(reason)}")
    end

  {:error, reason} ->
    IO.puts("Failed to register WebSocket provider: #{inspect(reason)}")
end

# =============================================================================
# GraphQL Streaming with Subscriptions
# =============================================================================

IO.puts("\n=== GraphQL Streaming Example ===")

# Create a GraphQL provider
graphql_provider = ExUtcp.Providers.new_graphql_provider([
  name: "graphql_api",
  url: "https://api.example.com/graphql"
])

# Register the provider
case ExUtcp.Client.register_provider(client, graphql_provider) do
  {:ok, tools} ->
    IO.puts("Registered GraphQL provider with #{length(tools)} tools")

    # Call a streaming tool (subscription)
    case ExUtcp.Client.call_tool_stream(client, "graphql_api:subscribe_updates", %{"filter" => "important"}) do
      {:ok, %{type: :stream, data: stream, metadata: metadata}} ->
        IO.puts("GraphQL Stream started with metadata: #{inspect(metadata)}")

        # Process the stream
        stream
        |> Enum.take(3)  # Take first 3 chunks
        |> Enum.each(fn chunk ->
          IO.puts("GraphQL Chunk: #{inspect(chunk)}")
        end)

      {:error, reason} ->
        IO.puts("GraphQL streaming failed: #{inspect(reason)}")
    end

  {:error, reason} ->
    IO.puts("Failed to register GraphQL provider: #{inspect(reason)}")
end

# =============================================================================
# gRPC Streaming
# =============================================================================

IO.puts("\n=== gRPC Streaming Example ===")

# Create a gRPC provider
grpc_provider = ExUtcp.Providers.new_grpc_provider([
  name: "grpc_service",
  host: "localhost",
  port: 50051,
  service_name: "StreamingService",
  method_name: "StreamData"
])

# Register the provider
case ExUtcp.Client.register_provider(client, grpc_provider) do
  {:ok, tools} ->
    IO.puts("Registered gRPC provider with #{length(tools)} tools")

    # Call a streaming tool
    case ExUtcp.Client.call_tool_stream(client, "grpc_service:stream_data", %{"request_id" => "123"}) do
      {:ok, %{type: :stream, data: stream, metadata: metadata}} ->
        IO.puts("gRPC Stream started with metadata: #{inspect(metadata)}")

        # Process the stream
        stream
        |> Enum.take(3)  # Take first 3 chunks
        |> Enum.each(fn chunk ->
          IO.puts("gRPC Chunk: #{inspect(chunk)}")
        end)

      {:error, reason} ->
        IO.puts("gRPC streaming failed: #{inspect(reason)}")
    end

  {:error, reason} ->
    IO.puts("Failed to register gRPC provider: #{inspect(reason)}")
end

# =============================================================================
# MCP Streaming with JSON-RPC 2.0
# =============================================================================

IO.puts("\n=== MCP Streaming Example ===")

# Create an MCP provider
mcp_provider = ExUtcp.Providers.new_mcp_provider([
  name: "mcp_service",
  url: "https://mcp.example.com/api"
])

# Register the provider
case ExUtcp.Client.register_provider(client, mcp_provider) do
  {:ok, tools} ->
    IO.puts("Registered MCP provider with #{length(tools)} tools")

    # Call a streaming tool
    case ExUtcp.Client.call_tool_stream(client, "mcp_service:stream_tools", %{"context" => "development"}) do
      {:ok, %{type: :stream, data: stream, metadata: metadata}} ->
        IO.puts("MCP Stream started with metadata: #{inspect(metadata)}")

        # Process the stream
        stream
        |> Enum.take(3)  # Take first 3 chunks
        |> Enum.each(fn chunk ->
          IO.puts("MCP Chunk: #{inspect(chunk)}")
        end)

      {:error, reason} ->
        IO.puts("MCP streaming failed: #{inspect(reason)}")
    end

  {:error, reason} ->
    IO.puts("Failed to register MCP provider: #{inspect(reason)}")
end

# =============================================================================
# Advanced Streaming Patterns
# =============================================================================

IO.puts("\n=== Advanced Streaming Patterns ===")

# Stream Processing with Error Handling
defmodule StreamProcessor do
  def process_stream(stream, processor_fn) do
    stream
    |> Stream.map(fn chunk ->
      case chunk do
        %{type: :error, error: error} ->
          IO.puts("Stream error: #{error}")
          {:error, error}
        %{type: :end} ->
          IO.puts("Stream ended")
          :done
        chunk ->
          processor_fn.(chunk)
      end
    end)
    |> Stream.reject(&(&1 == :done))
    |> Enum.to_list()
  end

  def filter_by_metadata(stream, key, value) do
    Stream.filter(stream, fn chunk ->
      case chunk do
        %{metadata: metadata} when is_map(metadata) ->
          Map.get(metadata, key) == value
        _ ->
          false
      end
    end)
  end

  def aggregate_stream(stream) do
    stream
    |> Stream.reduce({[], 0, 0}, fn chunk, {acc, count, errors} ->
      case chunk do
        %{type: :error} ->
          {acc, count, errors + 1}
        chunk ->
          {[chunk | acc], count + 1, errors}
      end
    end)
  end
end

# Example: Process a stream with custom logic
IO.puts("Processing stream with custom logic...")

# This would be used with a real stream
# result = StreamProcessor.process_stream(stream, fn chunk ->
#   IO.puts("Processing: #{inspect(chunk.data)}")
#   chunk
# end)

IO.puts("\n=== Streaming Examples Complete ===")
IO.puts("All streaming implementations are now enhanced with:")
IO.puts("- Comprehensive metadata tracking")
IO.puts("- Sequence numbering")
IO.puts("- Timestamp tracking")
IO.puts("- Protocol-specific information")
IO.puts("- Error handling and stream termination")
IO.puts("- Enhanced type safety with proper stream_result types")

