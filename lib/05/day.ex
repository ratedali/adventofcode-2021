defmodule Day05 do
  @moduledoc false

  def input do
    {:ok, input} = File.read('./lib/05/input.txt')

    for line <- input |> String.split("\n", trim: true) do
      for point <- line |> String.split("->") do
        for coord <- point |> String.split(",") do
          coord |> String.trim() |> String.to_integer()
        end
        |> List.to_tuple()
      end
      |> Enum.sort()
      |> List.to_tuple()
    end
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> Enum.filter(&is_straight?/1)
    |> Enum.flat_map(&line_to_points/1)
    |> Enum.frequencies()
    |> Enum.filter(fn {_, n} -> n > 1 end)
    |> Enum.count()
  end

  defp part2 do
    input()
    |> Enum.flat_map(&line_to_points/1)
    |> Enum.frequencies()
    |> Enum.filter(fn {_, n} -> n > 1 end)
    |> Enum.count()
  end

  defp is_straight?({{x, _}, {x, _}}), do: true
  defp is_straight?({{_, y}, {_, y}}), do: true
  defp is_straight?(_), do: false

  defp line_to_points({{x, y1}, {x, y2}}) do
    y1..y2 |> Enum.map(&{x, &1})
  end

  defp line_to_points({{x1, y}, {x2, y}}) do
    x1..x2 |> Enum.map(&{&1, y})
  end

  defp line_to_points({{x1, y1}, {x2, y2}}) do
    Enum.zip(x1..x2, y1..y2)
  end
end
