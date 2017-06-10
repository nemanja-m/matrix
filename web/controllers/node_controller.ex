defmodule Matrix.NodeController do
  use Matrix.Web, :controller

  def register(conn, %{"aliaz" => aliaz, "address" => address}) do
    conn
    |> json(%{})
  end
end
