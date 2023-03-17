defmodule Tests.Map do
  use ExUnit.Case, async: true
  alias Xod, as: X

  test "map wrong type" do
    assert_raise(X.XodError, "Expected map, got number (in path [])", fn ->
      X.parse!(X.map(%{}), 13.0)
    end)

    assert X.parse!(X.map(%{0 => X.string(), a: X.number()}), ["test", a: 13.0]) == %{
             0 => "test",
             a: 13.0
           }

    assert_raise(X.XodError, "Expected map, got list (in path [])", fn ->
      X.parse!(X.map(%{}, coerce: false), [])
    end)
  end

  test "map key types" do
    assert_raise(X.XodError, "Expected number, got nil (in path [:x])", fn ->
      X.parse!(X.map(%{x: X.number()}), %{
        "x" => 13.0
      })
    end)

    assert X.parse(X.map(%{12 => X.string()}), %{12 => "abc"}) == {:ok, %{12 => "abc"}}

    assert X.parse!(
             X.map(
               %{
                 4 => X.string(),
                 "y" => X.number(),
                 x: X.number()
               },
               key_coerce: true
             ),
             %{
               4 => "abc",
               "y" => 15.0,
               "x" => 13.0
             }
           ) == %{
             4 => "abc",
             "y" => 15.0,
             x: 13.0
           }

    assert X.parse!(X.map(%{x: X.number()}, key_coerce: true), %{"x" => 15.0, x: 13.0}) == %{
             x: 13.0
           }
  end

  test "map foreign keys" do
    assert X.parse!(X.map(%{}), %{a: "b"}) == %{}

    assert_raise(X.XodError, "Unrecognized key(s) in map: :a (in path [])", fn ->
      X.parse!(X.map(%{}, foreign_keys: :strict), %{a: "b"})
    end)

    assert X.parse!(X.map(%{a: X.string()}, foreign_keys: :strict), %{a: "b"}) == %{a: "b"}

    assert X.parse!(X.map(%{}, foreign_keys: :passthrough), %{a: "b"}) == %{a: "b"}

    assert X.parse!(X.map(%{}, foreign_keys: X.string()), %{a: "b"}) == %{a: "b"}
  end

  defmodule MockStruct do
    defstruct [:a, :b]
  end

  test "map into struct" do
    assert X.parse!(X.map(%{}, struct: MockStruct), %{}) == %MockStruct{a: nil, b: nil}

    assert X.parse!(X.map(%{b: X.number()}, struct: MockStruct), %{b: 13.0}) == %MockStruct{
             a: nil,
             b: 13.0
           }

    assert X.parse!(X.map(%{b: X.number()}, struct: %MockStruct{a: 11}), %{b: 13.0}) ==
             %MockStruct{a: 11, b: 13.0}
  end
end
