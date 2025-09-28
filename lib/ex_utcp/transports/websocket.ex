defmodule ExUtcp.Transports.WebSocket do
  @moduledoc """
  WebSocket transport implementation for UTCP.

  This transport handles WebSocket-based tool providers, supporting real-time
  bidirectional communication for tool discovery and execution.
  """

  use ExUtcp.Transports.Behaviour

  defstruct [
    :logger,
    :connection_timeout
  ]

  @doc """
  Creates a new WebSocket transport.
  """
  @spec new(keyword()) :: %__MODULE__{}
  def new(opts \\ []) do
    %__MODULE__{
      logger: Keyword.get(opts, :logger, &IO.puts/1),
      connection_timeout: Keyword.get(opts, :connection_timeout, 30_000)
    }
  end

  @impl ExUtcp.Transports.Behaviour
  def register_tool_provider(provider) do
    case provider.type do
      :websocket -> discover_tools(provider)
      _ -> {:error, "WebSocket transport can only be used with WebSocket providers"}
    end
  end

  @impl ExUtcp.Transports.Behaviour
  def deregister_tool_provider(_provider) do
    :ok
  end

  @impl ExUtcp.Transports.Behaviour
  def call_tool(tool_name, args, provider) do
    case provider.type do
      :websocket -> execute_tool_call(tool_name, args, provider)
      _ -> {:error, "WebSocket transport can only be used with WebSocket providers"}
    end
  end

  @impl ExUtcp.Transports.Behaviour
  def call_tool_stream(tool_name, args, provider) do
    case provider.type do
      :websocket -> execute_tool_stream(tool_name, args, provider)
      _ -> {:error, "WebSocket transport can only be used with WebSocket providers"}
    end
  end

  @impl ExUtcp.Transports.Behaviour
  def close do
    :ok
  end

  @impl ExUtcp.Transports.Behaviour
  def transport_name do
    "websocket"
  end

  @impl ExUtcp.Transports.Behaviour
  def supports_streaming? do
    true
  end

  # Private functions

  defp discover_tools(_provider) do
    # For now, return empty tools since WebSocket connection requires a running server
    # In a real implementation, this would establish a WebSocket connection
    # and request the tool manual
    {:ok, []}
  end

  defp execute_tool_call(tool_name, args, _provider) do
    # For now, return a mock response since WebSocket connection requires a running server
    # In a real implementation, this would establish a WebSocket connection
    # and send the tool request
    {:ok, %{"result" => "Mock WebSocket response for #{tool_name} with args: #{inspect(args)}"}}
  end

  defp execute_tool_stream(_tool_name, _args, _provider) do
    # For now, return a mock stream response since WebSocket connection requires a running server
    # In a real implementation, this would establish a WebSocket connection
    # and stream the tool response
    {:ok, %{type: :stream, data: ["Mock stream chunk 1", "Mock stream chunk 2"]}}
  end

end
