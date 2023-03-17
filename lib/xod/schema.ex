defprotocol Xod.Schema do
  @spec parse(t, term(), Xod.Common.path()) :: Xod.Common.result(term())
  def parse(schema, value, path)
end

defmodule Xod.Common do
  @type path() :: [binary() | non_neg_integer()]
  @type result(x) :: {:error, Xod.XodError.t()} | {:ok, x}
  @type type_atom() :: :map | :list | :tuple | :string | :number | :boolean | nil | :unknown

  @doc false
  @spec get_type(term()) :: type_atom()
  def get_type(value) do
    case value do
      x when is_map(x) -> :map
      x when is_list(x) -> :list
      x when is_tuple(x) -> :tuple
      x when is_binary(x) -> :string
      x when is_number(x) -> :number
      x when is_boolean(x) -> :boolean
      x when is_nil(x) -> nil
      _otherwise -> :unknown
    end
  end

  @doc false
  @spec kv_from_list(list()) :: [{atom() | non_neg_integer(), term()}]
  def kv_from_list(l) do
    Stream.with_index(l)
    |> Enum.map(fn {x, i} ->
      case x do
        {k, v} ->
          {k, v}

        other ->
          {i, other}
      end
    end)
  end

  defp set_field(field_name, type) do
    spec_call = {field_name, [], [quote(do: t()), type]}
    call = {field_name, [], [quote(do: schema), quote(do: value)]}

    quote do
      @spec unquote(spec_call) :: t()
      def(unquote(call), do: Map.put(schema, unquote(field_name), value))
    end
  end

  defmacro set_fields(fields) do
    {:__block__, [], Enum.map(fields, fn {k, t} -> set_field(k, t) end)}
  end
end
