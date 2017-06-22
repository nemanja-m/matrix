defmodule Matrix.Agents do
  @moduledoc """
  Holds state about posible agent types and currently running agents in cluster.

  This module is meant to be used when new agent centers are registered / unregistered
  to / from cluster.

  When new agent center is registered to cluster, it's available agent types are
  sent to every other agent center.

  When agent center is unregistered from cluster, it's agent types are deleted from
  every other agent center.
  """

  use GenServer

  alias Matrix.{Env, Cluster, AgentCenter, AgentType}

  defmodule State do
    @moduledoc """
    Represents state of agents in cluster.

    * agent_types - All supported agent types in cluster.

      Map where key is agent center alias and value is list of agent types
      available on that agent center.

    * running_agents - Running agents in cluster.

      Map where key is agent center alias and value is list of Agent structs
      running on that agent center.

    """
    defstruct agent_types: %{}, running_agents: %{}

    @type t :: %__MODULE__{agent_types: Map.t, running_agents: Map.t}
  end

  def start_link(args \\ []) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  # Client API

  @doc """
  Adds list of agent types to given agent center.

  Args:
    * `agent_center` - Alias of agent center
    * `types` - List of supported agent types

  ## Example

    Agents.add_types("Mars", [%AgentType{name: "Ping", module: "Test"}])

  """
  @spec add_types(agent_center :: String.t, types :: list[Matrix.AgentType.t]) :: :ok
  def add_types(agent_center, types) do
    GenServer.cast(__MODULE__, {:add_types, agent_center, types})
  end

  @doc """
  Deletes agent types of given agent center.

  Args:
    * `agent_center` - Alias of agent center

  ## Example

    Agents.delete_types_for("Mars")

  """
  @spec delete_types_for(agent_center :: String.t) :: :ok
  def delete_types_for(agent_center) do
    GenServer.cast(__MODULE__, {:delete_types, agent_center})
  end

  @doc """
  Returns all supported agent types in cluster for each agent center.

  ## Example

    Agents.types
    # => `%{"Mars" => [%AgentType{name: "Ping", module: "Agents"}]}`

  """
  @spec types :: %{required(String.t) => list(Matrix.AgentType.t)}
  def types do
    GenServer.call(__MODULE__, {:types})
  end

  @doc """
  Returns list of supported agent types for given agent center.

  ## Example

    Agents.add_types("Mars", [%AgentType{name: "Ping", module: "Agents"}])

    Agents.types_for("Mars")
    # => [`%AgentType{name: "Ping", module: "Agents"}]

  """
  @spec types_for(agent_center :: String.t) :: list(Matrix.AgentType.t)
  def types_for(agent_center) do
    GenServer.call(__MODULE__, {:types, agent_center})
  end

  @spec find_agent_center_with_type(type :: AgentType.t) :: AgentCenter.t | nil
  def find_agent_center_with_type(type) do
    GenServer.call(__MODULE__, {:find_agent_center_with_type, type})
  end

  @doc """
  Returns all running agents on cluster.

  ## Example

    Agents.running
    # => `[%Agent{id: %AID{}]`

  """
  @spec running :: %{required(String.t) => list(Matrix.Agent.t)}
  def running do
    GenServer.call(__MODULE__, {:running})
  end

  @doc """
  Returns all running agents on given agent center.

  ## Example

    Agents.running_on("Mars")
    # => `[%Agent{id: %AID{}]`

  """
  @spec running_on(agent_center :: String.t) :: list[Matrix.Agent.t]
  def running_on(agent_center) do
    GenServer.call(__MODULE__, {:running, agent_center})
  end

  @doc """
  Returns map where key is agent center alias,
  value is list of running agents on that center.

  ## Example

    Agents.running_per_agent_center
    # => `%{"Mars" => [%Agent{id: %AID{}}]}`

  """
  @spec running_per_agent_center :: Map.t
  def running_per_agent_center do
    GenServer.call(__MODULE__, {:running_per_agent_center})
  end

  @doc """
  Adds new agent for given agent center.

  ## Example

    Agents.add_running("Mars", %Agent{})

  """
  @spec add_running(agent_center :: String.t, running_agents :: list(Matrix.Agent)) :: :ok
  def add_running(agent_center, running_agents) do
    GenServer.cast(__MODULE__, {:add_running, agent_center, running_agents})
  end

  @doc """
  Deletes running agent from agent center.

  ## Example

    ping = Agent.new(...)
    Agents.delete_running(ping)

  """
  @spec delete_running(agent :: Agent.t) :: any
  def delete_running(agent) do
    GenServer.cast(__MODULE__, {:delete_running, agent})
  end

  @spec delete_running_for(agent_center :: String.t) :: :ok
  def delete_running_for(agent_center) do
    GenServer.cast(__MODULE__, {:delete_running_for, agent_center})
  end

  @doc """
  Resets data about agent types and running agents.
  """
  @spec reset :: :ok
  def reset do
    GenServer.cast(__MODULE__, {:reset})
  end

  @spec exists?(name :: String.t) :: boolean
  def exists?(name) do
    running() |> Enum.any?(fn agent -> agent.id.name == name end)
  end

  # Server callbacks

  def handle_call({:types}, _from, state) do
    {:reply, state.agent_types, state}
  end

  def handle_call({:types, aliaz}, _from, state) do
    {:reply, state.agent_types[aliaz] || [], state}
  end

  def handle_call({:running}, _from, state) do
    running_agents =
      state.running_agents
      |> Enum.reduce([], fn {_, agents}, acc ->
        acc ++ agents
      end)

    {:reply, running_agents, state}
  end

  def handle_call({:running, agent_center}, _from, state) do
    {:reply, state.running_agents[agent_center] || [], state}
  end

  def handle_call({:running_per_agent_center}, _from, state) do
    {:reply, state.running_agents, state}
  end

  def handle_call({:find_agent_center_with_type, type}, _from, state) do
    pair =
      state.agent_types
      |> Enum.find(fn {aliaz, agent_types} ->
        (Env.this_aliaz != aliaz) && (type in agent_types)
      end)

    case pair do
      {aliaz, _} ->
        {:reply, %AgentCenter{aliaz: aliaz, address: Cluster.address_for(aliaz)}, state}

      nil ->
        {:reply, nil, state}

      _ -> raise "Invalid state struct"
    end
  end

  def handle_cast({:add_types, aliaz, types}, state) do
    types = state.agent_types |> Map.put_new(aliaz, types)

    {:noreply, %State{agent_types: types, running_agents: state.running_agents}}
  end

  def handle_cast({:add_running, aliaz, running_agents}, state) do
    agents = (state.running_agents[aliaz] || []) ++ running_agents

    running_agents_map = Map.put(state.running_agents, aliaz, agents)

    {:noreply, %State{agent_types: state.agent_types, running_agents: running_agents_map}}
  end

  def handle_cast({:delete_types, aliaz}, state) do
    types = state.agent_types |> Map.delete(aliaz)

    {:noreply, %State{agent_types: types, running_agents: state.running_agents}}
  end

  def handle_cast({:delete_running, agent}, state) do
    new_running_agents = state.running_agents[agent.id.host.aliaz] |> List.delete(agent)

    {:noreply, put_in(state.running_agents[agent.id.host.aliaz], new_running_agents)}
  end

  def handle_cast({:delete_running_for, agent_center}, state) do
    {:noreply, put_in(state.running_agents[agent_center], [])}
  end

  def handle_cast({:reset}, _state) do
    {:noreply, %State{}}
  end

  def init(agent_types) do
    {:ok, %State{agent_types: %{Matrix.Env.this_aliaz => agent_types}}}
  end

end
