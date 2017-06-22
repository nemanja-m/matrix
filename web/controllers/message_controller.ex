defmodule Matrix.MessageController do
  use Matrix.Web, :controller

  alias Matrix.MessageDispatcher

  plug :set_headers

  def performatives(conn, _params) do
    conn
    |> json(Matrix.AclMessage.performatives)
  end

  def send_message(conn, %{"data" => message}) do
    MessageDispatcher.dispatch(message)

    conn
    |> json("ok")
  end
end
