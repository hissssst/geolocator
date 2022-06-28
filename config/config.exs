# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Repo
config :geolocator,
  ecto_repos: [Geolocator.Repo]

config :geolocator, Geolocator.Repo,
  # UTCfication of migration timestamps
  migration_timestamps: [type: :utc_datetime],
  # Postgres adapter with PostGIS types
  adapter: Ecto.Adapters.Postgres,
  types: Geolocator.PostgresTypes

config :geolocator_web,
  ecto_repos: [Geolocator.Repo],
  generators: [context_app: :geolocator]

# Configures the endpoint
config :geolocator_web, GeolocatorWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: GeolocatorWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Geolocator.PubSub,
  live_view: [signing_salt: "w/7zEYiv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
