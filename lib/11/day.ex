defmodule Day11 do
  @moduledoc false
  @grid_limit 9

  @typep energy :: 0..9
  @typep grid() :: [[energy()]]
  @typep coordinates() :: {integer(), integer()}

  @spec input() :: grid()
  def input do
    {:ok, input} = File.read('./lib/11/input.txt')

    for line <- String.split(input, "\n", trim: true) do
      line
      |> String.graphemes()
      |> Enum.map(&String.to_integer/1)
    end
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> simulate(100)
    |> elem(1)
    |> List.flatten()
    |> length()
  end

  @spec simulate(grid(), integer(), [[coordinates()]]) :: {grid(), [[coordinates()]]}
  defp simulate(grid, steps, flashes \\ [])
  defp simulate(grid, 0, flashes), do: {grid, flashes}

  defp simulate(grid, steps, flashes) do
    {new_grid, new_flashes} = step(grid)
    simulate(new_grid, steps - 1, flashes ++ [MapSet.to_list(new_flashes)])
  end

  defp part2 do
    input()
    |> synchoronous_flash()
  end

  @spec synchoronous_flash(grid(), integer(), [coordinates()]) :: integer()
  defp synchoronous_flash(grid, curr_step \\ 0, flashes \\ [])
  defp synchoronous_flash(_, curr_step, flashes) when length(flashes) == 100, do: curr_step

  defp synchoronous_flash(grid, curr_step, _) do
    {next_grid, flashes} = step(grid)
    synchoronous_flash(next_grid, curr_step + 1, MapSet.to_list(flashes))
  end

  @spec step(grid()) :: {grid(), MapSet.t(coordinates())}
  defp step(grid) do
    grid
    |> increment_energy()
    |> count_flashes()
  end

  @spec count_flashes(grid()) :: {grid(), MapSet.t(coordinates())}
  defp count_flashes(grid), do: flash(grid, flashing_coords(grid))

  @spec flash(grid(), [coordinates()], MapSet.t(coordinates())) ::
          {grid(), MapSet.t(coordinates())}
  defp flash(grid, to_flash, flashed \\ MapSet.new())
  defp flash(grid, [], flashed), do: {grid, flashed}

  defp flash(grid, [coords | remaining], flashed) do
    adj =
      adjacent(coords)
      |> Enum.reject(&MapSet.member?(flashed, &1))

    next_grid =
      adj
      |> Enum.reduce(grid, fn
        coords, grid -> update_grid_at(grid, coords, &(&1 + 1))
      end)
      |> update_grid_at(coords, fn _ -> 0 end)

    flash_next =
      adj
      |> Enum.filter(&flashing?(grid_at(next_grid, &1)))
      |> Enum.reject(&Enum.member?(remaining, &1))

    flash(next_grid, flash_next ++ remaining, MapSet.put(flashed, coords))
  end

  @spec flashing_coords(grid()) :: [coordinates()]
  defp flashing_coords(grid) do
    for {row, y} <- Enum.with_index(grid),
        {energy, x} <- Enum.with_index(row),
        flashing?(energy) do
      {x, y}
    end
  end

  @spec flashing?(energy()) :: boolean()
  defp flashing?(energy), do: energy > 9

  @spec increment_energy(grid()) :: grid()
  defp increment_energy(grid) do
    for row <- grid do
      for energy <- row do
        energy + 1
      end
    end
  end

  @spec adjacent(coordinates()) :: [coordinates()]
  defp adjacent({x, y}) do
    for xj <- [x - 1, x, x + 1],
        yj <- [y - 1, y, y + 1],
        (xj != x or y != yj) and
          xj >= 0 and xj <= @grid_limit and
          yj >= 0 and yj <= @grid_limit do
      {xj, yj}
    end
  end

  @spec update_grid_at(grid(), coordinates(), (energy() -> energy())) :: grid()
  defp update_grid_at(grid, {x, y}, fun) do
    List.update_at(grid, y, fn
      row -> List.update_at(row, x, fun)
    end)
  end

  @spec grid_at(grid(), coordinates()) :: energy()
  defp grid_at(grid, {x, y}), do: grid |> Enum.at(y) |> Enum.at(x)
end
