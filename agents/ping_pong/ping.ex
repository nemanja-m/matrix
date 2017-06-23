defmodule PingPong.Ping do
  use Matrix.Agent,
    state: %{}

  require Logger

  alias Matrix.{AclMessage, MessageDispatcher, Agents}

  def handle_message(message = %AclMessage{performative: :request}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender || "client"}"

    pong = Agents.find_by_name(message.content)
    message = %AclMessage{performative: :request, sender: state.id.name}

    MessageDispatcher.send_message(pong, message)

    {:ok, state}
  end

  def handle_message(message = %AclMessage{performative: :inform}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    {:ok, state}
  end
end
