defmodule GeolocatorWeb.Router do
  use GeolocatorWeb, :router

  pipeline :api do
    plug :accepts, ["json", "csv"]
  end

  scope "/api/v1", GeolocatorWeb do
    pipe_through :api
    resources "/location", LocationController, only: ~w[index show create]a
    post "/import", ImportController, :import_data
  end
end
