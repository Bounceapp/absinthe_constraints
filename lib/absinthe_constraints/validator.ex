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

  def handle_constraint({:min_length, min_length}, value) do
    if String.length(value) < min_length,
      do: ["must be at least #{min_length} characters in length"],
      else: []
  end

  def handle_constraint({:max_length, max_length}, value) do
    if String.length(value) > max_length,
      do: ["must be no more than #{max_length} characters in length"],
      else: []
  end

  def handle_constraint({:format, "uuid"}, value) do
    case UUID.info(value) do
      {:ok, _} -> []
      {:error, _} -> ["must be a valid UUID"]
    end
  end

  @email_regex ~r/^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/

  def handle_constraint({:format, "email"}, value) do
    if String.match?(value, @email_regex),
      do: [],
      else: ["must be a valid email address"]
  end
end
