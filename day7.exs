defmodule CamelCards do
  defmodule Part1 do
    def process(map, ""), do: map
    def process(map, <<card::utf8, rest::binary>>) do
      Map.update(map, card, 1, fn x -> x + 1 end) |> process(rest)
    end
    def score(?2), do: 2
    def score(?3), do: 3
    def score(?4), do: 4
    def score(?5), do: 5
    def score(?6), do: 6
    def score(?7), do: 7
    def score(?8), do: 8
    def score(?9), do: 9
    def score(?T), do: 10
    def score(?J), do: 11
    def score(?Q), do: 12
    def score(?K), do: 13
    def score(?A), do: 14
    def is_better_hand?({value1, <<card1::utf8, rest1::binary>>, _}, {value2, <<card2::utf8, rest2::binary>>, _}) when value1 == value2 do
      cond do
        card1 == card2 -> is_better_hand?({value1, rest1, nil}, {value2, rest2, nil})
        true -> score(card1) > score(card2)
      end
    end
    def is_better_hand?({value1, _, _}, {value2, _, _}), do: value1 > value2
    def run(stream) do
      sorted =
        stream
        |> Stream.map(&String.split(&1, " "))
        |> Stream.map(fn [cards, num] ->
          {num, ""} = Integer.parse(num)
          value =
            process(%{}, cards)
            |> Enum.map(fn {_, v} -> v * v end)
            |> Enum.reduce(fn x, y -> x + y end)
          {value, cards, num}
        end)
        |> Enum.to_list()
        |> Enum.sort(&is_better_hand?/2)
        |> Enum.map(fn {_, _, num} -> num end)
      length = length(sorted)
      sorted |> Enum.with_index |> Enum.reduce(0, fn {num, idx}, acc ->
        num * (length - idx) + acc
      end)
    end
  end
  defmodule Part2 do
    def process(map, ""), do: map
    def process(map, <<card::utf8, rest::binary>>) do
      Map.update(map, card, 1, fn x -> x + 1 end) |> process(rest)
    end
    def score(?2), do: 2
    def score(?3), do: 3
    def score(?4), do: 4
    def score(?5), do: 5
    def score(?6), do: 6
    def score(?7), do: 7
    def score(?8), do: 8
    def score(?9), do: 9
    def score(?T), do: 10
    def score(?J), do: 1
    def score(?Q), do: 12
    def score(?K), do: 13
    def score(?A), do: 14
    def is_better_hand?({value1, <<card1::utf8, rest1::binary>>, _}, {value2, <<card2::utf8, rest2::binary>>, _}) when value1 == value2 do
      cond do
        card1 == card2 -> is_better_hand?({value1, rest1, nil}, {value2, rest2, nil})
        true -> score(card1) > score(card2)
      end
    end
    def is_better_hand?({value1, _, _}, {value2, _, _}), do: value1 > value2
    def upgrade(hand) do
      {jokers, hand} = Map.pop(hand, ?J, 0)
      {max, max_count} =
        hand
        |> Enum.reduce({0, 0}, fn {card, count}, {card_max, count_max} ->
          cond do
            count > count_max -> {card, count}
            count < count_max -> {card_max, count_max}
            score(card) > score(card_max) -> {card, count}
            true -> {card_max, count_max}
          end
        end)
      Map.put(hand, max, max_count + jokers)
    end
    def run(stream) do
      sorted =
        stream
        |> Stream.map(&String.split(&1, " "))
        |> Stream.map(fn [cards, num] ->
          {num, ""} = Integer.parse(num)
          value =
            process(%{}, cards)
            |> upgrade()
            |> Enum.map(fn {_, v} -> v * v end)
            |> Enum.reduce(fn x, y -> x + y end)
          {value, cards, num}
        end)
        |> Enum.to_list()
        |> Enum.sort(&is_better_hand?/2)
        |> Enum.map(fn {_, _, num} -> num end)
      length = length(sorted)
      sorted |> Enum.with_index |> Enum.reduce(0, fn {num, idx}, acc ->
        num * (length - idx) + acc
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

result_part1 = ReadInput.values_stream! |> CamelCards.Part1.run
result_part2 = ReadInput.values_stream! |> CamelCards.Part2.run

IO.puts("Result part 1: #{result_part1}")
IO.puts("Result part 2: #{result_part2}")
