# examples/search_example.exs
#
# This example demonstrates the advanced search capabilities in ExUtcp.
# It shows how to use different search algorithms, filters, and security scanning.
#
# To run this example:
# elixir examples/search_example.exs

alias ExUtcp.{Client, Providers, Search}

# Start the ExUtcp application
{:ok, _} = Application.ensure_all_started(:ex_utcp)

# 1. Start the client
{:ok, client} = Client.start_link()
IO.puts "Started ExUtcp client"

# 2. Register some providers for testing
providers = [
  Providers.new_http_provider(
    name: "user_api",
    url: "https://api.example.com/users",
    http_method: "GET"
  ),
  Providers.new_websocket_provider(
    name: "notification_ws",
    url: "wss://notifications.example.com"
  ),
  Providers.new_grpc_provider(
    name: "data_service",
    url: "grpc://data.example.com:50051",
    proto_path: "/path/to/proto",
    service_name: "DataService"
  ),
  Providers.new_cli_provider(
    name: "file_processor",
    command_name: "process_files"
  )
]

# Register providers and their tools
Enum.each(providers, fn provider ->
  {:ok, tools} = Client.register_tool_provider(client, provider)
  IO.puts "Registered provider: #{provider.name} with #{length(tools)} tools"
end)

# Add some mock tools for demonstration
mock_tools = [
  %{
    name: "get_user_profile",
    provider_name: "user_api",
    definition: %{
      name: "get_user_profile",
      description: "Retrieve detailed user profile information including preferences and settings",
      parameters: %{
        "type" => "object",
        "properties" => %{
          "user_id" => %{"type" => "string", "description" => "Unique user identifier"}
        }
      },
      response: %{
        "type" => "object",
        "properties" => %{
          "profile" => %{"type" => "object", "description" => "User profile data"}
        }
      }
    }
  },
  %{
    name: "create_user_account",
    provider_name: "user_api",
    definition: %{
      name: "create_user_account",
      description: "Create a new user account with email verification",
      parameters: %{
        "type" => "object",
        "properties" => %{
          "email" => %{"type" => "string", "description" => "User email address"},
          "password" => %{"type" => "string", "description" => "Account password"}
        }
      },
      response: %{
        "type" => "object",
        "properties" => %{
          "user_id" => %{"type" => "string", "description" => "Created user ID"}
        }
      }
    }
  },
  %{
    name: "send_notification",
    provider_name: "notification_ws",
    definition: %{
      name: "send_notification",
      description: "Send real-time notification to connected users",
      parameters: %{
        "type" => "object",
        "properties" => %{
          "message" => %{"type" => "string", "description" => "Notification message"},
          "recipients" => %{"type" => "array", "description" => "List of recipient user IDs"}
        }
      },
      response: %{
        "type" => "object",
        "properties" => %{
          "sent" => %{"type" => "boolean", "description" => "Whether notification was sent"}
        }
      }
    }
  },
  %{
    name: "process_file_data",
    provider_name: "file_processor",
    definition: %{
      name: "process_file_data",
      description: "Process and analyze file data for insights",
      parameters: %{
        "type" => "object",
        "properties" => %{
          "file_path" => %{"type" => "string", "description" => "Path to file"}
        }
      },
      response: %{
        "type" => "object",
        "properties" => %{
          "analysis" => %{"type" => "object", "description" => "File analysis results"}
        }
      }
    }
  }
]

# Add mock tools to demonstrate search (in a real app, these would come from providers)
IO.puts "\nAdding mock tools for search demonstration..."

# 3. Demonstrate different search algorithms

IO.puts "\n=== EXACT SEARCH ==="
IO.puts "Searching for 'get_user_profile' with exact algorithm:"
exact_results = Client.search_tools(client, "get_user_profile", %{algorithm: :exact})
Enum.each(exact_results, fn result ->
  IO.puts "  - #{result.tool.name} (score: #{Float.round(result.score, 2)}, type: #{result.match_type})"
end)

IO.puts "\n=== FUZZY SEARCH ==="
IO.puts "Searching for 'get_usr' with fuzzy algorithm:"
fuzzy_results = Client.search_tools(client, "get_usr", %{
  algorithm: :fuzzy,
  threshold: 0.5
})
Enum.each(fuzzy_results, fn result ->
  IO.puts "  - #{result.tool.name} (score: #{Float.round(result.score, 2)}, type: #{result.match_type})"
  IO.puts "    Matched fields: #{Enum.join(result.matched_fields, ", ")}"
end)

