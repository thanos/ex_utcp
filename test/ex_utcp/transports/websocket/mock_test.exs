defmodule ExUtcp.Transports.WebSocket.MockTest do
  use ExUnit.Case, async: true

  import Mox

  alias ExUtcp.Transports.WebSocket.Testable
  alias ExUtcp.Transports.WebSocket.ConnectionMock
  alias ExUtcp.Providers

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  describe "WebSocket Transport with Mocks" do
    test "registers tool provider successfully with mocked connection" do
      # Set up the connection module mock
      Application.put_env(:ex_utcp, :connection_module, ConnectionMock)

      # Create a mock connection
      mock_conn = :mock_connection_pid

      # Mock the connection operations
      stub(ConnectionMock, :start_link, fn (_, _, _) -> {:ok, mock_conn} end)
      expect(ConnectionMock, :send_message, fn (^mock_conn, "manual") -> :ok end)
      expect(ConnectionMock, :get_next_message, fn (^mock_conn, 5000) ->
        {:ok, Jason.encode!(%{"tools" => []})}
      end)

      # Create the testable transport
      transport = Testable.new()

      provider = Providers.new_websocket_provider([
        name: "test",
        url: "ws://example.com/ws"
      ])

      # This should now work with mocks
      assert {:ok, []} = Testable.register_tool_provider(transport, provider)
    end

    test "handles connection errors gracefully with mocks" do
      # Set up the connection module mock
      Application.put_env(:ex_utcp, :connection_module, ConnectionMock)

      # Mock the connection to fail
      stub(ConnectionMock, :start_link, fn (_, _, _) ->
        {:error, "Connection failed"}
      end)

      # Create the testable transport
      transport = Testable.new()

      provider = Providers.new_websocket_provider([
        name: "test",
        url: "ws://invalid-url/ws"
      ])

      # This should return an error
      assert {:error, _reason} = Testable.register_tool_provider(transport, provider)
    end

    test "calls tool successfully with mocked connection" do
      # Set up the connection module mock
      Application.put_env(:ex_utcp, :connection_module, ConnectionMock)

      # Create a mock connection
      mock_conn = :mock_connection_pid

      # Mock the connection operations
      stub(ConnectionMock, :start_link, fn (_, _, _) -> {:ok, mock_conn} end)
      expect(ConnectionMock, :send_message, fn (^mock_conn, _json_data) -> :ok end)
      expect(ConnectionMock, :get_next_message, fn (^mock_conn, 30000) ->
        {:ok, Jason.encode!(%{"result" => "Tool executed successfully"})}
      end)

      # Create the testable transport
      transport = Testable.new()

      provider = Providers.new_websocket_provider([
        name: "test",
        url: "ws://example.com/ws"
      ])

      # This should work with mocks
      assert {:ok, %{"result" => "Tool executed successfully"}} =
        Testable.call_tool(transport, "test.tool", %{"arg" => "value"}, provider)
    end

    test "calls tool stream successfully with mocked connection" do
      # Set up the connection module mock
      Application.put_env(:ex_utcp, :connection_module, ConnectionMock)

      # Create a mock connection
      mock_conn = :mock_connection_pid

      # Mock the connection operations
      stub(ConnectionMock, :start_link, fn (_, _, _) -> {:ok, mock_conn} end)
      expect(ConnectionMock, :send_message, fn (^mock_conn, _json_data) -> :ok end)
      expect(ConnectionMock, :get_all_messages, fn (^mock_conn) ->
        [Jason.encode!(%{"chunk" => "data1"}), Jason.encode!(%{"chunk" => "data2"})]
      end)

      # Create the testable transport
      transport = Testable.new()

      provider = Providers.new_websocket_provider([
        name: "test",
        url: "ws://example.com/ws"
      ])

      # This should work with mocks
      assert {:ok, %{type: :stream, data: _}} =
        Testable.call_tool_stream(transport, "test.tool", %{"arg" => "value"}, provider)
    end

    test "handles retry logic with mocks" do
      # Set up the connection module mock
      Application.put_env(:ex_utcp, :connection_module, ConnectionMock)

      # Create a mock connection
      mock_conn = :mock_connection_pid

      # Mock the connection to fail first, then succeed
      call_count = Agent.start_link(fn -> 0 end)
      {:ok, call_count} = call_count

      stub(ConnectionMock, :start_link, fn (_, _, _) ->
        current_count = Agent.get_and_update(call_count, fn count -> {count + 1, count + 1} end)
        if current_count < 2 do
          {:error, "Connection failed"}
        else
          {:ok, mock_conn}
        end
      end)

      # Mock the connection operations for successful retry
      expect(ConnectionMock, :send_message, fn (^mock_conn, "manual") -> :ok end)
      expect(ConnectionMock, :get_next_message, fn (^mock_conn, 5000) ->
        {:ok, Jason.encode!(%{"tools" => []})}
      end)

      # Create the testable transport
      transport = Testable.new()

      provider = Providers.new_websocket_provider([
        name: "test",
        url: "ws://example.com/ws"
      ])

      # This should retry and eventually succeed
      assert {:ok, []} = Testable.register_tool_provider(transport, provider)

      # Clean up the agent
      Agent.stop(call_count)
    end
  end
end
