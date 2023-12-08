defmodule WaitForIt do
  defmodule Part1 do
    def parse_int(string) do
      {int, ""} = Integer.parse(string)
      int
    end
    def calculate(_hold, 0), do: []
    def calculate(0, race), do: calculate(1, race - 1)
    def calculate(hold, race) do
      [hold * race | calculate(hold + 1, race - 1)]
    end
    def handle([], []), do: []
    def handle([time | times], [distance | distances]) do
      wins =
        calculate(0, time)
        |> Enum.filter(fn
          x when x > distance -> true
          _ -> false
        end)
        |> length()
      [wins | handle(times, distances)]
    end
    def run(stream) do
      [{:time, times}, {:distance, distances}] =
        stream
        |> Stream.map(&String.trim/1)
        |> Stream.filter(fn
          "" -> false
          _ -> true
        end)
        |> Stream.map(fn
          "Time: " <> rest ->
            {:time, rest |> String.split(" ", [trim: true]) |> Enum.map(&parse_int/1)}
          "Distance: " <> rest ->
            {:distance, rest |> String.split(" ", [trim: true]) |> Enum.map(&parse_int/1)}
        end)
        |> Enum.to_list()
      handle(times, distances)
      |> Enum.reduce(fn x, y -> x * y end)
    end
  end
  defmodule Part2 do
    def parse_int(string) do
      {int, ""} = Integer.parse(string)
      int
    end
    def calculate(_hold, 0), do: []
    def calculate(0, race), do: calculate(1, race - 1)
    def calculate(hold, race) do
      [hold * race | calculate(hold + 1, race - 1)]
    end
    def handle([], []), do: []
    def handle([time | times], [distance | distances]) do
      wins =
        calculate(0, time)
        |> Enum.filter(fn
          x when x > distance -> true
          _ -> false
        end)
        |> length()
      [wins | handle(times, distances)]
    end
    def run(stream) do
      stream
      |> Stream.map(&String.trim/1)
      |> Stream.filter(fn
        "" -> false
        _ -> true
      end)
      |> Stream.map(fn
        "Time: " <> rest ->
          "Time: " <> (rest |> String.replace(" ", ""))
        "Distance: " <> rest ->
          "Distance: " <> (rest |> String.replace(" ", ""))
      end)
      |> WaitForIt.Part1.run
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

result_part1 = ReadInput.values_stream! |> WaitForIt.Part1.run
result_part2 = ReadInput.values_stream! |> WaitForIt.Part2.run

IO.puts("Result part 1: #{result_part1}")
IO.puts("Result part 2: #{result_part2}")
