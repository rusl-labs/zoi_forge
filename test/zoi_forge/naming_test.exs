defmodule ZoiForge.NamingTest do
  use ExUnit.Case, async: true

  alias ZoiForge.Naming

  @common_schema "rusl/schemas/common.schema.json"
  @baz_schema "foo/baz.schema.json"

  describe "module_name/3" do
    test "combines app prefix, lib-relative output path, and schema path" do
      assert Naming.module_name("ZoiForge", "lib/schemas", @common_schema) ==
               "ZoiForge.Schemas.Rusl.Schemas.Common"

      assert Naming.module_name("FooDeFafa", "lib/schemas", @common_schema) ==
               "FooDeFafa.Schemas.Rusl.Schemas.Common"

      assert Naming.module_name("ZoiForge", "lib/schemas", @baz_schema) ==
               "ZoiForge.Schemas.Foo.Baz"
    end

    test "uses output segments without an app prefix" do
      assert Naming.module_name(nil, "lib/schemas", @common_schema) ==
               "Schemas.Rusl.Schemas.Common"
    end

    test "skips the app prefix when it matches the first source segment" do
      assert Naming.module_name("Rusl", "lib/schemas", @common_schema) ==
               "Schemas.Rusl.Schemas.Common"
    end

    test "ignores output dirs outside lib/" do
      assert Naming.module_name("ZoiForge", "tmp/generated", @baz_schema) ==
               "ZoiForge.Foo.Baz"

      assert Naming.module_name("Rusl", "tmp/generated", @baz_schema) ==
               "Rusl.Foo.Baz"
    end
  end

  describe "path segment helpers" do
    test "source_path_segments/1 strips the schema suffix and camelizes" do
      assert Naming.source_path_segments(@common_schema) == ["Rusl", "Schemas", "Common"]
    end

    test "output_dir_segments/1 takes segments after lib/" do
      assert Naming.output_dir_segments("lib/schemas") == ["Schemas"]

      assert Naming.output_dir_segments("/abs/project/lib/schemas/vendor") == [
               "Schemas",
               "Vendor"
             ]

      assert Naming.output_dir_segments("tmp/generated") == []
    end
  end
end
