defmodule AbsintheConstraints.Phase do
  @moduledoc """
  Defines an Absinthe Document Phase that validates inputs against constraints defined by the `constraints` directive.

  Use add_to_pipeline/2 to add this phase to your Absinthe pipeline.
  """
  use Absinthe.Phase

  alias Absinthe.Blueprint

  alias AbsintheConstraints.Validator

  def add_to_pipeline(pipeline, opts) do
    Absinthe.Pipeline.insert_before(
      pipeline,
      Absinthe.Phase.Document.Validation.Result,
      {__MODULE__, opts}
    )
  end

  @impl Absinthe.Phase
  def run(blueprint, _opts) do
    # We use postwalk instead of prewalk in order to append the location to errors in input object fields.
    result = Blueprint.postwalk(blueprint, &handle_node/1)
    {:ok, result}
  end

  # This matches: Absinthe.Blueprint.Input.Argument
  # We handle this node in order to append the location to errors in input field coming from query variables.
  # This also requires a postwalk, in order to first handle each input object field separately without the location,
  # and then append the location to every error that doesn't have one.
  defp handle_node(
         %{
           input_value: %{
             normalized: %Absinthe.Blueprint.Input.Object{fields: _}
           },
           source_location: source_location
         } = node
       ) do
    update_in(
      node,
      [
        Access.key(:input_value),
        Access.key(:normalized),
        Access.key(:fields),
        Access.all(),
        Access.key(:errors),
        Access.all(),
        Access.key(:locations)
      ],
      fn
        locations when is_nil(locations) or locations == [] ->
          locations ++ [source_location]

        locations ->
          locations
      end
    )
  end

  # Handles the same nodes as below but for Lists
  # TODO: We could also validate the items inside lists with other constraints.
  defp handle_node(
         %{
           input_value: %{normalized: %Absinthe.Blueprint.Input.List{items: value}},
           schema_node: %{__private__: private}
         } = node
       ),
       do: handle_node_value(node, value, private)

  # Handles the following nodes:
  # Absinthe.Blueprint.Input.Field
  # Absinthe.Blueprint.Input.Argument
  defp handle_node(
         %{
           input_value: %{normalized: %{value: value}},
           schema_node: %{__private__: private}
         } = node
       ),
       do: handle_node_value(node, value, private)

  # Handle all other nodes
  defp handle_node(node), do: node

  defp handle_node_value(node, value, private) do
    Keyword.get(private, :constraints, [])
    |> Enum.flat_map(&handle_constraint(&1, value, node))
    |> Enum.reduce(node, &Absinthe.Phase.put_error(&2, &1))
  end

  defp handle_constraint(config, value, node) do
    Validator.handle_constraint(config, value)
    |> make_errors(node)
  end

  defp make_errors(error_messages, %{name: name, source_location: source_location}) do
    error_messages
    |> Enum.map(fn message ->
      %Absinthe.Phase.Error{
        phase: __MODULE__,
        message: "\"#{name}\" #{message}",
        locations: List.wrap(source_location)
      }
    end)
  end
end
