#!/usr/bin/env elixir

# MCP (Model Context Protocol) Transport Example
# This example demonstrates how to use the MCP transport for AI tool integration

Mix.install([
  {:ex_utcp, path: "."}
])

defmodule McpExample do
  @moduledoc """
  Example demonstrating MCP transport usage.
  """

  def run do
    IO.puts("=== MCP Transport Example ===")
    IO.puts("")

    # Create MCP provider
    provider = ExUtcp.Providers.new_mcp_provider([
      name: "mcp_provider",
      url: "http://localhost:3000/mcp",
      auth: nil
    ])

    IO.puts("Created MCP provider: #{inspect(provider)}")
    IO.puts("")

    # Start UTCP client
    {:ok, client} = ExUtcp.Client.start_link(%{
      variables: %{},
      providers_file_path: nil,
      load_variables_from: []
    })

    IO.puts("Started UTCP client")
    IO.puts("")

    # Register MCP provider
    case ExUtcp.Client.register_tool_provider(client, provider) do
      {:ok, tools} ->
        IO.puts("Registered MCP provider successfully")
        IO.puts("Discovered #{length(tools)} tools:")
        Enum.each(tools, fn tool ->
          IO.puts("  - #{tool.name}: #{tool.description}")
        end)
        IO.puts("")

        # Call a tool if available
        if length(tools) > 0 do
          tool_name = List.first(tools).name
          IO.puts("Calling tool: #{tool_name}")

          case ExUtcp.Client.call_tool(client, tool_name, %{}) do
            {:ok, result} ->
              IO.puts("Tool call successful:")
              IO.puts("  Result: #{inspect(result)}")
            {:error, reason} ->
              IO.puts("Tool call failed: #{inspect(reason)}")
          end
        end

      {:error, reason} ->
        IO.puts("Failed to register MCP provider: #{inspect(reason)}")
    end

    IO.puts("")

    # Demonstrate direct MCP transport usage
    IO.puts("=== Direct MCP Transport Usage ===")

    # Start MCP transport
    {:ok, _pid} = ExUtcp.Transports.Mcp.start_link()

    # Send a JSON-RPC request
    case ExUtcp.Transports.Mcp.send_request("tools/list", %{}, provider) do
      {:ok, result} ->
        IO.puts("MCP request successful:")
        IO.puts("  Result: #{inspect(result)}")
      {:error, reason} ->
        IO.puts("MCP request failed: #{inspect(reason)}")
    end

    # Send a JSON-RPC notification
    case ExUtcp.Transports.Mcp.send_notification("tools/update", %{name: "test_tool"}, provider) do
      :ok ->
        IO.puts("MCP notification sent successfully")
      {:error, reason} ->
        IO.puts("MCP notification failed: #{inspect(reason)}")
    end

    IO.puts("")

    # Demonstrate JSON-RPC message building
    IO.puts("=== JSON-RPC Message Examples ===")

    # Build a request message
    request = ExUtcp.Transports.Mcp.Message.build_request("tools/list", %{})
    IO.puts("Request message: #{inspect(request)}")

    # Build a notification message
    notification = ExUtcp.Transports.Mcp.Message.build_notification("tools/update", %{name: "test"})
    IO.puts("Notification message: #{inspect(notification)}")

    # Build a response message
    response = ExUtcp.Transports.Mcp.Message.build_response(%{tools: []}, 123)
    IO.puts("Response message: #{inspect(response)}")

    # Build an error response
    error = ExUtcp.Transports.Mcp.Message.build_error_response(-32601, "Method not found", %{method: "invalid"}, 123)
    IO.puts("Error response: #{inspect(error)}")

    IO.puts("")
    IO.puts("=== MCP Example Complete ===")
  end
end

# Run the example
McpExample.run()
