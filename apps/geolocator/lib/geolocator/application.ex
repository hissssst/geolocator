defmodule Geolocator.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Geolocator.Repo
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Geolocator.Supervisor)
  end
end
