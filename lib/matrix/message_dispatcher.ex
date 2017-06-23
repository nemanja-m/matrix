defmodule Matrix.MessageDispatcher do
  require Logger

  alias Matrix.{Agents, Agent, AID, Env}

  def dispatch(message) do
    message.receivers
    |> Enum.each(fn receiver ->
      case Agents.find_by_name(receiver) do
        nil   -> Logger.error "Agent is not running"
        agent -> send_message(agent, message)
      end
    end)
  end

  def send_message(%Agent{id: %AID{name: name, host: host}}, message) do
    if host == Env.this do
      GenServer.call process_name(name), {:handle_message, message}
    else
      Logger.warn "Agent: #{name} is running on #{host.aliaz} node"
      Logger.warn "Redirecting ..."

      url = "#{host.address}/messages"
      body = Poison.encode! %{data: put_in(message.receivers, [name])}
      headers = [{"Content-Type", "application/json"}]

      HTTPoison.post(url, body, headers)
    end
  end

  defp process_name(name) do
    name
    |> String.to_atom
  end
end
