defmodule Matrix.AgentControllerTest do
  use Matrix.ConnCase

  alias Matrix.{Agents, AgentType, Configuration}

  setup do
    Agents.reset
  end

  @ping %AgentType{name: "Ping", module: "Test"}
  @pong %AgentType{name: "Pong", module: "Test"}

  describe "GET /agents/classes" do
    it "returns supported agent types on given agent center", %{conn: conn} do
      Agents.add_types(agent_center: Configuration.this_aliaz, types: [@ping, @pong])

      conn = get conn, "/agents/classes"

      ping = %{"name" => "Ping", "module" => "Test"}
      pong = %{"name" => "Pong", "module" => "Test"}

      assert json_response(conn, 200)["data"] == [ping, pong]
    end
  end
end
