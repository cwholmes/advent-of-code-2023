defmodule Mirage do
  defmodule Part1 do
    def all_zero?([]), do: true
    def all_zero?([0 | nums]), do: all_zero?(nums)
    def all_zero?(_), do: false
    def get_differences([]), do: []
    def get_differences([_]), do: []
    def get_differences([num1, num2 | nums]) do
      [num2 - num1 | get_differences([num2 | nums])]
    end
    def process(nums) do
      diffs = get_differences(nums)
      last = List.last(nums)
      cond do
        all_zero?(diffs) ->
          List.last(nums)
        true ->
          process(diffs) + last
      end
    end
    def run(stream) do
      stream
      |> Stream.map(&String.split(&1, " "))
      |> Stream.map(fn x ->
        x
        |> Enum.map(fn num ->
          {num, ""} = Integer.parse(num)
          num
        end)
      end)
      |> Stream.map(&process/1)
      |> Enum.reduce(&(&1 + &2))
    end
  end
  defmodule Part2 do
    def all_zero?([]), do: true
    def all_zero?([0 | nums]), do: all_zero?(nums)
    def all_zero?(_), do: false
    def get_differences([]), do: []
    def get_differences([_]), do: []
    def get_differences([num1, num2 | nums]) do
      [num2 - num1 | get_differences([num2 | nums])]
    end
    def process([num | _] = nums) do
      diffs = get_differences(nums)
      cond do
        all_zero?(diffs) -> num
        true -> num - process(diffs)
      end
    end
    def run(stream) do
      stream
      |> Stream.map(&String.split(&1, " "))
      |> Stream.map(fn x ->
        x
        |> Enum.map(fn num ->
          {num, ""} = Integer.parse(num)
          num
        end)
      end)
      |> Stream.map(&process/1)
      |> Enum.reduce(&(&1 + &2))
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

result_part1 = ReadInput.values_stream! |> Mirage.Part1.run
result_part2 = ReadInput.values_stream! |> Mirage.Part2.run

IO.puts("Result part 1: #{result_part1}")
IO.puts("Result part 2: #{result_part2}")
