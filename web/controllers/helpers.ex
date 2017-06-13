defmodule Matrix.Controllers.Helpers do
  import Plug.Conn

  def set_headers(conn, _) do
    conn
    |> put_resp_header("content-type", "application/json")
  end
end
