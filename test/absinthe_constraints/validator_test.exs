defmodule AbsintheConstraints.ValidatorTest do
  use ExUnit.Case

  import AbsintheConstraints.Validator, only: [handle_constraint: 2]

  describe "handle_constraint/2" do
    test "should validate min" do
      assert handle_constraint({:min, 5}, 4) == ["must be greater than or equal to 5"]
      assert handle_constraint({:min, 5}, 5) == []
      assert handle_constraint({:min, 5}, 6) == []
      assert handle_constraint({:min, 5}, 6) == []
    end

    test "should validate max" do
      assert handle_constraint({:max, 5}, 4) == []
      assert handle_constraint({:max, 5}, 5) == []
      assert handle_constraint({:max, 5}, 6) == ["must be less than or equal to 5"]
    end

    test "should validate min_length" do
      assert handle_constraint({:min_length, 5}, "1234") == [
               "must be at least 5 characters in length"
             ]

      assert handle_constraint({:min_length, 5}, "12345") == []
      assert handle_constraint({:min_length, 5}, "123456") == []
    end

    test "should validate max_length" do
      assert handle_constraint({:max_length, 5}, "1234") == []
      assert handle_constraint({:max_length, 5}, "12345") == []

      assert handle_constraint({:max_length, 5}, "123456") == [
               "must be no more than 5 characters in length"
             ]
    end

    test "should validate format uuid" do
      assert handle_constraint({:format, "uuid"}, "1234") == ["must be a valid UUID"]
      assert handle_constraint({:format, "uuid"}, "12345678-1234-1234-1234-123456789012") == []

      assert handle_constraint({:format, "uuid"}, "12345678-1234-1234-1234-1234567890123") == [
               "must be a valid UUID"
             ]
    end

    test "should validate format email" do
      assert handle_constraint({:format, "email"}, "1234") == ["must be a valid email address"]
      assert handle_constraint({:format, "email"}, "email@example.com") == []
    end
  end
end
