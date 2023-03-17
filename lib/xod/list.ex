defmodule Xod.List do
  alias Xod, as: X
  require X.Common

  @type t() :: %__MODULE__{
          element: X.Schema.t(),
          keys: %{(atom() | non_neg_integer()) => X.Schema.t()},
          min: non_neg_integer(),
          max: non_neg_integer(),
          length: non_neg_integer(),
          coerce: boolean()
        }

  @enforce_keys [:element]
  defstruct [:element, :keys, :min, :max, :length, coerce: true]

  @type args() :: [
          keys: list(),
          min: non_neg_integer(),
          max: non_neg_integer(),
          length: non_neg_integer(),
          coerce: boolean()
        ]

  @spec new(X.Schema.t(), args()) :: t()
  def new(element, options \\ []) when is_struct(element) do
    if not is_nil(options[:keys]) and not is_list(options[:keys]),
      do: raise("keys should be list")

    struct(%__MODULE__{element: element}, options) |> keys(options[:keys])
  end

  X.Common.set_fields(
    min: non_neg_integer(),
    max: non_neg_integer(),
    length: non_neg_integer()
  )

  @spec keys(t(), list()) :: t()
  def keys(schema, keys) do
    keys =
      with false <- is_nil(keys) do
        Enum.into(X.Common.kv_from_list(keys), %{})
      else
        _ -> nil
      end

    Map.put(schema, :keys, keys)
  end

  defimpl X.Schema do
    defp parse_item(item, i, nil, element, path),
      do: X.Schema.parse(element, item, List.insert_at(path, -1, i))

    defp parse_item({k, v}, i, keys, element, path) do
      string_to_atom = Map.keys(keys) |> Stream.map(&{to_string(&1), &1}) |> Enum.into(%{})
      schema = Map.get(keys, k, Map.get(keys, Map.get(string_to_atom, k), element))

      with {:ok, value} <- X.Schema.parse(schema, v, List.insert_at(path, -1, i)) do
        {:ok, {Map.get(string_to_atom, k, k), value}}
      end
    end

    defp parse_item(item, i, keys, element, path) do
      schema = Map.get(keys, i, element)
      X.Schema.parse(schema, item, List.insert_at(path, -1, i))
    end

    @impl true
    def parse(%X.List{coerce: false}, map, path) when is_map(map) do
      {:error, X.XodError.invalid_type(:list, :map, path)}
    end

    @impl true
    def parse(_, not_a_list, path) when not is_list(not_a_list) and not is_map(not_a_list) do
      {:error, X.XodError.invalid_type(:list, X.Common.get_type(not_a_list), path)}
    end

    @impl true
    @spec parse(X.List.t(), list(), X.Common.path()) :: X.Common.result(list())
    def parse(schema, value, path) do
      length_errors =
        [
          schema.max && length(value) > schema.max &&
            [
              type: :too_big,
              path: path,
              message: "List must contain at most #{schema.max} character(s)",
              data: [
                max: schema.max
              ]
            ],
          schema.min && length(value) < schema.min &&
            [
              type: :too_small,
              path: path,
              message: "List must contain at least #{schema.min} character(s)",
              data: [
                min: schema.min
              ]
            ],
          schema.length && length(value) !== schema.length &&
            [
              type: if(length(value) < schema.length, do: :too_small, else: :too_big),
              path: path,
              message: "List must contain exactly #{schema.length} character(s)",
              data: [
                equal: schema.length
              ]
            ]
        ]
        |> Enum.filter(&Function.identity/1)

      if length(length_errors) > 0 do
        {:error, %X.XodError{issues: length_errors}}
      else
        %{error: errors, ok: values} =
          value
          |> Stream.with_index()
          |> Stream.map(fn {x, i} -> parse_item(x, i, schema.keys, schema.element, path) end)
          |> Enum.group_by(&elem(&1, 0), fn val ->
            case val do
              {:ok, val} -> val
              {:error, %X.XodError{issues: issues}} -> issues
            end
          end)
          |> Map.put_new(:ok, [])
          |> Map.put_new(:error, [])

        if length(errors) > 0 do
          {:error, %X.XodError{issues: :lists.append(errors)}}
        else
          {:ok, values}
        end
      end
    end
  end
end
