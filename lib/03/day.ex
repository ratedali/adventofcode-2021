defmodule Day03 do
  @moduledoc false

  def input do
    {:ok, input} = File.read('./lib/03/input.txt')

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    {gamma, epsilon} =
      for bits <- input() |> List.zip(), reduce: {[], []} do
        {gamma, epsilon} ->
          case most_common_bit(bits) do
            ?1 -> {gamma ++ [?1], epsilon ++ [?0]}
            ?0 -> {gamma ++ [?0], epsilon ++ [?1]}
          end
      end

    List.to_integer(gamma, 2) * List.to_integer(epsilon, 2)
  end

  defp part2 do
    o2 = input() |> rating(:o2)
    co2 = input() |> rating(:co2)
    o2 * co2
  end

  defp rating(readings, type, bit_loc \\ 0)
  defp rating([reading], _type, _bit_loc), do: List.to_integer(reading, 2)

  defp rating(readings, type, bit_loc) do
    bits =
      readings
      |> List.zip()
      |> Enum.at(bit_loc)

    most_common = most_common_bit(bits)
    least_common = if most_common == ?1, do: ?0, else: ?1

    filter =
      case type do
        :o2 -> most_common
        :co2 -> least_common
      end

    filterd_readings =
      readings
      |> Enum.zip(Tuple.to_list(bits))
      |> Enum.filter(fn {_, bit} -> bit == filter end)
      |> Enum.map(&elem(&1, 0))

    rating(filterd_readings, type, bit_loc + 1)
  end

  defp most_common_bit(bits) do
    ones = count_ones(bits)

    if ones >= tuple_size(bits) - ones do
      ?1
    else
      ?0
    end
  end

  defp count_ones(bits) do
    bits
    |> Tuple.to_list()
    |> Enum.count(fn bit -> bit == ?1 end)
  end
end
