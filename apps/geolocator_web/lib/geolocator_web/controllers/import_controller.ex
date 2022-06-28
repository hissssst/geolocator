defmodule GeolocatorWeb.ImportController do
  use GeolocatorWeb, :controller

  # 50 MB
  @max_length 50 * 1024 * 1024

  def import_data(conn, _params) do
    conn
    |> stream_body()
    |> GeolocatorStreamCsv.from_chunks()
    |> Geolocator.import_locations()
    |> case do
      %{imported: 0} ->
        send_resp(conn, 400, Jason.encode!(%{reason: "Failed to import any data"}))

      other ->
        json(conn, other)
    end
  end

  defp stream_body(conn) do
    # Stream module is not the best part of Elixir, haha
    Stream.resource(
      fn -> conn end,
      fn conn ->
        case read_body(conn, length: @max_length) do
          {:ok, "", conn} ->
            {:halt, conn}

          {ok_or_more, body, conn} when ok_or_more in ~w[ok more]a ->
            # We can't emit and halt, so when final data is read
            # we emit, then get the error and halt. Nice
            {[body], conn}

          {:error, _} ->
            {:halt, conn}
        end
      end,
      fn conn -> conn end
    )
  end
end
