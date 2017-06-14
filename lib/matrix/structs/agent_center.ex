defmodule Matrix.AgentCenter do
  @moduledoc """
  Represents agent center with alias ad address on network.
  """

  @derive [Poison.Encoder]
  defstruct [:aliaz, :address]

  @type t :: %__MODULE__{aliaz: String.t, address: String.t}
end
