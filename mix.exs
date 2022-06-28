defmodule Geolocator.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases(),
      aliases: aliases()
    ]
  end

  defp releases do
    [
      default_release: [
        include_executables_for: [:unix],
        strip_beams: true,
        applications: [
          geolocator: :permanent,
          geolocator_web: :permanent
        ]
      ]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: ~w[dev test]a, runtime: false}
    ]
  end

  defp aliases do
    [
      # run `mix setup` in all child apps
      setup: ["cmd mix setup"]
    ]
  end
end
