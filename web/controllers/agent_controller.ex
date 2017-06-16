defmodule Matrix.AgentController do
  use Matrix.Web, :controller

  alias Matrix.{AgentManager, Configuration}

  plug :set_headers

  def get_classes(conn, _params) do
    conn
    |> json(%{data: %{Configuration.this_aliaz => AgentManager.self_agent_types}})
  end

  def set_classes(conn, %{"data" => data}) do
    AgentManager.add_agent_types(data)

    conn
    |> json("ok")
  end

  def set_running(conn, %{"data" => data}) do
    AgentManager.add_running_agents(data)

    conn
    |> json("ok")
  end
end
