defmodule AbsintheConstraints.Directive do
  @moduledoc """
  Defines a GraphQL directive to add constraints to field definitions and argument definitions.

  Example

  ```elixir
  input_object :my_input do
    field(:my_field, :integer, directives: [constraints: [min: 1]])
  end

  #...
  object :my_query do
    field :my_field, non_null(:string) do
      arg(:my_arg, non_null(:string), directives: [constraints: [format: "uuid"]])
      resolve(&MyResolver.resolve/2)
    end
  end
  ```
  """

  use Absinthe.Schema.Prototype

  alias Absinthe.Blueprint.TypeReference.List
  alias Absinthe.Blueprint.TypeReference.NonNull

  @string_args [:min_length, :max_length, :format, :pattern]
  @number_args [:min, :max]
  @list_args [:min_items, :max_items] ++ @string_args

  directive :constraints do
    on([:argument_definition, :field_definition])

    arg(:min, :integer, description: "Ensure value is greater than or equal to")
    arg(:max, :integer, description: "Ensure value is less than or equal to")

    arg(:format, :string, description: "Restricts the string to a specific format")
    arg(:pattern, :string, description: "Ensure value matches regex")

    arg(:min_length, :integer, description: "Restrict to a minimum length")
    arg(:max_length, :integer, description: "Restrict to a maximum length")

    arg(:min_items, :integer, description: "Restrict to a minimum number of items")
    arg(:max_items, :integer, description: "Restrict to a maximum number of items")

    expand(&__MODULE__.expand_constraints/2)
  end

  def expand_constraints(args, %{type: type} = node),
    do: do_expand(args, node, get_args(type))

  defp get_args(:string), do: @string_args
  defp get_args(:integer), do: @number_args
  defp get_args(:float), do: @number_args
  defp get_args(%List{}), do: @list_args
  defp get_args(%NonNull{of_type: of_type}), do: get_args(of_type)
  defp get_args(type), do: raise("Unsupported type: #{inspect(type)}")

  defp do_expand(args, node, args_list) do
    {valid_args, invalid_args} = Map.split(args, args_list)
    handle_invalid_args(node, invalid_args)

    update_node(valid_args, node)
  end

  defp handle_invalid_args(_, args) when args == %{}, do: nil

  defp handle_invalid_args(%{type: type, name: name} = node, invalid_args) do
    args = Map.keys(invalid_args)
    location_line = get_in(node.__reference__, [:location, :line])

    raise Absinthe.Schema.Error,
      phase_errors: [
        %Absinthe.Phase.Error{
          phase: __MODULE__,
          message:
            "Invalid constraints for field/arg `#{name}` of type `#{inspect(type)}`: #{inspect(args)}",
          locations: [%{line: location_line, column: 0}]
        }
      ]
  end

  defp update_node(args, node) do
    %{node | __private__: Keyword.put(node.__private__, :constraints, args)}
  end
end
