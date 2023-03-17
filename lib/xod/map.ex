defmodule Xod.Map do
  alias Xod, as: X
  require X.Common

  @type foreign_keys() :: :strip | :strict | :passthrough | X.Schema.t()

  @type t() :: %__MODULE__{
          keyval: %{optional(term()) => X.Schema.t()},
          foreign_keys: foreign_keys(),
          coerce: boolean(),
          key_coerce: boolean(),
          struct: module() | struct()
        }

  @enforce_keys [:keyval]
  defstruct [:keyval, :struct, foreign_keys: :strip, coerce: true, key_coerce: false]

  @spec new(%{optional(term()) => X.Schema.t()},
          foreign_keys: foreign_keys(),
          coerce: boolean(),
          key_coerce: boolean(),
          struct: module() | struct()
        ) ::
          %__MODULE__{}
  def new(map, opts \\ []) when is_map(map) do
    struct(%__MODULE__{keyval: map}, opts)
  end

  @spec shape(t()) :: %{optional(term()) => X.Schema.t()}
  def shape(schema), do: schema.keyval

  @spec check_all(t(), X.Schema.t()) :: t()
  def check_all(schema, check), do: Map.put(schema, :foreign_keys, check)

  defimpl Xod.Schema do
    alias Xod, as: X

    defp from_list(l) do
      Enum.into(X.Common.kv_from_list(l), %{})
    end

    defp get_key(m, a) do
      Map.get(m, a, Map.get(m, to_string(a)))
    end

    defp del_key(m, a) do
      Map.drop(m, [a, to_string(a)])
    end

    @impl true
    def parse(%X.Map{coerce: false}, list, path) when is_list(list) do
      {:error, X.XodError.invalid_type(:map, :list, path)}
    end

    @impl true
    def parse(_, not_a_map, path) when not is_map(not_a_map) and not is_list(not_a_map) do
      {:error, X.XodError.invalid_type(:map, X.Common.get_type(not_a_map), path)}
    end

    @impl true
    def parse(schema, map, path) do
      map = if(is_list(map), do: from_list(map), else: map)
      get = if(schema.key_coerce, do: &get_key/2, else: &Map.get/2)
      drop = if(schema.key_coerce, do: &del_key/2, else: &Map.drop(&1, [&2]))

      {parsed, mapLeft, errors} =
        Enum.reduce(
          schema.keyval,
          {%{}, map, []},
          fn {key, schema}, {parsed, mapLeft, errors} ->
            res = X.Schema.parse(schema, get.(mapLeft, key), List.insert_at(path, -1, key))

            case res do
              {:error, err} ->
                {parsed, drop.(mapLeft, key), List.insert_at(errors, -1, err)}

              {:ok, val} ->
                {Map.put(parsed, key, val), drop.(mapLeft, key), errors}
            end
          end
        )

      {extraParsed, _, extraErrors} =
        if is_struct(schema.foreign_keys) do
          Enum.reduce(
            mapLeft,
            {%{}, map, []},
            fn {key, value}, {parsed, mapLeft, errors} ->
              res = X.Schema.parse(schema.foreign_keys, value, List.insert_at(path, -1, key))

              case res do
                {:error, err} ->
                  {parsed, drop.(mapLeft, key), List.insert_at(errors, -1, err)}

                {:ok, val} ->
                  {Map.put(parsed, key, val), drop.(mapLeft, key), errors}
              end
            end
          )
        else
          {%{}, nil, []}
        end

      parsed = Map.merge(parsed, extraParsed)
      errors = errors ++ extraErrors

      parsed =
        unless(is_nil(schema.struct),
          do: struct(schema.struct, parsed),
          else: parsed
        )

      case {errors, schema.foreign_keys} do
        {[], :passthrough} ->
          {:ok, Map.merge(parsed, mapLeft)}

        {[], :strict} ->
          case mapLeft do
            left when map_size(left) == 0 ->
              {:ok, parsed}

            left ->
              {:error,
               %X.XodError{
                 issues: [
                   [
                     type: :unrecognized_keys,
                     path: path,
                     data: [keys: Map.keys(left)],
                     message:
                       "Unrecognized key(s) in map: #{Enum.map_join(Map.keys(left), ", ", &inspect(&1))}"
                   ]
                 ]
               }}
          end

        {[], k} when k == :strip or is_struct(k) ->
          {:ok, parsed}

        {errors, _} ->
          {:error, %X.XodError{issues: Enum.map(errors, & &1.issues) |> :lists.append()}}
      end
    end
  end
end
