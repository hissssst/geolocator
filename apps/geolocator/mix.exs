defmodule Geolocator.MixProject do
  use Mix.Project

  def project do
    [
      app: :geolocator,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Geolocator.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Ecto extensions
      {:geo_postgis, "~> 3.4"},
      {:geo, "~> 3.4"},
      {:ecto_network, "~> 1.3"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},

      # Jason -- JSON encoder/decoder
      {:jason, "~> 1.2"},

      # StreamData for property testing
      {:stream_data, "~> 0.5", only: :test, runtime: false},

      # Adapter to import values from stream
      {:geolocator_stream_csv, in_umbrella: true},

      # Easy-to-use GenStage for parallel pipeline stream processing
      {:flow, "~> 1.2"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
