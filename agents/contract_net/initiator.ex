defmodule ContractNet.Initiator do
  use Matrix.Agent,
    state: %{}

  require Logger

  alias Matrix.{AclMessage, MessageDispatcher, Agents}

  def handle_message(message = %AclMessage{performative: :refuse}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    {:ok, state}
  end

  def handle_message(message = %AclMessage{performative: :propose}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    # Simulate work
    :timer.sleep(:rand.uniform(5) * 1000)

    receiver = Agents.find_by_name(message.sender)

    # Accept proposal with 42% chance
    performative = if :rand.uniform(100) <= 42, do: :accept_proposal, else: :reject_proposal

    message = %AclMessage{performative: performative, sender: state.id.name}

    MessageDispatcher.send_message(receiver, message)

    {:ok, state}
  end

  def handle_message(message = %AclMessage{performative: :inform}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"
    Logger.warn "Content: #{message.content}"

    {:ok, state}
  end

  def handle_message(message = %AclMessage{performative: :failure}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    {:ok, state}
  end

  def handle_message(_, state), do: {:ok, state}
end
