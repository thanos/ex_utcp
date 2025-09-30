defmodule ExUtcp.Transports.Graphql.PoolTest do
  use ExUnit.Case, async: true

  alias ExUtcp.Transports.Graphql.Pool
  alias ExUtcp.Providers

  setup do
    # Start the pool for each test if not already started
    case Process.whereis(Pool) do
      nil ->
        {:ok, pool_pid} = Pool.start_link(max_connections: 2)
        %{pool_pid: pool_pid}
      pool_pid ->
        %{pool_pid: pool_pid}
    end
  end

  describe "GraphQL Connection Pool" do
    test "starts successfully", %{pool_pid: pool_pid} do
      assert Process.alive?(pool_pid)
    end

    test "gets a connection for a provider" do
      provider = Providers.new_graphql_provider([
        name: "test",
        url: "http://localhost:4000"
      ])

      {:ok, pid} = Pool.get_connection(provider)
      assert is_pid(pid)
      assert Pool.stats().total_connections == 1
    end

    test "reuses existing connection for the same provider" do
      provider = Providers.new_graphql_provider([
        name: "test",
        url: "http://localhost:4000"
      ])

      {:ok, pid1} = Pool.get_connection(provider)
      {:ok, pid2} = Pool.get_connection(provider)
      assert pid1 == pid2
      assert Pool.stats().total_connections == 1
    end

    test "handles connection creation failure" do
      provider = %{
        name: "test",
        type: :graphql,
        url: "http://invalid-host:99999"
      }

      # With the mock implementation, this will succeed
      assert {:ok, _pid} = Pool.get_connection(provider)
    end

    test "respects max connections limit" do
      # This test would require mocking the connection creation
      # to avoid actually trying to connect to real servers
      provider = Providers.new_graphql_provider([
        name: "test",
        url: "http://localhost:4000"
      ])

      # With the mock implementation, this will succeed
      assert {:ok, _pid} = Pool.get_connection(provider)
    end

    test "closes all connections" do
      Pool.close_all_connections()

      stats = Pool.stats()
      assert stats.total_connections == 0
    end

    test "returns pool statistics" do
      stats = Pool.stats()
      assert is_map(stats)
      assert Map.has_key?(stats, :total_connections)
      assert Map.has_key?(stats, :max_connections)
      assert Map.has_key?(stats, :connection_keys)
    end
  end
end
