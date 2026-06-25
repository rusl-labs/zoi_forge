defmodule ZoiForge.GeneratorTest do
  use ExUnit.Case, async: true

  alias ZoiForge.Generator

  @fixtures Path.join([__DIR__, "..", "fixtures", "schemas"])
  @tmp_output Path.join([__DIR__, "..", "tmp", "generated_schemas"])
  @lib_schemas_output Path.join(@tmp_output, "lib/schemas")

  @dogfood_prefix "ZoiForge"
  @dogfood_common_module "ZoiForge.Schemas.Rusl.Schemas.Common"
  @dogfood_baz_module "ZoiForge.Schemas.Foo.Baz"

  setup do
    on_exit(fn ->
      File.rm_rf!(@tmp_output)
    end)

    :ok
  end

  test "generates app-prefixed modules under lib/schemas" do
    {:ok, generated} =
      Generator.run(
        source_dir: @fixtures,
        output_dir: @lib_schemas_output,
        prefix: @dogfood_prefix
      )

    common_path = Path.join(@lib_schemas_output, "rusl/schemas/common.ex")
    baz_path = Path.join(@lib_schemas_output, "foo/baz.ex")

    assert Enum.sort(generated) ==
             [
               {@dogfood_baz_module, baz_path},
               {@dogfood_common_module, common_path}
             ]

    common_source = File.read!(common_path)
    baz_source = File.read!(baz_path)

    assert common_source =~ "defmodule #{@dogfood_common_module} do"
    assert common_source =~ "defmodule AccountSlug do"
    assert common_source =~ "defmodule SchemaRef do"
    assert common_source =~ "Configuration for Common"
    assert common_source =~ "def raw_schema, do: @raw_schema"
    [parent_section | _] = String.split(common_source, "  defmodule AccountSlug do")
    refute parent_section =~ "@schema"
    refute parent_section =~ "def parse(data)"

    assert baz_source =~ "defmodule #{@dogfood_baz_module} do"
    assert baz_source =~ "def parse(data), do: Zoi.parse(@schema, data)"
    assert baz_source =~ "Configuration for Baz"
    assert baz_source =~ "\#{Zoi.describe(@schema)}"
  end

  test "deduplicates app prefix when it matches the first source segment" do
    {:ok, generated} =
      Generator.run(
        source_dir: @fixtures,
        output_dir: @lib_schemas_output,
        prefix: "Rusl"
      )

    assert {"Schemas.Rusl.Schemas.Common", _} =
             List.keyfind(generated, "Schemas.Rusl.Schemas.Common", 0)

    assert {"Rusl.Schemas.Foo.Baz", _} = List.keyfind(generated, "Rusl.Schemas.Foo.Baz", 0)
  end

  test "generates path-only modules when prefix is nil and output is outside lib/" do
    {:ok, generated} =
      Generator.run(
        source_dir: @fixtures,
        output_dir: @tmp_output,
        prefix: nil
      )

    assert {"Rusl.Schemas.Common", _} = List.keyfind(generated, "Rusl.Schemas.Common", 0)
    assert {"Foo.Baz", _} = List.keyfind(generated, "Foo.Baz", 0)
  end

  test "generates app-prefixed modules outside lib/ without Schemas segment" do
    {:ok, generated} =
      Generator.run(
        source_dir: @fixtures,
        output_dir: @tmp_output,
        prefix: "Rusl"
      )

    assert Enum.sort(generated) ==
             [
               {"Rusl.Foo.Baz", Path.join(@tmp_output, "foo/baz.ex")},
               {"Rusl.Schemas.Common", Path.join(@tmp_output, "rusl/schemas/common.ex")}
             ]
  end

  test "prunes previous output before generating" do
    stale_dir = Path.join(@lib_schemas_output, "stale")
    File.mkdir_p!(stale_dir)
    File.write!(Path.join(stale_dir, "orphan.ex"), "# stale")

    {:ok, _} =
      Generator.run(
        source_dir: @fixtures,
        output_dir: @lib_schemas_output,
        prefix: @dogfood_prefix
      )

    refute File.exists?(Path.join(stale_dir, "orphan.ex"))
  end

  test "returns error when source directory is missing" do
    assert {:error, {:source_dir_not_found, _}} =
             Generator.run(
               source_dir: Path.join(@tmp_output, "missing"),
               output_dir: @lib_schemas_output,
               prefix: @dogfood_prefix
             )
  end

  test "returns error for invalid json schema files" do
    invalid_dir = Path.join(@tmp_output, "invalid_source")
    File.mkdir_p!(invalid_dir)
    File.write!(Path.join(invalid_dir, "broken.schema.json"), "{not json")

    assert {:error, {:generation_failed, _path, {:json_decode_failed, _}}} =
             Generator.run(
               source_dir: invalid_dir,
               output_dir: Path.join(@tmp_output, "invalid_output"),
               prefix: @dogfood_prefix
             )
  end
end
