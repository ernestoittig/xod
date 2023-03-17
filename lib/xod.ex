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

  # Schemata
  # =======

  @doc """
  Schema for validating strings

  It accepts the following options:

   - `validate` :: `t:boolean/0` — Check string is valid UTF-8, defaults to `true`
   - `max` :: `t:non_neg_integer/0` — Max length of the string (inclusive)
   - `min` :: `t:non_neg_integer/0` — Min length of the string (inclusive)
   - `length` :: `t:non_neg_integer/0` — Exact length of the string
   - `regex` :: `t:Regex.t/0` — Regular expression the string must match

  ## Examples

      iex> Xod.parse Xod.string(), "foo bar"
      {:ok, "foo bar"}
      
      iex> Xod.parse! Xod.string(), 13.0
      ** (Xod.XodError) Expected string, got number (in path [])
  """
  @doc section: :schemas
  @spec string(Xod.String.args()) :: Xod.String.t()
  defdelegate string(opts \\ []), to: Xod.String, as: :new

  @doc """
  Schema for validating numbers

  It accepts the following options:

    - lt :: `t:number/0` — Check number is less than value
    - le :: `t:number/0` — Check number is less than or equal to value
    - gt :: `t:number/0` — Check number is greater than value
    - ge :: `t:number/0` — Check number is greater than or equal to value
    - int :: `t:boolean/0` — Whether number must be integer, defaults to `false`
    - step :: `t:integer/0` — Check number is multiple of value. Implies `int`

  ## Examples

      iex> Xod.parse Xod.number(), 175.3
      {:ok, 175.3}
      
      iex> Xod.parse! Xod.number(), nil
      ** (Xod.XodError) Expected number, got nil (in path [])
  """
  @doc section: :schemas
  defdelegate number(opts \\ []), to: Xod.Number, as: :new

  @doc """
  Schema for validationg booleans

  It accepts the following options:
    - `coerce` :: `t:boolean/0` — Coerce truthy or falsy values to boolean, defaults to `false`

  ## Examples

      iex> Xod.parse Xod.boolean(), true
      {:ok, true}
      
      iex> Xod.parse! Xod.boolean(), {3.0, "abc"}
      ** (Xod.XodError) Expected boolean, got tuple (in path [])
  """
  @doc section: :schemas
  defdelegate boolean(opts \\ []), to: Xod.Boolean, as: :new

  @doc """
  Schema for validating tuples

  Must pass argument, which is a tuple of other schemata

  It accepts the following options:
    - `coerce` :: `t:boolean/0` — Coerce lists into tuples, defaults to `true`

  ## Examples

      iex> Xod.parse Xod.tuple({Xod.number(), Xod.number()}), {5, 8}
      {:ok, {5, 8}}
      
      iex> Xod.parse! Xod.tuple({Xod.number(), Xod.number()}), %{0 => 5, 1 => 8}
      ** (Xod.XodError) Expected tuple, got map (in path [])
      
      iex> Xod.parse! Xod.tuple({Xod.number(), Xod.number()}), {1, []}
      ** (Xod.XodError) Expected number, got list (in path [1])
  """
  @doc section: :schemas
  defdelegate tuple(schemata, opts \\ []), to: Xod.Tuple, as: :new

  @doc """
  Schema for validating maps

  Must pass an argument, which is a map values to schemata.

  It accepts the following options:
    - `foreign_keys` :: `t:Xod.Map.foreign_keys/0` — This option determines
    what happens when there are unknown keys in the map. If set to :strip, the
    entries are dropped; if set to :strict, an error is returned; if set to
    passthrough, the entries are included _as is_; and if set to a schema, it is
    used to parse and validate each entry.
    - `coerce` :: `t:boolean/0` — If true, when a list is parsed, it is
    converted to a map using the following algorithm: if an item is a 2-tuple,
    it is included as a key-value pair; if not, the index is used as key.
    Defaults to `true`
    - `key_coerce` :: `t:boolean/0` — If true, not only are the passed keys
    checked, but also their string representations. This is useful to transform
    string keys into atom keys without creating atoms at runtime. Defaults to
    false
    - `struct` :: `t:module/0` | `t:struct/0` — If provided, map will be
    converted to struct after parsing

  ## Examples

      iex> Xod.parse(
      ...>   Xod.map(%{my_key: Xod.number(), other: Xod.string()}, key_coerce: true),
      ...>   %{"my_key" => 13, other: "bar baz"})
      {:ok, %{my_key: 13, other: "bar baz"}}
      
      iex> Xod.parse! Xod.map(%{x: Xod.number()}), %{x: true}
      ** (Xod.XodError) Expected number, got boolean (in path [:x])
  """
  @doc section: :schemas
  defdelegate map(map, options \\ []), to: Xod.Map, as: :new

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

  @doc """
  Set the `lt` option on a number schema

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.lt(10), 10)
      ** (Xod.XodError) Number must be smaller than 10 (in path [])
  """
  @doc section: :mods
  @spec lt(Xod.Number.t(), number()) :: Xod.Number.t()
  defdelegate lt(schema, value), to: Xod.Number

  @doc """
  Set the `gt` option on a number schema

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.gt(10), 10)
      ** (Xod.XodError) Number must be greater than 10 (in path [])
  """
  @doc section: :mods
  @spec gt(Xod.Number.t(), number()) :: Xod.Number.t()
  defdelegate gt(schema, value), to: Xod.Number

  @doc """
  Set the `le` option on a number schema

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.le(10), 11)
      ** (Xod.XodError) Number must be smaller than or equal to 10 (in path [])
  """
  @doc section: :mods
  @spec le(Xod.Number.t(), number()) :: Xod.Number.t()
  defdelegate le(schema, value), to: Xod.Number

  @doc """
  Set the `ge` option on a number schema

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.ge(10), 9)
      ** (Xod.XodError) Number must be greater than or equal to 10 (in path [])
  """
  @doc section: :mods
  @spec ge(Xod.Number.t(), number()) :: Xod.Number.t()
  defdelegate ge(schema, value), to: Xod.Number

  @doc """
  Set the `int` option on a number schema

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.int(true), 11.5)
      ** (Xod.XodError) Expected integer, got float (in path [])
  """
  @doc section: :mods
  @spec int(Xod.Number.t(), boolean()) :: Xod.Number.t()
  defdelegate int(schema, value), to: Xod.Number

  @doc """
  Set the `step` option on a number schema

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.step(2), 11)
      ** (Xod.XodError) Number must be multiple of 2 (in path [])
  """
  @doc section: :mods
  @spec step(Xod.Number.t(), integer()) :: Xod.Number.t()
  defdelegate step(schema, value), to: Xod.Number

  @doc """
  Changes a number schema to only match positive values

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.positive(), 0)
      ** (Xod.XodError) Number must be greater than 0 (in path [])
  """
  @doc section: :mods
  @spec positive(Xod.Number.t()) :: Xod.Number.t()
  defdelegate positive(schema), to: Xod.Number

  @doc """
  Changes a number schema to only match non-negative values

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.nonnegative(), -1)
      ** (Xod.XodError) Number must be greater than or equal to 0 (in path [])
  """
  @doc section: :mods
  @spec nonnegative(Xod.Number.t()) :: Xod.Number.t()
  defdelegate nonnegative(schema), to: Xod.Number

  @doc """
  Changes a number schema to only match negative values

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.negative(), 0)
      ** (Xod.XodError) Number must be smaller than 0 (in path [])
  """
  @doc section: :mods
  @spec negative(Xod.Number.t()) :: Xod.Number.t()
  defdelegate negative(schema), to: Xod.Number

  @doc """
  Changes a number schema to only match non-positive values

  See: `Xod.number/1`

  ## Example

      iex> Xod.parse!(Xod.number() |> Xod.nonpositive(), 1)
      ** (Xod.XodError) Number must be smaller than or equal to 0 (in path [])
  """
  @doc section: :mods
  @spec nonpositive(Xod.Number.t()) :: Xod.Number.t()
  defdelegate nonpositive(schema), to: Xod.Number

  @doc """
  Gets the underlying schema map

  ## Example

      iex> my_schema = Xod.map %{x: Xod.boolean()}
      iex> Xod.shape my_schema
      %{x: %Xod.Boolean{}}
  """
  @doc section: :mods
  @spec shape(Xod.Map.t()) :: map()
  defdelegate shape(schema), to: Xod.Map

  @doc """
  Sets the `foreign_keys` option of the map to the provided schema

  See: `Xod.map/2`

  ## Example

      iex> my_schema = Xod.map(%{}) |> Xod.check_all(Xod.number())
      iex> Xod.parse!(my_schema, %{key: "abc"})
      ** (Xod.XodError) Expected number, got string (in path [:key])
  """
  @doc section: :mods
  @spec check_all(Xod.Map.t(), Xod.Schema.t()) :: map()
  defdelegate check_all(schema, check), to: Xod.Map
end
