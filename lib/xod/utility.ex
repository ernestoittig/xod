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
