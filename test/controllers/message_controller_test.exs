defmodule Matrix.MessageControllerTest do
  use Matrix.ConnCase

  setup %{conn: conn} do
    conn = put_req_header(conn, "content-type", "application/json")

    {:ok, conn: conn}
  end

  describe "GET /messages" do
    it "returns list of available performatives", %{conn: conn} do
      conn = get conn, "/messages"

      ["inform", "cfp", "request", "refuse"]
      |> Enum.each(fn performative ->
        assert performative in json_response(conn, 200)["data"]
      end)
    end
  end

end
