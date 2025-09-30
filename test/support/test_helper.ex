defmodule ExUtcp.TestHelper do
  @moduledoc """
  Test helper functions and setup.
  """

  def setup_mocks do
    # Set up Mox mocks
    Mox.defmock(ExUtcp.Transports.WebSocketMock, for: ExUtcp.Transports.Behaviour)
    Mox.defmock(ExUtcp.Transports.WebSocket.ConnectionMock, for: ExUtcp.Transports.WebSocket.Connection)
    Mox.defmock(ExUtcp.Transports.WebSocket.GenServerMock, for: GenServer)
  end

  def mock_websocket_transport do
    ExUtcp.Transports.WebSocketMock
  end

  def mock_websocket_connection do
    ExUtcp.Transports.WebSocket.ConnectionMock
  end

  def mock_websocket_genserver do
    ExUtcp.Transports.WebSocket.GenServerMock
  end
end
