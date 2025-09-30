ExUnit.start()

# Set up Mox mocks
Mox.defmock(ExUtcp.Transports.WebSocketMock, for: ExUtcp.Transports.Behaviour)
Mox.defmock(ExUtcp.Transports.WebSocket.ConnectionMock, for: ExUtcp.Transports.WebSocket.ConnectionBehaviour)
Mox.defmock(ExUtcp.Transports.WebSocket.GenServerMock, for: GenServer)
