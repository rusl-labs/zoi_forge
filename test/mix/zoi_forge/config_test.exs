defmodule Mix.ZoiForge.ConfigTest do
  use ExUnit.Case, async: false

  alias Mix.ZoiForge.Config
  alias ZoiForge.Naming

  @common_schema "rusl/schemas/common.schema.json"

  test "app_to_prefix/1 converts snake_case app names" do
    assert Config.app_to_prefix(:foo_de_fafa) == "FooDeFafa"
    assert Config.app_to_prefix(:zoi_forge) == "ZoiForge"
    assert Config.app_to_prefix(:rusl) == "Rusl"
  end

  test "project_prefix!/0 uses the active Mix project app" do
    assert Config.project_prefix!() == "ZoiForge"
  end

  test "build/1 defaults match this repo's dogfood layout" do
    config = Config.build([])

    assert config[:prefix] == "ZoiForge"
    assert config[:source_dir] == "priv/schemas"
    assert config[:output_dir] == "lib/schemas"

    assert Naming.module_name(config[:prefix], config[:output_dir], @common_schema) ==
             "ZoiForge.Schemas.Rusl.Schemas.Common"
  end

  test "build/1 disables the project prefix when auto_prefix is false" do
    previous = Application.get_env(:zoi_forge, :auto_prefix)
    Application.put_env(:zoi_forge, :auto_prefix, false)

    on_exit(fn ->
      case previous do
        nil -> Application.delete_env(:zoi_forge, :auto_prefix)
        value -> Application.put_env(:zoi_forge, :auto_prefix, value)
      end
    end)

    config = Config.build([])

    assert config[:prefix] == nil

    assert Naming.module_name(config[:prefix], config[:output_dir], @common_schema) ==
             "Schemas.Rusl.Schemas.Common"
  end

  test "build/1 prefers explicit CLI options" do
    config = Config.build(prefix: "Rusl", source_dir: "src", output_dir: "out")

    assert config[:prefix] == "Rusl"
    assert config[:source_dir] == "src"
    assert config[:output_dir] == "out"
  end
end
