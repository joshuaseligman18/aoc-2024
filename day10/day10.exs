defmodule Day10 do
  def solve_part1() do
    {map, trailheads} = parse_input()
    Enum.reduce(trailheads, 0, fn trailhead, acc -> 
      acc + (get_peaks(trailhead, map) |> Enum.uniq() |> length())
    end)
  end

  def solve_part2() do
    {map, trailheads} = parse_input()
    Enum.reduce(trailheads, 0, fn trailhead, acc -> 
      acc + (get_peaks(trailhead, map) |> length())
    end)
  end

  defp parse_input() do
    input = File.read!("input.txt") |> String.split("\n") |> Enum.reverse() |> tl() |> Enum.reverse()
    input |> Enum.with_index() |> Enum.map_reduce([], fn {row, rowNum}, trailheads ->
      {cleanRow, rowTrailheads} = Enum.to_list(0..(String.length(row) - 1))
        |> Enum.map_reduce([], fn col, heads ->
          nodeHeight = String.at(row, col) |> String.to_integer()
          newHeads = cond do
            nodeHeight == 0 -> heads ++ [{rowNum, col}]
            true -> heads
          end
          {nodeHeight, newHeads}
        end)
      {cleanRow, trailheads ++ rowTrailheads}
    end)
  end

  defp get_peaks({row, col} = pos, map) do
    localHeight = get_height_by_position(pos, map)
    cond do
      localHeight == 9 -> [pos]
      true ->
        diffs = [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
        Enum.reduce(diffs, [], fn {dr, dc}, acc -> 
          neighborPos = {row + dr, col + dc}
          neighborHeight = get_height_by_position(neighborPos, map) 
          cond do
            neighborHeight == nil -> acc
            neighborHeight != localHeight + 1 -> acc
            true -> acc ++ get_peaks(neighborPos, map)
          end
        end)
    end
  end

  defp get_height_by_position({row, col}, map) do
    cond do
      row < 0 || row >= length(map) -> nil
      true ->
        theRow = Enum.at(map, row)
        cond do
          col < 0 || col >= length(theRow) -> nil
          true -> Enum.at(theRow, col)
        end
    end
  end
end

IO.puts Day10.solve_part1()
IO.puts Day10.solve_part2()
