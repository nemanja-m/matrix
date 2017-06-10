defmodule Matrix.ConnectionManager do
  alias Matrix.Configuration

  require Logger

  def register_self do
    register_self(master_node: Configuration.is_master_node?)
  end
  defp register_self(master_node: false) do
    headers = [
      {"Content-Type", "application/json"}
    ]

    url = "#{Configuration.master_node_url}/node"
    body = Configuration.this

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200}} ->
        Logger.info "Node registered successfully"
        :ok
      _ ->
        Logger.error "Node registeration failed"
        :error
    end
  end
  defp register_self(master_node: true), do: nil

end
