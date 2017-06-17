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

    get  "/agents/classes", AgentController, :get_classes
    post "/agents/classes", AgentController, :set_classes

    get    "/agents/running", AgentController, :get_running
    post   "/agents/running", AgentController, :set_running
    put    "/agents/running", AgentController, :start_agent
    delete "/agents/running", AgentController, :stop_agent
  end
end
