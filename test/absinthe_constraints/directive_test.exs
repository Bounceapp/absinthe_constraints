defmodule AbsintheConstraints.DirectiveTest do
  use ExUnit.Case

  alias Absinthe.Blueprint.TypeReference.List
  alias Absinthe.Blueprint.TypeReference.NonNull

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

  @non_null_node %{
    name: "feedback",
    identifier: :feedback,
    type: %NonNull{of_type: :string},
    __reference__: %{
      location: %{
        file: "/myapp/lib/types.ex",
        line: 42
      },
      module: Types
    },
    __private__: []
  }

  @list_node %{
    name: "feedback",
    identifier: :feedback,
    type: %List{of_type: :string},
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

    test "inserts constraints into NonNull fields" do
      assert expand_constraints(%{min_length: 2}, @non_null_node) == %{
               @non_null_node
               | __private__: [constraints: %{min_length: 2}]
             }
    end

    test "inserts constraints into List fields" do
      assert expand_constraints(%{min_items: 2}, @list_node) == %{
               @list_node
               | __private__: [constraints: %{min_items: 2}]
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
