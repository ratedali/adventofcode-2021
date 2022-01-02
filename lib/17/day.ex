defmodule Day17 do
  @moduledoc false

  @typep range() :: {integer(), integer()}
  @typep target() :: %{x: range(), y: range()}

  @spec input() :: target()
  def input do
    {:ok, input} = File.read('./lib/17/input.txt')

    [x, y] =
      Regex.scan(~r/-?\d+/, input)
      |> Enum.map(&hd/1)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
      |> Enum.map(&Enum.sort/1)
      |> Enum.map(&List.to_tuple/1)

    %{x: x, y: y}
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> Map.fetch!(:y)
    |> elem(0)
    |> abs()
    |> Kernel.then(&(&1 * (&1 - 1)))
    |> div(2)
  end

  defp part2 do
    input()
    |> all_valid_v_pairs()
    |> MapSet.size()
  end

  defp all_valid_v_pairs(target) do
    target
    |> all_valid_vy_t_pairs()
    |> Enum.reduce(MapSet.new(), &(all_valid_vx_pairs(&1, target) |> MapSet.union(&2)))
  end

  defp all_valid_vx_pairs({vy, n}, %{x: {x_min, x_max}}) do
    vx_min_rest = rest_velocity(x_min) |> ceil()
    vx_max_rest = rest_velocity(x_max) |> floor()

    # all vx values that would be at rest on the target at step n
    rest_vx =
      vx_min_rest..min(n, vx_max_rest)//1
      |> Enum.to_list()

    vx_min_moving = velocity_for(x_min, n) |> ceil()
    vx_max_moving = velocity_for(x_max, n) |> floor()
    IO.inspect({vx_min_moving, vx_max_moving}, label: "moving at n=#{n}")

    # all vx values that would be moving through the target at step n
    # exclude initial velocities currently at rest
    moving_vx =
      max(n, vx_min_moving)..vx_max_moving//1
      |> Enum.to_list()

    (rest_vx ++ moving_vx)
    |> Enum.map(&{&1, vy})
    |> MapSet.new()
  end

  defp all_valid_vy_t_pairs(%{y: {y_min, _} = y}) do
    # the range of valid vy values
    y_min..(-y_min - 1)
    |> Enum.flat_map(&valid_y_steps(&1, y))
  end

  defp valid_y_steps(v, y) when v >= 0 do
    valid_y_steps(-v - 1, y)
    |> Enum.map(fn {_, n} -> {v, n + 2 * v + 1} end)
  end

  defp valid_y_steps(v, {y_min, y_max}) do
    t_min = step_to(v, y_max) |> ceil()
    t_max = step_to(v, y_min) |> floor()

    max(1, t_min)..t_max//1
    |> Enum.map(&{v, &1})
  end

  defp step_to(v, d), do: (2 * v + 1 + :math.sqrt((2 * v + 1) ** 2 - 8 * d)) / 2
  defp rest_velocity(d), do: (-1 + :math.sqrt(1 + 8 * d)) / 2
  defp velocity_for(d, n), do: d / n + (n - 1) / 2
end
