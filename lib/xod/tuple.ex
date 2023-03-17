defmodule Xod.Tuple do
  @type t() :: %__MODULE__{values: tuple()}

  @enforce_keys [:values]
  defstruct [:values, coerce: true]

  @spec new(tuple(), coerce: true) :: t()
  def new(values, opts \\ []), do: struct(%__MODULE__{values: values}, opts)

  defimpl Xod.Schema do
    alias Xod, as: X

    @impl true
    def parse(%X.Tuple{coerce: false}, values, path) when is_list(values) do
      {:error, X.XodError.invalid_type(:tuple, :list, path)}
    end

    @impl true
    def parse(_, values, path) when not is_tuple(values) and not is_list(values) do
      {:error, X.XodError.invalid_type(:tuple, X.Common.get_type(values), path)}
    end

    @impl true
    def parse(schema, values, path) do
      %Xod.Tuple{values: schemata} = schema
      values = if is_tuple(values), do: Tuple.to_list(values), else: values

      try do
        Tuple.to_list(schemata)
        |> Stream.with_index()
        |> Enum.reduce({[], [], values}, fn {x, i}, {values, errors, remaining} ->
          case X.Schema.parse(x, hd(remaining), List.insert_at(path, -1, i)) do
            {:ok, v} ->
              {List.insert_at(values, -1, v), errors, tl(remaining)}

            {:error, err} ->
              {values, List.insert_at(errors, -1, err.issues), tl(remaining)}
          end
        end)
      rescue
        ArgumentError ->
          {:error,
           %X.XodError{
             issues: [
               [
                 code: :too_small,
                 path: path,
                 message: "Tuple must contain #{tuple_size(schemata)} element(s)",
                 data: [
                   equal: tuple_size(schemata)
                 ]
               ]
             ]
           }}
      else
        {values, [], []} ->
          {:ok, List.to_tuple(values)}

        {_, errors, []} ->
          {:error, %X.XodError{issues: :lists.append(errors)}}

        {_, _, _} ->
          {:error,
           %X.XodError{
             issues: [
               [
                 code: :too_big,
                 path: path,
                 message: "Tuple must contain #{tuple_size(schemata)} element(s)",
                 data: [
                   equal: tuple_size(schemata)
                 ]
               ]
             ]
           }}
      end
    end
  end
end
