defmodule ZoiForge.SchemaRendererTest do
  use ExUnit.Case, async: true

  alias ZoiForge.SchemaRenderer

  @module_name "ZoiForge.Schemas.Rusl.Schemas.Common"

  test "renders nested def modules inside the parent module" do
    json_map = %{
      "description" => "Common defs",
      "$defs" => %{
        "account-slug" => %{
          "type" => "string",
          "description" => "A URL-safe account identifier"
        }
      }
    }

    source =
      SchemaRenderer.render(
        @module_name,
        json_map,
        Jason.encode!(json_map)
      )

    assert source =~ "defmodule #{@module_name} do"
    assert source =~ "defmodule AccountSlug do"
    assert source =~ "Configuration for Common"
    assert source =~ "Jason.decode!(@raw_schema)"
    assert source =~ "Configuration for AccountSlug"
    assert source =~ "A URL-safe account identifier"
    refute source =~ "defmodule #{@module_name}.AccountSlug do"
  end
end
