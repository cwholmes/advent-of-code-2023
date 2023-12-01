defmodule Trebuchet do
  defmodule Base do
    defmacro __using__(__opts) do
      quote do
        # TODO: This could come from a macro
        def get_ints(?0), do: [0]
        def get_ints(?1), do: [1]
        def get_ints(?2), do: [2]
        def get_ints(?3), do: [3]
        def get_ints(?4), do: [4]
        def get_ints(?5), do: [5]
        def get_ints(?6), do: [6]
        def get_ints(?7), do: [7]
        def get_ints(?8), do: [8]
        def get_ints(?9), do: [9]
        def get_ints(:break), do: [:break]
        def get_ints(_other), do: []

        # TODO: This could come from a macro
        def words_to_ints("one" <> rest), do: [?1 | words_to_ints("ne" <> rest)]
        def words_to_ints("two" <> rest), do: [?2 | words_to_ints("wo" <> rest)]
        def words_to_ints("three" <> rest), do: [?3 | words_to_ints("hree" <> rest)]
        def words_to_ints("four" <> rest), do: [?4 | words_to_ints("our" <> rest)]
        def words_to_ints("five" <> rest), do: [?5 | words_to_ints("ive" <> rest)]
        def words_to_ints("six" <> rest), do: [?6 | words_to_ints("ix" <> rest)]
        def words_to_ints("seven" <> rest), do: [?7 | words_to_ints("even" <> rest)]
        def words_to_ints("eight" <> rest), do: [?8 | words_to_ints("ight" <> rest)]
        def words_to_ints("nine" <> rest), do: [?9 | words_to_ints("ine" <> rest)]
        def words_to_ints(<<first::utf8, rest::binary>>), do: [first | words_to_ints(rest)]
        def words_to_ints(""), do: []

        def process_acc(:break, {}), do: {[], {:break}}
        def process_acc(:break, {:break}), do: {[], {:break}}
        def process_acc(:break, {single}), do: {[single * 10 + single], {:break}}
        def process_acc(:break, {first, second}), do: {[first * 10 + second], {:break}}
        def process_acc(next, {:break}), do: {[], {next}}
        def process_acc(next, {value1}), do: {[], {value1, next}}
        def process_acc(next, {value1, _value2}), do: {[], {value1, next}}
      end
    end
  end
  defmodule Part1 do
    use Base

    def string_int_chars(string), do: to_charlist(string)

    def run(stream) do
      stream
      |> Stream.flat_map(fn x -> Stream.concat(string_int_chars(x), [:break]) end)
      |> Stream.flat_map(&get_ints/1)
      |> Stream.transform({:break}, &process_acc/2)
      # |> Stream.each(&IO.puts/1)
      |> Enum.reduce(fn x, y -> x + y end)
    end
  end

  defmodule Part2 do
    use Base

    def string_int_chars(string), do: words_to_ints(string)

    def run(stream) do
      stream
      |> Stream.flat_map(fn x -> Stream.concat(string_int_chars(x), [:break]) end)
      |> Stream.flat_map(&get_ints/1)
      |> Stream.transform({:break}, &process_acc/2)
      # |> Stream.each(&IO.puts/1)
      |> Enum.reduce(fn x, y -> x + y end)
    end
  end
end

defmodule ReadInput do
  def values_stream! do
    case System.argv do
      [] -> raise ArgumentError, message: "Input should either be a single file name or list of values"
      [input_file] -> File.stream!(input_file)
      values -> values
    end
  end
end

result_part1 = ReadInput.values_stream! |> Trebuchet.Part1.run
result_part2 = ReadInput.values_stream! |> Trebuchet.Part2.run

IO.puts("Result part 1: #{result_part1}")
IO.puts("Result part 2: #{result_part2}")
