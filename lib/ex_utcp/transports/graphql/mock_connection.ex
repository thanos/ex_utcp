defmodule ExUtcp.Transports.Graphql.MockConnection do
  @moduledoc """
  Mock connection for testing GraphQL transport without real network calls.
  """

  @doc """
  Executes a GraphQL query.
  """
  @spec query(atom(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, term()}
  def query(_conn, _query_string, _variables \\ %{}, _opts \\ []) do
    {:ok, %{"result" => "Mock query result"}}
  end

  @doc """
  Executes a GraphQL mutation.
  """
  @spec mutation(atom(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, term()}
  def mutation(_conn, _mutation_string, _variables \\ %{}, _opts \\ []) do
    {:ok, %{"result" => "Mock mutation result"}}
  end

  @doc """
  Executes a GraphQL subscription.
  """
  @spec subscription(atom(), String.t(), map(), keyword()) :: {:ok, [map()]} | {:error, term()}
  def subscription(_conn, _subscription_string, _variables \\ %{}, _opts \\ []) do
    {:ok, [%{"data" => "Mock subscription data"}]}
  end

  @doc """
  Introspects the GraphQL schema.
  """
  @spec introspect_schema(atom(), keyword()) :: {:ok, map()} | {:error, term()}
  def introspect_schema(_conn, _opts \\ []) do
    {:ok, %{"__schema" => %{"queryType" => %{"name" => "Query"}}}}
  end
end
