defmodule ConnectionManagerTest do
  use ExSpec, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  import Mock

  alias Matrix.{Configuration, ConnectionManager}

  setup_all do
    ExVCR.Config.cassette_library_dir("", "fixture/cassettes")
    :ok
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
end
