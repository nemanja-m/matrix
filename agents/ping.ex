defmodule Ping do
  use Matrix.Agent,
    state: %{}

  def handle_message(message, state) do
    {:ok, "#{message} from #{state.id.name}", state}
  end
end
