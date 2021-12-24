defmodule Day07 do
  @moduledoc false

  require Integer

  def input do
    {:ok, input} = File.read('./lib/07/input.txt')

    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> cheapest_consumption(:linear)
  end

  defp part2 do
    input()
    |> cheapest_consumption(:cumulative)
  end

  defp cheapest_consumption(positions, mode) do
    {p0, pf} = Enum.min_max(positions)

    p0..pf
    |> Enum.map(&total_cost(positions, &1, mode))
    |> Enum.min()
  end

  defp total_cost(positions, target, mode) do
    positions
    |> Enum.map(&cost(target, &1, mode))
    |> Enum.sum()
  end

  defp cost(x0, xf, :linear), do: abs(xf - x0)

  defp cost(x0, xf, :cumulative) do
    n = abs(xf - x0)
    div(n * (n + 1), 2)
  end
end
