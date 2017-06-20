defmodule Matrix.ClusterTest do
  use ExSpec, async: true

  alias Matrix.{Cluster, Env, AgentCenter}

  setup do
    Cluster.reset
  end

  @neptune %AgentCenter{aliaz: "Neptune", address: "MilkyWay"}

  describe ".start_link" do
    it "initializes cluster with this node" do
      assert Cluster.nodes == [Env.this]
    end
  end

  describe ".nodes" do
    it "returns nodes in cluster" do
      assert Cluster.nodes == [Env.this]
    end
  end

  describe ".reset" do
    it "deletes all nodes except this" do
      :ok = Cluster.register_node(@neptune)
      assert Cluster.nodes == [Env.this, @neptune]

      Cluster.reset
      assert Cluster.nodes == [Env.this]
    end
  end

  describe ".exist?" do
    it "returns true when node exists" do
      assert Cluster.exist?(Env.this_aliaz)
    end

    it "returns false when node doesn't exist" do
      refute Cluster.exist?("Jupiter")
    end
  end

  describe ".register_node" do
    context "when node doesn't exist" do
      it "adds node to cluster" do
        assert Cluster.register_node(@neptune) == :ok
        assert Cluster.nodes == [Env.this, @neptune]
      end
    end

    context "when node already exist" do
      it "doesn't add node to cluster" do
        assert Cluster.register_node(Env.this) == {:error, :exists}
        assert Cluster.nodes == [Env.this]
      end
    end
  end

  describe ".unregister_node" do
    it "deletes node from cluster" do
      Cluster.unregister_node(Env.this_aliaz)

      assert Cluster.nodes == []
    end
  end

  describe ".address_for" do
    context "when agent center exists in cluster" do
      it "returns address for given agent center" do
        assert Cluster.address_for(Env.this_aliaz) == Env.this_address

        Cluster.register_node(@neptune)
        assert Cluster.address_for(@neptune.aliaz) == @neptune.address
      end
    end

    context "when agent cener doesn't exists in cluster" do
      it "returns nil" do
        refute Cluster.address_for("Neptune")
      end
    end
  end
end
