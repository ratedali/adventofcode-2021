defmodule Day13 do
  @moduledoc false

  @typep dot() :: {integer(), integer()}
  @typep axis() :: :x | :y
  @typep fold() :: {axis(), integer()}
  @typep paper() :: MapSet.t(dot())

  @spec input() :: {paper(), [fold()]}
  def input do
    {:ok, input} = File.read('./lib/13/input.txt')

    {paper, folds} =
      input
      |> String.split("\n", trim: true)
      |> Enum.split_while(&String.contains?(&1, ","))

    {
      paper |> parse_paper(),
      folds |> parse_folds()
    }
  end

  defp parse_paper(paper) do
    for dot <- paper, into: MapSet.new() do
      dot
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end
  end

  defp parse_folds(folds) do
    for fold <- folds do
      ["fold", "along", coords] = String.split(fold)

      [axis, value] = String.split(coords, "=")
      {String.to_atom(axis), String.to_integer(value)}
    end
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    {paper, [fold | _]} = input()

    paper
    |> fold_paper(fold)
    |> MapSet.size()
  end

  defp part2 do
    {paper, folds} = input()

    folds
    |> List.foldl(paper, &fold_paper(&2, &1))
    |> draw_paper()
    |> IO.puts()
  end

  @spec draw_paper(paper()) :: String.t()
  defp draw_paper(paper) do
    xf = Enum.map(paper, fn {x, _} -> x end) |> Enum.max()
    yf = Enum.map(paper, fn {_, y} -> y end) |> Enum.max()

    for y <- 0..yf, into: "" do
      for x <- 0..xf, into: "" do
        if MapSet.member?(paper, {x, y}), do: "#", else: "."
      end <> "\n"
    end
  end

  @spec fold_paper(paper(), fold()) :: paper()
  defp fold_paper(paper, fold) do
    dots = Enum.filter(paper, &will_fold?(&1, fold))

    dots
    |> Enum.reduce(paper, &MapSet.delete(&2, &1))
    |> MapSet.union(
      dots
      |> Enum.map(&fold_dot(&1, fold))
      |> MapSet.new()
    )
  end

  @spec fold_dot(dot(), fold()) :: dot()
  defp fold_dot({x, y}, {:x, value}), do: {value - (x - value), y}
  defp fold_dot({x, y}, {:y, value}), do: {x, value - (y - value)}

  @spec will_fold?(dot(), fold()) :: boolean()
  defp will_fold?({x, _}, {:x, value}), do: x > value
  defp will_fold?({_, y}, {:y, value}), do: y > value
end
