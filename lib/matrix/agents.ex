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
    defstruct agent_types: %{}, running_agents: %{}
    @type t :: %__MODULE__{agent_types: map, running_agents: map}
  end

  def start_link(_options \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Client API

  @doc """
  Adds list of agent types to given agent center.

  Args:
    * `aliaz` - Alias of agent center
    * `types` - List of supported agent types

  ## Example

    Agents.add_types(agent_center: "Mars", types: [%AgentType{name: "Ping", module: "Test"}])

  """
  @spec add_types(Keyword.t) :: :ok
  def add_types(agent_center: aliaz, types: types) do
    GenServer.cast(__MODULE__, {:add_types, aliaz, types})
  end

  @doc """
  Deletes agent types of given agent center.

  Args:
    * `aliaz` - Alias of agent center

  ## Example

    Agents.delete_types(agent_center: "Mars")

  """
  @spec delete_types(Keyword.t) :: :ok
  def delete_types(agent_center: aliaz) do
    GenServer.cast(__MODULE__, {:delete_types, aliaz})
  end

  @doc """
  Returns list of all supported agent types in cluster.
  """
  @spec types :: list(Matrix.AgentType.t)
  def types do
    GenServer.call(__MODULE__, {:types})
  end

  @doc """
  Returns list of supported agent types for given agent center.
  """
  @spec types(Keyword.t) :: list(Matrix.AgentType.t)
  def types(for: aliaz) do
    GenServer.call(__MODULE__, {:types, aliaz})
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
