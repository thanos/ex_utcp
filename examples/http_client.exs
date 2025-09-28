#!/usr/bin/env elixir

# HTTP Client Example
# This example demonstrates how to use the UTCP client with HTTP providers.

Mix.install([
  {:ex_utcp, path: "."}
])

alias ExUtcp.{Client, Config}

defmodule HttpClientExample do
  def run do
    IO.puts("=== UTCP HTTP Client Example ===")

    # Create a client configuration
    config = Config.new(providers_file_path: "examples/provider.json")

    # Start the UTCP client
    {:ok, client} = Client.start_link(config)

    # Wait a moment for initialization
    Process.sleep(500)

    # Search for tools
    IO.puts("\n=== Tool Discovery ===")
    case Client.search_tools(client, "", 10) do
      {:ok, tools} ->
        IO.puts("Discovered #{length(tools)} tools:")
        Enum.each(tools, fn tool ->
          IO.puts("  - #{tool.name}: #{tool.description}")
        end)

        # Call a tool if available
        if length(tools) > 0 do
          tool = List.first(tools)
          IO.puts("\n=== Tool Call Test ===")
          IO.puts("Calling tool '#{tool.name}' with args: %{message: \"Hello from Elixir!\"}")

          case Client.call_tool(client, tool.name, %{"message" => "Hello from Elixir!"}) do
            {:ok, result} ->
              IO.puts("SUCCESS: #{inspect(result)}")
            {:error, reason} ->
              IO.puts("ERROR: #{inspect(reason)}")
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
  end
end

# Run the example
HttpClientExample.run()
