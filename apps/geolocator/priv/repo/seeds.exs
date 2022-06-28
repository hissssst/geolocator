# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Geolocator.Repo.insert!(%Geolocator.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

"#{:code.priv_dir(:geolocator)}/data_dump.csv"
|> File.stream!()
|> GeolocatorStreamCsv.from_lines(
  ~w[ip_address country_code country city latitude longitude mystery_value]
)
|> Geolocator.import_locations()
|> IO.inspect(label: :seeds_import)
