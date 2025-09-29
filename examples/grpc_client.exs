#!/usr/bin/env elixir

# gRPC Client Example
# This example demonstrates how to use the UTCP client with gRPC providers.

Mix.install([
  {:ex_utcp, path: "."}
])

alias ExUtcp.{Client, Config, Providers}

defmodule GrpcClientExample do
  def run do
    IO.puts("=== UTCP gRPC Client Example ===")

    # Create a client configuration
    config = Config.new()

    # Start the UTCP client
    {:ok, client} = Client.start_link(config)

    # Create a gRPC provider
    provider = Providers.new_grpc_provider([
      name: "grpc_demo",
      host: "localhost",
      port: 9339,
      service_name: "UTCPService",
      method_name: "CallTool",
      use_ssl: false,
      auth: ExUtcp.Auth.new_api_key_auth(api_key: "secret-key", location: "header")
    ])

    # Register the provider
    IO.puts("\n=== Registering gRPC Provider ===")
    case Client.register_tool_provider(client, provider) do
      {:ok, tools} ->
        IO.puts("Successfully registered gRPC provider with #{length(tools)} tools:")
        Enum.each(tools, fn tool ->
          IO.puts("  - #{tool.name}: #{tool.description}")
        end)

        # Search for tools
        IO.puts("\n=== Searching Tools ===")
        case Client.search_tools(client, "", 10) do
          {:ok, found_tools} ->
            IO.puts("Found #{length(found_tools)} tools:")
            Enum.each(found_tools, fn tool ->
              IO.puts("  - #{tool.name}: #{tool.description}")
            end)

            # Call a tool if available
            if length(found_tools) > 0 do
              tool = List.first(found_tools)
              IO.puts("\n=== Tool Call Test ===")
              IO.puts("Calling tool '#{tool.name}' with args: %{message: \"Hello gRPC!\"}")

              case Client.call_tool(client, tool.name, %{"message" => "Hello gRPC!"}) do
                {:ok, result} ->
                  IO.puts("SUCCESS: #{inspect(result)}")
                {:error, reason} ->
                  IO.puts("ERROR: #{inspect(reason)}")
              end

              # Test streaming if supported
              IO.puts("\n=== Streaming Test ===")
              case Client.call_tool_stream(client, tool.name, %{"stream" => true}) do
                {:ok, stream_result} ->
                  IO.puts("STREAM SUCCESS: #{inspect(stream_result)}")
                {:error, reason} ->
                  IO.puts("STREAM ERROR: #{inspect(reason)}")
              end
            end
          {:error, reason} ->
            IO.puts("Search error: #{inspect(reason)}")
        end

        # Get client statistics
        stats = Client.get_stats(client)
        IO.puts("\n=== Client Statistics ===")
        IO.puts("Tool count: #{stats.tool_count}")
        IO.puts("Provider count: #{stats.provider_count}")

      {:error, reason} ->
        IO.puts("Registration error: #{inspect(reason)}")
        IO.puts("Note: This example requires a gRPC server running on localhost:9339")
    end

    # Clean up
    GenServer.stop(client)
  end
end

# Run the example
GrpcClientExample.run()
