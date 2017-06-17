defmodule Matrix.AgentController do
  use Matrix.Web, :controller

  alias Matrix.{AgentManager, Configuration, Agents}

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
end
