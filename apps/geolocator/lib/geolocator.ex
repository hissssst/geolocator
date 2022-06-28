defmodule Geolocator do
  @moduledoc """
  Entrypoint for interactions with external systems
  """

  alias Geolocator.{Location, Repo}

  @type either(ok) :: {:ok, ok} | {:error, reason :: any()}

  @doc """
  Imports location from enumerable of maps
  Default chunk size is 66535 (max postgres params size) / (max amount of fields in entry)
  """
  @spec import_locations(Enumerable.t()) :: Map.t()
  def import_locations(enumerable, chunk_size \\ nil) do
    started_at = :erlang.monotonic_time(:millisecond)
    empty_location = struct(Location, [])
    chunk_size = chunk_size || div(65_535, map_size(empty_location) - 2)

    {imported_amount, failed_amount} =
      enumerable
      |> Flow.from_enumerable(max_demand: chunk_size)
      |> Flow.map(fn location -> Location.changeset(empty_location, location) end)
      |> Flow.partition(max_demand: chunk_size)
      |> Flow.map_batch(fn chunk ->
        {imported, failed} = import_chunk(chunk)
        [{imported, Enum.count(failed)}]
      end)
      |> Enum.reduce({0, 0}, fn {imported, failed}, {all_imported, all_failed} ->
        {imported + all_imported, failed + all_failed}
      end)

    %{
      imported: imported_amount,
      failed: failed_amount,
      time: :erlang.monotonic_time(:millisecond) - started_at
    }
  end

  @doc """
  Returns a list locations by passed clauses
  """
  @spec get_locations(Keyword.t()) :: [Location.t()]
  def get_locations(clauses \\ []) do
    import Ecto.Query

    query =
      Enum.reduce(clauses, from(location in Location, select: location, limit: 1_000_000), fn
        {:city, city}, query ->
          city = "%#{city}%"
          where(query, [location], ilike(location.city, ^city))

        {:country, country}, query ->
          country = "%#{country}%"
          where(query, [location], ilike(location.country, ^country))

        filter, query ->
          filter = [filter]
          where(query, ^filter)
      end)

    Repo.all(query)
  end

  @doc """
  Creates a new location in database by passed 
  """
  @spec get_locations(Keyword.t()) :: [Location.t()]
  def create_location(location) do
    Location
    |> struct
    |> Location.changeset(location)
    |> Repo.insert(returning: true)
  end

  # Helpers

  # imports locations in one transaction
  defp import_chunk(changesets) do
    {entries, failed} =
      Enum.reduce(changesets, {[], []}, fn
        %{valid?: true, changes: changes}, {entries, failed} ->
          {[changes | entries], failed}

        %{valid?: false, errors: errors}, {entries, failed} ->
          {entries, [errors | failed]}
      end)

    {inserted_amount, _} = Repo.insert_all(Location, entries)
    {inserted_amount, failed}
  end
end
