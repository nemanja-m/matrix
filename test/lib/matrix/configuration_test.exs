defmodule ConfigurationTest do
  use ExSpec, async: true

  alias Matrix.Configuration

  import Mock

  describe ".is_master_node?" do
    context "when node is master" do
      it "returns true" do
        assert Configuration.is_master_node?
      end
    end

    context "when node is not master" do
      it "returns false" do
        with_mock Application, [get_env: fn (_, _) -> "false" end] do
          refute Configuration.is_master_node?
        end
      end
    end
  end
end
