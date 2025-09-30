defmodule ExUtcp.Transports.GraphqlUnitTest do
  use ExUnit.Case, async: true

  alias ExUtcp.Transports.Graphql
  alias ExUtcp.Providers

  describe "GraphQL Transport Unit Tests" do
    test "creates new transport" do
      transport = Graphql.new()

      assert %Graphql{} = transport
      assert transport.logger != nil
      assert transport.connection_timeout == 30_000
    end

    test "creates transport with custom options" do
      logger = fn msg -> IO.puts("Custom: #{msg}") end
      transport = Graphql.new(logger: logger, connection_timeout: 60_000)

      assert %Graphql{} = transport
      assert transport.logger == logger
      assert transport.connection_timeout == 60_000
    end

    test "returns correct transport name" do
      assert Graphql.transport_name() == "graphql"
    end

    test "supports streaming" do
      assert Graphql.supports_streaming?() == true
    end

    test "validates provider type" do
      valid_provider = %{
        name: "test",
        type: :graphql,
        url: "http://localhost:4000/graphql",
        auth: nil,
        headers: %{}
      }

      invalid_provider = %{
        name: "test",
        type: :http,
        url: "http://localhost:4000",
        auth: nil,
        headers: %{}
      }

      # Test with valid provider
      assert :ok = Graphql.register_tool_provider(valid_provider)

      # Test with invalid provider type
      assert {:error, "Invalid provider type for GraphQL transport"} =
        Graphql.register_tool_provider(invalid_provider)
    end

    test "deregister_tool_provider always succeeds" do
      provider = %{
        name: "test",
        type: :graphql,
        url: "http://localhost:4000/graphql",
        auth: nil,
        headers: %{}
      }

      assert :ok = Graphql.deregister_tool_provider(provider)
    end

    test "close always succeeds" do
      assert :ok = Graphql.close()
    end
  end
end
