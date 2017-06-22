defmodule Matrix.AgentsChannel do
  use Phoenix.Channel

  def join("agents", _message, socket) do
    {:ok, socket}
  end

end
