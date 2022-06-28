defmodule GeolocatorTest do
  use Geolocator.DataCase

  defp ip_int, do: StreamData.integer(0..255)

  defp sample_data do
    import StreamData

    name = string(Enum.concat([[?\s], ?a..?z, ?A..?z]), length: 1..255)

    optional_map(%{
      ip_address:
        frequency([
          {98, tuple({ip_int(), ip_int(), ip_int(), ip_int()})},
          {1, constant("123.123.123.123")},
          {1, constant("0.0.0.256")}
        ]),
      country_code: string(?A..?Z, length: 2),
      # TIL Longest country name is "United Kingdom of ..."
      country: name,
      city: name,
      latitude: float(min: -90.0, max: 90.0),
      longitude: float(min: -180.0, max: 180.0),
      mystery_value: integer(0..999_999_999)
    })
  end

  @valid_data %{
    ip_address: {1, 2, 3, 4},
    country_code: "XX",
    country: "XXland",
    city: "The Capital of XXland",
    latitude: -84.87503094689836,
    longitude: 170.87503094689836,
    mystery_value: 0
  }

  @invalid_data %{
    ip_address: {1, 2, 3, 4},
    country_code: "XX",
    country: "XXland",
    city: "The Capital of XXland",
    latitude: -100,
    longitude: 200.0,
    mystery_value: 123
  }

  describe "Import" do
    test "valid import" do
      assert %{imported: 1, failed: 0} = Geolocator.import_locations([@valid_data])
    end

    test "invalid import" do
      assert %{imported: 0, failed: 1} = Geolocator.import_locations([@invalid_data])
    end

    test "property test" do
      assert %{imported: imported, failed: failed} =
               sample_data()
               |> Enum.take(10_000)
               # to test chunking
               |> Geolocator.import_locations(100)

      assert imported + failed == 10_000
      assert imported > 0
      assert failed > 0
    end
  end

  describe "Getting locations" do
    setup do
      1..1000
      |> Stream.map(fn i -> %{@valid_data | mystery_value: i} end)
      |> Geolocator.import_locations()
    end

    test "by mystery_value" do
      assert [%{mystery_value: 1}] = Geolocator.get_locations(mystery_value: 1)
      assert [] = Geolocator.get_locations(mystery_value: 0)
    end

    test "by country code" do
      values = Geolocator.get_locations(country_code: "XX")
      assert 1000 == Enum.count(values)
    end

    test "by country" do
      values = Geolocator.get_locations(country: "XX")
      assert 1000 == Enum.count(values)
    end
  end

  describe "Creating location" do
    # TODO test which actually test intersections and stuff
    test "just create" do
      assert {:ok, %{country_code: "XX"}} = Geolocator.create_location(%{"country_code" => "XX"})
      assert [%{country_code: "XX"}] = Geolocator.get_locations(country_code: "XX")
    end
  end
end
