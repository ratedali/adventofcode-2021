defmodule Day02 do
  @moduledoc false

  def input do
    {:ok, input} = File.read('./lib/02/input.txt')

    input
    |> String.split("\n")
    |> Enum.map(&parse_command/1)
  end

  defp parse_command(line) do
    [prefix, suffix] = String.split(line)
    {String.to_atom(prefix), String.to_integer(suffix)}
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    %{x: x, y: y} =
      input()
      |> List.foldl(%{x: 0, y: 0}, &get_position/2)

    x * y
  end

  defp get_position({command, n}, pos) do
    case command do
      :down -> %{pos | y: pos[:y] + n}
      :up -> %{pos | y: pos[:y] - n}
      :forward -> %{pos | x: pos[:x] + n}
    end
  end

  defp part2 do
    %{x: x, y: y} =
      input()
      |> List.foldl(%{x: 0, y: 0, aim: 0}, &get_position_with_aim/2)

    x * y
  end

  defp get_position_with_aim({command, n}, pos) do
    case command do
      :down -> %{pos | aim: pos[:aim] + n}
      :up -> %{pos | aim: pos[:aim] - n}
      :forward -> %{pos | x: pos[:x] + n, y: pos[:y] + pos[:aim] * n}
    end
  end
end
