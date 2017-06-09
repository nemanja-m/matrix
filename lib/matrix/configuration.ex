defmodule Matrix.Configuration do

  def is_master_node? do
    (Application.get_env(:matrix, :master_node) |> String.downcase) == "true"
  end

end
