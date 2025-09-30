defmodule ExUtcp.Transports.Grpc.GnmiTest do
  use ExUnit.Case, async: true

  alias ExUtcp.Transports.Grpc.Gnmi

  describe "gNMI functionality" do
    test "validates paths correctly" do
      valid_paths = ["/interfaces/interface[name=eth0]/state", "/system/state"]
      assert {:ok, validated_paths} = Gnmi.validate_paths(valid_paths)
      assert length(validated_paths) == 2
    end

    test "rejects empty paths" do
      assert {:error, "No valid paths provided"} = Gnmi.validate_paths([])
      assert {:error, "No valid paths provided"} = Gnmi.validate_paths([""])
      assert {:error, "No valid paths provided"} = Gnmi.validate_paths(["", "   "])
    end

    test "normalizes paths" do
      paths = ["/interfaces//interface[name=eth0]//state", "  /system/state  "]
      {:ok, normalized} = Gnmi.validate_paths(paths)

      assert "interfaces/interface[name=eth0]/state" in normalized
      assert "system/state" in normalized
    end

    test "builds paths from components" do
      path = Gnmi.build_path("openconfig-interfaces", ["interfaces", "interface"], "name=eth0")
      assert path == "openconfig-interfaces/interfaces/interface[name=eth0]"
    end

    test "builds paths without target" do
      path = Gnmi.build_path("openconfig-system", ["system", "state"])
      assert path == "openconfig-system/system/state"
    end

    test "parses paths correctly" do
      path = "openconfig-interfaces/interfaces/interface[name=eth0]/state"
      assert {:ok, parsed} = Gnmi.parse_path(path)

      assert parsed.origin == "openconfig-interfaces"
      assert parsed.elements == ["interfaces", "interface[name=eth0]", "state"]
      assert parsed.full_path == path
    end

    test "handles empty path parsing" do
      assert {:error, "Empty path"} = Gnmi.parse_path("")
    end

    test "handles malformed path parsing" do
      # This should not raise an exception
      assert {:ok, _} = Gnmi.parse_path("simple/path")
    end
  end
end
