defmodule Day06 do
  @moduledoc false

  def input do
    {:ok, input} = File.read('./lib/06/input.txt')

    input
    |> String.split(",", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> simulate(80)
    |> count_fish()
  end

  defp part2 do
    input()
    |> simulate(256)
    |> count_fish()
  end

  defp count_fish(state), do: state |> Map.values() |> Enum.sum()

  defp simulate(state, 0), do: state
  defp simulate(state, days), do: simulate(pass_day(state), days - 1)

  defp pass_day(state) do
    ready = Map.get(state, 0, 0)

    for {days, population} <- state, days > 0, into: %{} do
      {days - 1, population}
    end
    |> Map.update(8, ready, &(&1 + ready))
    |> Map.update(6, ready, &(&1 + ready))
  end
end
