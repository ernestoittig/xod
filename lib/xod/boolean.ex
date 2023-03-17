defmodule Xod.Boolean do
  @type t() :: %__MODULE__{coerce: boolean()}

  defstruct [:coerce]

  @spec new(coerce: boolean()) :: t()
  def new(opts \\ []), do: struct(__MODULE__, opts)

  defimpl Xod.Schema do
    @impl true
    def parse(%Xod.Boolean{coerce: coerce}, value, path)
        when (is_nil(coerce) or not coerce) and not is_boolean(value) do
      {:error, Xod.XodError.invalid_type(:boolean, Xod.Common.get_type(value), path)}
    end

    @impl true
    def parse(_, value, _) do
      if value, do: {:ok, true}, else: {:ok, false}
    end
  end
end
