defmodule Day7 do
  def solve_part1() do
    parse_input()
      |> Enum.filter(fn row -> is_valid1(elem(row, 0), elem(row, 1)) end)
      |> Enum.reduce(0, fn row, acc -> acc + elem(row, 0) end)
  end

  def solve_part2() do
    parse_input()
      |> Enum.filter(fn row -> is_valid2(elem(row, 0), elem(row, 1)) end)
      |> Enum.reduce(0, fn row, acc -> acc + elem(row, 0) end)
  end

  defp parse_input() do
    File.read!("input.txt")
      |> String.split("\n")
      |> Enum.reverse()
      |> tl()
      |> Enum.map(fn row -> 
        Regex.split(~r"(?::?\s)", row)
          |> Enum.map(fn data -> String.to_integer(data) end)
      end)
      |> Enum.map(fn row -> {hd(row), tl(row)} end)
  end

  defp is_valid1(target, list, acc \\ 0, isFirst \\ true) do
    cond do
      length(list) == 0 -> acc == target
      true -> is_valid1(target, tl(list), acc + hd(list), false) || (!isFirst && is_valid1(target, tl(list), acc * hd(list), false))
    end
  end

  defp is_valid2(target, list, acc \\ 0, isFirst \\ true) do
    cond do
      length(list) == 0 -> acc == target
      true ->
        is_valid2(target, tl(list), acc + hd(list), false) || 
        (is_valid2(target, tl(list), String.to_integer(Integer.to_string(acc) <> Integer.to_string(hd(list))), isFirst)) ||
        (!isFirst && is_valid2(target, tl(list), acc * hd(list), false))
    end
  end
end

IO.puts Day7.solve_part1()
IO.puts Day7.solve_part2()
