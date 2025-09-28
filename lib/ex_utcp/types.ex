defmodule ExUtcp.Types do
  @moduledoc """
  Core types and data structures for the UTCP protocol.
  """

  @type provider_type :: :http | :sse | :http_stream | :cli | :websocket | :grpc | :graphql | :tcp | :udp | :webrtc | :mcp | :text

  @type tool_input_output_schema :: %{
    type: String.t(),
    properties: %{String.t() => any()},
    required: [String.t()],
    description: String.t(),
    title: String.t(),
    items: %{String.t() => any()},
    enum: [any()],
    minimum: float() | nil,
    maximum: float() | nil,
    format: String.t()
  }

  @type tool :: %{
    name: String.t(),
    description: String.t(),
    inputs: tool_input_output_schema(),
    outputs: tool_input_output_schema(),
    tags: [String.t()],
    average_response_size: integer() | nil,
    provider: provider()
  }

  @type provider :: %{
    name: String.t(),
    type: provider_type(),
    __struct__: module()
  }

  @type auth :: %{
    type: String.t(),
    __struct__: module()
  }

  @type api_key_auth :: %{
    type: String.t(),
    api_key: String.t(),
    location: String.t(),
    var_name: String.t()
  }

  @type basic_auth :: %{
    type: String.t(),
    username: String.t(),
    password: String.t()
  }

  @type oauth2_auth :: %{
    type: String.t(),
    client_id: String.t(),
    client_secret: String.t(),
    token_url: String.t(),
    scope: String.t()
  }

  @type http_provider :: %{
    name: String.t(),
    type: :http,
    http_method: String.t(),
    url: String.t(),
    content_type: String.t(),
    auth: auth() | nil,
    headers: %{String.t() => String.t()},
    body_field: String.t() | nil,
    header_fields: [String.t()]
  }

  @type cli_provider :: %{
    name: String.t(),
    type: :cli,
    command_name: String.t(),
    working_dir: String.t() | nil,
    env_vars: %{String.t() => String.t()}
  }

  @type websocket_provider :: %{
    name: String.t(),
    type: :websocket,
    url: String.t(),
    auth: auth() | nil,
    headers: %{String.t() => String.t()}
  }

  @type grpc_provider :: %{
    name: String.t(),
    type: :grpc,
    host: String.t(),
    port: integer(),
    auth: auth() | nil,
    headers: %{String.t() => String.t()}
  }

  @type graphql_provider :: %{
    name: String.t(),
    type: :graphql,
    url: String.t(),
    auth: auth() | nil,
    headers: %{String.t() => String.t()}
  }

  @type tcp_provider :: %{
    name: String.t(),
    type: :tcp,
    host: String.t(),
    port: integer()
  }

  @type udp_provider :: %{
    name: String.t(),
    type: :udp,
    host: String.t(),
    port: integer()
  }

  @type webrtc_provider :: %{
    name: String.t(),
    type: :webrtc,
    url: String.t(),
    auth: auth() | nil
  }

  @type mcp_provider :: %{
    name: String.t(),
    type: :mcp,
    url: String.t(),
    auth: auth() | nil
  }

  @type text_provider :: %{
    name: String.t(),
    type: :text,
    file_path: String.t()
  }

  @type sse_provider :: %{
    name: String.t(),
    type: :sse,
    url: String.t(),
    auth: auth() | nil,
    headers: %{String.t() => String.t()}
  }

  @type streamable_http_provider :: %{
    name: String.t(),
    type: :http_stream,
    url: String.t(),
    auth: auth() | nil,
    headers: %{String.t() => String.t()}
  }

  @type variable_not_found :: %{
    __exception__: true,
    variable_name: String.t()
  }

  @type client_config :: %{
    variables: %{String.t() => String.t()},
    providers_file_path: String.t() | nil,
    load_variables_from: [module()]
  }

  @type tool_repository :: %{
    tools: %{String.t() => [tool()]},
    providers: %{String.t() => provider()}
  }

  @type transport :: module()

  @type stream_result :: any()

  @type call_result :: {:ok, any()} | {:error, any()}

  @type search_result :: {:ok, [tool()]} | {:error, any()}

  @type register_result :: {:ok, [tool()]} | {:error, any()}

  @type deregister_result :: :ok | {:error, any()}
end
