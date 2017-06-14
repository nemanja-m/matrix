defmodule Matrix.Agent do
  @moduledoc """
  Represents agent.
  """

  defstruct id: nil

  @type t :: %__MODULE__{id: Matrix.AID.t}
end
