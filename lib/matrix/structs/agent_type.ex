defmodule Matrix.AgentType do
  @enforce_keys [:name, :module]

  defstruct [:name, :module]
end