IO.puts "\n=== SEMANTIC SEARCH ==="
IO.puts "Searching for 'user management' with semantic algorithm:"
semantic_results = Client.search_tools(client, "user management", %{
  algorithm: :semantic,
  threshold: 0.2,
  use_haystack: false  # Use keyword-based for demo
})
Enum.each(semantic_results, fn result ->
  IO.puts "  - #{result.tool.name} (score: #{Float.round(result.score, 2)}, type: #{result.match_type})"
  IO.puts "    Description: #{String.slice(result.tool.definition.description, 0, 60)}..."
end)

IO.puts "\n=== COMBINED SEARCH ==="
IO.puts "Searching for 'user' with combined algorithm:"
combined_results = Client.search_tools(client, "user", %{
  algorithm: :combined,
  threshold: 0.1,
  limit: 5
})
Enum.each(combined_results, fn result ->
  IO.puts "  - #{result.tool.name} (score: #{Float.round(result.score, 2)}, type: #{result.match_type})"
end)

# 4. Demonstrate search filters

IO.puts "\n=== FILTERED SEARCH ==="
IO.puts "Searching for 'user' filtered by HTTP providers:"
filtered_results = Client.search_tools(client, "user", %{
  algorithm: :combined,
  filters: %{
    transports: [:http],
    providers: ["user_api"]
  },
  threshold: 0.1
})
Enum.each(filtered_results, fn result ->
  IO.puts "  - #{result.tool.name} (provider: #{result.tool.provider_name})"
end)

# 5. Demonstrate security scanning

IO.puts "\n=== SECURITY SCANNING ==="
IO.puts "Searching with security scanning enabled:"
secure_results = Client.search_tools(client, "user", %{
  algorithm: :combined,
  security_scan: true,
  threshold: 0.1,
  limit: 3
})
Enum.each(secure_results, fn result ->
  IO.puts "  - #{result.tool.name}"
  if length(result.security_warnings) > 0 do
    IO.puts "    ⚠️  Security warnings: #{length(result.security_warnings)}"
    Enum.each(result.security_warnings, fn warning ->
      IO.puts "      - #{warning.type} in #{warning.field}"
    end)
  else
    IO.puts "    ✅ No security warnings"
  end
end)

# 6. Demonstrate provider search

IO.puts "\n=== PROVIDER SEARCH ==="
IO.puts "Searching for providers with 'api':"
provider_results = Client.search_providers(client, "api", %{
  algorithm: :fuzzy,
  threshold: 0.3
})
Enum.each(provider_results, fn result ->
  IO.puts "  - #{result.provider.name} (type: #{result.provider.type}, score: #{Float.round(result.score, 2)})"
end)

# 7. Demonstrate search suggestions

IO.puts "\n=== SEARCH SUGGESTIONS ==="
IO.puts "Getting suggestions for 'us':"
suggestions = Client.get_search_suggestions(client, "us", limit: 5)
Enum.each(suggestions, fn suggestion ->
  IO.puts "  - #{suggestion}"
end)

# 8. Demonstrate similar tools

IO.puts "\n=== SIMILAR TOOLS ==="
IO.puts "Finding tools similar to 'get_user_profile':"
case Client.find_similar_tools(client, "get_user_profile", limit: 3) do
  similar_tools when is_list(similar_tools) ->
    Enum.each(similar_tools, fn result ->
      IO.puts "  - #{result.tool.name} (similarity: #{Float.round(result.score, 2)})"
      IO.puts "    Description: #{String.slice(result.tool.definition.description, 0, 60)}..."
    end)
  {:error, reason} ->
    IO.puts "  Error finding similar tools: #{inspect(reason)}"
end

# 9. Advanced search with multiple options

IO.puts "\n=== ADVANCED SEARCH ==="
IO.puts "Advanced search for 'notification' with all features:"
advanced_results = Client.search_tools(client, "notification", %{
  algorithm: :combined,
  filters: %{
    transports: [:websocket, :http]
  },
  limit: 10,
  threshold: 0.1,
  include_descriptions: true,
  use_haystack: true,
  security_scan: true,
  filter_sensitive: false
})

Enum.each(advanced_results, fn result ->
  IO.puts "  - #{result.tool.name}"
  IO.puts "    Score: #{Float.round(result.score, 2)} | Type: #{result.match_type}"
  IO.puts "    Matched: #{Enum.join(result.matched_fields, ", ")}"
  IO.puts "    Security: #{if length(result.security_warnings) > 0, do: "⚠️  #{length(result.security_warnings)} warnings", else: "✅ Clean"}"
  IO.puts ""
end)

IO.puts "Search example completed!"


