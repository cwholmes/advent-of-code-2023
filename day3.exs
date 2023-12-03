defmodule GearRatios do
  def symbols(line_num, idx, <<first::utf8, rest::binary>>) do
    cond do
      first <= 10 -> symbols(line_num, idx + 1, rest)
      first == ?. -> symbols(line_num, idx + 1, rest)
      first >= ?0 && first <= ?9 -> symbols(line_num, idx + 1, rest)
      true -> [{line_num, idx, first} | symbols(line_num, idx + 1, rest)]
    end
  end
  def symbols(_line_num, _idx, ""), do: []
  def symbols(line_num, string), do: symbols(line_num, 1, string)
  def complete_number(<<first::utf8, rest::binary>>) when first >= ?0 and first <= ?9 do
    {num_string, remaining} = complete_number(rest)
    {<<first, num_string::binary>>, remaining}
  end
  def complete_number(string) do
    {"", string}
  end
  def numbers(line_num, idx, <<first::utf8, rest::binary>>) do
    cond do
      first >= ?0 && first <= ?9 ->
        {num_string, remaining} = complete_number(rest)
        {num, ""} = Integer.parse(<<first, num_string::binary>>)
        next_idx = idx + String.length(num_string)
        [{line_num, idx, next_idx, num} | numbers(line_num, next_idx + 1, remaining)]
      true -> numbers(line_num, idx + 1, rest)
    end
  end
  def numbers(_line_num, _idx, ""), do: []
  def numbers(line_num, string), do: numbers(line_num, 1, string)
  def symbol_points({line_num, min_idx, max_idx, _num}) do
    Enum.map(min_idx-1..max_idx+1, fn x -> {line_num-1, x} end)
    |> MapSet.new()
    |> MapSet.union([{line_num, min_idx-1}, {line_num, max_idx+1}] |> MapSet.new())
    |> MapSet.union(Enum.map(min_idx-1..max_idx+1, fn x -> {line_num+1, x} end) |> MapSet.new())
  end
  defmodule Part1 do
    def part_number?(number, symbols) do
      !MapSet.disjoint?(symbols, GearRatios.symbol_points(number))
    end
    def run(stream) do
      {symbols, numbers} =
        stream
        |> Stream.with_index(1)
        |> Stream.map(fn {string, line_num} ->
          symbols =
            GearRatios.symbols(line_num, string)
            |> Enum.map(fn {l, i, _} -> {l, i} end)
            |> MapSet.new()
          numbers =
            GearRatios.numbers(line_num, string)
            |> MapSet.new()
          {symbols, numbers}
        end)
        |> Enum.reduce({MapSet.new(), MapSet.new()}, fn {symbols, numbers}, {next_s, next_n} ->
          {symbols |> MapSet.union(next_s), numbers |> MapSet.union(next_n)}
        end)
      numbers
      |> Enum.filter(fn x -> part_number?(x, symbols) end)
      |> Enum.map(fn {_, _, _, num} -> num end)
      |> Enum.reduce(0, fn x, y -> x + y end)
    end
  end
  defmodule Part2 do
    def gear_points({line_num, idx}, numbers) do
      maybe_points = MapSet.new([
        {line_num-1, idx-1},
        {line_num-1, idx},
        {line_num-1, idx+1},
        {line_num, idx-1},
        {line_num, idx+1},
        {line_num+1, idx-1},
        {line_num+1, idx},
        {line_num+1, idx+1},
      ])
      intersect_points = MapSet.intersection(numbers, maybe_points)
      cond do
        MapSet.size(intersect_points) == 2 -> MapSet.to_list(intersect_points)
        true -> []
      end
    end
    def gear_points({_, _, _, num} = number, symbols) do
      MapSet.intersection(symbols, GearRatios.symbol_points(number))
      |> Enum.reduce(%{}, fn x, map -> Map.update(map, x, [num], fn y -> [num | y] end) end)
    end
    def run(stream) do
      {symbols, numbers} =
        stream
        |> Stream.with_index(1)
        |> Stream.map(fn {string, line_num} ->
          symbols =
            GearRatios.symbols(line_num, string)
            |> Enum.filter(fn {_, _, c} -> c == ?* end)
            |> Enum.map(fn {l, i, _} -> {l, i} end)
            |> MapSet.new()
            numbers =
              GearRatios.numbers(line_num, string)
              |> MapSet.new()
            {symbols, numbers}
        end)
        |> Enum.reduce({MapSet.new(), MapSet.new()}, fn {symbols, numbers}, {next_s, next_n} ->
          {symbols |> MapSet.union(next_s), numbers |> MapSet.union(next_n)}
        end)
      numbers
      |> Enum.map(fn x -> gear_points(x, symbols) end)
      |> Enum.reduce(%{}, fn x, acc ->
        Enum.reduce(x, acc, fn {point, num_list}, acc ->
          Map.update(acc, point, num_list, fn x -> num_list ++ x end)
        end)
      end)
      |> Enum.flat_map(fn {_point, num_list} ->
        case num_list do
          [first, second] -> [first * second]
          _ -> []
        end
      end)
      |> Enum.reduce(0, fn x, y -> x + y end)
    end
  end
end
defmodule ReadInput do
  def values_stream! do
    case System.argv do
      [input_file] -> File.stream!(input_file)
      _ -> raise ArgumentError, message: "Input should be a single file name"
    end
  end
end

result_part1 = ReadInput.values_stream! |> GearRatios.Part1.run
result_part2 = ReadInput.values_stream! |> GearRatios.Part2.run

IO.puts("Result part 1: #{result_part1}")
IO.puts("Result part 2: #{result_part2}")
