defmodule Matrix.ConnectionManager do
  import Matrix.Retry

  require Logger

  alias Matrix.{Configuration, AgentCenter, Cluster, Agents, AgentManager}

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

  def register_agent_center(agent_center) do
    register_agent_center(agent_center, master_node: Configuration.is_master_node?)
  end
  defp register_agent_center(agent_center, master_node: true) do
    case handshake(agent_center) do
      {:ok, _} ->
        add_agent_center(agent_center)

      {:error, _} ->
        Logger.error "Agent center '#{agent_center.aliaz}' handshake failed"
        remove_agent_center(agent_center.aliaz)
    end
  end
  defp register_agent_center(agent_center, master_node: false) do
    add_agent_center(agent_center)
  end

  def add_agent_center(agent_center) do
    Cluster.register_node(agent_center)
    Logger.warn "Agent center '#{agent_center.aliaz}' registered successfully"
  end

  def remove_agent_center(aliaz) do
    clear_agent_center_data(aliaz)

    agent_centers()
    |> Enum.each(fn %AgentCenter{address: address} ->
      url = "#{address}/node/#{aliaz}"

      HTTPoison.delete(url)
    end)
  end

  def clear_agent_center_data(aliaz) do
    Cluster.unregister_node(aliaz)
    Agents.delete_types_for(aliaz)

    Logger.warn "'#{aliaz}' removed from cluster"

    # TODO Delete agent data
  end

  def agent_centers do
    Cluster.nodes
    |> Enum.reject(fn %AgentCenter{aliaz: aliaz} ->
      Configuration.this_aliaz == aliaz
    end)
  end

  defp handshake(agent_center) do
    agent_center
    |> get_new_agent_center_agent_types
    |> update_other_agent_centers
    |> update_new_agent_center
  end

  defp update_other_agent_centers({:ok, agent_center}) do
    agent_center
    |> send_new_agent_center
    |> send_new_agent_center_agent_types
  end
  defp update_other_agent_centers({:error, reason}), do: {:error, reason}

  defp update_new_agent_center({:ok, agent_center}) do
    agent_center
    |> send_agent_centers
    |> send_agent_types
    |> send_running_agents
  end
  defp update_new_agent_center({:error, reason}), do: {:error, reason}

  defp get_new_agent_center_agent_types(agent_center) do
    url = "#{agent_center.address}/agents/classes"

    retry delay: 500, count: 1 do
      case HTTPoison.get(url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          Poison.decode!(body)["data"]
          |> AgentManager.add_agent_types
          true

        _ ->
          Logger.warn "[RETRY] GET #{url}"
          false
      end
    after
      {:ok, agent_center}
    else
      {:error, :handshake_failed}
    end
  end

  defp send_new_agent_center(agent_center) do
    agent_centers()
    |> Enum.map(fn %AgentCenter{address: address} ->
      url = "#{address}/node"
      body = Poison.encode! %{data: [agent_center]}
      headers = [
        {"Content-Type", "application/json"}
      ]

      retry_post url: url, body: body, headers: headers
    end)
    |> Enum.any?(fn {status, _} -> status == :error end)
    |> case do
      false -> {:ok, agent_center}
      true  -> {:error, :handshake_failed}
    end
  end

  defp send_new_agent_center_agent_types({:ok, agent_center}) do
    agent_centers()
    |> Enum.map(fn %AgentCenter{address: address} ->
      url = "#{address}/agent/classes"
      body = Poison.encode! %{data: %{agent_center.aliaz => Agents.types_for(agent_center.aliaz)}}
      headers = [
        {"Content-Type", "application/json"}
      ]

      retry_post url: url, body: body, headers: headers
    end)
    |> Enum.any?(fn {status, _} -> status == :error end)
    |> case do
      false -> {:ok, agent_center}
      true  -> {:error, :handshake_failed}
    end
  end
  defp send_new_agent_center_agent_types(error), do: error

  defp send_agent_centers(agent_center) do
    url = "#{agent_center.address}/node"
    body = Poison.encode! %{data: Cluster.nodes}
    headers = [
      {"Content-Type", "application/json"}
    ]

    case retry_post url: url, body: body, headers: headers do
      {:ok, _} -> {:ok, agent_center}
      error    -> error
    end
  end

  defp send_agent_types({:ok, agent_center}) do
    url = "#{agent_center.address}/agents/classes"
    body = Poison.encode! %{data: Agents.types}
    headers = [
      {"Content-Type", "application/json"}
    ]

    case retry_post url: url, body: body, headers: headers do
      {:ok, _} -> {:ok, agent_center}
      error    -> error
    end
  end
  defp send_agent_types(error), do: error

  defp send_running_agents({:ok, agent_center}) do
    url = "#{agent_center.address}/agents/running"
    body = Poison.encode! %{data: Agents.running_per_agent_center}
    headers = [
      {"Content-Type", "application/json"}
    ]

    case retry_post url: url, body: body, headers: headers do
      {:ok, _} -> {:ok, agent_center}
      error    -> error
    end
  end
  defp send_running_agents(error), do: error

end
