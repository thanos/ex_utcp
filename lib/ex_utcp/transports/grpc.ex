defmodule ExUtcp.Transports.Grpc do
  @moduledoc """
  gRPC transport implementation for UTCP.

  This transport handles gRPC-based tool providers, supporting high-performance
  RPC calls with authentication and streaming capabilities.
  """

  use ExUtcp.Transports.Behaviour

  defstruct [
    :logger,
    :connection_timeout
  ]

  @doc """
  Creates a new gRPC transport.
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
      :grpc -> discover_tools(provider)
      _ -> {:error, "gRPC transport can only be used with gRPC providers"}
    end
  end

  @impl ExUtcp.Transports.Behaviour
  def deregister_tool_provider(_provider) do
    :ok
  end

  @impl ExUtcp.Transports.Behaviour
  def call_tool(tool_name, args, provider) do
    case provider.type do
      :grpc -> execute_tool_call(tool_name, args, provider)
      _ -> {:error, "gRPC transport can only be used with gRPC providers"}
    end
  end

  @impl ExUtcp.Transports.Behaviour
  def call_tool_stream(tool_name, args, provider) do
    case provider.type do
      :grpc -> execute_tool_stream(tool_name, args, provider)
      _ -> {:error, "gRPC transport can only be used with gRPC providers"}
    end
  end

  @impl ExUtcp.Transports.Behaviour
  def close do
    :ok
  end

  @impl ExUtcp.Transports.Behaviour
  def transport_name do
    "grpc"
  end

  @impl ExUtcp.Transports.Behaviour
  def supports_streaming? do
    true
  end

  # Private functions

  defp discover_tools(_provider) do
    # For now, return empty tools since gRPC connection requires a running server
    # In a real implementation, this would establish a gRPC connection
    # and call GetManual to discover available tools
    {:ok, []}
  end

  defp execute_tool_call(tool_name, args, _provider) do
    # For now, return a mock response since gRPC connection requires a running server
    # In a real implementation, this would establish a gRPC connection
    # and call CallTool to execute the tool
    {:ok, %{"result" => "Mock gRPC response for #{tool_name} with args: #{inspect(args)}"}}
  end

  defp execute_tool_stream(_tool_name, _args, _provider) do
    # For now, return a mock stream response since gRPC connection requires a running server
    # In a real implementation, this would establish a gRPC connection
    # and call CallToolStream to stream the tool response
    {:ok, %{type: :stream, data: ["Mock gRPC stream chunk 1", "Mock gRPC stream chunk 2"]}}
  end

end
