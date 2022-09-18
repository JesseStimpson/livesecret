defmodule LiveSecretWeb.PageControllerTest do
  use LiveSecretWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "LiveSecret"
  end
end
