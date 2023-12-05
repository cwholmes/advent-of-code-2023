defmodule Scratchcards do
  defmodule Part1 do
    def run(stream) do
      stream
      |> Stream.map(fn x -> Regex.named_captures(~r/Card\s+(?<game>[0-9]+): (?<win>[0-9\s]+) \| (?<nums>[0-9\s]+)/, x) end)
      |> Stream.filter(fn x -> x != nil end)
      |> Stream.map(fn x ->
        {
          MapSet.new(String.split(Map.get(x, "win", ""))),
          MapSet.new(String.split(Map.get(x, "nums", "")))
        }
      end)
      |> Stream.map(fn {win, nums} -> MapSet.intersection(win, nums) end)
      |> Stream.map(&MapSet.size/1)
      |> Stream.filter(fn x -> x > 0 end)
      |> Stream.map(fn x -> :math.pow(2, x - 1) end)
      |> Enum.reduce(0, fn x, y -> x + y end)
    end
  end
  defmodule Part2 do
    def combine([], list), do: list
    def combine(list, []), do: list
    def combine([num1 | rest1], [num2 | rest2]), do: [num1 + num2 | combine(rest1, rest2)]
    def run(stream) do
      stream
      |> Stream.map(fn x -> Regex.named_captures(~r/Card\s+(?<game>[0-9]+): (?<win>[0-9\s]+) \| (?<nums>[0-9\s]+)/, x) end)
      |> Stream.filter(fn x -> x != nil end)
      |> Stream.map(fn x ->
        {
          MapSet.new(String.split(Map.get(x, "win", ""))),
          MapSet.new(String.split(Map.get(x, "nums", "")))
        }
      end)
      |> Stream.map(fn {win, nums} -> MapSet.intersection(win, nums) end)
      |> Stream.map(&MapSet.size/1)
      |> Stream.transform([], fn x, acc ->
        case acc do
          [] ->
            {[1], List.duplicate(1, x)}
          [copies | rest] ->
            {[copies + 1], List.duplicate(copies + 1, x) |> combine(rest)}
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

result_part1 = ReadInput.values_stream! |> Scratchcards.Part1.run
result_part2 = ReadInput.values_stream! |> Scratchcards.Part2.run

IO.puts("Result part 1: #{result_part1}")
IO.puts("Result part 2: #{result_part2}")
