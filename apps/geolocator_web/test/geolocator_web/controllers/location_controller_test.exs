defmodule GeolocatorWeb.LocationControllerTest do
  use GeolocatorWeb.ConnCase

  setup do
    {:ok, %{id: id}} = Geolocator.create_location(%{country_code: "XX", country: "XXland"})
    {:ok, %{id: id}}
  end

  describe "Index" do
    test "valid", %{conn: conn} do
      assert [%{"country_code" => "XX", "country" => "XXland"}] =
               conn
               |> get("/api/v1/location")
               |> json_response(200)
    end

    test "empty query", %{conn: conn} do
      assert [] =
               conn
               |> get("/api/v1/location?country_code=YY")
               |> json_response(200)
    end
  end

  test "Show", %{conn: conn, id: id} do
    assert %{"country_code" => "XX"} =
             conn
             |> get("/api/v1/location/#{id}")
             |> json_response(200)
  end

  test "Create", %{conn: conn} do
    assert %{"country_code" => "ZZ"} =
             conn
             |> post("/api/v1/location", %{country_code: "ZZ"})
             |> json_response(200)

    assert [_] = Geolocator.get_locations(country_code: "ZZ")
  end
end
