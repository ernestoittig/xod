defmodule Tests.List do
  use ExUnit.Case, async: true
  alias Xod, as: X

  test "list invalid keys" do
    assert_raise RuntimeError, "keys should be list", fn -> X.keyword(%{}) end
  end

  test "list coerce" do
    assert X.parse(X.list(X.never()), %{}) == {:ok, []}

    assert X.parse(
             X.list(X.never(),
               keys: [
                 hour: X.number(),
                 minute: X.number()
               ]
             ),
             %{"hour" => 12, "minute" => 30}
           ) == {:ok, [hour: 12, minute: 30]}

    assert_raise X.XodError, "Expected list, got map (in path [])", fn ->
      X.parse!(X.list(X.never(), coerce: false), %{})
    end

    assert_raise X.XodError, "Expected list, got string (in path [])", fn ->
      X.parse!(X.list(X.never(), coerce: false), "any")
    end
  end
end
