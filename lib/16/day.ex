defmodule Day16 do
  @moduledoc false

  @typep transmission() :: bitstring()
  @typep opcode() :: :sum | :prod | :min | :max | :lt | :gt | :eq
  @typep version() :: non_neg_integer()
  @typep packet() :: {version(), :literal, non_neg_integer()} | {version(), opcode(), [packet()]}

  @spec input() :: transmission()
  def input do
    {:ok, input} = File.read('./lib/16/input.txt')

    input
    |> Base.decode16!()
  end

  def solution do
    %{"part1" => part1(), "part2" => part2()}
  end

  defp part1 do
    input()
    |> parse_transmission()
    |> sum_versions()
  end

  @spec sum_versions(packet()) :: non_neg_integer()
  defp sum_versions(packet)
  defp sum_versions({version, :literal, _}), do: version

  defp sum_versions({version, _, subpackets}) do
    subpackets
    |> Enum.map(&sum_versions/1)
    |> Enum.sum()
    |> Kernel.+(version)
  end

  defp part2 do
    input()
    |> parse_transmission()
    |> evaluate()
  end

  @spec evaluate(packet()) :: non_neg_integer()
  defp evaluate({_, :literal, value}), do: value

  defp evaluate({_, operator, subpackets}) do
    values = subpackets |> Enum.map(&evaluate/1)

    case operator do
      :sum -> Enum.sum(values)
      :prod -> Enum.product(values)
      :min -> Enum.min(values)
      :max -> Enum.max(values)
      :lt -> if Enum.at(values, 0) < Enum.at(values, 1), do: 1, else: 0
      :gt -> if Enum.at(values, 0) > Enum.at(values, 1), do: 1, else: 0
      :eq -> if Enum.at(values, 0) == Enum.at(values, 1), do: 1, else: 0
    end
  end

  @spec parse_transmission(transmission()) :: packet()
  defp parse_transmission(transmission) do
    {packet, _} = parse_packet(transmission)
    packet
  end

  @spec parse_packet(transmission()) :: {packet(), transmission()}
  defp parse_packet(<<version::3, 4::3, payload::bits>>) do
    {value, rest} = parse_literal(payload)
    {{version, :literal, value}, rest}
  end

  defp parse_packet(<<version::3, opcode::3, 0::1, subpackets_len::15, payload::bits>>) do
    <<subpackets::bits-size(subpackets_len), rest::bits>> = payload
    {{version, parse_opcode(opcode), parse_subpackets(subpackets)}, rest}
  end

  defp parse_packet(<<version::3, opcode::3, 1::1, num_subpackets::11, payload::bits>>) do
    {subpackets, rest} = parse_n_subpackets(payload, num_subpackets)
    {{version, parse_opcode(opcode), subpackets}, rest}
  end

  @spec parse_subpackets(transmission(), [packet()]) :: [packet()]
  defp parse_subpackets(transmission, subpackets \\ [])
  defp parse_subpackets(<<>>, subpackets), do: subpackets

  defp parse_subpackets(transmission, subpackets) do
    {packet, rest} = parse_packet(transmission)
    parse_subpackets(rest, subpackets ++ [packet])
  end

  @spec parse_n_subpackets(transmission(), pos_integer(), [packet()]) ::
          {[packet()], transmission()}
  defp parse_n_subpackets(transmission, number, subpackets \\ [])
  defp parse_n_subpackets(rest, 0, subpackets), do: {subpackets, rest}

  defp parse_n_subpackets(transmission, number, subpackets) do
    {packet, rest} = parse_packet(transmission)
    parse_n_subpackets(rest, number - 1, subpackets ++ [packet])
  end

  @spec parse_literal(transmission(), bitstring()) :: {non_neg_integer(), transmission()}
  defp parse_literal(payload, literal \\ <<>>)

  defp parse_literal(<<0::1, chunk::bits-size(4), rest::bits>>, literal) do
    literal_bits = <<literal::bits, chunk::bits>>
    num_bits = bit_size(literal_bits)
    <<value::integer-size(num_bits)>> = literal_bits
    {value, rest}
  end

  defp parse_literal(<<1::1, chunk::bits-size(4), rest::bits>>, literal) do
    parse_literal(rest, <<literal::bits, chunk::bits>>)
  end

  @spec parse_opcode(non_neg_integer()) :: opcode()
  defp parse_opcode(0), do: :sum
  defp parse_opcode(1), do: :prod
  defp parse_opcode(2), do: :min
  defp parse_opcode(3), do: :max
  defp parse_opcode(5), do: :gt
  defp parse_opcode(6), do: :lt
  defp parse_opcode(7), do: :eq
end
