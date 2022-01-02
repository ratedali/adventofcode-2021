defmodule Day18 do
  @moduledoc false

  @typep snailfish_num() :: [String.t() | non_neg_integer()]

  @spec input() :: [snailfish_num()]
  def input do
    {:ok, input} = File.read('./lib/18/input.txt')

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_number(&1))
  end

  @spec parse_number(String.t(), [non_neg_integer()], snailfish_num()) :: snailfish_num()
  defp parse_number(str, digits \\ [], parsed \\ [])
  defp parse_number(<<>>, _, parsed), do: parsed
  defp parse_number(<<"[", str::binary>>, _, parsed), do: parse_number(str, [], parsed ++ ["["])

  defp parse_number(<<",", str::binary>>, [], parsed), do: parse_number(str, [], parsed)

  defp parse_number(<<",", str::binary>>, digits, parsed) do
    parse_number(str, [], parsed ++ [Integer.undigits(digits)])
  end

  defp parse_number(<<"]", str::binary>>, [], parsed), do: parse_number(str, [], parsed ++ ["]"])

  defp parse_number(<<"]", str::binary>>, digits, parsed) do
    parse_number(str, [], parsed ++ [Integer.undigits(digits), "]"])
  end

  defp parse_number(<<d::binary-size(1), str::binary>>, digits, parsed) do
    parse_number(str, digits ++ [String.to_integer(d)], parsed)
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> Enum.reduce(&add(&2, &1))
    |> magnitude()
  end

  defp part2 do
    input()
    |> all_pair_sums()
    |> Enum.map(&magnitude(&1))
    |> Enum.max()
  end

  @spec all_pair_sums([snailfish_num()]) :: [non_neg_integer()]
  defp all_pair_sums(numbers) do
    for {lhs, i} <- Enum.with_index(numbers),
        {rhs, j} <- Enum.with_index(numbers),
        i != j do
      add(lhs, rhs)
    end
  end

  @spec magnitude(snailfish_num(), [1 | 2 | 3], :none | :left | :right, non_neg_integer()) ::
          non_neg_integer()
  defp magnitude(number, multipliers \\ [], pos \\ :none, total \\ 0)

  defp magnitude([], _, _, total), do: total

  defp magnitude(["[" | number], _, :none, total) do
    magnitude(number, [1], :left, total)
  end

  defp magnitude(["[" | number], multipliers, pos, total) do
    magnitude(number, [multiplier(pos) | multipliers], :left, total)
  end

  defp magnitude([n | number], multipliers, pos, total) when is_number(n) do
    magnitude(
      number,
      multipliers,
      :right,
      total + n * multiplier(pos) * Enum.product(multipliers)
    )
  end

  defp magnitude(["]" | number], [_ | multipliers], pos, total) do
    magnitude(number, multipliers, pos, total)
  end

  defp multiplier(:left), do: 3
  defp multiplier(:right), do: 2

  @spec add(snailfish_num(), snailfish_num()) :: snailfish_num()
  defp add(lhs, rhs), do: (["["] ++ lhs ++ rhs ++ ["]"]) |> reduce()

  @spec reduce(snailfish_num()) :: snailfish_num()
  defp reduce(number) do
    case explode(number) do
      false ->
        case split(number) do
          false -> number
          {true, number} -> reduce(number)
        end

      {true, number} ->
        reduce(number)
    end
  end

  @spec explode(snailfish_num()) :: {true, snailfish_num()} | false
  defp explode(number) do
    case explosion_index(number) do
      nil -> false
      index -> {true, do_explode(number, index)}
    end
  end

  @spec do_explode(snailfish_num(), non_neg_integer()) :: snailfish_num()
  defp do_explode(number, index) do
    [n1, n2] = Enum.slice(number, index + 1, 2)

    number =
      number
      |> Enum.take(index)
      |> find_rightmost_number()
      |> case do
        nil -> number
        idx -> List.update_at(number, idx, &(&1 + n1))
      end

    number =
      number
      |> Enum.drop(index + 4)
      |> find_leftmost_number()
      |> case do
        nil -> number
        idx -> List.update_at(number, index + 4 + idx, &(&1 + n2))
      end

    Enum.take(number, index) ++ [0] ++ Enum.drop(number, index + 4)
  end

  @spec explosion_index(snailfish_num()) :: non_neg_integer() | nil
  defp explosion_index(number) do
    number
    |> Enum.with_index()
    |> depth_index(4)
  end

  @spec split(snailfish_num()) :: {true, snailfish_num()} | false
  defp split(number) do
    case Enum.find_index(number, &(is_number(&1) and &1 >= 10)) do
      nil ->
        false

      index ->
        n = Enum.at(number, index)
        e = div(n, 2)

        {
          true,
          Enum.take(number, index) ++ ["[", e, n - e, "]"] ++ Enum.drop(number, index + 1)
        }
    end
  end

  @spec depth_index(snailfish_num(), non_neg_integer()) :: non_neg_integer() | nil
  defp depth_index([], _), do: nil
  defp depth_index([{"[", open} | _], 0), do: open
  defp depth_index([{"[", _} | rest], depth), do: depth_index(rest, depth - 1)
  defp depth_index([{"]", _} | rest], depth), do: depth_index(rest, depth + 1)
  defp depth_index([_ | rest], depth), do: depth_index(rest, depth)

  @spec find_rightmost_number(snailfish_num()) :: non_neg_integer() | nil
  defp find_rightmost_number(number) do
    case number |> Enum.reverse() |> find_leftmost_number() do
      nil -> nil
      idx -> length(number) - idx - 1
    end
  end

  @spec find_leftmost_number(snailfish_num()) :: non_neg_integer() | nil
  defp find_leftmost_number(number), do: Enum.find_index(number, &is_number/1)
end
