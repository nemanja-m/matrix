defmodule Matrix.Heartbeat do
  use GenServer
  use Retry

  import Stream

  require Logger

  alias Matrix.{Cluster, Configuration, ConnectionManager, AgentCenter}

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

      wait lin_backoff(500, 1) |> take(1) do
        case HTTPoison.get(url) do
          {:ok, %HTTPoison.Response{status_code: 200}} -> true

          _ ->
            Logger.warn "Retrying ..."
            false
        end
      then
        Logger.warn "'#{node.aliaz}' is alive"
      else
        Logger.error "'#{node.aliaz}' is dead"

        ConnectionManager.remove_agent_center(node.aliaz)
      end
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
