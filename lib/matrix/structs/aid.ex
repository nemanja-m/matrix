defmodule Matrix.AID do
  @moduledoc """
  Represents agent id module.
  """

  defstruct name: nil, host: nil, type: nil

  @type t :: %__MODULE__{name: String.t, host: Matrix.AgentCenter.t, type: Matrix.AgentType.t}
end
