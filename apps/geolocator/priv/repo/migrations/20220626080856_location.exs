defmodule Geolocator.Repo.Migrations.Location do
  use Ecto.Migration

  def up do
    create table("locations") do
      add :ip_address, :inet, comment: "Location IP"
      add :country_code, :string, size: 2, comment: "Two-char country code"
      add :country, :string, comment: "Full name of a country"
      add :city, :string, comment: "Full name of a city"
      add :mystery_value, :bigint, comment: "Mystery value, non negative integer"

      timestamps(type: :utc_datetime, default: fragment("NOW()"))
    end

    # Add like this to enforce type for lng-lat (4326 stands for "standard GPS" point type)
    execute "SELECT AddGeometryColumn ('locations','point',4326,'POINT',2);"
    execute "COMMENT ON COLUMN locations.point IS 'Longitude-Latitude point'"
  end

  def down do
    drop table("locations")
  end
end
