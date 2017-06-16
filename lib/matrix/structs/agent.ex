defmodule Matrix.Agent do
  @moduledoc """
  Represents agent.
  """

  alias Matrix.{Agent, AID, AgentType, AgentCenter, Configuration}

  @derive [Poison.Encoder]
  defstruct [:id]

  @type t :: %__MODULE__{id: AID.t}

  @callback handle_message(message :: AclMessage.t, state :: any) :: {:ok, any, any} | {:error, any, any}

  defmacro __using__(options) do
    quote do
      use GenServer

      @behaviour Matrix.Agent

      def start_link(args, _options \\ []) do
        name = elem(args, 1) |> String.capitalize |> String.to_atom

        GenServer.start_link(__MODULE__, name, name: name)
      end

      def init(name) do
        state =
          Matrix.Agent.new(name, Matrix.AgentManager.module_to_type(__MODULE__))
          |> Map.merge(unquote(options[:state]))

        {:ok, state}
      end

      def handle_call({:handle_message, message}, _form, state) do
        case __MODULE__.handle_message(message, state) do
          {:ok, result, new_state}    -> {:reply, {:ok, result}, new_state}
          {:error, reason, new_state} -> {:reply, {:error, reason}, new_state}
        end
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
        host: Configuration.this,
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
