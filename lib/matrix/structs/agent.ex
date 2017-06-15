defmodule Matrix.Agent do
  @moduledoc """
  Represents agent.
  """

  @derive [Poison.Encoder]
  defstruct [:id]

  @type t :: %__MODULE__{id: Matrix.AID.t}

  alias Matrix.{Agent, AID, AgentType, AgentCenter}

  def from_hash(hash) do
    hash
    |> Poison.encode!
    |> Poison.decode!(as: %Agent{id: %AID{host: %AgentCenter{}, type: %AgentType{}}})
  end
end
