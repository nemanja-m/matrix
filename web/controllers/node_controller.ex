defmodule Matrix.NodeController do
  use Matrix.Web, :controller

  alias Matrix.{Cluster, ConnectionManager}

  plug :set_headers
  plug :check_node when action in [:register]

  def register(conn, %{"data" => agent_centers}) do
    agent_centers
    |> Enum.each(fn %{"aliaz" => aliaz, "address" => address} ->
      ConnectionManager.register_agent_center(aliaz: aliaz, address: address)
    end)

    conn
    |> json("ok")
  end

  def heartbeat(conn, _params) do
    conn
    |> json("alive")
  end

  def unregister(conn, %{"aliaz" => aliaz}) do
    ConnectionManager.clear_agent_center_data(aliaz)

    conn
    |> json("ok")
  end

  defp check_node(conn, true) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Agent center already exists in cluster"})
    |> halt
  end
  defp check_node(conn, false), do: conn
  defp check_node(conn, _) do
    agent_centers = conn.params["data"]

    conn
    |> check_node(
      Enum.any?(agent_centers, fn %{"aliaz" => aliaz, "address" => _addr} ->
        Cluster.exist?(aliaz)
      end)
    )
  end

end
