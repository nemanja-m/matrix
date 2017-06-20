defmodule Matrix.ConnectionManager do
  @moduledoc """
  Handles all communication between agent centers in cluster.

  This module is used for registration / unregistration of new agent centers.

  Also it provides neccesary functions for handshake mechanism between new agent center
  and master node.
  """

  import Matrix.Retry

  require Logger

  alias Matrix.{Env, AgentCenter, Cluster, Agents, AgentManager}

  @doc """
  Registers non-master node to cluster.
  """
  @spec register_self :: {:ok | :error}
  def register_self do
    register_self(master_node: Env.is_master_node?)
  end
  defp register_self(master_node: false) do
    url = "#{Env.master_node_url}/node"
    body = Poison.encode! %{data: [Env.this]}
    headers = [
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info "Node registered successfully"
        :ok

      {:ok, response} ->
        body = Poison.decode! response.body
        Logger.error "Node registration failed: #{body["error"]}"
        :error

      _ ->
        Logger.error "Node registration failed: Unknown error"
        :error
    end
  end
  defp register_self(master_node: true), do: nil

  @doc """
  Registers given agent center in cluster.

  If this node is master that rest of the cluster is updated with new agent center.

  Successful handshake between new agent center and master one is required before
  adding new node to cluster.

  ## Example

    ConnectionManager.register_agent_center(%AgentCenter{aliaz: "Mars", address: "MilkyWay"})

  """
  @spec register_agent_center(agent_center :: Matrix.AgentCenter.t) :: {{:ok, String.t} | {:error, String.t}}
  def register_agent_center(agent_center) do
    register_agent_center(agent_center, master_node: Env.is_master_node?)
  end
  defp register_agent_center(agent_center, master_node: true) do
    case handshake(agent_center) do
      {:ok, _} ->
        add_agent_center(agent_center)

      result = {:error, _} ->
        Logger.error "Agent center '#{agent_center.aliaz}' handshake failed"
        remove_agent_center(agent_center.aliaz)
        result
    end
  end
  defp register_agent_center(agent_center, master_node: false) do
    add_agent_center(agent_center)
  end

  defp add_agent_center(agent_center) do
    case Cluster.register_node(agent_center) do
      :ok ->
        Logger.warn "Agent center '#{agent_center.aliaz}' registered successfully"
        {:ok, ""}

      :exists ->
        {:error, "Node already exists"}
    end
  end

  @doc """
  Clears agent center related data from this node and
  sends message to the other agent centers to do so.

  ## Example

    ConnectionManager.remove_agent_center("Mars")

  """
  @spec remove_agent_center(aliaz :: String.t) :: :ok
  def remove_agent_center(aliaz) do
    clear_agent_center_data(aliaz)

    agent_centers()
    |> Enum.each(fn %AgentCenter{address: address} ->
      url = "#{address}/node/#{aliaz}"

      HTTPoison.delete(url)
    end)
  end

  @doc """
  Deletes all data related to given agent center:

    * agent types
    * running agents

  Agent center is removed from cluster too.

  ## Example

    ConnectionManager.clear_agent_center_data("Mars")

  """
  @spec clear_agent_center_data(agent_center :: String.t) :: any
  def clear_agent_center_data(agent_center) do
    Cluster.unregister_node(agent_center)
    Agents.delete_types_for(agent_center)

    Logger.warn "'#{agent_center}' removed from cluster"

    # TODO Delete agent data
  end

  @doc """
  Returns list of all agent centers in cluster except this one.
  """
  @spec agent_centers :: list(Matrix.AgentCenter.t)
  def agent_centers do
    Cluster.nodes
    |> Enum.reject(fn %AgentCenter{aliaz: aliaz} ->
      Env.this_aliaz == aliaz
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
          Poison.decode!(body)
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
