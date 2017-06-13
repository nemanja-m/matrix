defmodule Matrix.Cluster do
  use GenServer

  alias Matrix.{Configuration, AgentCenter}

  def start_link(_options \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Client API

  def nodes do
    GenServer.call(__MODULE__, {:nodes})
  end

  def register_node(aliaz: aliaz, address: address) do
    GenServer.call(__MODULE__, {:register_node, aliaz, address})
  end

  def unregister_node(aliaz) do
    GenServer.cast(__MODULE__, {:unregister_node, aliaz})
  end

  def exist?(aliaz) do
    GenServer.call(__MODULE__, {:exist?, aliaz})
  end

  def clear do
    GenServer.cast(__MODULE__, {:clear})
  end

  # Server callbacks

  def handle_call({:nodes}, _from, nodes) do
    {:reply, nodes_list(nodes), nodes}
  end

  def handle_call({:register_node, aliaz, address}, _from, nodes) do
    if Map.has_key?(nodes, aliaz) do
      {:reply, :already_exist, nodes}
    else
      nodes = Map.put(nodes, aliaz, address)

      {:reply, :ok, nodes}
    end
  end

  def handle_call({:exist?, aliaz}, _from, nodes) do
    {:reply, Map.has_key?(nodes, aliaz), nodes}
  end

  def handle_cast({:unregister_node, aliaz}, nodes) do
    {:noreply, Map.delete(nodes, aliaz)}
  end

  def handle_cast({:clear}, _nodes) do
    {:noreply, this_node()}
  end

  def init(_) do
    # Initialize cluster with this node
    {:ok, this_node()}
  end

  defp nodes_list(nodes) do
    nodes
    |> Enum.map(fn {aliaz, address} ->
      %AgentCenter{aliaz: aliaz, address: address}
    end)
  end

  defp this_node do
    Map.put(%{}, Configuration.this_aliaz, Configuration.this_address)
  end
end
