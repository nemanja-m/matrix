defmodule Matrix.AgentManager do
  @moduledoc """
  This module is responsible for agent related operations.

  It provides functions to add or remove running agents in cluster,
  loads and imports available agent types etc.
  """

  alias Matrix.{ConnectionManager, Env, Agents, AgentType, Agent, AgentCenter}

  require Logger

  @agent_supervisor_template "templates/agent_supervisor_template.eex"

  @doc """
  Returns list of AgentTypes avaialble on this agent center.
  """
  @spec self_agent_types :: list[AgentType.t]
  def self_agent_types do
    Agents.types_for(Env.this_aliaz)
  end

  @doc """
  Adds agent types data to this agent center.
  """
  @spec add_agent_types(types_map :: map) :: :ok
  def add_agent_types(types_map) do
    types_map
    |> Enum.each(fn {aliaz, types} ->
      agent_types =
        Enum.map(types, fn %{"name" => name, "module" => module} ->
          %AgentType{name: name, module: module}
        end)

      Agents.add_types(aliaz, agent_types)
    end)

    # Update clients via web sockets
    Matrix.Endpoint.broadcast! "agents", "types:update", Agents.types
  end

  @doc """
  Adds running agents data to this agent center.
  """
  @spec add_running_agents(running_agents_map :: map) :: :ok
  def add_running_agents(running_agents_map) do
    running_agents_map
    |> Enum.each(fn {aliaz, agents} ->
      running_agents =
        Enum.map(agents, fn hash -> Agent.from_hash(hash) end)

      # Update clients via web sockets
      Matrix.Endpoint.broadcast! "agents", "agent:start", %{agent: running_agents |> List.first}

      Agents.add_running(aliaz, running_agents)
    end)
  end

  @doc """
  Deletes given agent from running agents map.
  """
  @spec delete_running_agent(agent :: Agent.t) :: any
  def delete_running_agent(agent) do
    Agents.delete_running(agent)
    Logger.warn "Agent '#{agent.id.name}' stopped"

    Matrix.Endpoint.broadcast! "agents", "agent:stop", %{name: agent.id.name}
  end

  @spec start_agent(type :: AgentType.t, name :: String.t) :: :ok
  def start_agent(type, name) do
    start_agent(type, name, host_node: type in Agents.types_for(Env.this_aliaz))
  end
  defp start_agent(type, name, host_node: true) do
    case apply(String.to_atom("Elixir.Matrix.#{type.name}Supervisor"), :start_child, [name]) do
      {:ok, _} ->
        agent = Agent.new(name, type)

        Agents.add_running(Env.this_aliaz, [agent])
        Logger.warn "Agent '#{name}' started"

        # Update clients via web sockets
        Matrix.Endpoint.broadcast! "agents", "agent:start", %{agent: agent}

        ConnectionManager.agent_centers
        |> Enum.each(fn %AgentCenter{address: address} ->
          url = "#{address}/agents/running"
          body = Poison.encode!(%{data: %{Env.this_aliaz => [agent]}})
          headers = [{"Content-Type", "application/json"}]

          HTTPoison.post(url, body, headers)
        end)

        {:ok, agent}

      _ ->
        {:error, "Agent can't be started"}
    end
  end
  defp start_agent(type, name, host_node: false) do
    case Agents.find_agent_center_with_type(type) do
      nil ->
        Logger.error "Unsupported agent type"

      agent_center ->
        url = "#{agent_center.address}/agents/running"
        body = Poison.encode!(%{data: %{type: type, name: name}})
        headers = [{"Content-Type", "application/json"}]

        HTTPoison.put(url, body, headers)
    end
  end

  @doc """
  Stops given running agent and deletes it from cluster.

  If agent's host is current node then agent gen_server is stopped and other
  nodes are notified about agent's shutdown.

  If agent's host isn't current node, then delete request is sent to agent's host.

  ## Example

    AgentManager.stop_agent(%Agent{id: %AID{...})

  """
  @spec stop_agent(agent :: Agent.t) :: any
  def stop_agent(agent) do
    stop_agent(agent, host_node: agent.id.host == Env.this)
  end
  defp stop_agent(agent, host_node: true) do
    agent.id.name
    |> String.capitalize
    |> String.to_atom
    |> GenServer.stop(:shutdown)

    delete_running_agent(agent)

    ConnectionManager.agent_centers
    |> Enum.each(fn %AgentCenter{address: address} ->
      "#{delete_url(agent, address)}?update=true" |> send_delete_agent
    end)
  end
  defp stop_agent(agent, host_node: false) do
    delete_url(agent) |> send_delete_agent
  end

  defp delete_url(agent) do
    delete_url(agent, agent.id.host.address)
  end
  defp delete_url(agent, address) do
    host = "#{agent.id.host.aliaz}"
    type = "#{agent.id.type.name}/#{agent.id.type.module}"

    "#{address}/agents/running/id/#{agent.id.name}/host/#{host}/type/#{type}"
  end

  defp send_delete_agent(url) do
    headers = [{"Content-Type", "application/json"}]

    HTTPoison.delete(url, headers)
  end

  @doc """
  Compiles and imports all agent types located in specified agents directory.
  Returns list of available agent types on this node.

  This function should be run on application startup.

  ## Example

    # ls agents/ => ping.ex

    AgentManager.import_agent_types
    # => `[%Matrix.AgentType{name: "Ping", module: ""}]`

  """
  @spec import_agent_types :: list(AgentType.t)
  def import_agent_types do
    agents_dir()
    |> Path.join("**/*.ex")
    |> Path.wildcard()
    |> Enum.map(&Code.require_file/1)
    |> Enum.map(fn [{module, _}] -> module end)
    |> Enum.map(&module_to_type/1)
  end

  @doc """
  Converts given agent module to AgentType.

  ## Example

    AgentManager.module_to_type(Matrix.Ping)
    # => `%Matrix.AgentType{name: "Ping", module: "Matrix"}`

  """
  @spec module_to_type(module :: module) :: Matrix.AgentType.t
  def module_to_type(module) do
    name =
      module
      |> Module.split
      |> List.last

    type_module =
      module
      |> Module.split
      |> List.delete(name)
      |> Enum.join(".")

      %Matrix.AgentType{
        name: name,
        module: type_module
      }
  end

  @doc """
  For every loaded agent type creates supervisor module dynamically and
  loads it into VM.

  ## Example

    AgentManager.generate_agent_supervisor_modules(%AgentType{name: "Ping", module: ""})
    # => Matrix.PingSupervisor

  """
  @spec generate_agent_supervisor_modules(agent_types :: list(AgentType.t)) :: list(module)
  def generate_agent_supervisor_modules(agent_types) do
    agent_types
    |> Enum.map(fn %AgentType{name: name, module: module} ->
      EEx.eval_file(@agent_supervisor_template, assigns: [agent: name, agent_module: "#{module}.#{name}"])
      |> Code.compile_string
      |> Enum.map(fn {supervisor_module, _} -> supervisor_module end)
    end)
    |> List.flatten
  end

  defp agents_dir do
    Application.get_env(:matrix, :agents_dir) || "agents"
  end

end
