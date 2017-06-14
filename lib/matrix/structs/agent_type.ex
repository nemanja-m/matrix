defmodule Matrix.AgentType do
  @moduledoc """
  Represents agent type struct with :name and :module fields.
  """

  defstruct name: nil, module: nil

  @type t :: %__MODULE__{name: String.t, module: String.t}
end
