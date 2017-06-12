defmodule Matrix.ConnectionManager do
  alias Matrix.{Configuration, AgentCenter, Cluster}

  require Logger

  def register_self do
    register_self(master_node: Configuration.is_master_node?)
  end
  defp register_self(master_node: false) do
    url = "#{Configuration.master_node_url}/node"
    body = Poison.encode! %{data: [Configuration.this]}
    headers = [
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info "Node registered successfully"
        :ok

      {:ok, response} ->
        body = Poison.decode! response.body
        Logger.error "Node registeration failed: #{body["error"]}"
        :error

      _ ->
        Logger.error "Node registeration failed"
        :error
    end
  end
  defp register_self(master_node: true), do: nil

  def register_agent_center(aliaz: aliaz, address: address) do
    if Configuration.is_master_node? do
      update_cluster(%AgentCenter{aliaz: aliaz, address: address})
      update_new_agent_center(address)
    end

    Cluster.register_node(aliaz: aliaz, address: address)

    Logger.warn "Agent center '#{aliaz}' registered"
  end

  defp update_cluster(new_center) do
    agent_centers()
    |> Enum.each(fn %AgentCenter{address: address} ->
      url = "#{address}/node"
      body = Poison.encode! %{data: [new_center]}
      headers = [
        {"Content-Type", "application/json"}
      ]

      HTTPoison.post!(url, body, headers)
    end)
  end

  defp update_new_agent_center(address) do
    url = "#{address}/node"
    body = Poison.encode! %{data: Cluster.nodes}
    headers = [
      {"Content-Type", "application/json"}
    ]

    HTTPoison.post!(url, body, headers)
  end

  defp agent_centers do
    Cluster.nodes
    |> Enum.reject(fn %AgentCenter{aliaz: aliaz} ->
      Configuration.this_aliaz == aliaz
    end)
  end

  def remove_agent_center(aliaz) do
    clear_agent_center_data(aliaz)

    agent_centers
    |> Enum.each(fn %AgentCenter{address: address} ->
      url = "#{address}/node/#{aliaz}"

      HTTPoison.delete(url)
    end)
  end

  def clear_agent_center_data(aliaz) do
    Cluster.unregister_node(aliaz)

    Logger.warn "'#{aliaz}' removed from cluster"

    # TODO Delete agent data
  end
end
