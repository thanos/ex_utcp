#!/usr/bin/env elixir

# TCP/UDP Transport Examples
# This file demonstrates how to use the TCP/UDP transport for low-level network communication.

# Start the application
Mix.install([
  {:ex_utcp, path: "."}
])

alias ExUtcp.{Client, Config}
alias ExUtcp.Providers

defmodule TcpUdpExample do
  @moduledoc """
  Examples demonstrating TCP/UDP transport usage.
  """

  def run do
    IO.puts("=== TCP/UDP Transport Examples ===\n")

    # Create a client
    {:ok, client} = Client.start_link(%{providers_file_path: nil, variables: %{}})

    # Example 1: Basic TCP Provider
    tcp_example(client)

    # Example 2: Basic UDP Provider
    udp_example(client)

    # Example 3: TCP with Authentication
    tcp_auth_example(client)

    # Example 4: UDP with Custom Timeout
    udp_timeout_example(client)

    # Example 5: Streaming with TCP
    tcp_streaming_example(client)

    # Example 6: Error Handling
    error_handling_example(client)

    # Example 7: Multiple Providers
    multiple_providers_example(client)

    # Close the client
    Client.close(client)
  end

  defp tcp_example(client) do
    IO.puts("1. Basic TCP Provider Example")
    IO.puts("=" <> String.duplicate("=", 40))

    # Create a TCP provider
    tcp_provider = Providers.new_tcp_provider(
      name: "echo_tcp",
      host: "localhost",
      port: 8080
    )

    # Register the provider
    case Client.register_tool_provider(client, tcp_provider) do
      {:ok, tools} ->
        IO.puts("✓ TCP provider registered successfully")
        IO.puts("  Tools discovered: #{length(tools)}")
      {:error, reason} ->
        IO.puts("✗ Failed to register TCP provider: #{inspect(reason)}")
    end

    # Create a test tool
    tool = %{
      name: "echo_tcp",
      description: "Echo service over TCP",
      inputs: %{
        type: "object",
        properties: %{
          "message" => %{
            type: "string",
            description: "Message to echo"
          }
        },
        required: ["message"]
      },
      outputs: %{
        type: "object",
        properties: %{
          "response" => %{
            type: "string",
            description: "Echoed message"
          }
        },
        required: ["response"]
      },
      tags: ["tcp", "echo"],
      average_response_size: 100,
      provider: tcp_provider
    }

    # Register the tool
    case Client.register_tool(client, tool) do
      :ok ->
        IO.puts("✓ Tool registered successfully")
      {:error, reason} ->
        IO.puts("✗ Failed to register tool: #{inspect(reason)}")
    end

    # Call the tool (this will fail in the example since no server is running)
    case Client.call_tool(client, "echo_tcp", %{"message" => "Hello TCP!"}) do
      {:ok, result} ->
        IO.puts("✓ Tool call successful: #{inspect(result)}")
      {:error, reason} ->
        IO.puts("✗ Tool call failed: #{inspect(reason)}")
    end

    IO.puts("")
  end

  defp udp_example(client) do
    IO.puts("2. Basic UDP Provider Example")
    IO.puts("=" <> String.duplicate("=", 40))

    # Create a UDP provider
    udp_provider = Providers.new_udp_provider(
      name: "echo_udp",
      host: "localhost",
      port: 8081
    )

    # Register the provider
    case Client.register_tool_provider(client, udp_provider) do
      {:ok, tools} ->
        IO.puts("✓ UDP provider registered successfully")
        IO.puts("  Tools discovered: #{length(tools)}")
      {:error, reason} ->
        IO.puts("✗ Failed to register UDP provider: #{inspect(reason)}")
    end

    # Create a test tool
    tool = %{
      name: "echo_udp",
      description: "Echo service over UDP",
      inputs: %{
        type: "object",
        properties: %{
          "message" => %{
            type: "string",
            description: "Message to echo"
          }
        },
        required: ["message"]
      },
      outputs: %{
        type: "object",
        properties: %{
          "response" => %{
            type: "string",
            description: "Echoed message"
          }
        },
        required: ["response"]
      },
      tags: ["udp", "echo"],
      average_response_size: 100,
      provider: udp_provider
    }

    # Register the tool
    case Client.register_tool(client, tool) do
      :ok ->
        IO.puts("✓ Tool registered successfully")
      {:error, reason} ->
        IO.puts("✗ Failed to register tool: #{inspect(reason)}")
    end

    # Call the tool (this will fail in the example since no server is running)
    case Client.call_tool(client, "echo_udp", %{"message" => "Hello UDP!"}) do
      {:ok, result} ->
        IO.puts("✓ Tool call successful: #{inspect(result)}")
      {:error, reason} ->
        IO.puts("✗ Tool call failed: #{inspect(reason)}")
    end

    IO.puts("")
  end

  defp tcp_auth_example(client) do
    IO.puts("3. TCP with Authentication Example")
    IO.puts("=" <> String.duplicate("=", 40))

    # Create a TCP provider with API key authentication
    tcp_provider = Providers.new_tcp_provider(
      name: "secure_tcp",
      host: "secure.example.com",
      port: 8080,
      auth: %{
        type: "api_key",
        api_key: "Bearer ${API_KEY}",
        location: "header",
        var_name: "Authorization"
      }
    )

    # Register the provider
    case Client.register_tool_provider(client, tcp_provider) do
      {:ok, tools} ->
        IO.puts("✓ Secure TCP provider registered successfully")
        IO.puts("  Tools discovered: #{length(tools)}")
      {:error, reason} ->
        IO.puts("✗ Failed to register secure TCP provider: #{inspect(reason)}")
    end

    IO.puts("")
  end

  defp udp_timeout_example(client) do
    IO.puts("4. UDP with Custom Timeout Example")
    IO.puts("=" <> String.duplicate("=", 40))

    # Create a UDP provider with custom timeout
    udp_provider = Providers.new_udp_provider(
      name: "fast_udp",
      host: "fast.example.com",
      port: 8081,
      timeout: 1000  # 1 second timeout
    )

    # Register the provider
    case Client.register_tool_provider(client, udp_provider) do
      {:ok, tools} ->
        IO.puts("✓ Fast UDP provider registered successfully")
        IO.puts("  Tools discovered: #{length(tools)}")
        IO.puts("  Timeout: #{udp_provider.timeout}ms")
      {:error, reason} ->
        IO.puts("✗ Failed to register fast UDP provider: #{inspect(reason)}")
    end

    IO.puts("")
  end

  defp tcp_streaming_example(client) do
    IO.puts("5. TCP Streaming Example")
    IO.puts("=" <> String.duplicate("=", 40))

    # Create a TCP provider for streaming
    tcp_provider = Providers.new_tcp_provider(
      name: "stream_tcp",
      host: "stream.example.com",
      port: 8080
    )

    # Register the provider
    case Client.register_tool_provider(client, tcp_provider) do
      {:ok, tools} ->
        IO.puts("✓ Streaming TCP provider registered successfully")
        IO.puts("  Tools discovered: #{length(tools)}")
      {:error, reason} ->
        IO.puts("✗ Failed to register streaming TCP provider: #{inspect(reason)}")
    end

    # Create a streaming tool
    tool = %{
      name: "stream_data",
      description: "Stream data over TCP",
      inputs: %{
        type: "object",
        properties: %{
          "count" => %{
            type: "integer",
            description: "Number of data chunks to stream"
          }
        },
        required: ["count"]
      },
      outputs: %{
        type: "object",
        properties: %{
          "chunks" => %{
            type: "array",
            items: %{
              type: "object",
              properties: %{
                "data" => %{type: "string"},
                "sequence" => %{type: "integer"}
              }
            }
          }
        },
        required: ["chunks"]
      },
      tags: ["tcp", "streaming"],
      average_response_size: 1000,
      provider: tcp_provider
    }

    # Register the tool
    case Client.register_tool(client, tool) do
      :ok ->
        IO.puts("✓ Streaming tool registered successfully")
      {:error, reason} ->
        IO.puts("✗ Failed to register streaming tool: #{inspect(reason)}")
    end

    # Call the tool with streaming (this will fail in the example since no server is running)
    case Client.call_tool_stream(client, "stream_data", %{"count" => 5}) do
      {:ok, %{type: :stream, data: stream}} ->
        IO.puts("✓ Streaming tool call successful")
        IO.puts("  Stream type: #{inspect(stream)}")
      {:error, reason} ->
        IO.puts("✗ Streaming tool call failed: #{inspect(reason)}")
    end

    IO.puts("")
  end

  defp error_handling_example(client) do
    IO.puts("6. Error Handling Example")
    IO.puts("=" <> String.duplicate("=", 40))

    # Create a TCP provider with invalid host
    tcp_provider = Providers.new_tcp_provider(
      name: "invalid_tcp",
      host: "nonexistent.example.com",
      port: 9999
    )

    # Register the provider
    case Client.register_tool_provider(client, tcp_provider) do
      {:ok, tools} ->
        IO.puts("✓ Invalid TCP provider registered successfully")
        IO.puts("  Tools discovered: #{length(tools)}")
      {:error, reason} ->
        IO.puts("✗ Failed to register invalid TCP provider: #{inspect(reason)}")
    end

    # Create a test tool
    tool = %{
      name: "test_invalid",
      description: "Test tool with invalid connection",
      inputs: %{
        type: "object",
        properties: %{
          "message" => %{
            type: "string",
            description: "Message to send"
          }
        },
        required: ["message"]
      },
      outputs: %{
        type: "object",
        properties: %{
          "response" => %{
            type: "string",
            description: "Response from server"
          }
        },
        required: ["response"]
      },
      tags: ["tcp", "test"],
      average_response_size: 100,
      provider: tcp_provider
    }

    # Register the tool
    case Client.register_tool(client, tool) do
      :ok ->
        IO.puts("✓ Test tool registered successfully")
      {:error, reason} ->
        IO.puts("✗ Failed to register test tool: #{inspect(reason)}")
    end

    # Call the tool (this should fail gracefully)
    case Client.call_tool(client, "test_invalid", %{"message" => "Hello!"}) do
      {:ok, result} ->
        IO.puts("✓ Tool call successful: #{inspect(result)}")
      {:error, reason} ->
        IO.puts("✗ Tool call failed (expected): #{inspect(reason)}")
    end

    IO.puts("")
  end

  defp multiple_providers_example(client) do
    IO.puts("7. Multiple Providers Example")
    IO.puts("=" <> String.duplicate("=", 40))

    # Create multiple providers
    providers = [
      Providers.new_tcp_provider(name: "tcp1", host: "server1.example.com", port: 8080),
      Providers.new_tcp_provider(name: "tcp2", host: "server2.example.com", port: 8080),
      Providers.new_udp_provider(name: "udp1", host: "server1.example.com", port: 8081),
      Providers.new_udp_provider(name: "udp2", host: "server2.example.com", port: 8081)
    ]

    # Register all providers
    Enum.each(providers, fn provider ->
      case Client.register_tool_provider(client, provider) do
        {:ok, tools} ->
          IO.puts("✓ #{provider.name} registered successfully (#{length(tools)} tools)")
        {:error, reason} ->
          IO.puts("✗ Failed to register #{provider.name}: #{inspect(reason)}")
      end
    end)

    # List all registered providers
    case Client.list_providers(client) do
      {:ok, provider_list} ->
        IO.puts("\nRegistered providers:")
        Enum.each(provider_list, fn provider ->
          IO.puts("  - #{provider.name} (#{provider.type})")
        end)
      {:error, reason} ->
        IO.puts("✗ Failed to list providers: #{inspect(reason)}")
    end

    IO.puts("")
  end
end

# Run the examples
TcpUdpExample.run()
