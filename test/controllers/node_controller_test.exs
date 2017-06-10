defmodule Matrix.NodeControllerTest do
  use Matrix.ConnCase

  alias Matrix.Configuration

  setup %{conn: conn} do
    conn = put_req_header(conn, "content-type", "application/json")

    {:ok, conn: conn}
  end

  describe "POST /node" do
    context "when node is master" do

      context "with successful handshake" do
        it "registers node", %{conn: conn} do
          conn = post conn, "/node", %{aliaz: "Neptune", address: "localhost:3000"}

          assert json_response(conn, 200)
        end
      end

      @tag :skip
      context "with unsuccessful handshake" do
        it "doesn't register node", %{conn: conn} do
          conn = post conn, "/node", %{aliaz: "Neptune", address: "localhost:3000"}

          assert json_response(conn, 500)
        end
      end
    end
  end
end
