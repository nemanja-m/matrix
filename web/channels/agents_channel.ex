defmodule Matrix.AgentsChannel do
  use Phoenix.Channel

  alias Matrix.{Agents, AgentManager, AgentType}

  def join("agents", _message, socket) do
    {:ok, socket}
  end

  def handle_in("agent:start", agent, socket) do
    %{"name" => agent_name, "type" => %{"name" => type_name, "module" => module}} = agent

    if Agents.exists?(agent_name) do
      {:reply, :error, socket}
    else
      case AgentManager.start_agent(%AgentType{name: type_name, module: module}, agent_name) do
        {:ok, _} -> {:reply, :ok, socket}
        _        -> {:reply, :error, socket}
      end
    end
  end
end
