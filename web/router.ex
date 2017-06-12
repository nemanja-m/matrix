defmodule Matrix.Router do
  use Matrix.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Matrix do
    pipe_through :api

    get    "/node", NodeController, :heartbeat
    post   "/node", NodeController, :register
    delete "/node/:aliaz", NodeController, :unregister
  end
end
