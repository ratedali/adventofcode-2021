defmodule Day10 do
  @moduledoc false

  @typep token() :: String.grapheme()
  @typep line() :: [token()]

  @spec input() :: [line()]
  def input do
    {:ok, input} = File.read('./lib/10/input.txt')

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> Enum.map(&verify_line/1)
    |> Keyword.get_values(:corrupt)
    |> Enum.map(&checking_points/1)
    |> Enum.sum()
  end

  @spec checking_points(token()) :: number()
  defp checking_points(")"), do: 3
  defp checking_points("]"), do: 57
  defp checking_points("}"), do: 1197
  defp checking_points(">"), do: 25137

  defp part2 do
    input()
    |> Enum.map(&verify_line/1)
    |> Keyword.get_values(:incomplete)
    |> Enum.map(&completion_score/1)
    |> median()
  end

  defp median(scores), do: scores |> Enum.sort() |> Enum.at(length(scores) |> div(2))

  defp completion_score(completion) do
    List.foldl(completion, 0, &(&2 * 5 + completion_points(&1)))
  end

  @spec completion_points(token()) :: number()
  defp completion_points(")"), do: 1
  defp completion_points("]"), do: 2
  defp completion_points("}"), do: 3
  defp completion_points(">"), do: 4

  defp verify_line(line), do: verify_chunks(line, [])

  @spec verify_chunks(line(), [token()]) :: {:corrupt, token()} | {:incomplete | [token()]}
  defp verify_chunks([], unclosed), do: {:incomplete, Enum.map(unclosed, &closing_for/1)}

  defp verify_chunks([token | rest], unclosed) do
    cond do
      token in ["(", "[", "{", "<"] -> verify_chunks(rest, [token | unclosed])
      token == closing_for(hd(unclosed)) -> verify_chunks(rest, tl(unclosed))
      true -> {:corrupt, token}
    end
  end

  @spec closing_for(token()) :: token()
  defp closing_for("("), do: ")"
  defp closing_for("["), do: "]"
  defp closing_for("{"), do: "}"
  defp closing_for("<"), do: ">"
end
