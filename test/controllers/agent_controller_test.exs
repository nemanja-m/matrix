defmodule Matrix.AgentControllerTest do
  use Matrix.ConnCase

  alias Matrix.{Agents, AgentType, Configuration}

  setup do
    Agents.reset
  end

  @ping %AgentType{name: "Ping", module: "Test"}
  @pong %AgentType{name: "Pong", module: "Test"}

  @ping_map %{"name" => "Ping", "module" => "Test"}
  @pong_map %{"name" => "Pong", "module" => "Test"}

  describe "GET /agents/classes" do
    it "returns supported agent types on given agent center", %{conn: conn} do
      Agents.add_types(Configuration.this_aliaz, [@ping, @pong])

      conn = get conn, "/agents/classes"

      assert json_response(conn, 200)["data"] == [@ping_map, @pong_map]
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
end
