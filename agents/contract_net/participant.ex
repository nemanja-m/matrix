defmodule ContractNet.Participant do
  use Matrix.Agent,
    state: %{}

  require Logger

  alias Matrix.{AclMessage, MessageDispatcher, Agents}

  def handle_message(message = %AclMessage{performative: :cfp}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    # Simulate work
    :timer.sleep(:rand.uniform(5) * 1000)

    receiver = Agents.find_by_name(message.sender)

    # Propose with 42% chance
    performative = if :rand.uniform(100) <= 42, do: :propose, else: :refuse
    message = %AclMessage{performative: performative, sender: state.id.name}

    MessageDispatcher.send_message(receiver, message)

    {:ok, state}
  end

  def handle_message(message = %AclMessage{performative: :accept_proposal}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    receiver = Agents.find_by_name(message.sender)

    # Simulate work
    :timer.sleep(:rand.uniform(5) * 1000)

    performative = if :rand.uniform(100) <= 80, do: :inform, else: :failure
    content = if performative == :inform, do: "Done"

    message = %AclMessage{performative: performative, sender: state.id.name, content: content}

    MessageDispatcher.send_message(receiver, message)

    {:ok, state}
  end

  def handle_message(message = %AclMessage{performative: :reject_proposal}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    {:ok, state}
  end

  def handle_message(_, state), do: {:ok, state}
end
