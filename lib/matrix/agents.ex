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

  def start_link(_options \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
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
  Returns list of all supported agent types in cluster.

  ## Example

    Agents.types
    # => [`%AgentType{name: "Ping", module: "Agents"}]

  """
  @spec types :: list(Matrix.AgentType.t)
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

  @doc """
  Resets data about agent types and running agents.
  """
  @spec reset :: :ok
  def reset do
    GenServer.cast(__MODULE__, {:reset})
  end

  # Server callbacks

  def handle_call({:types}, _from, state) do
    types =
      state.agent_types
      |> Enum.reduce([], fn {_, types}, acc ->
        acc ++ types
      end)

    {:reply, types, state}
  end
  def handle_call({:types, aliaz}, _from, state) do
    {:reply, state.agent_types[aliaz], state}
  end

  def handle_cast({:add_types, aliaz, types}, state) do
    types = state.agent_types |> Map.put_new(aliaz, types)

    {:noreply, %State{agent_types: types, running_agents: state.running_agents}}
  end

  def handle_cast({:delete_types, aliaz}, state) do
    types = state.agent_types |> Map.delete(aliaz)

    {:noreply, %State{agent_types: types, running_agents: state.running_agents}}
  end

  def handle_cast({:reset}, _state) do
    {:noreply, %State{}}
  end

  def init(_) do
    {:ok, %State{}}
  end
end
