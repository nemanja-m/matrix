defmodule Matrix.AgentTest do
  use ExSpec

  alias Matrix.{Agent, AgentCenter, AgentType}

  describe ".from_hash" do
    it "creates Agent struct from hash" do
      hash = %{
        "id" => %{
          "name" => "Ping",
          "host" => %{
            "aliaz": "Mars",
            "address": "localhost:3000"
          },
          "type" => %{
            "name": "Ping",
            "module": "Agents"
          }
        }
      }

      agent = Agent.from_hash(hash)

      assert agent.id.name == "Ping"
      assert agent.id.host == %AgentCenter{aliaz: "Mars", address: "localhost:3000"}
      assert agent.id.type == %AgentType{name: "Ping", module: "Agents"}
    end
  end
end
