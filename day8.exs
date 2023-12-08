defmodule Wasteland do
  defmodule Part1 do
    def directions(""), do: []
    def directions(<<?R, rest::binary>>), do: [:right | directions(rest)]
    def directions(<<?L, rest::binary>>), do: [:left | directions(rest)]
    def inner_mapping(<<?(, xl::utf8, yl::utf8, zl::utf8, ", ", xr::utf8, yr::utf8, zr::utf8, ?)>>) do
      {<<xl, yl, zl>>, <<xr, yr, zr>>}
    end
    def mapping(<<x::utf8, y::utf8, z::utf8, " = ", rest::binary>>) do
      {<<x, y, z>>, inner_mapping(rest)}
    end
    def inner_step(_, "ZZZ", _, count), do: {:done, count}
    def inner_step([], target, _, count), do: {:continue, target, count}
    def inner_step([:right | directions], target, mappings, count) do
      {_, right} = Map.get(mappings, target)
      inner_step(directions, right, mappings, count + 1)
    end
    def inner_step([:left | directions], target, mappings, count) do
      {left, _} = Map.get(mappings, target)
      inner_step(directions, left, mappings, count + 1)
    end
    def step(directions, target, mappings) do
      case inner_step(directions, target, mappings, 0) do
        {:done, count} -> count
        {:continue, new_target, count} ->
          step(directions, new_target, mappings) + count
      end
    end
    def run(stream) do
      directions =
        stream
        |> Stream.take(1)
        |> Stream.flat_map(&directions/1)
        |> Enum.to_list()
      mappings =
        stream
        |> Stream.drop(1)
        |> Stream.filter(fn
          "" -> false
          _ -> true
        end)
        |> Stream.map(&mapping/1)
        |> Enum.reduce(%{}, fn
          {key, lr}, map ->
            Map.put(map, key, lr)
        end)
      step(directions, "AAA", mappings)
    end
  end
  defmodule Part2 do
    def directions(""), do: []
    def directions(<<?R, rest::binary>>), do: [:right | directions(rest)]
    def directions(<<?L, rest::binary>>), do: [:left | directions(rest)]
    def inner_mapping(<<?(, xl::utf8, yl::utf8, zl::utf8, ", ", xr::utf8, yr::utf8, zr::utf8, ?)>>) do
      {<<xl, yl, zl>>, <<xr, yr, zr>>}
    end
    def mapping(<<x::utf8, y::utf8, z::utf8, " = ", rest::binary>>) do
      {<<x, y, z>>, inner_mapping(rest)}
    end
    def inner_step(_, <<_::utf8, _::utf8, ?Z>>, _, count), do: {:done, count}
    def inner_step([], target, _, count), do: {:continue, target, count}
    def inner_step([:right | directions], target, mappings, count) do
      {_, right} = Map.get(mappings, target)
      inner_step(directions, right, mappings, count + 1)
    end
    def inner_step([:left | directions], target, mappings, count) do
      {left, _} = Map.get(mappings, target)
      inner_step(directions, left, mappings, count + 1)
    end
    def step(directions, target, mappings) do
      case inner_step(directions, target, mappings, 0) do
        {:done, count} -> count
        {:continue, new_target, count} ->
          step(directions, new_target, mappings) + count
      end
    end
    def run(stream) do
      directions =
        stream
        |> Stream.take(1)
        |> Stream.flat_map(&directions/1)
        |> Enum.to_list()
      mappings =
        stream
        |> Stream.drop(1)
        |> Stream.filter(fn
          "" -> false
          _ -> true
        end)
        |> Stream.map(&mapping/1)
        |> Enum.reduce(%{}, fn
          {key, lr}, map ->
            Map.put(map, key, lr)
        end)
      Map.keys(mappings)
      |> Enum.filter(fn
        <<_::utf8, _::utf8, ?A>> -> true
        _ -> false
      end)
      |> Enum.map(&step(directions, &1, mappings))
      |> Enum.reduce(fn x, y ->
        div(x * y, Integer.gcd(x, y))
      end)
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

# result_part1 = ReadInput.values_stream! |> Wasteland.Part1.run
result_part2 = ReadInput.values_stream! |> Wasteland.Part2.run

# IO.puts("Result part 1: #{result_part1}")
IO.puts("Result part 2: #{result_part2}")
