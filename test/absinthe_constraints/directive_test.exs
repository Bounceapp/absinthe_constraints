defmodule AbsintheConstraints.DirectiveTest do
  use ExUnit.Case

  import AbsintheConstraints.Directive, only: [expand_constraints: 2]

  @node %{
    name: "feedback",
    identifier: :feedback,
    type: :string,
    __reference__: %{
      location: %{
        file: "/myapp/lib/types.ex",
        line: 42
      },
      module: Types
    },
    __private__: []
  }

  describe "expand_constraints/2" do
    test "inserts constraints into __private__ field" do
      assert expand_constraints(%{min_length: 2}, @node) == %{
               @node
               | __private__: [constraints: %{min_length: 2}]
             }
    end

    test "raises error on invalid constraint" do
      assert_raise Absinthe.Schema.Error,
                   """
                   Compilation failed:
                   ---------------------------------------
                   ## Locations
                   Column 0, Line 42

                   Invalid constraints for field/arg `feedback` of type `:string`: [:min]

                   """,
                   fn ->
                     expand_constraints(%{min: 2}, @node)
                   end
    end
  end
end
