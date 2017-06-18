defmodule Matrix.MessageController do
  use Matrix.Web, :controller

  plug :set_headers

  def performatives(conn, _params) do
    conn
    |> json(%{data: Matrix.AclMessage.performatives})
  end

  def send_message(conn, %{"data" => message}) do
    conn
  end
end
