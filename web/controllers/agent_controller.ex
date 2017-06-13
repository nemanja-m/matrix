defmodule Matrix.AgentController do
  use Matrix.Web, :controller

  alias Matrix.{Configuration, Agents}

  plug :set_headers

  def get_classes(conn, _params) do
    conn
    |> json(%{data: Agents.types(for: Configuration.this_aliaz)})
  end

  defp set_headers(conn, _) do
    conn |> put_resp_header("content-type", "application/json")
  end
end
