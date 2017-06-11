defmodule Matrix.ClusterTest do
  use ExSpec, async: true

  alias Matrix.{Cluster, Configuration}

  describe ".start_link" do
    it "initializes cluster with this node" do
      assert Cluster.nodes == [Configuration.this]
    end
  end

end
