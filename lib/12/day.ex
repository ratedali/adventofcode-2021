defmodule Day12 do
  @moduledoc false

  @typep cave() :: String.t()
  @typep graph() :: %{cave() => [cave()]}

  @spec input() :: graph()
  def input do
    {:ok, input} = File.read('./lib/12/input.txt')

    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "-", trim: true))
    |> Enum.reduce(%{}, fn
      [cave1, cave2], graph ->
        graph
        |> Map.update(cave1, [cave2], &[cave2 | &1])
        |> Map.update(cave2, [cave1], &[cave1 | &1])
    end)
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> find_paths(1)
    |> length()
  end

  defp part2 do
    input()
    |> find_paths(2)
    |> length()
  end

  @typep visited() :: %{cave() => integer()}
  @typep path() :: {[cave()], visited()}

  defp find_paths(graph, max_visits, queue \\ [{"start", {[], %{}}, false}], completed \\ [])

  defp find_paths(_, _, [], completed), do: completed

  defp find_paths(graph, max_visits, [{"end", {trail, _}, _} | queue], completed) do
    find_paths(
      graph,
      max_visits,
      queue,
      [Enum.reverse(trail, ["end"]) | completed]
    )
  end

  defp find_paths(
         graph,
         max_visits,
         [{cave, {trail, visited}, already_exhausted} | queue],
         completed
       ) do
    path = {[cave | trail], Map.update(visited, cave, 1, &(&1 + 1))}
    exhausted = already_exhausted or exhausted_visits?(cave, path, max_visits)
    allowed_visits = if exhausted, do: 1, else: max_visits

    to_visit =
      graph
      |> Map.fetch!(cave)
      |> Enum.filter(&can_visit?(&1, path, allowed_visits))
      |> Enum.map(&{&1, path, exhausted})

    find_paths(graph, max_visits, to_visit ++ queue, completed)
  end

  @spec can_visit?(cave(), path(), integer()) :: boolean()
  defp can_visit?("start", _, _), do: false
  defp can_visit?(cave, path, max_visits), do: not exhausted_visits?(cave, path, max_visits)

  @spec exhausted_visits?(cave(), path(), integer()) :: boolean()
  defp exhausted_visits?(cave, {_, visited}, max_visits),
    do: small_cave?(cave) and Map.get(visited, cave, 0) >= max_visits

  @spec small_cave?(cave()) :: boolean()
  defp small_cave?(<<first_char::utf8, _::binary>>), do: first_char in ?a..?z
end
