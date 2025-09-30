#!/usr/bin/env elixir

# Production-Ready gRPC Transport Example
# This example demonstrates the full gRPC transport implementation with:
# - Real gRPC connections using Protocol Buffers
# - Connection pooling and lifecycle management
# - Authentication support
# - Error recovery with retry logic
# - gNMI integration for network management

Mix.install([
  {:ex_utcp, path: "."}
])

defmodule GrpcProductionExample do
  require Logger

  def run do
    Logger.info("Starting gRPC Production Example...")

    # Create a client with gRPC transport
    config = ExUtcp.Config.new()
    {:ok, client} = ExUtcp.Client.start_link(config)

    # Example 1: Basic gRPC Provider
    basic_grpc_example(client)

    # Example 2: gRPC Provider with Authentication
    authenticated_grpc_example(client)

    # Example 3: gNMI Network Management
    gnmi_example(client)

    # Example 4: Connection Pooling and Error Recovery
    connection_pooling_example(client)

    Logger.info("gRPC Production Example completed!")
  end

  defp basic_grpc_example(client) do
    Logger.info("\n=== Basic gRPC Provider Example ===")

    # Create a basic gRPC provider
    provider = ExUtcp.Providers.new_grpc_provider([
      name: "basic_grpc",
      host: "localhost",
      port: 50051,
      service_name: "UTCPService",
      method_name: "GetManual",
      use_ssl: false
    ])

    # Register the provider
    case ExUtcp.Client.register_tool_provider(client, provider) do
      {:ok, tools} ->
        Logger.info("Registered gRPC provider with #{length(tools)} tools")
      {:error, reason} ->
        Logger.error("Failed to register gRPC provider: #{inspect(reason)}")
    end

    # Call a tool
    case ExUtcp.Client.call_tool(client, "test.tool", %{"arg" => "value"}, provider) do
      {:ok, result} ->
        Logger.info("Tool call result: #{inspect(result)}")
      {:error, reason} ->
        Logger.error("Tool call failed: #{inspect(reason)}")
    end

    # Call a tool stream
    case ExUtcp.Client.call_tool_stream(client, "test.stream", %{"arg" => "value"}, provider) do
      {:ok, %{type: :stream, data: chunks}} ->
        Logger.info("Tool stream received #{length(chunks)} chunks")
        Enum.each(chunks, fn chunk ->
          Logger.info("Stream chunk: #{inspect(chunk)}")
        end)
      {:error, reason} ->
        Logger.error("Tool stream failed: #{inspect(reason)}")
    end
  end

  defp authenticated_grpc_example(client) do
    Logger.info("\n=== Authenticated gRPC Provider Example ===")

    # Create an authenticated gRPC provider
    auth = ExUtcp.Auth.new_api_key_auth(api_key: "secret-key", location: "header")

    provider = ExUtcp.Providers.new_grpc_provider([
      name: "auth_grpc",
      host: "grpc.example.com",
      port: 443,
      service_name: "UTCPService",
      method_name: "GetManual",
      use_ssl: true,
      auth: auth
    ])

    # Register the authenticated provider
    case ExUtcp.Client.register_tool_provider(client, provider) do
      {:ok, tools} ->
        Logger.info("Registered authenticated gRPC provider with #{length(tools)} tools")
      {:error, reason} ->
        Logger.error("Failed to register authenticated gRPC provider: #{inspect(reason)}")
    end
  end

  defp gnmi_example(client) do
    Logger.info("\n=== gNMI Network Management Example ===")

    # Create a gRPC provider for gNMI operations
    provider = ExUtcp.Providers.new_grpc_provider([
      name: "gnmi_router",
      host: "router.example.com",
      port: 50051,
      service_name: "UTCPService",
      method_name: "GetManual",
      use_ssl: false
    ])

    # Start the gRPC transport
    {:ok, _pid} = ExUtcp.Transports.Grpc.start_link()

    # gNMI Get operation - retrieve interface configuration
    paths = ["/interfaces/interface[name=eth0]/state", "/system/state"]
    case ExUtcp.Transports.Grpc.gnmi_get(provider, paths, [timeout: 30_000]) do
      {:ok, result} ->
        Logger.info("gNMI Get result: #{inspect(result)}")
      {:error, reason} ->
        Logger.error("gNMI Get failed: #{inspect(reason)}")
    end

    # gNMI Set operation - configure interface
    updates = [
      %{
        "path" => "/interfaces/interface[name=eth0]/config/enabled",
        "val" => %{"enabled" => true}
      }
    ]
    case ExUtcp.Transports.Grpc.gnmi_set(provider, updates, [timeout: 30_000]) do
      {:ok, result} ->
        Logger.info("gNMI Set result: #{inspect(result)}")
      {:error, reason} ->
        Logger.error("gNMI Set failed: #{inspect(reason)}")
    end

    # gNMI Subscribe operation - monitor interface state
    subscribe_paths = ["/interfaces/interface[name=eth0]/state"]
    case ExUtcp.Transports.Grpc.gnmi_subscribe(provider, subscribe_paths, [
      mode: "ON_CHANGE",
      sample_interval: 1000,
      timeout: 30_000
    ]) do
      {:ok, updates} ->
        Logger.info("gNMI Subscribe received #{length(updates)} updates")
        Enum.each(updates, fn update ->
          Logger.info("gNMI Update: #{inspect(update)}")
        end)
      {:error, reason} ->
        Logger.error("gNMI Subscribe failed: #{inspect(reason)}")
    end
  end

  defp connection_pooling_example(client) do
    Logger.info("\n=== Connection Pooling and Error Recovery Example ===")

    # Create multiple providers to test connection pooling
    providers = [
      ExUtcp.Providers.new_grpc_provider([
        name: "pool_provider_1",
        host: "server1.example.com",
        port: 50051,
        service_name: "UTCPService",
        method_name: "GetManual",
        use_ssl: false
      ]),
      ExUtcp.Providers.new_grpc_provider([
        name: "pool_provider_2",
        host: "server2.example.com",
        port: 50051,
        service_name: "UTCPService",
        method_name: "GetManual",
        use_ssl: false
      ])
    ]

    # Register multiple providers to test connection pooling
    Enum.each(providers, fn provider ->
      case ExUtcp.Client.register_tool_provider(client, provider) do
        {:ok, tools} ->
          Logger.info("Registered #{provider.name} with #{length(tools)} tools")
        {:error, reason} ->
          Logger.error("Failed to register #{provider.name}: #{inspect(reason)}")
      end
    end)

    # Test concurrent tool calls to demonstrate connection pooling
    tasks = Enum.map(providers, fn provider ->
      Task.async(fn ->
        case ExUtcp.Client.call_tool(client, "concurrent.tool", %{"id" => provider.name}, provider) do
          {:ok, result} ->
            Logger.info("Concurrent call to #{provider.name} succeeded: #{inspect(result)}")
          {:error, reason} ->
            Logger.error("Concurrent call to #{provider.name} failed: #{inspect(reason)}")
        end
      end)
    end)

    # Wait for all concurrent calls to complete
    Task.await_many(tasks, 30_000)

    # Test error recovery by calling a tool on a non-existent server
    error_provider = ExUtcp.Providers.new_grpc_provider([
      name: "error_provider",
      host: "non-existent-server.example.com",
      port: 50051,
      service_name: "UTCPService",
      method_name: "GetManual",
      use_ssl: false
    ])

    case ExUtcp.Client.call_tool(client, "error.tool", %{"test" => "error_recovery"}, error_provider) do
      {:ok, result} ->
        Logger.info("Error recovery test succeeded: #{inspect(result)}")
      {:error, reason} ->
        Logger.info("Error recovery test failed as expected: #{inspect(reason)}")
    end
  end
end

# Run the example
GrpcProductionExample.run()
