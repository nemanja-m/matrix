defmodule Matrix.AgentController do
  use Matrix.Web, :controller

  alias Matrix.AgentManager

  plug :set_headers

  def get_classes(conn, _params) do
    conn
    |> json(%{data: AgentManager.self_agent_types})
  end

  def set_classes(conn, %{"data" => data}) do
    AgentManager.add_agent_types(data)

    conn
    |> json("ok")
  end

  defp set_headers(conn, _) do
    conn |> put_resp_header("content-type", "application/json")
  end
end
