defmodule Day08 do
  @moduledoc false

  @typep segment() :: char()
  @typep pattern() :: charlist()
  @typep digit() :: ?0..?9
  @typep screen() :: %{patterns: [pattern()], digits: [pattern()]}

  @spec input() :: [screen()]
  def input do
    {:ok, input} = File.read('./lib/08/input.txt')

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_screen/1)
  end

  @spec parse_screen(String.t()) :: screen()
  defp parse_screen(screen) do
    [patterns, digits] = String.split(screen, "|", trim: true)

    %{
      patterns: parse_segments(patterns),
      digits: parse_segments(digits)
    }
  end

  @spec parse_segments(String.t()) :: [pattern()]
  defp parse_segments(segments) do
    for pattern <- String.split(segments) do
      pattern
      |> String.trim()
      |> String.to_charlist()
      |> Enum.sort()
    end
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> Enum.flat_map(&Map.get(&1, :digits))
    |> Enum.filter(fn pattern -> length(pattern) in [2, 3, 4, 7] end)
    |> Enum.count()
  end

  defp part2 do
    input()
    |> Enum.map(&decode/1)
    |> Enum.sum()
  end

  @spec decode(screen()) :: integer()
  defp decode(%{patterns: patterns, digits: digits}) do
    segment_map = decode_segments(patterns)

    digits
    |> Enum.map(&decode_pattern(&1, segment_map))
    |> Enum.map(&to_digit/1)
    |> List.to_integer()
  end

  @spec decode_pattern(pattern(), %{segment() => segment()}) :: pattern()
  defp decode_pattern(pattern, segment_map) do
    pattern
    |> Enum.map(&Map.get(segment_map, &1))
    |> Enum.sort()
  end

  @spec decode_segments([pattern()]) :: %{segment() => segment()}
  defp decode_segments(patterns) do
    decode_a_segment(patterns)
    |> decode_bdeg_segments(patterns)
    |> decode_cf_segments(patterns)
  end

  defp decode_a_segment(patterns) do
    one = patterns |> pattern_for(?1)
    seven = patterns |> pattern_for(?7)
    [a] = seven -- one

    %{a => ?a}
  end

  defp decode_bdeg_segments(map, patterns) do
    four = patterns |> pattern_for(?4)
    eight = patterns |> pattern_for(?8)

    acf = patterns |> pattern_for(?7)

    bd = four |> Enum.reject(&(&1 in acf))
    abcdf = acf ++ bd
    eg = eight |> Enum.reject(&(&1 in abcdf))

    be =
      patterns
      |> Enum.filter(&(length(&1) == 5))
      |> List.flatten()
      |> Enum.frequencies()
      |> Enum.filter(fn {_, freq} -> freq == 1 end)
      |> Enum.map(fn {segment, _} -> segment end)

    [d] = bd -- be
    [b] = bd -- [d]
    [g] = eg -- be
    [e] = eg -- [g]

    map
    |> Map.put(b, ?b)
    |> Map.put(d, ?d)
    |> Map.put(e, ?e)
    |> Map.put(g, ?g)
  end

  defp decode_cf_segments(map, patterns) do
    cf = patterns |> pattern_for(?1)
    abdeg = Map.keys(map)

    {f, _} =
      patterns
      |> Enum.filter(&(length(&1) == 6))
      |> List.flatten()
      |> Enum.reject(&(&1 in abdeg))
      |> Enum.frequencies()
      |> Enum.find(fn {_, freq} -> freq == 3 end)

    [c] = cf -- [f]

    map
    |> Map.put(c, ?c)
    |> Map.put(f, ?f)
  end

  defp pattern_for(patterns, ?1) do
    Enum.find(patterns, &(length(&1) == 2))
  end

  defp pattern_for(patterns, ?4) do
    Enum.find(patterns, &(length(&1) == 4))
  end

  defp pattern_for(patterns, ?7) do
    Enum.find(patterns, &(length(&1) == 3))
  end

  defp pattern_for(patterns, ?8) do
    Enum.find(patterns, &(length(&1) == 7))
  end

  @spec to_digit(pattern()) :: digit
  defp to_digit(pattern) do
    case pattern do
      'cf' -> ?1
      'acf' -> ?7
      'bcdf' -> ?4
      'abcdefg' -> ?8
      'acdeg' -> ?2
      'acdfg' -> ?3
      'abdfg' -> ?5
      'abdefg' -> ?6
      'abcdfg' -> ?9
      'abcefg' -> ?0
    end
  end
end
