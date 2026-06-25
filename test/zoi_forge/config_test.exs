defmodule ZoiForge.ConfigTest do
  use ExUnit.Case, async: true

  alias ZoiForge.Config

  test "defaults" do
    config = Config.new([])

    assert config.source_dir == "priv/schemas"
    assert config.output_dir == "lib/schemas"
    assert config.prefix == nil
  end

  test "accepts overrides and preserves struct input" do
    original = %Config{prefix: "Rusl", source_dir: "a", output_dir: "b"}
    assert Config.new(original) == original

    config = Config.new(prefix: "Rusl", source_dir: "src", output_dir: "out")
    assert config.prefix == "Rusl"
    assert config.source_dir == "src"
    assert config.output_dir == "out"
  end
end
