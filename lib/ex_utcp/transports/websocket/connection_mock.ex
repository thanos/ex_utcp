defmodule ExUtcp.Transports.WebSocket.ConnectionMock do
  @moduledoc """
  Mock implementation for WebSocket connections in tests.
  """

  @behaviour ExUtcp.Transports.WebSocket.ConnectionBehaviour

  def start_link(_provider) do
    {:ok, :mock_connection}
  end

  def call_tool(_pid, _tool_name, _args, _opts \\ []) do
    {:ok, %{"result" => "mock_result"}}
  end

  def call_tool_stream(_pid, _tool_name, _args, _opts \\ []) do
    {:ok, Stream.map([%{"chunk" => "mock_data"}], & &1)}
  end

  def close(_pid) do
    :ok
  end

  def get_last_used(_pid) do
    System.monotonic_time(:millisecond)
  end

  def update_last_used(_pid) do
    :ok
  end
end
