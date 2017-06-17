defmodule Matrix.AgentManager do
  @moduledoc """
  This module is responsible for agent related operations.

  It provides functions to add or remove running agents in cluster,
  loads and imports available agent types etc.
  """

  alias Matrix.{Configuration, Agents, AgentType, Agent}

  @agent_supervisor_template "templates/agent_supervisor_template.eex"

  @doc """
  Returns list of AgentTypes avaialble on this agent center.
  """
  @spec self_agent_types :: list[AgentType.t]
  def self_agent_types do
    Agents.types_for(Configuration.this_aliaz)
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

      Agents.add_running(aliaz, running_agents)
    end)
  end

  @spec start_agent(type :: AgentType.t, name :: String.t) :: :ok
  def start_agent(type, name) do
    apply(String.to_existing_atom("Elixir.Matrix.#{type.name}Supervisor"), :start_child, [name])

    # TODO Update cluster with new running agent
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
    |> Enum.map(fn %AgentType{name: name} ->
      EEx.eval_file(@agent_supervisor_template, assigns: [agent: name])
      |> Code.compile_string
      |> Enum.map(fn {supervisor_module, _} -> supervisor_module end)
    end)
    |> List.flatten
  end

  defp agents_dir do
    Application.get_env(:matrix, :agents_dir) || "agents"
  end

end
