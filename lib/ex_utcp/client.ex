defmodule ExUtcp.Client do
  @moduledoc """
  Main UTCP client implementation.

  This module provides the primary interface for interacting with UTCP providers
  and tools. It manages provider registration, tool discovery, and tool execution.
  """

  use GenServer

  alias ExUtcp.Types, as: T
  alias ExUtcp.{Config, Repository, Tools, Providers}

  defstruct [
    :config,
    :repository,
    :transports,
    :search_strategy
  ]

  @doc """
  Starts a new UTCP client with the given configuration.
  """
  @spec start_link(T.client_config()) :: GenServer.on_start()
  def start_link(config) do
    GenServer.start_link(__MODULE__, config)
  end

  @doc """
  Starts a new UTCP client with the given configuration and name.
  """
  @spec start_link(T.client_config(), GenServer.name()) :: GenServer.on_start()
  def start_link(config, name) do
    GenServer.start_link(__MODULE__, config, name: name)
  end

  @doc """
  Registers a tool provider and returns the discovered tools.
  """
  @spec register_tool_provider(GenServer.server(), T.provider()) :: T.register_result()
  def register_tool_provider(client, provider) do
    GenServer.call(client, {:register_provider, provider})
  end

  @doc """
  Deregisters a tool provider.
  """
  @spec deregister_tool_provider(GenServer.server(), String.t()) :: T.deregister_result()
  def deregister_tool_provider(client, provider_name) do
    GenServer.call(client, {:deregister_provider, provider_name})
  end

  @doc """
  Calls a specific tool with the given arguments.
  """
  @spec call_tool(GenServer.server(), String.t(), map()) :: T.call_result()
  def call_tool(client, tool_name, args \\ %{}) do
    GenServer.call(client, {:call_tool, tool_name, args})
  end

  @doc """
  Calls a tool with streaming support.
  """
  @spec call_tool_stream(GenServer.server(), String.t(), map()) :: {:ok, T.stream_result()} | {:error, any()}
  def call_tool_stream(client, tool_name, args \\ %{}) do
    GenServer.call(client, {:call_tool_stream, tool_name, args})
  end

  @doc """
  Searches for tools matching the given query.
  """
  @spec search_tools(GenServer.server(), String.t(), integer()) :: T.search_result()
  def search_tools(client, query \\ "", limit \\ 10) do
    GenServer.call(client, {:search_tools, query, limit})
  end

  @doc """
  Gets all available transports.
  """
  @spec get_transports(GenServer.server()) :: %{String.t() => module()}
  def get_transports(client) do
    GenServer.call(client, :get_transports)
  end

  @doc """
  Gets the client configuration.
  """
  @spec get_config(GenServer.server()) :: T.client_config()
  def get_config(client) do
    GenServer.call(client, :get_config)
  end

  @doc """
  Gets repository statistics.
  """
  @spec get_stats(GenServer.server()) :: map()
  def get_stats(client) do
    GenServer.call(client, :get_stats)
  end

  # GenServer callbacks

  @impl GenServer
  def init(config) do
    repository = Repository.new()
    transports = default_transports()
    search_strategy = default_search_strategy()

    # Load providers from file if specified
    state = %__MODULE__{
      config: config,
      repository: repository,
      transports: transports,
      search_strategy: search_strategy
    }

    if config.providers_file_path do
      case load_providers_from_file(state, config.providers_file_path) do
        {:ok, updated_state} -> {:ok, updated_state}
        {:error, reason} -> {:stop, reason}
      end
    else
      {:ok, state}
    end
  end

  @impl GenServer
  def handle_call({:register_provider, provider}, _from, state) do
    case register_provider(state, provider) do
      {:ok, tools, updated_state} -> {:reply, {:ok, tools}, updated_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def handle_call({:deregister_provider, provider_name}, _from, state) do
    case deregister_provider(state, provider_name) do
      {:ok, updated_state} -> {:reply, :ok, updated_state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def handle_call({:call_tool, tool_name, args}, _from, state) do
    case call_tool_impl(state, tool_name, args) do
      {:ok, result} -> {:reply, {:ok, result}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def handle_call({:call_tool_stream, tool_name, args}, _from, state) do
    case call_tool_stream_impl(state, tool_name, args) do
      {:ok, result} -> {:reply, {:ok, result}, state}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  @impl GenServer
  def handle_call({:search_tools, query, limit}, _from, state) do
    tools = Repository.search_tools(state.repository, query, limit)
    {:reply, {:ok, tools}, state}
  end

  @impl GenServer
  def handle_call(:get_transports, _from, state) do
    {:reply, state.transports, state}
  end

  @impl GenServer
  def handle_call(:get_config, _from, state) do
    {:reply, state.config, state}
  end

  @impl GenServer
  def handle_call(:get_stats, _from, state) do
    stats = %{
      tool_count: Repository.tool_count(state.repository),
      provider_count: Repository.provider_count(state.repository)
    }
    {:reply, stats, state}
  end

  # Private functions

  defp default_transports do
    %{
      "http" => ExUtcp.Transports.Http,
      "cli" => ExUtcp.Transports.Cli,
      "websocket" => ExUtcp.Transports.WebSocket,
      "grpc" => ExUtcp.Transports.Grpc
      # Add more transports as they are implemented
    }
  end

  defp default_search_strategy do
    # Simple search strategy - can be enhanced later
    fn repository, query, limit ->
      Repository.search_tools(repository, query, limit)
    end
  end

  defp load_providers_from_file(state, file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, data} -> parse_and_register_providers(state, data)
          {:error, reason} -> {:error, "Failed to parse JSON: #{reason}"}
        end
      {:error, reason} -> {:error, "Failed to read file: #{reason}"}
    end
  end

  defp parse_and_register_providers(state, data) do
    providers_data = case data do
      %{"providers" => providers} when is_list(providers) -> providers
      %{"providers" => provider} when is_map(provider) -> [provider]
      providers when is_list(providers) -> providers
      provider when is_map(provider) -> [provider]
      _ -> []
    end

    updated_state = Enum.reduce(providers_data, state, fn provider_data, acc_state ->
      case parse_provider(provider_data) do
        {:ok, provider} ->
          case register_provider(acc_state, provider) do
            {:ok, _tools, new_state} -> new_state
            {:error, _reason} -> acc_state
          end
        {:error, _reason} -> acc_state
      end
    end)

    {:ok, updated_state}
  end

  defp parse_provider(provider_data) do
    provider_type = Map.get(provider_data, "type") || Map.get(provider_data, "provider_type")

    case provider_type do
      "http" -> parse_http_provider(provider_data)
      "cli" -> parse_cli_provider(provider_data)
      "websocket" -> parse_websocket_provider(provider_data)
      "grpc" -> parse_grpc_provider(provider_data)
      _ -> {:error, "Unknown provider type: #{provider_type}"}
    end
  end

  defp parse_http_provider(data) do
    provider = Providers.new_http_provider([
      name: Map.get(data, "name", ""),
      http_method: Map.get(data, "http_method", "GET"),
      url: Map.get(data, "url", ""),
      content_type: Map.get(data, "content_type", "application/json"),
      auth: parse_auth(Map.get(data, "auth")),
      headers: Map.get(data, "headers", %{}),
      body_field: Map.get(data, "body_field"),
      header_fields: Map.get(data, "header_fields", [])
    ])
    {:ok, provider}
  end

  defp parse_cli_provider(data) do
    provider = Providers.new_cli_provider([
      name: Map.get(data, "name", ""),
      command_name: Map.get(data, "command_name", ""),
      working_dir: Map.get(data, "working_dir"),
      env_vars: Map.get(data, "env_vars", %{})
    ])
    {:ok, provider}
  end

  defp parse_websocket_provider(data) do
    provider = Providers.new_websocket_provider([
      name: Map.get(data, "name", ""),
      url: Map.get(data, "url", ""),
      protocol: Map.get(data, "protocol"),
      keep_alive: Map.get(data, "keep_alive", false),
      auth: parse_auth(Map.get(data, "auth")),
      headers: Map.get(data, "headers", %{}),
      header_fields: Map.get(data, "header_fields", [])
    ])
    {:ok, provider}
  end

  defp parse_grpc_provider(data) do
    provider = Providers.new_grpc_provider([
      name: Map.get(data, "name", ""),
      host: Map.get(data, "host", "127.0.0.1"),
      port: Map.get(data, "port", 9339),
      service_name: Map.get(data, "service_name", "UTCPService"),
      method_name: Map.get(data, "method_name", "CallTool"),
      target: Map.get(data, "target"),
      use_ssl: Map.get(data, "use_ssl", false),
      auth: parse_auth(Map.get(data, "auth"))
    ])
    {:ok, provider}
  end

  defp parse_auth(nil), do: nil
  defp parse_auth(auth_data) do
    case Map.get(auth_data, "type") || Map.get(auth_data, "auth_type") do
      "api_key" -> ExUtcp.Auth.new_api_key_auth(auth_data)
      "basic" -> ExUtcp.Auth.new_basic_auth(auth_data)
      "oauth2" -> ExUtcp.Auth.new_oauth2_auth(auth_data)
      _ -> nil
    end
  end

  defp register_provider(state, provider) do
    # Apply variable substitution
    substituted_provider = Config.substitute_variables(state.config, provider)

    # Normalize provider name
    normalized_name = Providers.normalize_name(Providers.get_name(substituted_provider))
    substituted_provider = Providers.set_name(substituted_provider, normalized_name)

    # Get transport
    transport_module = Map.get(state.transports, to_string(substituted_provider.type))
    if is_nil(transport_module) do
      {:error, "No transport available for provider type: #{substituted_provider.type}"}
    else
      # Register with transport
      case transport_module.register_tool_provider(substituted_provider) do
        {:ok, tools} ->
          # Normalize tool names
          normalized_tools = Enum.map(tools, fn tool ->
            normalized_name = Tools.normalize_name(tool.name, normalized_name)
            Map.put(tool, :name, normalized_name)
          end)

          # Save to repository
          updated_repository = Repository.save_provider_with_tools(
            state.repository,
            substituted_provider,
            normalized_tools
          )

          updated_state = %{state | repository: updated_repository}
          {:ok, normalized_tools, updated_state}
        {:error, reason} -> {:error, reason}
      end
    end
  end

  defp deregister_provider(state, provider_name) do
    case Repository.get_provider(state.repository, provider_name) do
      nil -> {:error, "Provider not found: #{provider_name}"}
      provider ->
        # Get transport
        transport_module = Map.get(state.transports, to_string(provider.type))
        if is_nil(transport_module) do
          {:error, "No transport available for provider type: #{provider.type}"}
        else
          # Deregister with transport
          transport_module.deregister_tool_provider(provider)

          # Remove from repository
          updated_repository = Repository.remove_provider(state.repository, provider_name)
          updated_state = %{state | repository: updated_repository}
          {:ok, updated_state}
        end
    end
  end

  defp call_tool_impl(state, tool_name, args) do
    case Repository.get_tool(state.repository, tool_name) do
      nil -> {:error, "Tool not found: #{tool_name}"}
      _tool ->
        provider_name = Tools.extract_provider_name(tool_name)
        case Repository.get_provider(state.repository, provider_name) do
          nil -> {:error, "Provider not found: #{provider_name}"}
          provider ->
            transport_module = Map.get(state.transports, to_string(provider.type))
            if is_nil(transport_module) do
              {:error, "No transport available for provider type: #{provider.type}"}
            else
              _transport = transport_module.new()
              call_name = if provider.type in [:mcp, :text] do
                Tools.extract_tool_name(tool_name)
              else
                tool_name
              end
              transport_module.call_tool(call_name, args, provider)
            end
        end
    end
  end

  defp call_tool_stream_impl(state, tool_name, args) do
    case Repository.get_tool(state.repository, tool_name) do
      nil -> {:error, "Tool not found: #{tool_name}"}
      _tool ->
        provider_name = Tools.extract_provider_name(tool_name)
        case Repository.get_provider(state.repository, provider_name) do
          nil -> {:error, "Provider not found: #{provider_name}"}
          provider ->
            transport_module = Map.get(state.transports, to_string(provider.type))
            if is_nil(transport_module) do
              {:error, "No transport available for provider type: #{provider.type}"}
            else
              _transport = transport_module.new()
              call_name = if provider.type in [:mcp, :text] do
                Tools.extract_tool_name(tool_name)
              else
                tool_name
              end
              transport_module.call_tool_stream(call_name, args, provider)
            end
        end
    end
  end
end
