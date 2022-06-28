defmodule Geolocator.Repo.Migrations.LoadPostgis do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS PostGIS")
  end

  def down, do: :ok
end
