defmodule CsvEx do
  @moduledoc """
  Documentation for CsvEx.
  """

  @csv_pattern ~r/(?:^|,)(?=[^"]|(")?)"?((?(1)[^"]*|[^,"]*))"?(?=,|$)/


  @doc """
  Load a CSV data from a CSV formatted string.

  ## Options

    - `:headers` - if `true` elements of the first line are used as CSV headers.
      Each line are parse as Map data.
      If `:atom` keys of Map data as atom. In this case, this function use [`String.to_existing_atom/1`](https://hexdocs.pm/elixir/String.html#to_existing_atom/1).

  ## Examples

      iex> CsvEx.load("abc,def,ghi\\n123,456,789\\n987,654,321\\n")
      [["abc", "def", "ghi"], ["123", "456", "789"], ["987", "654", "321"]]

      iex> CsvEx.load("abc,def,ghi\\n123,456,789\\n987,654,321\\n", headers: true)
      [%{"abc" => "123", "def" => "456", "ghi" => "789"}, %{"abc" => "987", "def" => "654", "ghi" => "321"}]

      iex> CsvEx.load("abc,def,ghi\\n123,456,789\\n987,654,321\\n", headers: :atom)
      [%{abc: "123", def: "456", ghi: "789"}, %{abc: "987", def: "654", ghi: "321"}]
  """
  def load(csv, opts \\ []) when is_list(opts) do
    options = opts |> Map.new()

    csv
    |> split()
    |> apply_headers(options)
  end

  defp split(csv) do
    csv
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      Regex.scan(@csv_pattern, row)
      |> Enum.map(&List.last/1)
    end)
  end

  defp apply_headers(source, %{headers: headers}) when headers or headers == :atom do
    [hs | body] = source

    hs =
      case headers do
        :atom -> hs |> Enum.map(&String.to_existing_atom/1)
        _ -> hs
      end

    body
    |> Enum.map(fn row ->
      Enum.zip(hs, row)
      |> Map.new()
    end)
  end

  defp apply_headers(source, _), do: source
end
