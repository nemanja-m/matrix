defmodule Matrix.AgentManagerTest do
  use ExSpec

  import Mock

  alias Matrix.{Cluster, Configuration, Agent, AID, Agents, AgentType, AgentCenter, AgentManager}

  setup do
    Agents.reset
    Cluster.reset
  end

  @neptune %AgentCenter{aliaz: "Neptune", address: "localhost:5000"}

  @ping %AgentType{name: "Ping", module: "Test"}
  @pong %AgentType{name: "Pong", module: "Test"}

  @ping_agent %Agent{
    id: %AID{
      name: "Ping",
      host: Configuration.this,
      type: @ping
    }
  }

  @pong_agent %Agent{
    id: %AID{
      name: "Pong",
      host: @neptune,
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

  describe ".stop_agent" do
    it "deletes running agent from agent center" do
      AgentManager.start_agent(@ping, @ping_agent.id.name)
      assert Agents.running_on(Configuration.this_aliaz) == [@ping_agent]

      AgentManager.stop_agent(@ping_agent)
      assert Agents.running_on(Configuration.this_aliaz) == []
    end

    context "agent's host is current node" do
      it "stops agent's gen_server" do
        AgentManager.start_agent(@ping, @ping_agent.id.name)
        assert Agents.running_on(Configuration.this_aliaz) == [@ping_agent]

        AgentManager.stop_agent(@ping_agent)
        assert Supervisor.which_children(Matrix.PingSupervisor) == []
      end

      it "send delete request to other aggent centers" do
        Cluster.register_node(@neptune)

        with_mock HTTPoison, [delete: fn (_, _, _) -> "ok" end] do
          AgentManager.start_agent(@ping, @ping_agent.id.name)
          AgentManager.stop_agent(@ping_agent)

          url = "#{@neptune.address}/agents/running"
          body = Poison.encode!(%{data: @ping_agent |> Map.merge(%{update: true})})
          headers = [{"Content-Type", "application/json"}]

          assert called HTTPoison.delete(url, body, headers)
        end
      end
    end

    context "when agent's host isn't current node" do
      it "sends delete request to agent's host node" do
        with_mock HTTPoison, [delete: fn (_, _, _) -> "ok" end] do
          AgentManager.stop_agent(@pong_agent)

          url = "#{@neptune.address}/agents/running"
          body = Poison.encode!(%{data: @pong_agent})
          headers = [{"Content-Type", "application/json"}]

          assert called HTTPoison.delete(url, body, headers)
        end
      end
    end
  end
end
