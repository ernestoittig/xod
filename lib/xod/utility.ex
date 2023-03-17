defmodule Xod.Any do
  @type t() :: %__MODULE__{}

  defstruct []

  @spec new() :: t()
  def new(), do: %__MODULE__{}

  defimpl Xod.Schema do
    @impl true
    def parse(_, value, _), do: {:ok, value}
  end
end

defmodule Xod.Never do
  @type t() :: %__MODULE__{}

  defstruct []

  @spec new() :: t()
  def new(), do: %__MODULE__{}

  defimpl Xod.Schema do
    @impl true
    def parse(_, v, path) do
      {:error, Xod.XodError.invalid_type(:never, Xod.Common.get_type(v), path)}
    end
  end
end

defmodule Xod.Transform do
  @type t() :: %__MODULE__{schema: Xod.Schema.t(), closure: (term() -> term())}

  @enforce_keys [:schema, :closure]
  defstruct [:schema, :closure]

  @spec new(Xod.Schema.t(), (term() -> term())) :: t()
  def new(schema, closure) when is_struct(schema) and is_function(closure, 1) do
    %__MODULE__{schema: schema, closure: closure}
  end

  defimpl Xod.Schema do
    alias Xod, as: X

    @impl true
    def parse(schema, value, path) do
      with {:ok, inner} <- X.Schema.parse(schema.schema, value, path) do
        {:ok, schema.closure.(inner)}
      end
    end
  end
end

defmodule Xod.Literal do
  @type t() :: %__MODULE__{value: term(), strict: boolean()}

  @enforce_keys [:value]
  defstruct [:value, strict: false]

  @spec new(term(), strict: boolean()) :: t()
  def new(value, options \\ []), do: struct(%__MODULE__{value: value}, options)

  defimpl Xod.Schema do
    @impl true
    def parse(schema, value, path) do
      eq = if schema.strict, do: &===/2, else: &==/2

      if eq.(schema.value, value) do
        {:ok, value}
      else
        {:error,
         %Xod.XodError{
           issues: [
             [
               type: :invalid_literal,
               path: path,
               message: "Invalid literal value, expected #{inspect(schema.value)}",
               data: [
                 expected: schema.value,
                 got: value
               ]
             ]
           ]
         }}
      end
    end
  end
end

defmodule Xod.Union do
  @type t() :: %__MODULE__{schemata: list(Xod.Schema.t())}

  @enforce_keys [:schemata]
  defstruct [:schemata]

  @spec new(list(Xod.Schema.t())) :: t()
  def new(schemata) when is_list(schemata) and length(schemata) > 1,
    do: %__MODULE__{schemata: schemata}

  defimpl Xod.Schema do
    @impl true
    def parse(%Xod.Union{schemata: schemata}, value, path) when length(schemata) > 1 do
      try do
        Enum.map(schemata, fn x ->
          case Xod.Schema.parse(x, value, path) do
            {:error, error} ->
              error

            {:ok, value} ->
              throw(value)
          end
        end)
      catch
        value ->
          {:ok, value}
      else
        errors ->
          {:error,
           %Xod.XodError{
             issues: [
               type: :invalid_union,
               path: path,
               message: "Invalid input",
               data: [
                 union_errors: errors
               ]
             ]
           }}
      end
    end
  end
end

defmodule Xod.Default do
  @type t() :: %__MODULE__{schema: Xod.Schema.t(), default: term()}

  @enforce_keys [:schema, :default]
  defstruct [:schema, :default]

  @spec new(Xod.Schema.t(), term()) :: t()
  def new(schema, default) when is_struct(schema) do
    %__MODULE__{schema: schema, default: default}
  end

  defimpl Xod.Schema do
    alias Xod, as: X

    @impl true
    def parse(%Xod.Default{schema: schema, default: default}, value, path) do
      case value do
        nil ->
          {:ok, default}

        other ->
          X.Schema.parse(schema, other, path)
      end
    end
  end
end
