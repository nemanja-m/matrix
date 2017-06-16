defmodule Matrix do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    # Import defined agents into VM
    agent_types = Matrix.AgentManager.import_agent_types

    # Generate supervisors for imported agents
    agent_supervisors =
      Matrix.AgentManager.generate_agent_supervisor_modules(agent_types)
      |> Enum.map(fn module -> supervisor(module, []) end)

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Matrix.Endpoint, []),
      worker(Matrix.Cluster, []),
      worker(Matrix.Agents, [agent_types]),
      worker(Matrix.Heartbeat, [])
    ]

    opts = [strategy: :one_for_one, name: Matrix.Supervisor]
    pid = Supervisor.start_link(children ++ agent_supervisors, opts)

    # Register this node to network
    Matrix.ConnectionManager.register_self

    pid
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    Matrix.Endpoint.config_change(changed, removed)
    :ok
  end
end
