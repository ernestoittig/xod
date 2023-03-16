defmodule Xod do
  @moduledoc File.read!('README.md')

  @doc """
  Parses and validates `value` using the provided `schema`

  On success, returns `{:ok, value}` with the parsed value. 
  On error, returns `{:error, error}` where `error` is a `Xod.XodError`
  """
  @spec parse(Xod.Schema.t(), term()) :: Xod.Common.result(term())
  def parse(schema, value), do: Xod.Schema.parse(schema, value, [])

  @doc """
  Parses and validates `value` using the provided `schema`

  Like `Xod.parse/2`, but just returns the value and raises in case of a
  validation error.
  """
  @spec parse!(Xod.Schema.t(), term()) :: term()
  def parse!(schema, value) do
    case parse(schema, value) do
      {:ok, value} ->
        value

      {:error, err} ->
        raise err
    end
  end

end
