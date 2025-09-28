#!/usr/bin/env elixir

# WebSocket Server Example
# This example demonstrates a simple WebSocket server that implements UTCP protocol.

Mix.install([
  {:cowboy, "~> 2.14"},
  {:jason, "~> 1.4"}
])

defmodule WebSocketServer do
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: WebSocketServer.Router, options: [port: 8080]}
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

defmodule WebSocketServer.Router do
  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/ws" do
    conn
    |> put_resp_header("upgrade", "websocket")
    |> put_resp_header("connection", "upgrade")
    |> put_resp_header("sec-websocket-accept", "test")
    |> send_resp(101, "")
  end

  # Fallback route
  match _ do
    send_resp(conn, 404, "Not Found")
  end
end

defmodule WebSocketServer.Handler do
  @behaviour :cowboy_websocket

  def init(req, state) do
    {:cowboy_websocket, req, state}
  end

  def websocket_init(state) do
    IO.puts("WebSocket connection established")
    {:ok, state}
  end

  def websocket_handle({:text, "manual"}, state) do
    # Send tool manual
    manual = %{
      "tools" => [
        %{
          "name" => "echo",
          "description" => "Echoes back the provided message",
          "inputs" => %{
            "type" => "object",
            "properties" => %{
              "message" => %{
                "type" => "string",
                "description" => "The message to echo back"
              }
            },
            "required" => ["message"]
          },
          "outputs" => %{
            "type" => "object",
            "properties" => %{
              "result" => %{
                "type" => "string",
                "description" => "The echoed message"
              }
            }
          },
          "tags" => ["utility", "echo"]
        },
        %{
          "name" => "timestamp",
          "description" => "Returns the current timestamp",
          "inputs" => %{
            "type" => "object",
            "properties" => %{}
          },
          "outputs" => %{
            "type" => "object",
            "properties" => %{
              "result" => %{
                "type" => "string",
                "description" => "Current timestamp in RFC3339 format"
              }
            }
          },
          "tags" => ["utility", "time"]
        }
      ]
    }

    response = Jason.encode!(manual)
    {:reply, {:text, response}, state}
  end

  def websocket_handle({:text, data}, state) do
    # Handle tool calls
    case Jason.decode(data) do
      {:ok, %{"message" => message}} ->
        response = %{"result" => "Echo: #{message}"}
        {:reply, {:text, Jason.encode!(response)}, state}

      {:ok, %{"stream" => true}} ->
        # Simulate streaming response
        responses = [
          %{"chunk" => 1, "data" => "Streaming response part 1"},
          %{"chunk" => 2, "data" => "Streaming response part 2"},
          %{"chunk" => 3, "data" => "Streaming response part 3"}
        ]

        Enum.each(responses, fn resp ->
          send(self(), {:send, {:text, Jason.encode!(resp)}})
        end)

        {:ok, state}

      _ ->
        response = %{"error" => "Unknown request format"}
        {:reply, {:text, Jason.encode!(response)}, state}
    end
  end

  def websocket_info({:send, message}, state) do
    {:reply, message, state}
  end

  def websocket_terminate(reason, _state) do
    IO.puts("WebSocket connection terminated: #{inspect(reason)}")
    :ok
  end
end

# Start the server
IO.puts("Starting WebSocket server on ws://localhost:8080/ws")
WebSocketServer.start(nil, nil)
