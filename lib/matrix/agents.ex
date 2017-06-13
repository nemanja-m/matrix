defmodule Matrix.Agents do
  use GenServer

  defmodule State do
    defstruct agent_types: %{}, running_agents: %{}
    @type t :: %__MODULE__{agent_types: map, running_agents: map}
  end

  def start_link(_options \\ []) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # Client API

  def add_types(agent_center: aliaz, types: types) do
    GenServer.cast(__MODULE__, {:add_types, aliaz, types})
  end

  def delete_types(agent_center: aliaz) do
    GenServer.cast(__MODULE__, {:delete_types, aliaz})
  end

  def types do
    GenServer.call(__MODULE__, {:types})
  end
  def types(for: aliaz) do
    GenServer.call(__MODULE__, {:types, aliaz})
  end

  def reset do
    GenServer.cast(__MODULE__, {:reset})
  end

  # Server callbacks

  def handle_call({:types}, _from, state) do
    types =
      state.agent_types
      |> Enum.reduce([], fn {_, types}, acc ->
        acc ++ types
      end)

    {:reply, types, state}
  end
  def handle_call({:types, aliaz}, _from, state) do
    {:reply, state.agent_types[aliaz], state}
  end

  def handle_cast({:add_types, aliaz, types}, state) do
    types = state.agent_types |> Map.put_new(aliaz, types)

    {:noreply, %State{agent_types: types, running_agents: state.running_agents}}
  end

  def handle_cast({:delete_types, aliaz}, state) do
    types = state.agent_types |> Map.delete(aliaz)

    {:noreply, %State{agent_types: types, running_agents: state.running_agents}}
  end

  def handle_cast({:reset}, _state) do
    {:noreply, %State{}}
  end

  def init(_) do
    {:ok, %State{}}
  end
end
