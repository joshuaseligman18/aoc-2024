defmodule Day8 do
  def solve_part1() do
    {antenna_map, numRows, numCols} = parse_input()
    antenna_map |> Enum.reduce([], fn {_k, locations}, acc -> 
      acc ++ generate_antinode_list1(locations, numRows, numCols)
    end) |> Enum.uniq() |> length()
  end

  def solve_part2() do
    {antenna_map, numRows, numCols} = parse_input()
    antenna_map |> Enum.reduce([], fn {_k, locations}, acc -> 
      acc ++ generate_antinode_list2(locations, numRows, numCols)
    end) |> Enum.uniq() |> length()
  end

  defp parse_input() do
    input = File.read!("input.txt") |> String.split("\n") |> Enum.reverse() |> tl() |> Enum.reverse()
    antenna_map = Enum.to_list(0..(length(input) - 1))
      |> Enum.reduce(%{}, fn rowNum, acc ->
        row = Enum.at(input, rowNum)
        rowRes = Enum.to_list(0..(String.length(row) - 1))
          |> Enum.reduce(%{}, fn colNum, acc ->
            cond do
              Regex.match?(~r"(?:\d|[A-Za-z])", String.at(row, colNum)) ->
                acc |> Map.update(String.at(row, colNum), [{rowNum, colNum}], fn existing_value -> [{rowNum, colNum} | existing_value] end)
              true -> acc
            end
          end)
        acc |> Map.merge(rowRes, fn _k, v1, v2 -> v1 ++ v2 end)
      end)
    {antenna_map, length(input), String.length(Enum.at(input, 0))}
  end

  defp generate_antinode_list1(antennaList, numRows, numCols) do
    Enum.to_list(0..(length(antennaList) - 2))
      |> Enum.reduce([], fn antennaIndex, accRow ->
        {ar1, ac1} = Enum.at(antennaList, antennaIndex)
        accRow ++ (Enum.slice(antennaList, (antennaIndex + 1)..length(antennaList) - 1)
          |> Enum.reduce([], fn {ar2, ac2}, accCol ->
            dr = ar2 - ar1
            dc = ac2 - ac1
            antinode1 = {ar1 - dr, ac1 - dc}
            antinode2 = {ar2 + dr, ac2 + dc}

            accCol ++ (Enum.filter([antinode1, antinode2], fn antinode ->
              elem(antinode, 0) >= 0 && elem(antinode, 0) < numRows &&
              elem(antinode, 1) >= 0 && elem(antinode, 1) < numCols
            end))
          end))
      end)
      |> Enum.uniq()
  end

  defp generate_antinode_list2(antennaList, numRows, numCols) do
    Enum.to_list(0..(length(antennaList) - 2))
      |> Enum.reduce([], fn antennaIndex, accRow ->
        {ar1, ac1} = Enum.at(antennaList, antennaIndex)
        accRow ++ (Enum.slice(antennaList, (antennaIndex + 1)..length(antennaList) - 1)
          |> Enum.reduce([], fn {ar2, ac2}, accCol ->
            dr = ar2 - ar1
            dc = ac2 - ac1

            rowsFromA1 = Enum.to_list(ar1..0//-dr)
            rowsFromA2 = Enum.to_list(ar2..(numRows - 1)//dr)

            colsFromA1 = cond do
              dc >= 0 -> Enum.to_list(ac1..0//-dc)
              dc < 0 -> Enum.to_list(ac1..(numCols - 1)//-dc)
            end
            colsFromA2 = cond do
              dc >= 0 -> Enum.to_list(ac2..(numCols - 1)//dc)
              dc < 0 -> Enum.to_list(ac2..0//dc)
            end

            pointsFromA1 = Enum.zip(rowsFromA1, colsFromA1)
            pointsFromA2 = Enum.zip(rowsFromA2, colsFromA2)

            accCol ++ pointsFromA1 ++ pointsFromA2
          end))
      end)
      |> Enum.uniq()
  end
end

IO.puts Day8.solve_part1()
IO.puts Day8.solve_part2()
