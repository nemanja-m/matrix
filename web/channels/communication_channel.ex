defmodule Matrix.CommunicationChannel do
  use Phoenix.Channel

  def join("communication:*", _message, socket) do
    {:ok, socket}
  end

end
