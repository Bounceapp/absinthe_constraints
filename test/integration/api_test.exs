defmodule AbsintheConstraints.Integration.APITest do
  use ExUnit.Case, async: true

  describe "without a custom default resolver defined" do
    defmodule NormalSchema do
      use Absinthe.Schema

      @prototype_schema AbsintheConstraints.Directive

      input_object :input_object do
        field(:id, :string, directives: [constraints: [format: "uuid"]])
      end

      query do
        field :test, non_null(:string) do
          arg(:list, list_of(:integer), directives: [constraints: [min_items: 2]])
          arg(:number, :integer, directives: [constraints: [min: 2]])
          resolve(fn _, _ -> {:ok, "asdf"} end)
        end
      end

      mutation do
        field(:do_something, :string) do
          arg(:id, non_null(:string), directives: [constraints: [format: "uuid"]])
          arg(:id_obj, non_null(:input_object))

          resolve(fn _, _ -> {:ok, %{status: "ok"}} end)
        end
      end
    end

    test "should validate query arguments" do
      assert {:ok,
              %{
                errors: [
                  %{
                    message: "\"list\" must have at least 2 items",
                    locations: [%{line: 1, column: 8}]
                  },
                  %{
                    message: "\"number\" must be greater than or equal to 2",
                    locations: [%{line: 1, column: 19}]
                  }
                ]
              }} ==
               Absinthe.run("{ test(list: [1], number: 1) }", NormalSchema,
                 pipeline_modifier: &AbsintheConstraints.Phase.add_to_pipeline/2
               )
    end

    test "should validate mutation arguments" do
      assert {:ok,
              %{
                errors: [
                  %{message: "\"id\" must be a valid UUID", locations: [%{line: 1, column: 25}]},
                  %{message: "\"id\" must be a valid UUID", locations: [%{line: 1, column: 46}]}
                ]
              }} ==
               Absinthe.run(
                 "mutation { do_something(id: \"asdf\", id_obj: {id: \"123\"}) }",
                 NormalSchema,
                 pipeline_modifier: &AbsintheConstraints.Phase.add_to_pipeline/2
               )
    end
  end
end
