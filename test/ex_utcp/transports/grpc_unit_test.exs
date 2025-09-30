defmodule ExUtcp.Transports.GrpcUnitTest do
  use ExUnit.Case, async: true

  alias ExUtcp.Transports.Grpc
  alias ExUtcp.Providers

  describe "gRPC Transport Unit Tests" do
    test "creates new transport" do
      transport = Grpc.new()

      assert %Grpc{} = transport
      assert transport.logger != nil
      assert transport.connection_timeout == 30_000
    end

    test "creates transport with custom options" do
      logger = fn msg -> IO.puts("Custom: #{msg}") end
      transport = Grpc.new(logger: logger, connection_timeout: 60_000)

      assert %Grpc{} = transport
      assert transport.logger == logger
      assert transport.connection_timeout == 60_000
    end

    test "returns correct transport name" do
      assert Grpc.transport_name() == "grpc"
    end

    test "supports streaming" do
      assert Grpc.supports_streaming?() == true
    end

    test "validates provider type" do
      valid_provider = %{
        name: "test",
        type: :grpc,
        url: "http://localhost:50051",
        auth: nil,
        headers: %{}
      }

      invalid_provider = %{
        name: "test",
        type: :http,
        url: "http://localhost:4000",
        auth: nil,
        headers: %{}
      }

      # Test with valid provider
      assert :ok = Grpc.register_tool_provider(valid_provider)

      # Test with invalid provider type
      assert {:error, "Invalid provider type for gRPC transport"} =
        Grpc.register_tool_provider(invalid_provider)
    end

    test "deregister_tool_provider always succeeds" do
      provider = %{
        name: "test",
        type: :grpc,
        url: "http://localhost:50051",
        auth: nil,
        headers: %{}
      }

      assert :ok = Grpc.deregister_tool_provider(provider)
    end

    test "close always succeeds" do
      assert :ok = Grpc.close()
    end
  end
end
