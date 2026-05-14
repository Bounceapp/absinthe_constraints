defmodule AbsintheConstraints do
  @moduledoc """
  Adds the `@constraints` directive to your Absinthe schema.

  ## Usage

      defmodule MyAppWeb.Schema do
        use Absinthe.Schema
        use AbsintheConstraints

        # ...
      end

  This imports the `@constraints` directive declaration into your schema. The
  declaration is then included in `mix absinthe.schema.sdl` output, so the
  generated SDL is valid GraphQL that downstream tooling can parse.

  Constraint validation still runs as a document phase that has to be added to
  your Absinthe pipeline; see `AbsintheConstraints.Phase.add_to_pipeline/2`.
  """

  defmacro __using__(_opts) do
    quote do
      @prototype_schema AbsintheConstraints.Directive
      import_directives(AbsintheConstraints.Directive)
    end
  end
end
