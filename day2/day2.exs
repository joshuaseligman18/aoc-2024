defmodule Day2 do
  def solve_part1() do
    parse_input() |> Enum.count(fn report -> is_safe(report) end)
  end

  def solve_part2() do
    parse_input() |> Enum.count(fn report -> is_safe2(report) end)
  end

  defp parse_input() do
    File.read!("input.txt")
      |> String.split("\n")
      |> Enum.map(fn row -> 
          String.split(row)
          |> Enum.map(fn data -> String.to_integer(data) end)
         end)
      |> Enum.reverse() |> tl()
  end

  defp get_dir(num1, num2) do
    diff = num2 - num1
    cond do
      diff > 0 && diff <= 3 -> :inc
      diff < 0 && diff >= -3 -> :dec
      true -> :none
    end
  end

  defp is_safe(the_list, dir \\ nil)
  defp is_safe([], _dir) do true end
  defp is_safe([_elem], _dir) do true end
  defp is_safe([num | rest], dir) do
    the_dir = get_dir(num, hd(rest))
    the_dir in [:inc, :dec] && (dir == nil || the_dir == dir) && is_safe(rest, the_dir)
  end

  defp is_safe2(the_list, dir \\ nil, has_removed_step \\ false)
  defp is_safe2([], _dir, _has_removed_step) do true end
  defp is_safe2([_elem], _dir, _has_removed_step) do true end
  defp is_safe2([prev | [num]], dir, has_removed_step) do
    the_dir = get_dir(prev, num)
    cond do
      dir == nil -> the_dir in [:inc, :dec]
      dir != nil -> the_dir in [:inc, :dec] || !has_removed_step
    end
  end
  defp is_safe2([prev | [num | rest]] = the_list, dir, has_removed_step) when dir == nil do
    dir1 = get_dir(prev, num)
    dir2 = get_dir(num, hd(rest))

    cond do
      dir1 in [:inc, :dec] && dir2 in [:inc, :dec] && dir1 == dir2 -> is_safe2(the_list, dir1, has_removed_step)
      dir1 in [:inc, :dec] && dir2 in [:inc, :dec] && dir1 != dir2 -> !has_removed_step && (is_safe2([num | rest], nil, true) || is_safe2([prev | rest], nil, true) || is_safe2([prev | [num | tl(rest)]], nil, true))
      dir1 == :none && dir2 in [:inc, :dec] -> !has_removed_step && (is_safe2([num | rest], nil, true) || is_safe2([prev | rest], nil, true))
      dir1 in [:inc, :dec] && dir2 == :none -> !has_removed_step && (is_safe2([prev | rest], nil, true) || is_safe2([prev | [num | tl(rest)]], nil, true))
      dir1 == :none && dir2 == :none -> false
    end
  end
  defp is_safe2([prev | [num | rest]], dir, has_removed_step) when dir != nil do
    dir1 = get_dir(prev, num)
    dir2 = get_dir(num, hd(rest))
    (dir1 == dir && dir2 == dir && is_safe2([num | rest], dir, has_removed_step)) ||
      (
        !has_removed_step &&
          (
            is_safe2([prev | rest], dir, true) ||
            is_safe2([prev | [num | tl(rest)]], dir, true)
          )
      )
  end
end

IO.puts Day2.solve_part1()
IO.puts Day2.solve_part2()
