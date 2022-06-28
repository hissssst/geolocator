defmodule GeolocatorStreamCsv.MixProject do
  use Mix.Project

  def project do
    [
      app: :geolocator_stream_csv,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      # CSV Stream parser
      {:nimble_csv, "~> 1.2"}
    ]
  end
end
