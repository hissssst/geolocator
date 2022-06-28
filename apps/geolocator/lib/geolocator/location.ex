defmodule Geolocator.Location do
  @moduledoc """
  Defines location imported from CSV
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Geo.Point

  @geosrid 4326

  defguard is_longitude(x) when is_number(x) and x >= -180 and x <= 180
  defguard is_latitude(x) when is_number(x) and x >= -90 and x <= 90

  schema "locations" do
    field :ip_address, EctoNetwork.INET
    field :country_code, :string
    field :country, :string
    field :city, :string
    field :point, Geo.PostGIS.Geometry
    field :mystery_value, :integer

    # This can be moved to custom schema macro,
    # but there's only one schema right now, so this
    # is not neccessary
    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          ip_address: Postgrex.INET.t() | String.t(),
          country_code: String.t(),
          country: String.t(),
          city: String.t(),
          point: Geo.Point.t(),
          mystery_value: non_neg_integer(),
          __meta__: Ecto.Schema.Metadata.t()
        }

  @doc "Generic changeset for Location"
  @spec changeset(Ecto.Changeset.t(t()) | t(), Map.t()) :: Ecto.Changeset.t(t())
  def changeset(location, params \\ %{}) do
    params = lnglat_to_point(params)

    location
    |> cast(params, ~w[ip_address country_code country city point mystery_value]a)
    |> validate_format(:country_code, ~r/^[A-Z][A-Z]$/,
      message: "Only uppercase two-symbol country codes are allowed"
    )
    |> validate_change(:point, fn :point, point ->
      case point do
        %Point{coordinates: {lng, lat}, srid: @geosrid}
        when is_latitude(lat) and is_longitude(lng) ->
          []

        %Point{coordinates: {_, _}, srid: @geosrid} ->
          [point: "Longitude or latitude is out of bounds"]

        %Point{srid: _other} ->
          [point: "only #{@geosrid} srID is allowed"]

        _ ->
          [point: "Only 2D points are allowed"]
      end
    end)
  end

  defp lnglat_to_point(%{point: %Point{}} = params), do: params

  defp lnglat_to_point(%{latitude: latitude, longitude: longitude} = params) do
    Map.put(params, :point, %Point{coordinates: {longitude, latitude}, srid: @geosrid})
  end

  defp lnglat_to_point(params), do: params

  defimpl Jason.Encoder do
    @fields ~w[city country country_code id ip_address mystery_value]a

    def encode(%{point: %Geo.Point{coordinates: {lng, lat}}} = location, opts) do
      location
      |> Map.take(@fields)
      |> inet_to_ip()
      |> Map.merge(%{latitude: lat, longitude: lng})
      |> Jason.Encode.map(opts)
    end

    def encode(location, opts) do
      location
      |> Map.take(@fields)
      |> inet_to_ip()
      |> Map.merge(%{latitude: nil, longitude: nil})
      |> Jason.Encode.map(opts)
    end

    defp inet_to_ip(%{ip_address: %Postgrex.INET{address: {x1, x2, x3, x4}}} = location) do
      %{location | ip_address: "#{x1}.#{x2}.#{x3}.#{x4}"}
    end

    defp inet_to_ip(other), do: other
  end
end
