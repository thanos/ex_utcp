#!/usr/bin/env elixir

# Simple UTCP Example
# This example demonstrates basic usage of the ExUtcp library.

Mix.install([
  {:ex_utcp, path: "."}
])

alias ExUtcp.{Client, Config, Providers}

defmodule SimpleExample do
  def run do
    IO.puts("=== Simple UTCP Example ===")

    # Create a client configuration
    config = Config.new()

    # Start the UTCP client
    {:ok, client} = Client.start_link(config)

    # Create a simple CLI provider that echoes tools
    provider = Providers.new_cli_provider([
      name: "echo_provider",
      command_name: "echo '{\"tools\":[{\"name\":\"hello\",\"description\":\"Says hello\",\"inputs\":{\"type\":\"object\",\"properties\":{\"name\":{\"type\":\"string\"}},\"required\":[\"name\"]},\"outputs\":{\"type\":\"object\",\"properties\":{\"result\":{\"type\":\"string\"}}},\"tags\":[\"greeting\"]}]}'"
    ])

    # Register the provider
    IO.puts("\n=== Registering Provider ===")
    case Client.register_tool_provider(client, provider) do
      {:ok, tools} ->
        IO.puts("Successfully registered provider with #{length(tools)} tools:")
        Enum.each(tools, fn tool ->
          IO.puts("  - #{tool.name}: #{tool.description}")
        end)

        # Search for tools
        IO.puts("\n=== Searching Tools ===")
        case Client.search_tools(client, "hello", 10) do
          {:ok, found_tools} ->
            IO.puts("Found #{length(found_tools)} tools matching 'hello':")
            Enum.each(found_tools, fn tool ->
              IO.puts("  - #{tool.name}: #{tool.description}")
            end)
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
    end

    # Clean up
    GenServer.stop(client)
  end
end

# Run the example
SimpleExample.run()
