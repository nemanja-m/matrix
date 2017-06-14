defmodule Matrix.AID do
  @moduledoc """
  Represents agent id module.
  """

  @derive [Poison.Encoder]
  defstruct [:name, :host, :type]

  @type t :: %__MODULE__{name: String.t, host: Matrix.AgentCenter.t, type: Matrix.AgentType.t}
end
