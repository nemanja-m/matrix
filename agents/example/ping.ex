defmodule Example.Ping do
  use Matrix.Agent,
    state: %{}

  require Logger

  def handle_message(message, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    {:ok, "", state}
  end
end
