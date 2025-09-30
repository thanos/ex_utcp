defmodule ExUtcp.Mocks do
  @moduledoc """
  Mocks for testing ExUtcp modules.
  """

  # WebSocket Transport Mock
  defmock(ExUtcp.Transports.WebSocketMock, for: ExUtcp.Transports.Behaviour)

  # WebSocket Connection Mock
  defmock(ExUtcp.Transports.WebSocket.ConnectionMock, for: ExUtcp.Transports.WebSocket.Connection)

  # GenServer Mock for WebSocket Transport
  defmock(ExUtcp.Transports.WebSocket.GenServerMock, for: GenServer)
end
