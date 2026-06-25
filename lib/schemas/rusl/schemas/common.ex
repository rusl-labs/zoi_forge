defmodule ZoiForge.Schemas.Rusl.Schemas.Common do
  @raw_schema "{\"$defs\":{\"account-slug\":{\"description\":\"A URL-safe account identifier\",\"maxLength\":25,\"minLength\":3,\"pattern\":\"^[A-Za-z0-9][A-Za-z0-9\\\\-]*$\",\"type\":\"string\"},\"schema-ref\":{\"description\":\"A schema reference in 'account-slug/schemas/schema-slug' format\",\"pattern\":\"^[A-Za-z0-9][A-Za-z0-9\\\\-]*/schemas/[A-Za-z0-9][A-Za-z0-9\\\\-]*$\",\"type\":\"string\"},\"schema-slug\":{\"description\":\"A URL-safe schema identifier\",\"maxLength\":100,\"minLength\":1,\"pattern\":\"^[A-Za-z0-9][A-Za-z0-9\\\\-]*$\",\"type\":\"string\"},\"semver-requirement\":{\"description\":\"A semantic version requirement string (e.g. '~> 1.0', '>= 2.0.0', '== 1.2.3')\",\"minLength\":1,\"type\":\"string\"}},\"$id\":\"https://resources.rusl.com/resources/rusl/schemas/common\",\"$schema\":\"https://json-schema.org/draft/2020-12/schema\",\"description\":\"Reusable definitions for rusl identifiers, slugs, and version requirements.\",\"title\":\"Common Definitions\",\"version\":\"0.1.0\"}"
  @moduledoc """
  Configuration for Common.

  Reusable definitions for rusl identifiers, slugs, and version requirements.
  """

  @doc "Returns the raw JSON schema string."
  def raw_schema, do: @raw_schema

  defmodule AccountSlug do
    @raw_schema "{\"description\":\"A URL-safe account identifier\",\"maxLength\":25,\"minLength\":3,\"pattern\":\"^[A-Za-z0-9][A-Za-z0-9\\\\-]*$\",\"type\":\"string\"}"
    @schema Zoi.from_json_schema(Jason.decode!(@raw_schema))

    @moduledoc """
    Configuration for AccountSlug.

    A URL-safe account identifier
    """

    @type t :: unquote(Zoi.type_spec(@schema))

    @doc "Returns the parsed Zoi schema structure."
    def schema, do: @schema

    @doc "Returns the raw JSON schema string."
    def raw_schema, do: @raw_schema

    @doc "Validates data against the schema structure."
    def parse(data), do: Zoi.parse(@schema, data)
  end

  defmodule SchemaRef do
    @raw_schema "{\"description\":\"A schema reference in 'account-slug/schemas/schema-slug' format\",\"pattern\":\"^[A-Za-z0-9][A-Za-z0-9\\\\-]*/schemas/[A-Za-z0-9][A-Za-z0-9\\\\-]*$\",\"type\":\"string\"}"
    @schema Zoi.from_json_schema(Jason.decode!(@raw_schema))

    @moduledoc """
    Configuration for SchemaRef.

    A schema reference in 'account-slug/schemas/schema-slug' format
    """

    @type t :: unquote(Zoi.type_spec(@schema))

    @doc "Returns the parsed Zoi schema structure."
    def schema, do: @schema

    @doc "Returns the raw JSON schema string."
    def raw_schema, do: @raw_schema

    @doc "Validates data against the schema structure."
    def parse(data), do: Zoi.parse(@schema, data)
  end

  defmodule SchemaSlug do
    @raw_schema "{\"description\":\"A URL-safe schema identifier\",\"maxLength\":100,\"minLength\":1,\"pattern\":\"^[A-Za-z0-9][A-Za-z0-9\\\\-]*$\",\"type\":\"string\"}"
    @schema Zoi.from_json_schema(Jason.decode!(@raw_schema))

    @moduledoc """
    Configuration for SchemaSlug.

    A URL-safe schema identifier
    """

    @type t :: unquote(Zoi.type_spec(@schema))

    @doc "Returns the parsed Zoi schema structure."
    def schema, do: @schema

    @doc "Returns the raw JSON schema string."
    def raw_schema, do: @raw_schema

    @doc "Validates data against the schema structure."
    def parse(data), do: Zoi.parse(@schema, data)
  end

  defmodule SemverRequirement do
    @raw_schema "{\"description\":\"A semantic version requirement string (e.g. '~> 1.0', '>= 2.0.0', '== 1.2.3')\",\"minLength\":1,\"type\":\"string\"}"
    @schema Zoi.from_json_schema(Jason.decode!(@raw_schema))

    @moduledoc """
    Configuration for SemverRequirement.

    A semantic version requirement string (e.g. '~> 1.0', '>= 2.0.0', '== 1.2.3')
    """

    @type t :: unquote(Zoi.type_spec(@schema))

    @doc "Returns the parsed Zoi schema structure."
    def schema, do: @schema

    @doc "Returns the raw JSON schema string."
    def raw_schema, do: @raw_schema

    @doc "Validates data against the schema structure."
    def parse(data), do: Zoi.parse(@schema, data)
  end
end
