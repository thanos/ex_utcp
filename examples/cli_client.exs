#!/usr/bin/env elixir

# CLI Client Example
# This example demonstrates how to use the UTCP client with CLI providers.

Mix.install([
  {:ex_utcp, path: "."}
])

alias ExUtcp.{Client, Config, Providers}

defmodule CliClientExample do
  def run do
    IO.puts("=== UTCP CLI Client Example ===")

    # Create a client configuration
    config = Config.new()

    # Start the UTCP client
    {:ok, client} = Client.start_link(config)

    # Create a CLI provider
    provider = Providers.new_cli_provider([
      name: "hello",
      command_name: "echo '{\"tools\":[{\"name\":\"greet\",\"description\":\"Greets a person\",\"inputs\":{\"type\":\"object\",\"properties\":{\"name\":{\"type\":\"string\",\"description\":\"Name to greet\"}},\"required\":[\"name\"]},\"outputs\":{\"type\":\"object\",\"properties\":{\"result\":{\"type\":\"string\"}}},\"tags\":[\"greeting\"]}]}'"
    ])

    # Register the provider
    IO.puts("\n=== Registering CLI Provider ===")
    case Client.register_tool_provider(client, provider) do
      {:ok, tools} ->
        IO.puts("Successfully registered provider with #{length(tools)} tools:")
        Enum.each(tools, fn tool ->
          IO.puts("  - #{tool.name}: #{tool.description}")
        end)

        # Call a tool if available
        if length(tools) > 0 do
          tool = List.first(tools)
          IO.puts("\n=== Tool Call Test ===")
          IO.puts("Calling tool '#{tool.name}' with args: %{name: \"Elixir\"}")

          case Client.call_tool(client, tool.name, %{"name" => "Elixir"}) do
            {:ok, result} ->
              IO.puts("SUCCESS: #{inspect(result)}")
            {:error, reason} ->
              IO.puts("ERROR: #{inspect(reason)}")
          end
        end
      {:error, reason} ->
        IO.puts("Registration error: #{inspect(reason)}")
    end

    # Get client statistics
    stats = Client.get_stats(client)
    IO.puts("\n=== Client Statistics ===")
    IO.puts("Tool count: #{stats.tool_count}")
    IO.puts("Provider count: #{stats.provider_count}")
  end
end

# Run the example
CliClientExample.run()
