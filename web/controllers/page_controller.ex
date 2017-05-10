defmodule Matrix.PageController do
  use Matrix.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
