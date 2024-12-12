defmodule Day11 do
  def solve_part1() do
    stones = parse_input()
    Enum.to_list(0..24)
      |> Enum.reduce(stones, fn _i, curStones -> blink(curStones) end)
      |> Enum.reduce(0, fn {_k, v}, acc ->  acc + v end)
  end

  def solve_part2() do
    stones = parse_input()
    Enum.to_list(0..74)
      |> Enum.reduce(stones, fn _i, curStones -> blink(curStones) end)
      |> Enum.reduce(0, fn {_k, v}, acc ->  acc + v end)
  end

  defp parse_input() do
    File.read!("input.txt")
      |> String.replace_trailing("\n", "")
      |> String.split(" ")
      |> Enum.reduce(%{}, fn num, acc ->
        Map.update(acc, num, 1, fn oldCount -> oldCount + 1 end)
      end)
  end

  defp blink(stones) do
    stones
      |> Enum.reduce(%{}, fn {stone, count}, acc ->
        stoneStr = to_string(stone)
        numDigits = String.length(stoneStr)
        newStoneMap = cond do
          stoneStr == "0" -> %{} |> Map.put("1", count)
          rem(numDigits, 2) == 0 ->
            halfNum = Integer.floor_div(numDigits, 2)
            {left, right} = String.split_at(stoneStr, halfNum)
            cleanRight = right |> String.to_integer() |> Integer.to_string()
            %{} |> Map.put(left, count) |> Map.update(cleanRight, count, fn oldCount -> oldCount + count end)
          true ->
            newKey = Integer.to_string(String.to_integer(stoneStr) * 2024)
            %{} |> Map.put(newKey, count)
        end
        Map.merge(acc, newStoneMap, fn _k, v1, v2 -> v1 + v2 end)
    end)
  end
end

IO.puts Day11.solve_part1()
IO.puts Day11.solve_part2()
