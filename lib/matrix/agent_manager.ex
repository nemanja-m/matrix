defmodule Matrix.AgentManager do

  alias Matrix.{Configuration, Agents, AgentType, Agent}

  def self_agent_types do
    Agents.types_for(Configuration.this_aliaz)
  end

  def add_agent_types(types_map) do
    types_map
    |> Enum.each(fn {aliaz, types} ->
      agent_types =
        Enum.map(types, fn %{"name" => name, "module" => module} ->
          %AgentType{name: name, module: module}
        end)

      Agents.add_types(aliaz, agent_types)
    end)
  end

  def add_running_agents(running_agents_map) do
    running_agents_map
    |> Enum.each(fn {aliaz, agents} ->
      running_agents =
        Enum.map(agents, fn hash -> Agent.from_hash(hash) end)

      Agents.add_running(aliaz, running_agents)
    end)
  end
end
