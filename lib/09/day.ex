defmodule Day09 do
  @moduledoc false

  @typep height :: 0..9
  @typep heightmap :: [[height()]]
  @typep coordinates :: {integer(), integer()}

  @spec input() :: heightmap()
  def input do
    {:ok, input} = File.read('./lib/09/input.txt')

    for line <- String.split(input, "\n", trim: true) do
      for height <- String.graphemes(line) do
        height |> String.to_integer()
      end
    end
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> low_points()
    |> Enum.map(fn {_, height} -> risk(height) end)
    |> Enum.sum()
  end

  defp risk(height), do: height + 1

  defp part2 do
    heightmap = input()

    heightmap
    |> low_points()
    |> Enum.map(fn {coords, _} -> basin_size(heightmap, coords) end)
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  @spec basin_size(heightmap(), coordinates()) :: integer()
  defp basin_size(heightmap, coords), do: heightmap |> basin([coords]) |> MapSet.size()

  @spec basin(heightmap(), [coordinates()], MapSet.t(coordinates())) :: MapSet.t(coordinates())
  defp basin(heightmap, queue, visited \\ MapSet.new())
  defp basin(_, [], visited), do: visited

  defp basin(heightmap, [coords | queue], visited) do
    to_visit =
      heightmap
      |> adjacent(coords)
      |> Enum.reject(&(heightmap_at(heightmap, &1) == 9))
      |> Enum.reject(&(&1 in visited))

    basin(heightmap, to_visit ++ queue, MapSet.put(visited, coords))
  end

  @spec low_points(heightmap()) :: [{coordinates(), height()}]
  defp low_points(heightmap) do
    for {row, y} <- Enum.with_index(heightmap),
        {height, x} <- Enum.with_index(row),
        is_lowest?(heightmap, {x, y}) do
      {{x, y}, height}
    end
  end

  @spec is_lowest?(heightmap(), coordinates()) :: boolean()
  defp is_lowest?(heightmap, coordinates) do
    height = heightmap_at(heightmap, coordinates)

    heightmap
    |> adjacent(coordinates)
    |> Enum.all?(&(heightmap_at(heightmap, &1) > height))
  end

  @spec adjacent(heightmap(), coordinates()) :: [height()]
  defp adjacent(heightmap, {x, y}) do
    yf = length(heightmap) - 1
    xf = length(List.first(heightmap, [])) - 1

    [{x - 1, y}, {x + 1, y}, {x, y - 1}, {x, y + 1}]
    |> Enum.reject(fn {x, y} -> x < 0 or y < 0 or x > xf or y > yf end)
  end

  @spec heightmap_at(heightmap(), coordinates()) :: height()
  defp heightmap_at(heightmap, {x, y}), do: heightmap |> Enum.at(y) |> Enum.at(x)
end
