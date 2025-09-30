# examples/graphql_example.exs
# Run with: elixir --sname graphql_client -S mix run examples/graphql_example.exs

Application.ensure_all_started(:ex_utcp)

alias ExUtcp.{Client, Config, Providers}
alias ExUtcp.Transports.Graphql

Logger.info("Starting GraphQL Example...")

# 1. Create a client configuration
config = Config.new()
{:ok, client} = Client.start_link(config)

# 2. Create a GraphQL provider
# This example assumes a GraphQL server is running at localhost:4000
# For a real server, replace the URL accordingly.
graphql_provider = Providers.new_graphql_provider([
  name: "my_graphql_service",
  url: "http://localhost:4000",
  # auth: ExUtcp.Auth.new_api_key_auth(api_key: "my-secret-key", location: "header"),
  headers: %{"X-Custom-Header" => "value"}
])

Logger.info("Registering GraphQL provider: #{inspect(graphql_provider.name)}")
{:ok, tools} = Client.register_tool_provider(client, graphql_provider)
Logger.info("Discovered tools: #{inspect(tools)}")

# 3. Call a tool via GraphQL
tool_name = "getUser"
tool_args = %{"id" => "123"}
Logger.info("Calling GraphQL tool '#{tool_name}' with args: #{inspect(tool_args)}")

case Client.call_tool(client, tool_name, tool_args, graphql_provider) do
  {:ok, result} ->
    Logger.info("GraphQL Tool call result: #{inspect(result)}")
  {:error, reason} ->
    Logger.error("GraphQL Tool call failed: #{inspect(reason)}")
end

# 4. Call a streaming tool via GraphQL
streaming_tool_name = "subscribeToUser"
streaming_tool_args = %{"id" => "123"}
Logger.info("Calling GraphQL streaming tool '#{streaming_tool_name}' with args: #{inspect(streaming_tool_args)}")

case Client.call_tool_stream(client, streaming_tool_name, streaming_tool_args, graphql_provider) do
  {:ok, %{type: :stream, data: stream_data}} ->
    Logger.info("GraphQL Streaming tool result (first chunk): #{inspect(Enum.at(stream_data, 0))}")
  {:error, reason} ->
    Logger.error("GraphQL Streaming tool call failed: #{inspect(reason)}")
end

# 5. Demonstrate direct GraphQL operations
Logger.info("Demonstrating direct GraphQL operations...")

# GraphQL Query
query = """
query GetUser($id: String!) {
  user(id: $id) {
    id
    name
    email
  }
}
"""
variables = %{"id" => "123"}

case Graphql.query(graphql_provider, query, variables) do
  {:ok, result} ->
    Logger.info("GraphQL Query result: #{inspect(result)}")
  {:error, reason} ->
    Logger.error("GraphQL Query failed: #{inspect(reason)}")
end

# GraphQL Mutation
mutation = """
mutation CreateUser($input: UserInput!) {
  createUser(input: $input) {
    id
    name
    email
  }
}
"""
mutation_variables = %{"input" => %{"name" => "John Doe", "email" => "john@example.com"}}

case Graphql.mutation(graphql_provider, mutation, mutation_variables) do
  {:ok, result} ->
    Logger.info("GraphQL Mutation result: #{inspect(result)}")
  {:error, reason} ->
    Logger.error("GraphQL Mutation failed: #{inspect(reason)}")
end

# GraphQL Subscription
subscription = """
subscription UserUpdates($id: String!) {
  userUpdates(id: $id) {
    id
    name
    email
    updatedAt
  }
}
"""
subscription_variables = %{"id" => "123"}

case Graphql.subscription(graphql_provider, subscription, subscription_variables) do
  {:ok, results} ->
    Logger.info("GraphQL Subscription result (first update): #{inspect(Enum.at(results, 0))}")
  {:error, reason} ->
    Logger.error("GraphQL Subscription failed: #{inspect(reason)}")
end

# GraphQL Schema Introspection
case Graphql.introspect_schema(graphql_provider) do
  {:ok, schema} ->
    Logger.info("GraphQL Schema introspection result (query type): #{inspect(get_in(schema, ["__schema", "queryType"]))}")
  {:error, reason} ->
    Logger.error("GraphQL Schema introspection failed: #{inspect(reason)}")
end

Logger.info("GraphQL Example finished.")
