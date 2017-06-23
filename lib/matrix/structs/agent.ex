defmodule Matrix.Agent do
  @moduledoc """
  Represents agent.
  """

  alias Matrix.{Agent, AID, AgentType, AgentCenter, Env}

  @derive [Poison.Encoder]
  defstruct [:id]

  @type t :: %__MODULE__{id: AID.t}

  @callback handle_message(message :: AclMessage.t, state :: any) :: {:ok, any, any} | {:error, any, any}

  defmacro __using__(options) do
    quote do
      use GenServer

      @behaviour Matrix.Agent

      def start_link(args, _options \\ []) do
        name = elem(args, 1)

        GenServer.start_link(__MODULE__, name, name: name |> String.to_atom)
      end

      def init(name) do
        {:ok, initial_state(name)}
      end

      def reset_state(name) do
        GenServer.cast(name |> String.to_existing_atom, :reset)
      end

      defp initial_state(name) do
        name
        |> Matrix.Agent.new(Matrix.AgentManager.module_to_type(__MODULE__))
        |> Map.merge(unquote(options[:state]))
      end

      def handle_cast({:handle_message, message}, state) do
        case __MODULE__.handle_message(message, state) do
          {_, new_state} -> {:noreply, merge_state(state, new_state)}
          _              -> {:noreply, state}
        end
      end

      defp merge_state(old_state, new_state) do
        Map.merge(old_state, new_state, fn _, old_value, new_value -> new_value end)
      end

      def handle_cast(:reset, state) do
        {:noreply, initial_state(state.id.name)}
      end

      def handle_call(:state, _from, state) do
        {:reply, state, state}
      end

    end
  end

  @spec new(name :: String.t, type :: AgentType.t) :: Agent.t
  def new(name, type) do
    %Agent{
      id: %AID{
        name: name,
        host: Env.this,
        type: type
      }
    }
  end

  def from_hash(hash) do
    hash
    |> Poison.encode!
    |> Poison.decode!(as: %Agent{
      id: %AID{
        host: %AgentCenter{},
        type: %AgentType{}
      }
    })
  end

end
