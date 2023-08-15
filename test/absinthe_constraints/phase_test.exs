defmodule AbsintheConstraints.PhaseTest do
  use ExUnit.Case

  import AbsintheConstraints.Phase, only: [run: 2]

  # This is a simplified map of the actual struct that is passed to the phase.
  # This matches the structure of these structs:
  # Absinthe.Blueprint.Input.Field
  # Absinthe.Blueprint.Input.Argument
  @node %{
    name: "test",
    source_location: %Absinthe.Blueprint.SourceLocation{column: 0, line: 42},
    input_value: %{normalized: %{value: 123}},
    schema_node: %{__private__: [constraints: %{min: 2}]},
    errors: []
  }

  # This is a simplified map of the actual struct that is passed to the phase.
  @nested_node %Absinthe.Blueprint.Input.Argument{
    name: "coordinates",
    input_value: %Absinthe.Blueprint.Input.Value{
      schema_node: nil,
      raw: nil,
      normalized: %Absinthe.Blueprint.Input.Object{
        source_location: nil,
        fields: [
          %{
            name: "latitude",
            source_location: nil,
            input_value: %{normalized: %{value: 123}},
            schema_node: %{__private__: [constraints: %{min: -90, max: 90}]},
            errors: []
          },
          %{
            name: "longitude",
            source_location: nil,
            input_value: %{normalized: %{value: 45}},
            schema_node: %{__private__: [constraints: %{min: -90, max: 90}]},
            errors: []
          }
        ],
        flags: %{},
        schema_node: nil,
        errors: []
      },
      data: nil
    },
    source_location: %Absinthe.Blueprint.SourceLocation{
      line: 6,
      column: 8
    }
  }

  describe "handle_node/2" do
    test "returns unchanged node when validation passes" do
      assert run(@node, nil) == {:ok, @node}
    end

    test "returns node with an error when validation fails" do
      invalid_node = %{@node | input_value: %{normalized: %{value: 1}}}

      assert run(invalid_node, nil) ==
               {:ok,
                %{
                  invalid_node
                  | errors: [
                      %Absinthe.Phase.Error{
                        message: "\"test\" must be greater than or equal to 2",
                        phase: AbsintheConstraints.Phase,
                        locations: [%Absinthe.Blueprint.SourceLocation{line: 42, column: 0}],
                        extra: %{},
                        path: []
                      }
                    ]
                }}
    end

    test "returns node with an error with a location for input values" do
      updated_node =
        update_in(
          @nested_node,
          [
            Access.key(:input_value),
            Access.key(:normalized),
            Access.key(:fields),
            Access.filter(fn field -> field.name == "latitude" end)
          ],
          fn field ->
            %{
              field
              | errors: [
                  %Absinthe.Phase.Error{
                    message: "\"latitude\" must be less than or equal to 90",
                    phase: AbsintheConstraints.Phase,
                    locations: [%Absinthe.Blueprint.SourceLocation{line: 6, column: 8}],
                    extra: %{},
                    path: []
                  }
                ]
            }
          end
        )

      assert run(@nested_node, nil) == {:ok, updated_node}
    end
  end
end
