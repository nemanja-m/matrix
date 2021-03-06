defmodule EnvTest do
  use ExSpec, async: true

  alias Matrix.Env

  import Mock

  describe ".is_master_node?" do
    context "when node is master" do
      it "returns true" do
        with_mock Application, [get_env: fn (_, _) -> "true" end] do
          assert Env.is_master_node?
        end
      end
    end

    context "when node is not master" do
      it "returns false" do
        with_mock Application, [get_env: fn (_, _) -> "false" end] do
          refute Env.is_master_node?
        end
      end
    end
  end

  describe ".master_node_url" do
    test_with_mock "returns master node url", Application, [get_env: fn (:matrix, :master_node_url) -> "http://localhost:4000" end] do
      assert Env.master_node_url == "http://localhost:4000"
    end
  end

  describe ".this" do
    it "returns this agent center struct" do
      assert Env.this.aliaz == "Mars"
      assert Env.this.address == "localhost:4001"
    end
  end

  describe ".this_address" do
    it "returns url of this node" do
      assert Env.this_address == "localhost:4001"
    end
  end

end
