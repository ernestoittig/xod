defmodule Xod.XodError do
  alias Xod, as: X

  @moduledoc """
  An error encountered during schema validation.
  """

  @type issue() :: [
          type: atom(),
          path: Xod.Common.path(),
          message: binary() | nil,
          data: keyword()
        ]

  @type t() :: %__MODULE__{
          issues: [issue()]
        }

  @doc """
  The error struct.

  `issues` contains a list of issues encountered while validating a schema
  """
  defexception issues: []

  @impl true
  def message(%__MODULE__{issues: issues}) do
    issues
    |> Enum.map(&"#{&1[:message]} (in path #{inspect(&1[:path])})")
    |> Enum.join("\n")
  end

  @spec invalid_type(atom(), atom(), X.Common.path()) :: t()
  def invalid_type(expected, got, path) do
    %X.XodError{
      issues: [
        [
          type: :invalid_type,
          path: path,
          data: [
            expected: expected,
            got: got
          ],
          message: "Expected #{Atom.to_string(expected)}, got #{Atom.to_string(got)}"
        ]
      ]
    }
  end
end
