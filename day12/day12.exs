defmodule Day12 do
  def solve_part1() do
    garden = parse_input()
    visited = garden |> Enum.map(fn row -> row |> Enum.map(fn _plant -> false end) end)

    Enum.to_list(0..(length(garden) - 1))
      |> Enum.reduce({0, visited}, fn row, rowAcc ->
          colReduction = Enum.to_list(0..(length(garden) - 1)) |>
            Enum.reduce({0, elem(rowAcc, 1)}, fn col, colAcc ->
              {updatedVisitedMap, regionArea, regionPerimeter} = compute_region1(garden, elem(colAcc, 1), {row, col})
              {regionArea * regionPerimeter + elem(colAcc, 0), updatedVisitedMap}
            end)
          {elem(colReduction, 0) + elem(rowAcc, 0), elem(colReduction, 1)}
      end)
      |> elem(0)
  end

  def solve_part2() do
    garden = parse_input()
    visited = garden |> Enum.map(fn row -> row |> Enum.map(fn _plant -> false end) end)

    Enum.to_list(0..(length(garden) - 1))
      |> Enum.reduce({0, visited}, fn row, rowAcc ->
          colReduction = Enum.to_list(0..(length(garden) - 1)) |>
            Enum.reduce({0, elem(rowAcc, 1)}, fn col, colAcc ->
              {updatedVisitedMap, regionArea, rowFences, colFences} = compute_region2(garden, elem(colAcc, 1), {row, col})

              rowFences = rowFences
                |> Enum.sort(fn {row1, col1, dir1}, {row2, col2, dir2} ->
                  cond do
                    row1 < row2 -> true
                    row1 > row2 -> false
                    row1 == row2 -> cond do
                      dir1 < dir2 -> true
                      dir1 > dir2 -> false 
                      dir1 == dir2 -> col1 <= col2
                    end
                  end
                end)
                
              rowSides = rowFences
                |> Enum.with_index()
                |> Enum.filter(fn {{row, col, dir}, i} ->
                  cond do
                    i == length(rowFences) - 1 -> true
                    true ->
                      {nextRow, nextCol, nextDir} = rowFences |> Enum.at(i + 1)
                      row != nextRow || dir != nextDir || col + 1 != nextCol
                  end
                end)
                |> length()

              colFences = colFences
                |> Enum.sort(fn {row1, col1, dir1}, {row2, col2, dir2} ->
                  cond do
                    col1 < col2 -> true
                    col1 > col2 -> false
                    col1 == col2 -> cond do
                      dir1 < dir2 -> true
                      dir1 > dir2 -> false 
                      dir1 == dir2 -> row1 <= row2
                    end
                  end
                end)

              colSides = colFences
                |> Enum.with_index()
                |> Enum.filter(fn {{row, col, dir}, i} ->
                  cond do
                    i == length(colFences) - 1 -> true
                    true ->
                      {nextRow, nextCol, nextDir} = colFences |> Enum.at(i + 1)
                      col != nextCol || dir != nextDir || row + 1 != nextRow
                  end
                end)
                |> length()

              {regionArea * (rowSides + colSides) + elem(colAcc, 0), updatedVisitedMap}
            end)
          {elem(colReduction, 0) + elem(rowAcc, 0), elem(colReduction, 1)}
      end)
      |> elem(0)
  end

  defp parse_input() do
    File.read!("input.txt")
      |> String.split("\n")
      |> Enum.reverse()
      |> tl()
      |> Enum.reverse()
      |> Enum.map(fn row -> row |> String.split("") |> Enum.filter(fn ch -> ch != "" end) end)
  end

  defp compute_region1(garden, visitedMap, {row, col}, area \\ 0, perimeter \\ 0) do
    cond do
      visitedMap |> Enum.at(row) |> Enum.at(col) == true -> {visitedMap, area, perimeter}
      true ->
        updatedVisitedRow = visitedMap |> Enum.at(row) |> List.replace_at(col, true)
        updatedVisitedMap = visitedMap |> List.replace_at(row, updatedVisitedRow)
        updatedArea = area + 1
        updatedPerimeter = perimeter

        plant = garden |> Enum.at(row) |> Enum.at(col)
        
        {updatedVisitedMap, updatedArea, updatedPerimeter} = cond do
          row > 0 && garden |> Enum.at(row - 1) |> Enum.at(col) == plant ->
            compute_region1(garden, updatedVisitedMap, {row - 1, col}, updatedArea, updatedPerimeter)
          true -> {updatedVisitedMap, updatedArea, updatedPerimeter + 1}
        end

        {updatedVisitedMap, updatedArea, updatedPerimeter} = cond do
          row < length(garden) - 1 && garden |> Enum.at(row + 1) |> Enum.at(col) == plant ->
            compute_region1(garden, updatedVisitedMap, {row + 1, col}, updatedArea, updatedPerimeter)
          true -> {updatedVisitedMap, updatedArea, updatedPerimeter + 1}
        end

        {updatedVisitedMap, updatedArea, updatedPerimeter} = cond do
          col > 0 && garden |> Enum.at(row) |> Enum.at(col - 1) == plant ->
            compute_region1(garden, updatedVisitedMap, {row, col - 1}, updatedArea, updatedPerimeter)
          true -> {updatedVisitedMap, updatedArea, updatedPerimeter + 1}
        end

        {updatedVisitedMap, updatedArea, updatedPerimeter} = cond do
          col < length(garden |> Enum.at(row)) && garden |> Enum.at(row) |> Enum.at(col + 1) == plant ->
            compute_region1(garden, updatedVisitedMap, {row, col + 1}, updatedArea, updatedPerimeter)
          true -> {updatedVisitedMap, updatedArea, updatedPerimeter + 1}
        end

        {updatedVisitedMap, updatedArea, updatedPerimeter}
    end
  end

  defp compute_region2(garden, visitedMap, {row, col}, area \\ 0, rowFences \\ [], colFences \\ []) do
    cond do
      visitedMap |> Enum.at(row) |> Enum.at(col) == true -> {visitedMap, area, rowFences, colFences}
      true ->
        updatedVisitedRow = visitedMap |> Enum.at(row) |> List.replace_at(col, true)
        updatedVisitedMap = visitedMap |> List.replace_at(row, updatedVisitedRow)
        updatedArea = area + 1
        updatedRowFences = rowFences
        updatedColFences = colFences

        plant = garden |> Enum.at(row) |> Enum.at(col)
        
        {updatedVisitedMap, updatedArea, updatedRowFences, updatedColFences} = cond do
          row > 0 && garden |> Enum.at(row - 1) |> Enum.at(col) == plant ->
            compute_region2(garden, updatedVisitedMap, {row - 1, col}, updatedArea, updatedRowFences, updatedColFences)
          true -> {updatedVisitedMap, updatedArea, [{row - 1, col, :left} | updatedRowFences], updatedColFences}
        end

        {updatedVisitedMap, updatedArea, updatedRowFences, updatedColFences} = cond do
          row < length(garden) - 1 && garden |> Enum.at(row + 1) |> Enum.at(col) == plant ->
            compute_region2(garden, updatedVisitedMap, {row + 1, col}, updatedArea, updatedRowFences, updatedColFences)
          true -> {updatedVisitedMap, updatedArea, [{row + 1, col, :right} | updatedRowFences], updatedColFences}
        end

        {updatedVisitedMap, updatedArea, updatedRowFences, updatedColFences} = cond do
          col > 0 && garden |> Enum.at(row) |> Enum.at(col - 1) == plant ->
            compute_region2(garden, updatedVisitedMap, {row, col - 1}, updatedArea, updatedRowFences, updatedColFences)
          true -> {updatedVisitedMap, updatedArea, updatedRowFences, [{row, col - 1, :top} | updatedColFences]}
        end

        {updatedVisitedMap, updatedArea, updatedRowFences, updatedColFences} = cond do
          col < length(garden |> Enum.at(row)) && garden |> Enum.at(row) |> Enum.at(col + 1) == plant ->
            compute_region2(garden, updatedVisitedMap, {row, col + 1}, updatedArea, updatedRowFences, updatedColFences)
          true -> {updatedVisitedMap, updatedArea, updatedRowFences, [{row, col + 1, :bottom} | updatedColFences]}
        end

        {updatedVisitedMap, updatedArea, updatedRowFences, updatedColFences}
    end
  end
end

IO.puts Day12.solve_part1()
IO.puts Day12.solve_part2()
