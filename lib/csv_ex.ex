defmodule CsvEx do
  @moduledoc """
  Documentation for CsvEx.
  """

  @csv_pattern ~r/(?:^|,)(?=[^"]|(")?)"?((?(1)[^"]*|[^,"]*))"?(?=,|$)/

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
