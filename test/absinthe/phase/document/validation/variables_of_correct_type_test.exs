defmodule Absinthe.Phase.Document.Validation.VariablesOfCorrectTypeTest do
  @phase Absinthe.Phase.Document.Arguments.VariableTypesMatch

  import ExUnit.CaptureLog

  use Absinthe.ValidationPhaseCase, async: true, phase: @phase

  test "types of variables does not match types of arguments" do
    fun = fn ->
      Absinthe.run(
        """
        query test($intArg: Int!) {
          complicatedArgs {
            stringArgField(stringArg: $intArg)
          }
        }
        """,
        Absinthe.Fixtures.PetsSchema,
        variables: %{"intArg" => 5}
      )
    end

    assert capture_log([level: :warn], fun) =~
             "In operation `test, variable `$intArg` of type `Int` found as input to argument of type `String`."
  end

  test "variable type check handles non existent type" do
    {:ok, %{errors: errors}} =
      Absinthe.run(
        """
        query test($intArg: DoesNotExist!) {
          complicatedArgs {
            stringArgField(stringArg: $intArg)
          }
        }
        """,
        Absinthe.Fixtures.PetsSchema,
        variables: %{"intArg" => 5}
      )

    expected_error_msg = "Argument \"stringArg\" has invalid value $intArg."
    assert expected_error_msg in (errors |> Enum.map(& &1.message))
  end

  test "types of variables does not match types of arguments even when the value is null" do
    fun = fn ->
      Absinthe.run(
        """
        query test($intArg: Int) {
          complicatedArgs {
            stringArgField(stringArg: $intArg)
          }
        }
        """,
        Absinthe.Fixtures.PetsSchema,
        variables: %{"intArg" => nil}
      )
    end

    assert capture_log([level: :warn], fun) =~
             "In operation `test, variable `$intArg` of type `Int` found as input to argument of type `String`."
  end

  test "types of variables does not match types of arguments in named fragments" do
    fun = fn ->
      Absinthe.run(
        """
        query test($intArg: Int) {
          complicatedArgs {
            ...Fragment
          }
        }

        fragment Fragment on ComplicatedArgs {
          stringArgField(stringArg: $intArg)
        }
        """,
        Absinthe.Fixtures.PetsSchema,
        variables: %{"intArg" => 5}
      )
    end

    assert capture_log([level: :warn], fun) =~
             "In operation `test, variable `$intArg` of type `Int` found as input to argument of type `String`."
  end
end
