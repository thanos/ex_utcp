defmodule ExUtcp.Transports.Http do
  @moduledoc """
  HTTP transport implementation for UTCP.

  This transport handles HTTP/HTTPS based tool providers, including REST APIs
  and OpenAPI specification discovery.
  """

  use ExUtcp.Transports.Behaviour

  alias ExUtcp.Auth

  defstruct [
    :http_client,
    :oauth_tokens,
    :logger
  ]

  @doc """
  Creates a new HTTP transport.
  """
  @spec new(keyword()) :: %__MODULE__{}
  def new(opts \\ []) do
    %__MODULE__{
      http_client: Keyword.get(opts, :http_client, Req.new()),
      oauth_tokens: %{},
      logger: Keyword.get(opts, :logger, &IO.puts/1)
    }
  end

  @impl ExUtcp.Transports.Behaviour
  def register_tool_provider(provider) do
    case provider.type do
      :http -> discover_tools(provider)
      _ -> {:error, "HTTP transport can only be used with HTTP providers"}
    end
  end

  @impl ExUtcp.Transports.Behaviour
  def deregister_tool_provider(_provider) do
    :ok
  end

  @impl ExUtcp.Transports.Behaviour
  def call_tool(tool_name, args, provider) do
    case provider.type do
      :http -> execute_tool_call(tool_name, args, provider)
      _ -> {:error, "HTTP transport can only be used with HTTP providers"}
    end
  end

  @impl ExUtcp.Transports.Behaviour
  def call_tool_stream(_tool_name, _args, _provider) do
    {:error, "Streaming not supported by HTTP transport"}
  end

  @impl ExUtcp.Transports.Behaviour
  def close do
    :ok
  end

  @impl ExUtcp.Transports.Behaviour
  def transport_name do
    "http"
  end

  @impl ExUtcp.Transports.Behaviour
  def supports_streaming? do
    false
  end

  # Private functions

  defp discover_tools(provider) do
    with {:ok, response} <- make_request(provider, provider.http_method, provider.url, %{}),
         {:ok, tools} <- parse_discovery_response(response, provider) do
      {:ok, tools}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp execute_tool_call(_tool_name, args, provider) do
    # Handle URL template substitution for path parameters
    url_template = substitute_url_params(provider.url, args)
    remaining_args = remove_url_params(args, provider.url)

    with {:ok, response} <- make_tool_request(provider, url_template, remaining_args),
         {:ok, result} <- parse_tool_response(response) do
      {:ok, result}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp make_request(provider, method, url, body) do
    headers = build_headers(provider)
    headers = Auth.apply_to_headers(provider.auth, headers)

    request_opts = [
      method: String.downcase(method),
      url: url,
      headers: headers,
      json: body,
      receive_timeout: 30_000
    ]

    case Req.request(request_opts) do
      {:ok, response} -> {:ok, response}
      {:error, reason} -> {:error, reason}
    end
  end

  defp make_tool_request(provider, url, args) do
    headers = build_headers(provider)
    headers = Auth.apply_to_headers(provider.auth, headers)

    request_opts = [
      method: String.downcase(provider.http_method),
      url: url,
      headers: headers,
      json: args,
      receive_timeout: 30_000
    ]

    case Req.request(request_opts) do
      {:ok, response} -> {:ok, response}
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_headers(provider) do
    base_headers = %{
      "Content-Type" => provider.content_type,
      "Accept" => "application/json"
    }

    Map.merge(base_headers, provider.headers)
  end

  defp substitute_url_params(url, args) do
    Enum.reduce(args, url, fn {key, value}, acc_url ->
      placeholder = "{#{key}}"
      if String.contains?(acc_url, placeholder) do
        String.replace(acc_url, placeholder, to_string(value))
      else
        acc_url
      end
    end)
  end

  defp remove_url_params(args, url) do
    url_params = extract_url_params(url)
    Map.drop(args, url_params)
  end

  defp extract_url_params(url) do
    Regex.scan(~r/\{(\w+)\}/, url)
    |> Enum.map(fn [_, param] -> param end)
  end

  defp parse_discovery_response(response, provider) do
    case response.status do
      status when status >= 200 and status < 300 ->
        case Jason.decode(response.body) do
          {:ok, data} -> parse_utcp_manual(data, provider)
          {:error, reason} -> {:error, "Failed to parse JSON response: #{reason}"}
        end
      status ->
        {:error, "HTTP error: #{status}"}
    end
  end

  defp parse_tool_response(response) do
    case response.status do
      status when status >= 200 and status < 300 ->
        case Jason.decode(response.body) do
          {:ok, data} -> {:ok, data}
          {:error, reason} -> {:error, "Failed to parse JSON response: #{reason}"}
        end
      status ->
        {:error, "HTTP error: #{status}"}
    end
  end

  defp parse_utcp_manual(data, provider) do
    case data do
      %{"version" => _} ->
        # UTCP manual format
        tools = Map.get(data, "tools", [])
        {:ok, Enum.map(tools, &normalize_tool(&1, provider))}
      _ ->
        # Try OpenAPI conversion
        case convert_openapi(data, provider) do
          {:ok, tools} -> {:ok, tools}
        end
    end
  end

  defp convert_openapi(_data, _provider) do
    # This would integrate with an OpenAPI converter
    # For now, return empty tools
    {:ok, []}
  end

  defp normalize_tool(tool_data, provider) do
    ExUtcp.Tools.new_tool([
      name: Map.get(tool_data, "name", ""),
      description: Map.get(tool_data, "description", ""),
      inputs: parse_schema(Map.get(tool_data, "inputs", %{})),
      outputs: parse_schema(Map.get(tool_data, "outputs", %{})),
      tags: Map.get(tool_data, "tags", []),
      average_response_size: Map.get(tool_data, "average_response_size"),
      provider: provider
    ])
  end

  defp parse_schema(schema_data) do
    ExUtcp.Tools.new_schema([
      type: Map.get(schema_data, "type", "object"),
      properties: Map.get(schema_data, "properties", %{}),
      required: Map.get(schema_data, "required", []),
      description: Map.get(schema_data, "description", ""),
      title: Map.get(schema_data, "title", ""),
      items: Map.get(schema_data, "items", %{}),
      enum: Map.get(schema_data, "enum", []),
      minimum: Map.get(schema_data, "minimum"),
      maximum: Map.get(schema_data, "maximum"),
      format: Map.get(schema_data, "format", "")
    ])
  end
end
