defmodule Matrix.ClusterTest do
  use ExSpec, async: true

  alias Matrix.{Cluster, Configuration, AgentCenter}

  setup do
    Cluster.clear
  end

  describe ".start_link" do
    it "initializes cluster with this node" do
      assert Cluster.nodes == [Configuration.this]
    end
  end

  describe ".nodes" do
    it "returns nodes in cluster" do
      assert Cluster.nodes == [Configuration.this]
    end
  end

  describe ".clear" do
    it "deletes all nodes except this" do
      :ok = Cluster.register_node(aliaz: "Neptune", address: "MilkyWay")
      assert Cluster.nodes == [Configuration.this, %AgentCenter{aliaz: "Neptune", address: "MilkyWay"}]

      Cluster.clear
      assert Cluster.nodes == [Configuration.this]
    end
  end

  describe ".register_node" do
    context "when node doesn't exist" do
      it "adds node to cluster" do
        assert Cluster.register_node(aliaz: "Neptune", address: "MilkyWay") == :ok
        assert Cluster.nodes == [Configuration.this, %AgentCenter{aliaz: "Neptune", address: "MilkyWay"}]
      end
    end

    context "when node already exist" do
      it "doesn't add node to cluster" do
        node = [
          {:aliaz, Configuration.this_aliaz},
          {:address, Configuration.this_address}
        ]

        assert Cluster.register_node(node) == :already_exist
        assert Cluster.nodes == [Configuration.this]
      end
    end
  end

  describe ".unregister_node" do
    it "deletes node from cluster" do
      Cluster.unregister_node(Configuration.this_aliaz)

      assert Cluster.nodes == []
    end
  end
end
