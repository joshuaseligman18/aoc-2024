defmodule Day1 do
  def solve_part1() do
    {left_list, right_list} = parse_input()
    Enum.zip_reduce(
      quicksort(left_list),
      quicksort(right_list),
      0,
      fn left_val, right_val, acc ->
        acc + abs(left_val - right_val)
      end
    )
  end

  def solve_part2() do
    {left_list, right_list} = parse_input()
    Enum.reduce(left_list, 0, fn left_val, acc ->
      acc + left_val * Enum.count(right_list, fn right_val -> left_val == right_val end)
    end)
  end

  defp parse_input() do
    file_input = File.read!("input.txt") |> String.split("\n")

    parsed_input = Enum.map(file_input, fn row -> 
      String.split(row) |> Enum.map(fn data -> String.to_integer(data) end) |> List.to_tuple()
    end) |> Enum.filter(fn row_data -> tuple_size(row_data) > 0 end)

    {
      Enum.map(parsed_input, fn row_data -> elem(row_data, 0) end),
      Enum.map(parsed_input, fn row_data -> elem(row_data, 1) end)
    }
  end

  # Wrote a (most likely inefficient) quicksort
  # instead of using Enum.sort to familiarize myself
  # with how functions work
  defp quicksort([]) do [] end
  defp quicksort([elem]) do [elem] end
  defp quicksort([pivot | rest]) do
    {left_pivot, right_pivot} = Enum.split_with(rest, fn elem -> elem < pivot end)
    quicksort(left_pivot) ++ [pivot] ++ quicksort(right_pivot)
  end
end

IO.puts(Day1.solve_part1())
IO.puts(Day1.solve_part2())
