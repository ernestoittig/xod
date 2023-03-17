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

  # Schemas
  # =======

  @doc """
  Schema for validating strings

  It accepts the following options:

   - `validate` :: `t:boolean()` — Check string is valid UTF-8, defaults to `true`
   - `max` :: `t:non_neg_integer()` — Max length of the string (inclusive)
   - `min` :: `t:non_neg_integer()` — Min length of the string (inclusive)
   - `length` :: `t:non_neg_integer()` — Exact length of the string
   - `regex` :: `t:Regex.t()` — Regular expression the string must match

  ## Examples

      iex> Xod.parse Xod.string(), "foo bar"
      {:ok, "foo bar"}
      
      iex> Xod.parse! Xod.string(), 13.0
      ** (Xod.XodError) Expected string, got number (in path [])
  """
  @doc section: :schemas
  @spec string(Xod.String.args()) :: Xod.String.t()
  defdelegate string(opts \\ []), to: Xod.String, as: :new

  # Modifiers
  # =========

  @doc """
  Set the `validate` option on a string schema

  See: `Xod.string/1`

  ## Example

      iex> Xod.parse!(Xod.string() |> Xod.validate(false), <<0xFFFF::16>>)
      <<0xFFFF::16>>
  """
  @doc section: :mods
  @spec validate(Xod.String.t(), boolean()) :: Xod.String.t()
  defdelegate validate(schema, value), to: Xod.String

  @doc """
  Set the `max` option on a string schema

  See: `Xod.string/1`

  ## Example

      iex> Xod.parse!(Xod.string() |> Xod.max(4), "12345")
      ** (Xod.XodError) String must contain at most 4 character(s) (in path [])
  """
  @doc section: :mods
  @spec max(Xod.String.t(), non_neg_integer()) :: Xod.String.t()
  defdelegate max(schema, value), to: Xod.String

  @doc """
  Set the `min` option on a string schema

  See: `Xod.string/1`

  ## Example

      iex> Xod.parse!(Xod.string() |> Xod.min(5), "1234")
      ** (Xod.XodError) String must contain at least 5 character(s) (in path [])
  """
  @doc section: :mods
  @spec min(Xod.String.t(), non_neg_integer()) :: Xod.String.t()
  defdelegate min(schema, value), to: Xod.String

  @doc """
  Set the `length` option on a string schema

  See: `Xod.string/1`

  ## Example

      iex> Xod.parse!(Xod.string() |> Xod.length(5), "1234")
      ** (Xod.XodError) String must contain exactly 5 character(s) (in path [])
      
      iex> Xod.parse!(Xod.string() |> Xod.length(3), "1234")
      ** (Xod.XodError) String must contain exactly 3 character(s) (in path [])
  """
  @doc section: :mods
  @spec length(Xod.String.t(), non_neg_integer()) :: Xod.String.t()
  defdelegate length(schema, value), to: Xod.String

  @doc """
  Set the `regex` option on a string schema

  See: `Xod.string/1`

  ## Example

      iex> Xod.parse!(Xod.string() |> Xod.regex(~r/ab*c?d/), "abbczz")
      ** (Xod.XodError) Invalid string: regex didn't match (in path [])
  """
  @doc section: :mods
  @spec regex(Xod.String.t(), Regex.t()) :: Xod.String.t()
  defdelegate regex(schema, value), to: Xod.String
end
