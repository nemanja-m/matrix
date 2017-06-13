defmodule Matrix.AgentsTest do
  use ExSpec

  alias Matrix.{Agents, AgentType}

  setup do
    Agents.reset
  end

  @ping %AgentType{name: "Ping", module: "Test"}
  @pong %AgentType{name: "Pong", module: "Test"}

  describe ".add_types" do
    it "adds new types for given agent center" do
      Agents.add_types(agent_center: "Mars", types: [@ping])

      assert Agents.types == [@ping]

      Agents.add_types(agent_center: "Neptune", types: [@pong])

      assert Agents.types == [@ping, @pong]
    end
  end

  describe ".delete_types" do
    it "deletes types for given agent center" do
      Agents.add_types(agent_center: "Mars", types: [@ping])
      Agents.add_types(agent_center: "Neptune", types: [@pong])

      assert Agents.types == [@ping, @pong]

      Agents.delete_types(agent_center: "Mars")

      assert Agents.types == [@pong]
      refute Agents.types(for: "Mars")
    end
  end

  describe ".types/0" do
    it "returns list of all agent types in cluster" do
      Agents.add_types(agent_center: "Mars", types: [@ping])
      Agents.add_types(agent_center: "Neptune", types: [@pong])

      assert Agents.types == [@ping, @pong]
    end
  end

  describe ".types/1" do
    it "returns agent types for given agent center" do
      Agents.add_types(agent_center: "Mars", types: [@ping])
      Agents.add_types(agent_center: "Neptune", types: [@pong])

      assert Agents.types(for: "Mars") == [@ping]
    end
  end

  describe ".reset" do
    it "resets all data" do
      Agents.add_types(agent_center: "Mars", types: [@ping])
      Agents.add_types(agent_center: "Neptune", types: [@pong])

      assert Agents.types == [@ping, @pong]

      Agents.reset

      assert Agents.types == []
    end
  end
end
