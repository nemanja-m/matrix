defmodule Matrix.AgentManagerTest do
  use ExSpec

  alias Matrix.{Configuration, Agents, AgentType, AgentManager}

  setup do
    Agents.reset
  end

  @ping %AgentType{name: "Ping", module: "Test"}
  @pong %AgentType{name: "Pong", module: "Test"}

  describe ".self_agent_types" do
    it "returns agent types on this agent center" do
      Agents.add_types(agent_center: Configuration.this_aliaz, types: [@ping])
      Agents.add_types(agent_center: "Neptune", types: [@pong])

      assert AgentManager.self_agent_types == [@ping]
    end
  end

  describe ".add_agent_types" do
    it "maps agent types to given agent centers" do
      types_map = %{
        "Mars" => [%{"name" => "Ping", "module" => "Test"}],
        "Neptune" => [%{"name" => "Pong", "module" => "Test"}],
      }

      AgentManager.add_agent_types(types_map)

      assert Agents.types(for: "Mars") == [@ping]
      assert Agents.types(for: "Neptune") == [@pong]
    end
  end
end
