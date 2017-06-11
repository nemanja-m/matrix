defmodule Matrix.Cluster do
  use GenServer

  alias Matrix.{Configuration, AgentCenter}

  def start_link(_options \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def nodes do
    GenServer.call(__MODULE__, {:nodes})
  end

  def handle_call({:nodes}, _from, nodes) do
    {:reply, nodes_list(nodes), nodes}
  end

  def init(_) do
    # Initialize cluster with this node
    {:ok, Map.put(%{}, Configuration.this_aliaz, Configuration.this_address)}
  end

  defp nodes_list(nodes) do
    nodes
    |> Enum.map(fn {aliaz, address} ->
      %AgentCenter{aliaz: aliaz, address: address}
    end)
  end
end
