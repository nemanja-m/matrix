defmodule Matrix.ApplicationControllerTest do
  use Matrix.ConnCase

  setup %{conn: conn} do
    conn = put_req_header(conn, "content-type", "application/json")

    {:ok, conn: conn}
  end

  describe "GET /index" do
    it "renders index.html", %{conn: conn} do
      conn = get conn, "/"

      assert html_response(conn, 200)
    end
  end

end
