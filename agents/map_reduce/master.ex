defmodule MapReduce.Master do
  use Matrix.Agent,
    state: %{
      slaves_count: 0,
      slaves_completed: 0,
      word_frequency: %{}
    }

  require Logger

  alias Matrix.{AclMessage, MessageDispatcher, AgentManager, AgentType, Agents}

  def handle_message(message = %AclMessage{performative: :request}, state) do
    Logger.warn "#{state.id.name} received #{message.performative} from #{message.sender}"

    files = Path.wildcard("#{message.content}/**/*.ex")

    # Start slave agent for each file in given folder
    files
    |> Enum.with_index
    |> Enum.each(fn {filename, index} ->
      {:ok, slave} =
        %AgentType{module: "MapReduce", name: "Slave"}
        |> AgentManager.start_agent("slave_#{index}")

      message = %AclMessage{
        performative: :request,
        sender: state.id.name,
        content: filename
      }

      MessageDispatcher.send_message(slave, message)
    end)

    # Save number of started slaves
    new_state = put_in(state.slaves_count, files |> Enum.count)

    {:ok, new_state}
  end

  def handle_message(%AclMessage{performative: :inform, content: content}, state) do
    words_count = Poison.decode! content

    new_word_freq = merge(state.word_frequency, words_count)
    slaves_completed = state.slaves_completed  + 1

    new_state = %{
      slaves_count: state.slaves_count,
      slaves_completed: slaves_completed,
      word_frequency: new_word_freq
    }

    case state.slaves_count do
      ^slaves_completed ->
        show_top_ten(new_word_freq)
        stop_slave_agents(state.slaves_count)

        # Reset master agent state
        reset_state(state.id.name)

       _ -> {:ok, new_state}
    end
  end

  def handle_message(_, state), do: {:ok, state}

  defp merge(old_freq, new_freq) do
    Map.merge(old_freq, new_freq, fn _, old_value, new_value ->
      old_value + new_value
    end)
  end

  defp show_top_ten(word_frequency) do
    IO.puts "\n--- Word frequency ---\n"

    word_frequency
    |> Enum.sort_by(fn {_, count} -> count end, &>=/2)
    |> Enum.take(10)
    |> Enum.each(fn {word, count} ->
      IO.puts "#{word} => #{count}"
    end)

    IO.puts "\n----------------------\n"
  end

  defp stop_slave_agents(slaves_count) do
    (0..(slaves_count - 1))
    |> Enum.each(fn index ->
      "slave_#{index}"
      |> Agents.find_by_name
      |> AgentManager.stop_agent
    end)
  end
end
