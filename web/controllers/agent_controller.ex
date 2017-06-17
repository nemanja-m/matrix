defmodule Matrix.AgentController do
  use Matrix.Web, :controller

  alias Matrix.{Agent, AgentType, AgentManager, Agents}

  plug :set_headers

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

  def stop_agent(conn, %{"data" => %{"id" => agent_hash, "update" => true}}) do
    AgentManager.delete_running_agent(Agent.from_hash(agent_hash))

    conn
    |> json("ok")
  end
  def stop_agent(conn, %{"data" => agent_hash}) do
    AgentManager.stop_agent(Agent.from_hash(agent_hash))

    conn
    |> json("ok")
  end
end
