defmodule Matrix.AgentType do
  @moduledoc """
  Represents agent type struct with :name and :module fields.
  """

  defstruct name: nil, module: nil

  @typedoc """
  Type that represents AgentType struct with :name and :module as Strings
  """
  @type t :: %__MODULE__{name: String.t, module: String.t}
end
