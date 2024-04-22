defmodule AbsintheConstraints.Validator do
  @moduledoc """
  Defines all the constraint handlers for the `constraints` directive.
  """

  def handle_constraint({:min, min}, value) do
    if value < min,
      do: ["must be greater than or equal to #{min}"],
      else: []
  end

  def handle_constraint({:max, max}, value) do
    if value > max,
      do: ["must be less than or equal to #{max}"],
      else: []
  end

  def handle_constraint({:min_items, min_items}, value) do
    if length(value) < min_items,
      do: ["must have at least #{min_items} items"],
      else: []
  end

  def handle_constraint({:min_length, min_length}, value) when is_list(value) do
    value |> Enum.map(&handle_constraint({:min_length, min_length}, &1.data)) |> List.flatten()
  end

  def handle_constraint({:min_length, min_length}, value) do
    if String.length(value) < min_length,
      do: ["must be at least #{min_length} characters in length"],
      else: []
  end

  def handle_constraint({:max_items, max_items}, value) do
    if length(value) > max_items,
      do: ["must have no more than #{max_items} items"],
      else: []
  end

  def handle_constraint({:max_length, max_length}, value) when is_list(value) do
    value |> Enum.map(&handle_constraint({:max_length, max_length}, &1.data)) |> List.flatten()
  end

  def handle_constraint({:max_length, max_length}, value) do
    if String.length(value) > max_length,
      do: ["must be no more than #{max_length} characters in length"],
      else: []
  end

  def handle_constraint({:format, "uuid"}, value) when is_list(value) do
    value |> Enum.map(&handle_constraint({:format, "uuid"}, &1.data)) |> List.flatten()
  end

  def handle_constraint({:format, "uuid"}, value) do
    case UUID.info(value) do
      {:ok, _} -> []
      {:error, _} -> ["must be a valid UUID"]
    end
  end

  @email_regex ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

  def handle_constraint({:format, "email"}, value) when is_list(value) do
    value |> Enum.map(&handle_constraint({:format, "email"}, &1.data)) |> List.flatten()
  end

  def handle_constraint({:format, "email"}, value) do
    if String.match?(value, @email_regex),
      do: [],
      else: ["must be a valid email address"]
  end

  def handle_constraint({:pattern, regex}, value) when is_list(value) do
    value |> Enum.map(&handle_constraint({:pattern, regex}, &1.data)) |> List.flatten()
  end

  def handle_constraint({:pattern, regex}, value) do
    if String.match?(value, Regex.compile!(regex)),
      do: [],
      else: ["must match regular expression `#{regex}`"]
  end
end
