defmodule Matrix.ConnectionManager do
  alias Matrix.Configuration

  def register_self do
    unless Configuration.is_master_node? do
      headers = [
        {"Content-Type", "application/json"}
      ]

      HTTPoison.post!("#{Configuration.master_node_url}/node", Configuration.this, headers)
    else
      nil
    end
  end
end
