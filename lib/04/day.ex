defmodule Day04 do
  @moduledoc false

  def input do
    {:ok, input} = File.read('./lib/04/input.txt')
    [numbers | boards] = input |> String.split("\n", trim: true)

    {
      numbers |> String.split(",", trim: true) |> Enum.map(&String.to_integer/1),
      boards |> parse_boards()
    }
  end

  defp parse_boards(board_lines) do
    board_lines
    |> Enum.map(&String.split(&1, " ", trim: true))
    |> Enum.reject(&(length(&1) != 5))
    |> Enum.map(fn row -> Enum.map(row, &String.to_integer/1) end)
    |> Enum.chunk_every(5)
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    {numbers, boards} = input()

    {win_idx, board_index} =
      boards
      |> Enum.map(&board_win?(&1, numbers))
      |> Enum.filter(fn {wins?, _} -> wins? end)
      |> Enum.map(fn {_, win_idx} -> win_idx end)
      |> Enum.with_index()
      |> Enum.min()

    winning_numbers = Enum.take(numbers, win_idx + 1)
    board = Enum.at(boards, board_index)
    board_score(board, winning_numbers) * List.last(winning_numbers)
  end

  defp part2 do
    {numbers, boards} = input()

    {win_idx, board_index} =
      boards
      |> Enum.map(&board_win?(&1, numbers))
      |> Enum.filter(fn {wins?, _} -> wins? end)
      |> Enum.map(fn {_, win_idx} -> win_idx end)
      |> Enum.with_index()
      |> Enum.max()

    winning_numbers = Enum.take(numbers, win_idx + 1)
    board = Enum.at(boards, board_index)
    board_score(board, winning_numbers) * List.last(winning_numbers)
  end

  defp board_score(board, winning_numbers) do
    for row <- board,
        num <- row,
        num not in winning_numbers,
        reduce: 0 do
      sum -> sum + num
    end
  end

  defp board_win?(board, numbers) do
    winning_idxs =
      for row <- board ++ transpose(board), Enum.all?(row, &(&1 in numbers)) do
        row
        |> Enum.map(fn num -> Enum.find_index(numbers, &(&1 == num)) end)
        |> Enum.max()
      end

    case winning_idxs do
      [] -> {false, :infinity}
      idx -> {true, Enum.min(idx)}
    end
  end

  defp transpose(board) do
    board
    |> List.zip()
    |> Enum.map(&Tuple.to_list/1)
  end
end
