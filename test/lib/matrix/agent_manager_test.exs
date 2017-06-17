defmodule Matrix.AgentManagerTest do
  use ExSpec

  alias Matrix.{Configuration, Agent, AID, AgentCenter, Agents, AgentType, AgentManager}

  setup do
    Agents.reset
  end

  @ping %AgentType{name: "Ping", module: "Test"}
  @pong %AgentType{name: "Pong", module: "Test"}

  @ping_agent %Agent{
    id: %AID{
      name: "Ping",
      host: %AgentCenter{
        aliaz: "Mars",
        address: "localhost:3000"
      },
      type: @ping
    }
  }

  @pong_agent %Agent{
    id: %AID{
      name: "Pong",
      host: %AgentCenter{
        aliaz: "Mars",
        address: "localhost:3000"
      },
      type: @pong
    }
  }

  describe ".self_agent_types" do
    it "returns agent types on this agent center" do
      Agents.add_types(Configuration.this_aliaz, [@ping])
      Agents.add_types("Neptune", [@pong])

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

      assert Agents.types_for("Mars") == [@ping]
      assert Agents.types_for("Neptune") == [@pong]
    end
  end

  describe ".add_running_agents" do
    it "maps running agents to given agent centers" do
      running_agents = %{
        "Mars" => [Map.from_struct(@ping_agent)],
        "Neptune" => [Map.from_struct(@pong_agent)],
      }

      AgentManager.add_running_agents(running_agents)

      assert Agents.running_on("Mars") == [@ping_agent]
      assert Agents.running_on("Neptune") == [@pong_agent]
    end
  end

  describe ".module_to_type" do
    it "converts agent module to agent type" do
      assert AgentManager.module_to_type(Test.Ping) == @ping
    end
  end

  describe ".generate_agent_supervisor_modules" do
    it "generates supervisor modules based on agent types" do
      assert AgentManager.generate_agent_supervisor_modules([@ping]) == [Matrix.PingSupervisor]
    end
  end
end
