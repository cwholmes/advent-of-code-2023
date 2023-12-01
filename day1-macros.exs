defmodule Trebuchet do
  defmodule Base do
    defmacro __using__(__opts) do
      int_to_word = %{
        1 => "one",
        2 => "two",
        3 => "three",
        4 => "four",
        5 => "five",
        6 => "six",
        7 => "seven",
        8 => "eight",
        9 => "nine",
      }
      num_methods =
        Enum.map(int_to_word, fn {digit, string} ->
          digit_unicode =
            case "#{digit}" do
              <<val::utf8>> -> val
            end
          remaining_string = String.slice(string, 2..-1)
          quote do
            def get_ints(unquote(digit_unicode)) do
              [unquote(digit)]
            end
            def words_to_ints(unquote(string) <> rest) do
              [unquote(digit_unicode) | words_to_ints(unquote(remaining_string) <> rest)]
            end
          end
        end)
      extra_methods =
        quote do
          def get_ints(:break), do: [:break]
          def get_ints(_other), do: []
          def words_to_ints(<<first::utf8, rest::binary>>), do: [first | words_to_ints(rest)]
          def words_to_ints(""), do: []
          def process_acc(:break, {}), do: {[], {:break}}
          def process_acc(:break, {:break}), do: {[], {:break}}
          def process_acc(:break, {single}), do: {[Integer.undigits([single, single])], {:break}}
          def process_acc(:break, {first, second}), do: {[Integer.undigits([first, second])], {:break}}
          def process_acc(next, {:break}), do: {[], {next}}
          def process_acc(next, {value1}), do: {[], {value1, next}}
          def process_acc(next, {value1, _value2}), do: {[], {value1, next}}
        end
      num_methods ++ [extra_methods]
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
