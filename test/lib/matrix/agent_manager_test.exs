defmodule Matrix.AgentManagerTest do
  use ExSpec

  import Mock

  alias Matrix.{Cluster, Env, Agent, AID, Agents, AgentType, AgentCenter, AgentManager}

  setup do
    Agents.reset
    Cluster.reset
  end

  @neptune %AgentCenter{aliaz: "Neptune", address: "localhost:5000"}
  @venera %AgentCenter{aliaz: "Venera", address: "localhost:6000"}

  @ping %AgentType{name: "Ping", module: "Test"}
  @pong %AgentType{name: "Pong", module: "Test"}

  @ping_agent %Agent{
    id: %AID{
      name: "Ping",
      host: Env.this,
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

  defp stop_agent(name) do
    name |> String.capitalize |> String.to_atom |> GenServer.stop(:shutdown)
  end

  describe ".self_agent_types" do
    it "returns agent types on this agent center" do
      Agents.add_types(Env.this_aliaz, [@ping])
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

  describe ".start_agent" do
    context "current host supports agent type" do
      it "adds running agent to agent center" do
        Agents.add_types(Env.this_aliaz, [@ping])
        AgentManager.start_agent(@ping, @ping_agent.id.name)

        assert Agents.running_on(Env.this_aliaz) == [@ping_agent]
        assert Supervisor.which_children(Matrix.PingSupervisor) |> Enum.count == 1

        stop_agent(@ping_agent.id.name)
      end

      it "sends post request to other agent centers" do
        with_mock HTTPoison, [post: fn (_, _, _) -> :ok end] do
          Cluster.register_node(@neptune)
          Agents.add_types(Env.this_aliaz, [@ping])
          AgentManager.start_agent(@ping, @ping_agent.id.name)

          url = "#{@neptune.address}/agents/running"
          body = Poison.encode!(%{data: %{Env.this_aliaz => [@ping_agent]}})
          headers = [{"Content-Type", "application/json"}]

          assert called HTTPoison.post(url, body, headers)

          stop_agent(@ping_agent.id.name)
        end
      end
    end

    context "current host doesn't support agent type" do
      it "sends put request to first agent center that supports given type" do
        with_mock HTTPoison, [put: fn (_, _, _) -> :ok end] do
          Cluster.register_node(@neptune)
          Cluster.register_node(@venera)

          Agents.add_types(@neptune.aliaz, [@pong])
          Agents.add_types(@venera.aliaz, [@pong])

          AgentManager.start_agent(@pong, @pong_agent.id.name)

          url = "#{@neptune.address}/agents/running"
          body = Poison.encode!(%{data: %{type: @pong, name: @pong_agent.id.name}})
          headers = [{"Content-Type", "application/json"}]

          assert called HTTPoison.put(url, body, headers)
        end
      end
    end
  end

  describe ".stop_agent" do
    it "deletes running agent from agent center" do
      Agents.add_types(Env.this_aliaz, [@ping])
      AgentManager.start_agent(@ping, @ping_agent.id.name)
      assert Agents.running_on(Env.this_aliaz) == [@ping_agent]

      AgentManager.stop_agent(@ping_agent)
      assert Agents.running_on(Env.this_aliaz) == []
    end

    context "agent's host is current node" do
      it "stops agent's gen_server" do
        Agents.add_types(Env.this_aliaz, [@ping])
        AgentManager.start_agent(@ping, @ping_agent.id.name)
        assert Agents.running_on(Env.this_aliaz) == [@ping_agent]

        AgentManager.stop_agent(@ping_agent)
        assert Supervisor.which_children(Matrix.PingSupervisor) == []
      end

      it "send delete request to other agent centers" do
        with_mock HTTPoison, [
          delete: fn (_, _) -> :ok end,
          post: fn (_, _, _) -> :ok end
        ]

        do
          Cluster.register_node(@neptune)
          Agents.add_types(Env.this_aliaz, [@ping])
          AgentManager.start_agent(@ping, @ping_agent.id.name)
          AgentManager.stop_agent(@ping_agent)

          host = "#{@ping_agent.id.host.aliaz}"
          type = "#{@ping_agent.id.type.name}/#{@ping_agent.id.type.module}"
          url  = "#{@neptune.address}/agents/running/id/#{@ping_agent.id.name}/host/#{host}/type/#{type}?update=true"

          headers = [{"Content-Type", "application/json"}]

          assert called HTTPoison.delete(url, headers)
        end
      end
    end

    context "when agent's host isn't current node" do
      it "sends delete request to agent's host node" do
        with_mock HTTPoison, [delete: fn (_, _) -> "ok" end] do
          AgentManager.stop_agent(@pong_agent)

          host = "#{@pong_agent.id.host.aliaz}"
          type = "#{@pong_agent.id.type.name}/#{@pong_agent.id.type.module}"
          url  = "#{@pong_agent.id.host.address}/agents/running/id/#{@pong_agent.id.name}/host/#{host}/type/#{type}"

          headers = [{"Content-Type", "application/json"}]

          assert called HTTPoison.delete(url, headers)
        end
      end
    end
  end
end
