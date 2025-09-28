defmodule ExUtcp.Transports.Behaviour do
  @moduledoc """
  Behaviour definition for UTCP transports.

  All transport implementations must implement this behaviour to ensure
  consistent interface across different communication protocols.
  """

  alias ExUtcp.Types, as: T

  @doc """
  Registers a tool provider and returns the discovered tools.
  """
  @callback register_tool_provider(T.provider()) :: T.register_result()

  @doc """
  Deregisters a tool provider.
  """
  @callback deregister_tool_provider(T.provider()) :: T.deregister_result()

  @doc """
  Calls a specific tool with the given arguments.
  """
  @callback call_tool(String.t(), map(), T.provider()) :: T.call_result()

  @doc """
  Calls a tool with streaming support.
  """
  @callback call_tool_stream(String.t(), map(), T.provider()) :: {:ok, T.stream_result()} | {:error, any()}

  @doc """
  Closes the transport and cleans up resources.
  """
  @callback close() :: :ok | {:error, any()}

  @doc """
  Gets the transport name.
  """
  @callback transport_name() :: String.t()

  @doc """
  Checks if the transport supports streaming.
  """
  @callback supports_streaming?() :: boolean()

  defmacro __using__(_opts) do
    quote do
      @behaviour ExUtcp.Transports.Behaviour
    end
  end
end
