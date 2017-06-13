defmodule Matrix.AgentManager do

  alias Matrix.{Configuration, Agents, AgentType}

  def self_agent_types do
    Agents.types(for: Configuration.this_aliaz)
  end

  def add_agent_types(types_map) do
    types_map
    |> Enum.each(fn {aliaz, types} ->
      agent_types =
        Enum.map(types, fn %{"name" => name, "module" => module} ->
          %AgentType{name: name, module: module}
        end)

      Agents.add_types(agent_center: aliaz, types: agent_types)
    end)
  end
end
