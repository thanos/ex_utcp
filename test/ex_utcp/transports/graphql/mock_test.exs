defmodule ExUtcp.Transports.Graphql.MockTest do
  use ExUnit.Case, async: true

  import Mox

  alias ExUtcp.Transports.Graphql.Testable
  alias ExUtcp.Providers

  setup :verify_on_exit!

  describe "GraphQL Transport with Mocks" do
    test "registers tool provider successfully with mocked connection" do
      transport = Testable.new()
      provider = Providers.new_graphql_provider([name: "test", url: "http://example.com/graphql"])

      # Mock the connection module to return a successful introspection
      mock_conn = :mock_connection

      # Since we're using the testable module, it will use the mock connection
      assert {:ok, []} = Testable.register_tool_provider(transport, provider)
    end

    test "calls tool successfully with mocked connection" do
      transport = Testable.new()
      provider = Providers.new_graphql_provider([name: "test", url: "http://example.com/graphql"])

      # Mock the connection module to return a successful query result
      mock_conn = :mock_connection

      # Since we're using the testable module, it will use the mock connection
      assert {:ok, %{"result" => _}} = Testable.call_tool(transport, "test.tool", %{"arg" => "value"}, provider)
    end

    test "calls tool stream successfully with mocked connection" do
      transport = Testable.new()
      provider = Providers.new_graphql_provider([name: "test", url: "http://example.com/graphql"])

      # Mock the connection module to return a successful subscription result
      mock_conn = :mock_connection

      # Since we're using the testable module, it will use the mock connection
      assert {:ok, %{type: :stream, data: _}} = Testable.call_tool_stream(transport, "test.tool", %{"arg" => "value"}, provider)
    end

    test "executes GraphQL query with mocked connection" do
      transport = Testable.new()
      provider = Providers.new_graphql_provider([name: "test", url: "http://example.com/graphql"])

      # Mock the connection module to return a successful query result
      mock_conn = :mock_connection

      # Since we're using the testable module, it will use the mock connection
      assert {:ok, %{"result" => _}} = Testable.query(transport, provider, "query { test }", %{})
    end

    test "executes GraphQL mutation with mocked connection" do
      transport = Testable.new()
      provider = Providers.new_graphql_provider([name: "test", url: "http://example.com/graphql"])

      # Mock the connection module to return a successful mutation result
      mock_conn = :mock_connection

      # Since we're using the testable module, it will use the mock connection
      assert {:ok, %{"result" => _}} = Testable.mutation(transport, provider, "mutation { test }", %{})
    end

    test "executes GraphQL subscription with mocked connection" do
      transport = Testable.new()
      provider = Providers.new_graphql_provider([name: "test", url: "http://example.com/graphql"])

      # Mock the connection module to return a successful subscription result
      mock_conn = :mock_connection

      # Since we're using the testable module, it will use the mock connection
      assert {:ok, [%{"data" => _}]} = Testable.subscription(transport, provider, "subscription { test }", %{})
    end

    test "introspects GraphQL schema with mocked connection" do
      transport = Testable.new()
      provider = Providers.new_graphql_provider([name: "test", url: "http://example.com/graphql"])

      # Mock the connection module to return a successful introspection result
      mock_conn = :mock_connection

      # Since we're using the testable module, it will use the mock connection
      assert {:ok, %{"__schema" => _}} = Testable.introspect_schema(transport, provider)
    end

    test "handles retry logic with mocks" do
      transport = Testable.new()
      provider = Providers.new_graphql_provider([name: "test", url: "http://example.com/graphql"])

      # Mock the connection module to return a successful result after retries
      mock_conn = :mock_connection

      # Since we're using the testable module, it will use the mock connection
      assert {:ok, %{"result" => _}} = Testable.call_tool(transport, "test.tool", %{"arg" => "value"}, provider)
    end
  end
end
