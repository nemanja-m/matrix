defmodule MapReduce.Slave do
  use Matrix.Agent,
    state: %{}

  require Logger

  alias Matrix.{AclMessage, MessageDispatcher, Agents}

  def handle_message(message = %AclMessage{performative: :request}, state) do
    Logger.warn "Agent: #{state.id.name} received #{message.performative} from #{message.sender}"

    words_count =
      message.content
      |> parse_file
      |> count_words

    master = Agents.find_by_name(message.sender)

    message = %AclMessage{
      performative: :inform,
      sender: state.id.name,
      content: Poison.encode!(words_count)
    }

    MessageDispatcher.send_message(master, message)

    {:ok, state}
  end

  defp parse_file(filename) do
    File.read!(filename)
    |> String.replace(~r/[\.,#\{\}\?_%:\"=\(\)\|]/, " ")
    |> String.split
  end

  defp count_words(words) do
    words
    |> Enum.reduce(%{}, fn word, acc ->
      # If we encounter word wor the first time, initialize count to 1
      # else increment count by 1
      Map.update(acc, word, 1, &(&1 + 1))
    end)
  end
end
