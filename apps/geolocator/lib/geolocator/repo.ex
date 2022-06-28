defmodule Geolocator.Repo do
  use Ecto.Repo,
    otp_app: :geolocator,
    adapter: Ecto.Adapters.Postgres
end
