defmodule Matrix.NodeControllerTest do
  use Matrix.ConnCase

  import Mock

  alias Matrix.{Cluster, AgentCenter}

  setup %{conn: conn} do
    Cluster.reset

    conn = put_req_header(conn, "content-type", "application/json")

    {:ok, conn: conn}
  end

  @neptune %AgentCenter{aliaz: "Neptune", address: "localhost:3000"}

  describe "POST /node" do
    context "when node is master" do

      context "with successful handshake" do
        it "registers node", %{conn: conn} do
          with_mock HTTPoison, [post!: fn (_, _, _) -> "ok" end] do
            conn = post conn, "/node", data: [@neptune |> Map.from_struct]

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

  describe "GET /node" do
    it "returns 200", %{conn: conn} do
      conn = get conn, "/node"

      assert response(conn, 200)
    end

    it "returns 'alive'" do
      conn = get build_conn(), "/node"

      assert conn.resp_body =~ "alive"
    end
  end

  describe "DELETE /node" do
    it "unregisters node from cluster", %{conn: conn} do
      Cluster.register_node(@neptune)
      assert (Cluster.nodes |> Enum.count) == 2

      delete conn, "/node/Neptune"
      assert (Cluster.nodes |> Enum.count) == 1
    end
  end
end
