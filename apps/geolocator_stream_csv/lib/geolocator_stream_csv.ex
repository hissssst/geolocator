defmodule GeolocatorStreamCsv do
  @moduledoc """
  Transforms CSV string content to importable stream
  """

  alias NimbleCSV.RFC4180, as: CSV

  @default_header ~w[ip_address country_code country city latitude longitude mystery_value]

  @doc """
  Given an enumerable of CSV RFC4180 format binary chunks, produces a stream of geolocator data
  """
  @spec from_lines(Enumerable.t(), [String.t()] | String.t()) :: Stream.t()
  def from_chunks(chunks, header \\ @default_header) do
    chunks
    |> CSV.to_line_stream()
    |> from_lines(header)
  end

  @doc """
  Given an enumerable of CSV RFC4180 format lines, produces a stream of geolocator data
  """
  @spec from_lines(Enumerable.t(), [String.t()] | String.t()) :: Stream.t()
  def from_lines(lines_stream, header \\ @default_header)

  def from_lines(lines_stream, header) when is_binary(header) do
    from_lines(lines_stream, CSV.parse_string(header, skip_headers: false))
  end

  def from_lines(lines_stream, header) do
    header = atom_header(header)

    lines_stream
    |> CSV.parse_stream(skip_headers: false)
    |> Stream.map(fn line ->
      parse_line(line, header)
    end)
  end

  @fields Map.new(
            @default_header,
            fn f -> {f, String.to_atom(f)} end
          )

  defmacrop unpack(code) do
    quote do
      case unquote(code) do
        {value, ""} -> value
        _ -> nil
      end
    end
  end

  # Transofmrs a csv-parsed line with headers into keyword
  # suitable for importing
  @spec parse_line([String.t()], [atom()], Map.t()) :: Map.t()
  defp parse_line(line, header, acc \\ default())
  defp parse_line(l, r, acc) when [] in [l, r], do: acc

  defp parse_line([_value | line], [nil | header], acc) do
    parse_line(line, header, acc)
  end

  defp parse_line(["" | line], [_field | header], acc) do
    parse_line(line, header, acc)
  end

  defp parse_line([value | line], [field | header], acc) when field in ~w[latitude longitude]a do
    parse_line(line, header, %{acc | field => unpack(Float.parse(value))})
  end

  defp parse_line([value | line], [:country_code | header], acc) do
    parse_line(line, header, %{acc | country_code: String.upcase(value)})
  end

  defp parse_line([value | line], [:mystery_value | header], acc) do
    parse_line(line, header, %{acc | mystery_value: unpack(Integer.parse(value))})
  end

  defp parse_line([value | line], [field | header], acc) do
    parse_line(line, header, %{acc | field => value})
  end

  @spec atom_header([String.t()]) :: [atom()]
  defp atom_header([]), do: []

  defp atom_header([field | tail]) do
    [Map.get(@fields, field, nil) | atom_header(tail)]
  end

  defp default do
    %{
      city: nil,
      country_code: nil,
      country: nil,
      ip_address: nil,
      latitude: nil,
      longitude: nil,
      mystery_value: nil
    }
  end
end
