defmodule Day14 do
  @moduledoc false
  @typep element() :: char()
  @typep pair() :: {element(), element()}
  @typep template() :: [char()]
  @typep pair_count() :: %{pair() => integer()}
  @typep rules() :: %{pair() => {pair(), pair()}}

  def input do
    {:ok, input} = File.read('./lib/14/input.txt')

    {[template], rules} =
      input
      |> String.split("\n", trim: true)
      |> Enum.split(1)

    {
      String.to_charlist(template) |> count_pairs(),
      rules |> Enum.map(&parse_rule/1) |> Map.new()
    }
  end

  @spec count_pairs(template()) :: pair_count()
  defp count_pairs(template) do
    template
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(&List.to_tuple/1)
    |> Enum.frequencies()
  end

  @spec parse_rule(String.t()) :: {pair(), {pair(), pair()}}
  defp parse_rule(<<e1, e2, _::binary-size(4), e>>), do: {{e1, e2}, {{e1, e}, {e, e2}}}

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> insert(10)
    |> answer()
  end

  defp part2 do
    input()
    |> insert(40)
    |> answer()
  end

  defp insert({polymer, _}, 0), do: polymer
  defp insert({polymer, rules}, steps), do: insert({step(polymer, rules), rules}, steps - 1)

  @spec answer(pair_count()) :: integer()
  defp answer(pair_count) do
    pair_count
    |> Enum.reduce(Map.new(), fn
      {{_, e2}, count}, elem_freq -> inc_count(elem_freq, e2, count)
    end)
    |> Map.values()
    |> Enum.min_max()
    |> Kernel.then(fn {min, max} -> max - min end)
  end

  @spec step(pair_count(), rules()) :: pair_count()
  defp step(pair_count, rules) do
    pair_count
    |> Enum.reduce(Map.new(), fn
      {pair, count}, new_pairs ->
        case Map.fetch(rules, pair) do
          :error ->
            new_pairs
            |> inc_count(pair, count)

          {:ok, {p1, p2}} ->
            new_pairs
            |> inc_count(p1, count)
            |> inc_count(p2, count)
        end
    end)
  end

  @spec inc_count(map(), any(), integer()) :: pair_count()
  defp inc_count(map, key, count), do: Map.update(map, key, count, &(&1 + count))
end
