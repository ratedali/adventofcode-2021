defmodule Day15 do
  @moduledoc false

  @typep risk() :: pos_integer()
  @typep coordinates() :: {non_neg_integer(), non_neg_integer()}
  @typep cave_map() :: %{coordinates() => risk()}

  @spec input() :: cave_map()
  def input do
    {:ok, input} = File.read('./lib/15/input.txt')

    for {row, y} <- input |> String.split("\n", trim: true) |> Enum.with_index(),
        {risk, x} <- row |> String.graphemes() |> Enum.with_index(),
        into: %{} do
      {{x, y}, String.to_integer(risk)}
    end
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> solve()
  end

  defp part2 do
    input()
    |> tile()
    |> solve()
  end

  defp tile(map) do
    {x_max, y_max} = Map.keys(map) |> Enum.max()
    {width, height} = {x_max + 1, y_max + 1}

    map
    |> Enum.flat_map(&tile_point(&1, width, :h))
    |> Enum.flat_map(&tile_point(&1, height, :v))
    |> Map.new()
  end

  defp tile_point({coords, risk}, size, orientation) do
    0..4
    |> Enum.map(fn index ->
      {
        get_tile_coordinates(coords, size, index, orientation),
        increment_risk(risk, index)
      }
    end)
  end

  defp get_tile_coordinates({x, y}, size, index, :h), do: {x + index * size, y}
  defp get_tile_coordinates({x, y}, size, index, :v), do: {x, y + index * size}

  defp increment_risk(risk, amount) do
    sum = risk + amount
    if sum > 9, do: sum - 9, else: sum
  end

  defp solve(map), do: cheapest_distance(map, get_destination(map))

  defp cheapest_distance(graph, destination, front \\ [{0, {0, 0}}], dist \\ %{})
  defp cheapest_distance(_, _, [], _), do: :unreachable

  defp cheapest_distance(_, destination, [{cost, destination} | _], _), do: cost

  defp cheapest_distance(graph, destination, [{curr_cost, curr_coords} | front], dist) do
    next_front =
      graph
      |> adjacent(curr_coords)
      |> Enum.map(&{curr_cost + Map.fetch!(graph, &1), &1})
      |> Enum.filter(fn
        {cost, coords} ->
          cost < Map.get(dist, coords, cost + 1)
      end)
      |> Enum.reduce(front, &:ordsets.add_element(&1, &2))

    cheapest_distance(
      graph,
      destination,
      next_front,
      dist |> Map.update(curr_coords, curr_cost, &min(&1, curr_cost))
    )
  end

  @spec adjacent(cave_map(), coordinates()) :: [coordinates()]
  defp adjacent(map, {x, y}) do
    [
      {x - 1, y},
      {x + 1, y},
      {x, y - 1},
      {x, y + 1}
    ]
    |> Enum.filter(&Map.has_key?(map, &1))
  end

  defp get_destination(map), do: Map.keys(map) |> Enum.max()
end
