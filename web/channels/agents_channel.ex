defmodule Matrix.AgentsChannel do
  use Phoenix.Channel

  alias Matrix.{
    Agent,
    AID,
    AgentCenter,
    Cluster,
    Agents,
    AgentManager,
    AgentType,
    MessageDispatcher,
    AclMessage
  }

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

  def handle_in("agent:stop", agent_data, socket) do
    create_agent(agent_data) |> AgentManager.stop_agent

    {:noreply, socket}
  end

  def handle_in("message:new", message, socket) do
    spawn fn ->
      message
      |> AclMessage.from_hash
      |> MessageDispatcher.dispatch
    end

    {:reply, :ok, socket}
  end

  defp create_agent(agent_data) do
    %{
      "name" => name,
      "type" => %{"name" => type_name, "module" => module},
      "host" => %{"aliaz" => aliaz, "address" => _addr},
    } = agent_data

    %Agent{
      id: %AID{
        name: name,
        type: %AgentType{name: type_name, module: module},
        host: %AgentCenter{aliaz: aliaz, address: Cluster.address_for(aliaz)}
      }
    }
  end
end
