defmodule ConnectionManagerTest do
  use ExSpec
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import Mock

  alias Matrix.{Configuration, ConnectionManager, AgentCenter, Cluster}

  setup_all do
    ExVCR.Config.cassette_library_dir("", "fixture/cassettes")
    :ok
  end

  setup do
    Cluster.clear
  end

  describe ".register_self" do
    context "given node is not master" do

      context "with sucessful registration" do
        it "returns :ok" do
          use_cassette "register_node_ok", custom: true do
            with_mock Configuration, [:passthrough], [is_master_node?: fn -> false end] do
              assert ConnectionManager.register_self == :ok
            end
          end
        end
      end

      context "with failed registration" do
        it "returns :error" do
          use_cassette "register_node_error", custom: true do
            with_mock Configuration, [:passthrough], [is_master_node?: fn -> false end] do
              assert ConnectionManager.register_self == :error
            end
          end
        end
      end
    end

    context "given node is master" do
      it "doesn't make register request" do
        with_mock Configuration, [:passthrough], [is_master_node?: fn -> true end] do
          refute ConnectionManager.register_self
        end
      end
    end
  end

  describe ".register_agent_center" do
    it "registers given node to cluster" do
      with_mock HTTPoison, [post!: fn (_, _, _) -> {:ok, :response} end] do
        ConnectionManager.register_agent_center(aliaz: "Neptune", address: "localhost:3000")

        assert %AgentCenter{aliaz: "Neptune", address: "localhost:3000"} in Cluster.nodes
      end
    end

    context "when node is master" do
      it "updates other agent centers in cluster with new center" do
        with_mock HTTPoison, [post!: fn (_, _, _) -> {:ok, :response} end] do
          Cluster.register_node(aliaz: "Venera", address: "localhost:5000")

          ConnectionManager.register_agent_center(aliaz: "Neptune", address: "localhost:3000")

          url = "localhost:5000/node"
          body = Poison.encode! %{data: [%{aliaz: "Neptune", address: "localhost:3000"}]}
          headers = [{"Content-Type", "application/json"}]

          assert called HTTPoison.post!(url, body, headers)
        end
      end

      it "updates new agent center with other agent centers" do
        with_mock HTTPoison, [post!: fn (_, _, _) -> {:ok, :response} end] do
          Cluster.register_node(aliaz: "Venera", address: "localhost:5000")

          ConnectionManager.register_agent_center(aliaz: "Neptune", address: "localhost:3000")

          url = "localhost:3000/node"
          body = Poison.encode! %{data: [Configuration.this, %{aliaz: "Venera", address: "localhost:5000"}]}
          headers = [{"Content-Type", "application/json"}]

          assert called HTTPoison.post!(url, body, headers)
        end
      end
    end
  end

  describe ".remove_agent_center" do
    it "sends DELETE /node/:aliaz to all agent centers" do
      with_mock HTTPoison, [delete: fn (_) -> {:ok, :response} end] do
        Cluster.register_node(aliaz: "Venera", address: "localhost:5000")
        ConnectionManager.remove_agent_center("Neptune")

        assert called HTTPoison.delete("localhost:5000/node/Neptune")
      end
    end
  end

  describe ".clear_agent_center_data" do
    it "unregisters node from cluster" do
      venera = %AgentCenter{aliaz: "Venera", address: "localhost:5000"}

      Cluster.register_node(aliaz: venera.aliaz, address: venera.address)
      assert venera in Cluster.nodes

      ConnectionManager.clear_agent_center_data(venera.aliaz)
      refute venera in Cluster.nodes
    end
  end

  describe ".agent_centers" do
    it "returns list of other agent centers" do
      venera = %AgentCenter{aliaz: "Venera", address: "localhost:5000"}

      Cluster.register_node(aliaz: venera.aliaz, address: venera.address)
      assert venera in Cluster.nodes

      assert ConnectionManager.agent_centers == [venera]
    end
  end
end
