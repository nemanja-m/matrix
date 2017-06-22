defmodule Matrix.MessageDispatcher do
  require Logger

  alias Matrix.{Agents, Agent, AID, Env}

  def dispatch(message) do
    message.receivers
    |> Enum.each(fn receiver ->
      case Agents.find_by_name(receiver) do
        agent -> send_message(agent, message)
        nil   -> Logger.error "Agent is not running"
      end
    end)
  end

  defp send_message(%Agent{id: %AID{name: name, host: host}}, message) do
    if host == Env.this do
      GenServer.call process_name(name), {:handle_message, message}
    else
      Logger.warn "Agent is running on #{host.aliaz} node"
    end
  end

  defp process_name(name) do
    name
    |> String.capitalize
    |> String.to_atom
  end
end