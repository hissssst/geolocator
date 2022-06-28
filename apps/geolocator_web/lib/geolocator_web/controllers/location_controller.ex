defmodule GeolocatorWeb.LocationController do
  use GeolocatorWeb, :controller

  @fields ~w[city country country_code id ip_address mystery_value]

  def index(conn, params) do
    json(conn, Geolocator.get_locations(parse_params(params)))
  end

  def show(conn, params) do
    case Geolocator.get_locations(parse_params(params)) do
      [] ->
        resp(conn, 404, Jason.encode!(%{reason: "Not found"}))

      [found] ->
        json(conn, found)
    end
  end

  def create(conn, params) do
    case Geolocator.create_location(params) do
      {:ok, location} ->
        json(conn, location)

      # TODO proper erorrs rendering
      {:error, %{errors: errors}} ->
        resp(conn, 400, Jason.encode!(%{reason: "#{inspect(errors)}"}))
    end
  end

  defp parse_params(params) do
    Enum.flat_map(params, fn
      {field, value} when field in @fields ->
        [{String.to_existing_atom(field), value}]

      _ ->
        []
    end)
  end
end
