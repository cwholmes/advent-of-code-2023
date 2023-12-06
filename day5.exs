defmodule SeedFertilizer do
  defmodule Part1 do
    def combine({nums, mapped}), do: MapSet.union(nums, mapped)
    def run(stream) do
      stream
      |> Stream.map(&String.trim/1)
      |> Enum.reduce({MapSet.new(), MapSet.new()}, fn line, {nums, mapped} ->
        cond do
          line == "" ->
            {nums, mapped}
          String.ends_with?(line, "map:") ->
            {MapSet.union(nums, mapped), MapSet.new()}
          String.starts_with?(line, "seeds: ") ->
            "seeds: " <> numbers = line
            nums =
              String.split(numbers, " ")
              |> Enum.map(fn x ->
                {x, ""} = Integer.parse(x)
                x
              end)
              |> MapSet.new()
            {nums, mapped}
          true ->
            [dest, source, length] =
              String.split(line, " ")
              |> Enum.map(fn x ->
                {x, ""} = Integer.parse(x)
                x
              end)
            nums_to_map =
              nums
              |> Enum.filter(fn x -> x >= source && x <= source + length end)
              |> MapSet.new()
            mapped =
              nums_to_map
              |> Enum.map(fn x -> dest + x - source end)
              |> MapSet.new()
              |> MapSet.union(mapped)
            {MapSet.difference(nums, nums_to_map), mapped}
        end
      end)
      |> combine()
      |> MapSet.to_list()
      |> Enum.reduce(fn x, y -> min(x, y) end)
    end
  end
  defmodule Part2 do
    def handle([], _dest, _source, _length), do: {[], []}
    def handle([{start, last} | rest], dest, source, length) do
      start_in = start >= source && start <= source + length
      last_in = last >= source && last <= source + length
      {nums, mapped} =
        cond do
          start_in and last_in ->
            {[], [{dest + start - source, dest + last - source}]}
          start_in ->
            {[{source + length, last}], [{dest + start - source, dest + length}]}
          last_in ->
            {[{start, source}], [{dest, dest + last - source}]}
          true ->
            {[{start, last}], []}
        end
      {handle_nums, handle_mapped} = handle(rest, dest, source, length)
      {nums ++ handle_nums, mapped ++ handle_mapped}
    end
    def combine({nums, mapped}), do: nums ++ mapped
    def run(stream) do
      stream
      |> Stream.map(&String.trim/1)
      |> Enum.reduce({[], []}, fn line, {nums, mapped} ->
        cond do
          line == "" ->
            {nums, mapped}
          String.ends_with?(line, "map:") ->
            {nums ++ mapped, []}
          String.starts_with?(line, "seeds: ") ->
            "seeds: " <> numbers = line
            nums =
              String.split(numbers, " ")
              |> Enum.map(fn x ->
                {x, ""} = Integer.parse(x)
                x
              end)
              |> Enum.chunk_every(2)
              |> Enum.map(fn [num, count] -> {num, num + count - 1} end)
            {nums, mapped}
          true ->
            [dest, source, length] =
              String.split(line, " ")
              |> Enum.map(fn x ->
                {x, ""} = Integer.parse(x)
                x
              end)
            {handle_nums, handle_mapped} = handle(nums, dest, source, length)
            {handle_nums, handle_mapped ++ mapped}
        end
      end)
      |> combine()
      |> Enum.map(fn {x, _} -> x end)
      |> Enum.reduce(fn x, y -> min(x, y) end)
    end
  end
end
defmodule ReadInput do
  def values_stream! do
    case System.argv do
      [input_file] -> File.stream!(input_file) |> Stream.map(&String.trim/1)
      _ -> raise ArgumentError, message: "Input should be a single file name"
    end
  end
end

result_part1 = ReadInput.values_stream! |> SeedFertilizer.Part1.run
result_part2 = ReadInput.values_stream! |> SeedFertilizer.Part2.run

IO.puts("Result part 1: #{result_part1}")
IO.puts("Result part 2: #{result_part2}")
