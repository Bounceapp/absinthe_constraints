defmodule AbsintheConstraints.Integration.SDLTest do
  use ExUnit.Case, async: true

  describe "`use AbsintheConstraints` schema" do
    defmodule UseSchema do
      use Absinthe.Schema
      use AbsintheConstraints

      query do
        field :test, non_null(:string) do
          arg(:id, non_null(:string), directives: [constraints: [format: "uuid"]])
          resolve(fn _, _ -> {:ok, "ok"} end)
        end
      end
    end

    test "emits the @constraints directive declaration in SDL output" do
      sdl = Absinthe.Schema.to_sdl(UseSchema)

      assert sdl =~ ~r/directive @constraints\(/
      assert sdl =~ "ARGUMENT_DEFINITION"
      assert sdl =~ "FIELD_DEFINITION"
      assert sdl =~ "INPUT_FIELD_DEFINITION"
    end

    test "still uses the @constraints directive on arguments" do
      sdl = Absinthe.Schema.to_sdl(UseSchema)

      assert sdl =~ ~r/@constraints\(format: "uuid"\)/
    end
  end

  describe "legacy `@prototype_schema` setup" do
    defmodule PrototypeSchema do
      use Absinthe.Schema

      @prototype_schema AbsintheConstraints.Directive

      query do
        field :test, non_null(:string) do
          arg(:id, non_null(:string), directives: [constraints: [format: "uuid"]])
          resolve(fn _, _ -> {:ok, "ok"} end)
        end
      end
    end

    test "does NOT emit the @constraints directive declaration in SDL output" do
      # This is the upstream Absinthe behavior: the SDL renderer only walks the
      # main schema's directive_definitions and does not include prototype
      # directives. `use AbsintheConstraints` (which uses `import_directives`)
      # is the supported path for producing valid SDL.
      sdl = Absinthe.Schema.to_sdl(PrototypeSchema)

      refute sdl =~ ~r/directive @constraints\(/
    end
  end
end
