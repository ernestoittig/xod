defmodule Xod.Number do
  alias Xod, as: X
  require X.Common

  @type t() :: %__MODULE__{
          lt: number(),
          gt: number(),
          le: number(),
          ge: number(),
          int: boolean(),
          step: number()
        }

  defstruct [:lt, :gt, :le, :ge, :int, :step]

  @spec new(
          lt: number(),
          gt: number(),
          le: number(),
          ge: number(),
          int: boolean(),
          step: number()
        ) :: t()
  def new(options \\ []) do
    struct(__MODULE__, options)
  end

  X.Common.set_fields(
    lt: number(),
    gt: number(),
    le: number(),
    ge: number(),
    int: boolean(),
    step: number()
  )

  @spec positive(t()) :: t()
  def positive(schema), do: gt(schema, 0)

  @spec nonnegative(t()) :: t()
  def nonnegative(schema), do: ge(schema, 0)

  @spec negative(t()) :: t()
  def negative(schema), do: lt(schema, 0)

  @spec nonpositive(t()) :: t()
  def nonpositive(schema), do: le(schema, 0)

  defimpl X.Schema do
    @impl true
    def parse(_, not_number, path) when not is_number(not_number) do
      {:error, X.XodError.invalid_type(:number, X.Common.get_type(not_number), path)}
    end

    @impl true
    @spec parse(X.Number.t(), number(), X.Common.path()) :: X.Common.result(number())
    def parse(schema, value, path) when is_number(value) do
      errors =
        [
          schema.lt && value >= schema.lt &&
            [
              type: :too_big,
              path: path,
              message: "Number must be smaller than #{schema.lt}",
              data: [
                max: schema.lt,
                exclusive: true
              ]
            ],
          schema.le && value > schema.le &&
            [
              type: :too_big,
              path: path,
              message: "Number must be smaller than or equal to #{schema.le}",
              data: [
                max: schema.le
              ]
            ],
          schema.gt && value <= schema.gt &&
            [
              type: :too_small,
              path: path,
              message: "Number must be greater than #{schema.gt}",
              data: [
                min: schema.gt,
                exclusive: true
              ]
            ],
          schema.ge && value < schema.ge &&
            [
              type: :too_small,
              path: path,
              message: "Number must be greater than or equal to #{schema.ge}",
              data: [
                min: schema.ge
              ]
            ],
          schema.int && not is_integer(value) &&
            X.XodError.invalid_type(:integer, :float, path).issues |> Enum.at(0),
          schema.step && is_integer(value) && Integer.mod(value, schema.step) != 0 &&
            [
              type: :not_multiple_of,
              path: path,
              message: "Number must be multiple of #{schema.step}",
              data: [
                step: schema.step
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
end
