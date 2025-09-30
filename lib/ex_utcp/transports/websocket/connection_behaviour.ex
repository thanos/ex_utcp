defmodule ExUtcp.Transports.WebSocket.ConnectionBehaviour do
  @moduledoc """
  Behaviour for WebSocket connection operations.
  """

  @callback start_link(String.t(), map(), keyword()) :: {:ok, pid()} | {:error, term()}
  @callback send_message(pid(), String.t()) :: :ok | {:error, term()}
  @callback close(pid()) :: :ok
  @callback get_next_message(pid(), timeout()) :: {:ok, String.t()} | {:error, :timeout}
  @callback get_all_messages(pid()) :: [String.t()]
  @callback clear_messages(pid()) :: :ok
end
