defmodule Matrix.AgentsTest do
  use ExSpec

  alias Matrix.{Env, Cluster, Agents, Agent, AID, AgentType, AgentCenter}

  setup do
    Agents.reset
    Cluster.reset
  end

  @neptune %AgentCenter{aliaz: "Neptune", address: "lcalhost:2000"}

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
      assert Agents.types_for("Mars") == [@ping]

      Agents.add_types("Neptune", [@pong])
      assert Agents.types_for("Neptune") == [@pong]
    end
  end

  describe ".delete_types_for" do
    it "deletes types for given agent center" do
      Agents.add_types("Mars", [@ping])
      Agents.add_types("Neptune", [@pong])

      assert Agents.types == %{
        "Mars" => [@ping],
        "Neptune" => [@pong]
      }

      Agents.delete_types_for("Mars")

      assert Agents.types == %{ "Neptune" => [@pong] }
      assert Agents.types_for("Mars") == []
    end
  end

  describe ".types" do
    it "returns map of all agent types in cluster for each agent center" do
      Agents.add_types("Mars", [@ping])
      Agents.add_types("Neptune", [@pong])

      assert Agents.types == %{
        "Mars" => [@ping],
        "Neptune" => [@pong]
      }
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

  describe ".delete_running" do
    it "deletes running agent from agent center" do
      Agents.add_running("Mars", [@ping_agent])
      assert Agents.running_on("Mars") == [@ping_agent]

      Agents.delete_running(@ping_agent)
      assert Agents.running_on("Mars") == []
    end
  end

  describe ".reset" do
    it "resets all data" do
      Agents.add_types("Mars", [@ping])
      Agents.add_types("Neptune", [@pong])

      assert Agents.types == %{
        "Mars" => [@ping],
        "Neptune" => [@pong]
      }

      Agents.reset

      assert Agents.types == %{}
    end
  end

  describe ".find_agent_center_with_type" do
    context "when there are agent centers having given agent type" do
      it "returns first agent center that supports given type" do
        Cluster.register_node(@neptune)
        Agents.add_types(@neptune.aliaz, [@ping])
        Agents.add_types(Env.this_aliaz, [@ping])

        assert Agents.find_agent_center_with_type(@ping) == @neptune
      end
    end

    context "when there are NO agent centers having given agent type" do
      it "returns nil" do
        refute Agents.find_agent_center_with_type(@ping)
      end
    end
  end

  describe ".exists?" do
    context "there is agent with given name in cluster" do
      it "returns true" do
        Agents.add_running(@neptune.aliaz, [@ping_agent])

        assert Agents.exists?(@ping_agent.id.name)
      end
    end

    context "there are no agents with given name in cluster" do
      it "returns false" do
        refute Agents.exists?(@ping_agent.id.name)
      end
    end
  end

  describe ".delete_running_for" do
    it "deletes running agnets on given node" do
      Agents.add_running("Mars", [@ping_agent])
      assert Agents.running_on("Mars") == [@ping_agent]

      Agents.delete_running_for("Mars")
      assert Agents.running_on("Mars") == []
    end
  end
end
