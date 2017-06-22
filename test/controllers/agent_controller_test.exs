defmodule Matrix.AgentControllerTest do
  use Matrix.ConnCase

  import Mock

  alias Matrix.{AgentManager, Agent, AID, AgentType, AgentCenter, Agents, AgentType, Env}

  setup do
    Agents.reset
  end

  @ping %AgentType{name: "Ping", module: "Test"}
  @pong %AgentType{name: "Pong", module: "Test"}

  @ping_map %{"name" => "Ping", "module" => "Test"}
  @pong_map %{"name" => "Pong", "module" => "Test"}

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

  describe "GET /agents/classes" do
    it "returns supported agent types on cluster", %{conn: conn} do
      Agents.add_types("Mars", [@ping, @pong])
      Agents.add_types("Neptune", [@ping])

      conn = get conn, "/agents/classes"

      assert json_response(conn, 200) == %{
        "Mars" => [@ping_map, @pong_map],
        "Neptune" => [@ping_map]
      }
    end
  end

  describe "POST /agents/classes" do
    it "saves agent types for given agent centers, at this node", %{conn: conn} do
      conn = post conn, "/agents/classes", %{data: %{"Mars" => [@ping_map], "Neptune" => [@pong_map]}}

      assert Agents.types_for("Mars") == [@ping]
      assert Agents.types_for("Neptune") == [@pong]
      assert json_response(conn, 200)
    end
  end

  describe "GET /agents/running" do
    it "returns all running agents on cluster", %{conn: conn}  do
      Agents.add_running("Mars", [@ping_agent])
      Agents.add_running("Neptune", [@pong_agent])

      conn = get conn, "/agents/running"

      ping = json_response(conn, 200)["Mars"]    |> List.first |> Agent.from_hash
      pong = json_response(conn, 200)["Neptune"] |> List.first |> Agent.from_hash

      assert [ping, pong] == [@ping_agent, @pong_agent]
    end
  end

  describe "PUT /agents/running" do
    it "starts new agent with given name", %{conn: conn} do
      Agents.add_types(Env.this_aliaz, [@ping])

      conn = put conn, "/agents/running", %{data: %{type: @ping_map, name: "Pinger"}}

      assert json_response(conn, 200)
      assert GenServer.call(:Pinger, :state).id.type.name == "Ping"
      assert GenServer.call(:Pinger, :state).id.name == "Pinger"
    end

    context "trying to start agent with taken name" do
      it "returns 400", %{conn: conn} do
        Agents.add_running(Env.this_aliaz, [@ping_agent])

        conn = put conn, "/agents/running", %{data: %{type: @ping_map, name: "Ping"}}

        assert json_response(conn, 400)["error"] =~ "already exists"
      end
    end

    context "when there is server side error" do
      it "returns 500" do
        with_mock AgentManager, [start_agent: fn (_, _) -> {:error, "can't be started"} end] do
          Agents.add_types(Env.this_aliaz, [@ping])

          conn = put conn, "/agents/running", %{data: %{type: @ping_map, name: "Ping"}}

          assert json_response(conn, 500)["error"] =~ "can't be started"
        end
      end
    end
  end
end
