defmodule Matrix.Cluster do
  @moduledoc """
  Holds state about agent centers registered in cluster.

  This module is meant to be used when new agent centers are registered / unregistered
  to / from cluster.

  ## Example

    Cluster.register_node %AgentCenter{aliaz: "Mars, address: "localhost:4000"}
    Cluster.unregister_node "Mars"

  """
  use GenServer

  alias Matrix.{Configuration, AgentCenter}

  defmodule State do
    @moduledoc """
    Map where key is agent center alias and value is agent center address.

    ## Example

      %State{nodes: %{"Mars" => "localhost:4000"}

    """
    defstruct nodes: nil

    @type t :: %__MODULE__{nodes: Map.t}
  end

  def start_link(_options \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Client API

  @doc """
  Returns all agent centers in cluster.

  ## Example

    Cluster.nodes
    # => `[%AgentCenter{aliaz: "Mars", address: "localhost:4000"}]`

  """
  @spec nodes :: list[AgentCenter.t]
  def nodes do
    GenServer.call(__MODULE__, {:nodes})
  end

  @spec address_for(aliaz :: String.t) :: String.t | nil
  def address_for(aliaz) do
    GenServer.call(__MODULE__, {:address_for, aliaz})
  end

  @doc """
  Adds new agent center to cluster.

  Args:
    * agent_center - AgentCenter struct being registered

  ## Example

   Cluster.register_node(%AgentCenter{aliaz: "Mars", address: "MilkyWay"}

  """
  @spec register_node(agent_center :: AgentCenter.t) :: {:ok | :exists}
  def register_node(agent_center) do
    GenServer.call(__MODULE__, {:register_node, agent_center})
  end

  @doc """
  Removes agent center from cluster.

  Args:
    * aliaz - Alias of agent center being unregistered

  ## Example

    Cluster.unregister_node "Mars"

  """
  @spec unregister_node(aliaz :: String.t) :: :ok
  def unregister_node(aliaz) do
    GenServer.cast(__MODULE__, {:unregister_node, aliaz})
  end

  @doc """
  Check if agent center exists in cluster.

  Args:
    * aliaz - Alias of agent center

  ## Example

    Cluster.exists? Configuration.this
    # => `true`

    Cluster.exists? "Venera"
    # => `false`

  """
  @spec exist?(aliaz :: String.t) :: boolean
  def exist?(aliaz) do
    GenServer.call(__MODULE__, {:exist?, aliaz})
  end

  @doc """
  Clears and resets cluster to contain only this agent center.

  ## Example

    Cluster.register_node(%AgentCenter{aliaz: "Mars", address: "MilkyWay"}
    Cluster.reset
    Cluster.nodes
    # => `[Configuration.this]`

  """
  @spec reset :: :ok
  def reset do
    GenServer.cast(__MODULE__, {:reset})
  end

  # Server callbacks

  def handle_call({:nodes}, _from, state) do
    {:reply, nodes_list(state), state}
  end

  def handle_call({:address_for, aliaz}, _from, state) do
    {:reply, state.nodes[aliaz], state}
  end

  def handle_call({:register_node, %AgentCenter{aliaz: aliaz, address: address}}, _from, state) do
    if Map.has_key?(state.nodes, aliaz) do
      {:reply, {:error, :exists}, state}
    else
      nodes = Map.put(state.nodes, aliaz, address)

      {:reply, :ok, %State{nodes: nodes}}
    end
  end

  def handle_call({:exist?, aliaz}, _from, state) do
    {:reply, Map.has_key?(state.nodes, aliaz), state}
  end

  def handle_cast({:unregister_node, aliaz}, state) do
    nodes = Map.delete(state.nodes, aliaz)

    {:noreply, %State{nodes: nodes}}
  end

  def handle_cast({:reset}, _nodes) do
    {:noreply, init_state()}
  end

  def init(_) do
    {:ok, init_state()}
  end

  defp nodes_list(state) do
    state.nodes
    |> Enum.map(fn {aliaz, address} ->
      %AgentCenter{aliaz: aliaz, address: address}
    end)
  end

  defp init_state do
    %State{nodes: %{Configuration.this_aliaz => Configuration.this_address}}
  end

end
