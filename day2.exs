defmodule CubeConundrum do
  defmodule Cubes do
    require Record
    Record.defrecord(:cubes, red: 0, green: 0, blue: 0)
    def combine({:cubes, x_red, x_green, x_blue}, {:cubes, y_red, y_green, y_blue}) do
      cubes(
        red: max(x_red, y_red),
        green: max(x_green, y_green),
        blue: max(x_blue, y_blue)
      )
    end
    def empty, do: cubes()
    def red(num) when is_integer(num) do
      cubes(red: num)
    end
    def green(num) when is_integer(num) do
      cubes(green: num)
    end
    def blue(num) when is_integer(num) do
      cubes(blue: num)
    end
  end
  def extract_result([_full, num_string, "red"]) do
    {num, ""} = Integer.parse(num_string)
    Cubes.red(num)
  end
  def extract_result([_full, num_string, "green"]) do
    {num, ""} = Integer.parse(num_string)
    Cubes.green(num)
  end
  def extract_result([_full, num_string, "blue"]) do
    {num, ""} = Integer.parse(num_string)
    Cubes.blue(num)
  end
  def extract_cubes(game_string) do
    case Regex.named_captures(~r/Game (?<game>[0-9]+): (?<results>.*)/, game_string) do
      %{"game" => game, "results" => results} ->
        cubes =
          Regex.scan(~r/([0-9]+) (green|red|blue)/, results)
          |> Enum.map(&extract_result/1)
          |> Enum.reduce(Cubes.empty, &Cubes.combine/2)
        {game, ""} = Integer.parse(game)
        [{game, cubes}]
      _ -> []
    end
  end
  defmodule Part1 do
    def possible_game({game, {:cubes, red, green, blue}}) do
      cond do
        red <= 12 && green <= 13 && blue <= 14 -> [game]
        true -> []
      end
    end
    def run(stream) do
      stream
      |> Stream.flat_map(&CubeConundrum.extract_cubes/1)
      |> Stream.flat_map(&possible_game/1)
      |> Enum.reduce(0, fn x, y -> x + y end)
    end
  end
  defmodule Part2 do
    def cube_power({_, {:cubes, red, green, blue}}) do
      red * green * blue
    end
    def run(stream) do
      stream
      |> Stream.flat_map(&CubeConundrum.extract_cubes/1)
      |> Stream.map(&cube_power/1)
      |> Enum.reduce(0, fn x, y -> x + y end)
    end
  end
end
defmodule ReadInput do
  def values_stream! do
    case System.argv do
      [input_file] -> File.stream!(input_file)
      _ -> raise ArgumentError, message: "Input should either be a single file name or list of values"
    end
  end
end

result_part1 = ReadInput.values_stream! |> CubeConundrum.Part1.run
result_part2 = ReadInput.values_stream! |> CubeConundrum.Part2.run

IO.puts("Result part 1: #{result_part1}")
IO.puts("Result part 2: #{result_part2}")
