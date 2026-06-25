defmodule ZoiForge.VerifyTest do
  use ExUnit.Case, async: true

  alias ZoiForge.{Generator, Verify}

  @fixtures Path.join([__DIR__, "..", "fixtures", "schemas"])
  @tmp_root Path.join([__DIR__, "..", "tmp", "verify"])
  @lib_schemas_output Path.join(@tmp_root, "lib/schemas")

  @dogfood_prefix "ZoiForge"

  setup do
    on_exit(fn ->
      File.rm_rf!(@tmp_root)
    end)

    :ok
  end

  test "returns ok when lib/schemas output matches fresh codegen" do
    {:ok, _} =
      Generator.run(
        source_dir: @fixtures,
        output_dir: @lib_schemas_output,
        prefix: @dogfood_prefix
      )

    assert :ok =
             Verify.run(
               source_dir: @fixtures,
               output_dir: @lib_schemas_output,
               prefix: @dogfood_prefix
             )
  end

  test "returns stale files when lib/schemas output differs" do
    {:ok, _} =
      Generator.run(
        source_dir: @fixtures,
        output_dir: @lib_schemas_output,
        prefix: @dogfood_prefix
      )

    baz_path = Path.join(@lib_schemas_output, "foo/baz.ex")
    File.write!(baz_path, String.replace(File.read!(baz_path), "def parse", "def parse_stale"))

    assert {:error, {:stale, stale}} =
             Verify.run(
               source_dir: @fixtures,
               output_dir: @lib_schemas_output,
               prefix: @dogfood_prefix
             )

    assert "foo/baz.ex" in stale
  end
end
