defmodule Matrix.AgentController do
  use Matrix.Web, :controller

  alias Matrix.{Agent, AID, AgentCenter, AgentType, AgentManager, Agents, Cluster}

  plug :set_headers
  plug :create_agent when action in [:stop_agent]

  def get_classes(conn, _params) do
    conn
    |> json(%{data: Agents.types})
  end

  def set_classes(conn, %{"data" => data}) do
    AgentManager.add_agent_types(data)

    conn
    |> json("ok")
  end

  def get_running(conn, _params) do
    conn
    |> json(%{data: Agents.running_per_agent_center})
  end

  def set_running(conn, %{"data" => data}) do
    AgentManager.add_running_agents(data)

    conn
    |> json("ok")
  end

  def start_agent(conn, %{"data" => %{"type" => type, "name" => name}}) do
    agent_type = %AgentType{name: type["name"], module: type["module"]}

    AgentManager.start_agent(agent_type, name)

    conn
    |> json("ok")
  end

  def stop_agent(conn, _params) do
    if conn.assigns[:update] do
      AgentManager.delete_running_agent(conn.assigns[:agent])
    else
      AgentManager.stop_agent(conn.assigns[:agent])
    end

    conn
    |> json("ok")
  end

  defp create_agent(conn, _) do
    %{
      "name" => name,
      "alias" => aliaz,
      "module" => module,
      "type_name" => type_name
    } = conn.params

    agent = %Agent{
      id: %AID{
        name: name,
        type: %AgentType{name: type_name, module: module},
        host: %AgentCenter{aliaz: aliaz, address: Cluster.address_for(aliaz)}
      }
    }

    conn
    |> assign(:agent, agent)
    |> assign(:update, conn.params["update"] == "true")
  end
end
