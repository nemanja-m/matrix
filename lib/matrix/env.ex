defmodule Matrix.Env do
  @moduledoc """
  Provides information about current and master node.
  """

  def is_master_node? do
    (Application.get_env(:matrix, :master_node) || "true")
    |> String.downcase
    |> String.equivalent?("true")
  end

  def master_node_url do
    Application.get_env(:matrix, :master_node_url) || "http://localhost:4000"
  end

  def this do
    %Matrix.AgentCenter{
      aliaz: this_aliaz(),
      address: this_address()
    }
  end

  def this_aliaz do
    Application.get_env(:matrix, :aliaz) || "Mars"
  end

  def this_address do
    host = Application.get_env(:matrix, Matrix.Endpoint)[:url][:host]
    port = Application.get_env(:matrix, Matrix.Endpoint)[:http][:port]

    "#{host}:#{port}"
  end
end
