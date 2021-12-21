defmodule Day01 do
  @moduledoc false

  def input do
    {:ok, input} = File.read('./lib/01/input.txt')

    input
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> count_increments
  end

  defp part2 do
    input()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&Enum.sum/1)
    |> count_increments
  end

  defp count_increments(enum, count \\ 0)
  defp count_increments([], count), do: count
  defp count_increments([_], count), do: count

  defp count_increments([head | tail], count) do
    count_increments(
      tail,
      count + count_contribution(head, tail)
    )
  end

  defp count_contribution(head, tail) do
    if List.first(tail) > head, do: 1, else: 0
  end
end
