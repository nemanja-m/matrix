defmodule PingPong.Pong do
  use Matrix.Agent,
    state: %{}

  require Logger

  alias Matrix.{AclMessage, MessageDispatcher, Agents}

  def handle_message(message = %AclMessage{performative: :request}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    ping = Agents.find_by_name(message.sender)
    message = %AclMessage{performative: :inform, sender: state.id.name}

    MessageDispatcher.send_message(ping, message)

    {:ok, state}
  end

  def handle_message(message, state), do: {:ok, state}
end
