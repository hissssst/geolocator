defmodule GeolocatorWeb.ImportControllerTest do
  use GeolocatorWeb.ConnCase

  @data """
  1.2.3.4,XX,XXland,Capital of XXland,-10.0001,10.0002,123
  ,XX,XXland,Capital of XXland,-10.0001,10,0
  """

  test "just works TM", %{conn: conn} do
    %{"imported" => 2, "failed" => 0} =
      conn
      |> put_req_header("content-type", "application/csv")
      |> post("/api/v1/import", @data)
      |> json_response(200)
  end
end
