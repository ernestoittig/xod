defmodule Xod.String do
  alias Xod, as: X
  require X.Common

  @type t() :: %__MODULE__{
          validate: boolean(),
          max: non_neg_integer(),
          min: non_neg_integer(),
          length: non_neg_integer(),
          regex: Regex.t()
        }

  defstruct [:max, :min, :length, :regex, validate: true]

  @type args() :: [
          validate: boolean(),
          max: non_neg_integer(),
          min: non_neg_integer(),
          length: non_neg_integer(),
          regex: Regex.t()
        ]

  @spec new(args()) :: t()
  def new(opts \\ []) do
    struct(__MODULE__, opts)
  end

  X.Common.set_fields(
    validate: boolean(),
    max: non_neg_integer(),
    min: non_neg_integer(),
    length: non_neg_integer(),
    regex: Regex.t()
  )
end

defimpl Xod.Schema, for: Xod.String do
  alias Xod, as: X

  @impl true
  def parse(_, not_a_string, path) when not is_binary(not_a_string) do
    {:error, X.XodError.invalid_type(:string, X.Common.get_type(not_a_string), path)}
  end

  @impl true
  @spec parse(X.String.t(), String.t(), X.Common.path()) :: X.Common.result(String.t())
  def parse(schema, value, path) do
    errors =
      [
        schema.max && String.length(value) > schema.max &&
          [
            type: :too_big,
            path: path,
            message: "String must contain at most #{schema.max} character(s)",
            data: [
              max: schema.max
            ]
          ],
        schema.min && String.length(value) < schema.min &&
          [
            type: :too_small,
            path: path,
            message: "String must contain at least #{schema.min} character(s)",
            data: [
              min: schema.min
            ]
          ],
        schema.length && String.length(value) !== schema.length &&
          [
            type: if(String.length(value) < schema.length, do: :too_small, else: :too_big),
            path: path,
            message: "String must contain exactly #{schema.length} character(s)",
            data: [
              equal: schema.length
            ]
          ],
        schema.regex && not Regex.match?(schema.regex, value) &&
          [
            type: :invalid_string,
            path: path,
            message: "Invalid string: regex didn't match",
            data: [
              validation: "regex",
              regex: schema.regex
            ]
          ],
        schema.validate && not String.valid?(value) &&
          [
            type: :invalid_string,
            path: path,
            message: "Invalid string: invalid UTF-8",
            data: [
              validation: "utf8"
            ]
          ]
      ]
      |> Enum.filter(&Function.identity/1)

    case errors do
      [] ->
        {:ok, value}

      issues ->
        {:error, %X.XodError{issues: issues}}
    end
  end
end
