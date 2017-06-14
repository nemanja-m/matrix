defmodule Matrix.AgentType do
  @moduledoc """
  Represents agent type struct with :name and :module fields.
  """

  @derive [Poison.Encoder]
  defstruct [:name, :module]

  @type t :: %__MODULE__{name: String.t, module: String.t}
end
