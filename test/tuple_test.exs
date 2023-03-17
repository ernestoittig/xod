defmodule Tests.Tuple do
  use ExUnit.Case, async: true

  test "tuple from list" do
    assert Xod.parse(
             Xod.tuple({Xod.number(), Xod.number()}),
             [5, 8]
           ) ==
             {:ok, {5, 8}}

    assert_raise Xod.XodError,
                 "Expected tuple, got list (in path [])",
                 fn ->
                   Xod.parse!(Xod.tuple({Xod.number(), Xod.number()}, coerce: false), [5, 8])
                 end
  end

  test "incorrect size tuples" do
    assert_raise Xod.XodError,
                 "Tuple must contain 2 element(s) (in path [])",
                 fn ->
                   Xod.parse!(Xod.tuple({Xod.number(), Xod.number()}), {})
                 end

    assert_raise Xod.XodError,
                 "Tuple must contain 2 element(s) (in path [])",
                 fn ->
                   Xod.parse!(Xod.tuple({Xod.number(), Xod.number()}), {1, 2, 3})
                 end
  end
end
