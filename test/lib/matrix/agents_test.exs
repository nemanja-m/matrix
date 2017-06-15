defmodule Matrix.AgentsTest do
  use ExSpec

  alias Matrix.{Agents, Agent, AID, AgentType, AgentCenter}

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

  describe ".add_types" do
    it "adds new types for given agent center" do
      Agents.add_types("Mars", [@ping])

      assert Agents.types == [@ping]

      Agents.add_types("Neptune", [@pong])

      assert Agents.types == [@ping, @pong]
    end
  end

  describe ".delete_types_for" do
    it "deletes types for given agent center" do
      Agents.add_types("Mars", [@ping])
      Agents.add_types("Neptune", [@pong])

      assert Agents.types == [@ping, @pong]

      Agents.delete_types_for("Mars")

      assert Agents.types == [@pong]
      assert Agents.types_for("Mars") == []
    end
  end

  describe ".types" do
    it "returns list of all agent types in cluster" do
      Agents.add_types("Mars", [@ping])
      Agents.add_types("Neptune", [@pong])

      assert Agents.types == [@ping, @pong]
    end
  end

  describe ".types_for" do
    it "returns agent types for given agent center" do
      Agents.add_types("Mars", [@ping])
      Agents.add_types("Neptune", [@pong])

      assert Agents.types_for("Mars") == [@ping]
      assert Agents.types_for("Neptune") == [@pong]
      assert Agents.types_for("Venera") == []
    end
  end

  describe ".running" do
    it "returns all running agents in cluster" do
      Agents.add_running("Mars", [@ping_agent])
      assert Agents.running == [@ping_agent]

      Agents.add_running("Mars", [@pong_agent])
      assert Agents.running == [@ping_agent, @pong_agent]
    end
  end

  describe ".running_on" do
    it "returns running agents on given agent center" do
      Agents.add_running("Mars", [@ping_agent])
      Agents.add_running("Neptune", [@pong_agent])

      assert Agents.running_on("Mars") == [@ping_agent]
    end
  end

  describe ".running_per_agent_center" do
    it "returns map of running agents per each agent center" do
      Agents.add_running("Mars", [@ping_agent])
      Agents.add_running("Neptune", [@pong_agent])

      running_agents = Agents.running_per_agent_center

      assert running_agents["Mars"] == [@ping_agent]
      assert running_agents["Neptune"] == [@pong_agent]
    end
  end
  describe ".add_running" do
    it "adds new running agent for given agent center" do
      assert Agents.running_on("Mars") == []

      Agents.add_running("Mars", [@ping_agent])
      assert Agents.running_on("Mars") == [@ping_agent]
    end
  end

  describe ".reset" do
    it "resets all data" do
      Agents.add_types("Mars", [@ping])
      Agents.add_types("Neptune", [@pong])

      assert Agents.types == [@ping, @pong]

      Agents.reset

      assert Agents.types == []
    end
  end
end
