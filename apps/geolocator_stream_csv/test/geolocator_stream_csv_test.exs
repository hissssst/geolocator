defmodule GeolocatorStreamCsvTest do
  use ExUnit.Case, async: true

  test "transforms" do
    assert %Stream{} =
             result =
             """
             1.2.3.4,XX,XXland,Capital of XXland,-10.0001,10.0002,123
             ,XX,XXland,Capital of XXland,-10.0001,10,0
             """
             |> String.split("\n")
             |> Enum.reject(&(&1 == ""))
             |> GeolocatorStreamCsv.from_lines(
               ~w[ip_address country_code country city latitude longitude mystery_value]
             )

    list = Enum.to_list(result)

    assert(
      %{
        ip_address: "1.2.3.4",
        country_code: "XX",
        country: "XXland",
        city: "Capital of XXland",
        longitude: 10.0002,
        latitude: -10.0001,
        mystery_value: 123
      } in list
    )

    assert(
      %{
        ip_address: nil,
        country_code: "XX",
        country: "XXland",
        city: "Capital of XXland",
        longitude: 10.0,
        latitude: -10.0001,
        mystery_value: 0
      } in list
    )
  end
end
