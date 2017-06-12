defmodule Matrix.Heartbeat do
  use GenServer

  alias Matrix.{Cluster, Configuration, AgentCenter}

  # 1 minute
  @period 1000 * 60

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()

    {:ok, state}
  end

  def handle_info(:work, state) do
    agent_centers()
    |> Enum.each(fn node ->
      url = "#{node.address}/node"

      IO.inspect HTTPoison.get(url)
    end)

    schedule_work()

    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @period)
  end

  defp agent_centers do
    Cluster.nodes
    |> Enum.reject(fn %AgentCenter{aliaz: aliaz} ->
      Configuration.this_aliaz == aliaz
    end)
  end
end
