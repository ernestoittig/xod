defprotocol Xod.Schema do
  @spec parse(t, term(), Xod.Common.path()) :: Xod.Common.result(term())
  def parse(schema, value, path)
end

defmodule Xod.Common do
  @type path() :: [binary() | non_neg_integer()]
  @type result(x) :: {:error, Xod.XodError.t()} | {:ok, x}
end
