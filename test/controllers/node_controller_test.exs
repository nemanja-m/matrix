defmodule Matrix.NodeControllerTest do
  use Matrix.ConnCase

  import Mock

  setup %{conn: conn} do
    Matrix.Cluster.clear

    conn = put_req_header(conn, "content-type", "application/json")

    {:ok, conn: conn}
  end

  @agent_center %{aliaz: "Neptune", address: "localhost:3000"}

  describe "POST /node" do
    context "when node is master" do

      context "with successful handshake" do
        it "registers node", %{conn: conn} do
          with_mock HTTPoison, [post!: fn (_, _, _) -> "ok" end] do
            conn = post conn, "/node", data: [@agent_center]

            assert response(conn, 200)
          end
        end
      end

      context "with unsuccessful handshake" do
        it "doesn't register node", %{conn: conn} do
          conn = post conn, "/node", data: [%{aliaz: "Mars", address: "MilkyWay"}]

          assert response(conn, 400)
        end
      end
    end
  end
end
