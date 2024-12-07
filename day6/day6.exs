defmodule Day6 do
  def solve_part1() do
    {obstacles, startingPos, numRows, numCols} = parse_input()
    length(get_distinct_steps(startingPos, :up, obstacles, numRows, numCols))
  end

  def solve_part2() do
    {obstacles, startingPos, numRows, numCols} = parse_input()
    Enum.to_list(0..(numRows - 1))
    |> Enum.reduce(0, fn rowNum, acc -> 
      acc + (Enum.to_list(0..(numCols - 1))
        |> Task.async_stream(fn colNum -> 
          cond do
            !Enum.any?(obstacles, fn obstacle -> {rowNum, colNum} == obstacle end) && {rowNum, colNum} != startingPos ->
              is_loop(startingPos, :up, [{rowNum, colNum} | obstacles], numRows, numCols)
            true -> false
          end
        end)
        |> Enum.count(fn {:ok, res} -> res == true end)
    )
    end)
  end

  defp parse_input() do
    input = File.read!("input.txt") |> String.split("\n") |> Enum.reverse() |> tl() |> Enum.reverse()
    Enum.to_list(0..(length(input) - 1))
      |> Enum.reduce({[], nil}, fn rowNum, acc ->
        row = Enum.at(input, rowNum)
        rowRes = Enum.to_list(0..(String.length(row) - 1))
          |> Enum.reduce({[], nil}, fn colNum, acc ->
            cond do
              String.at(row, colNum) == "#" -> put_elem(acc, 0, [{rowNum, colNum} | elem(acc, 0)])
              String.at(row, colNum) == "^" -> put_elem(acc, 1, {rowNum, colNum})
              true -> acc
            end
          end)
        cond do
          elem(rowRes, 1) != nil ->
            put_elem(acc, 0, elem(acc, 0) ++ elem(rowRes, 0))
              |> put_elem(1, elem(rowRes, 1))
          elem(rowRes, 1) == nil ->
            put_elem(acc, 0, elem(acc, 0) ++ elem(rowRes, 0))
        end
      end)
      |> Tuple.append(length(input))
      |> Tuple.append(String.length(Enum.at(input, 0)))
  end

  defp get_distinct_steps(curPos, curDir, obstacles, numRows, numCols, pastSteps \\ []) do
    history = cond do
      !Enum.any?(pastSteps, fn step -> curPos == step end) -> [curPos | pastSteps]
      true -> pastSteps
    end

    next_step_out = next_step(curPos, curDir, obstacles, numRows, numCols)
    cond do
      next_step_out == nil -> history
      true -> get_distinct_steps(elem(next_step_out, 0), elem(next_step_out, 1), obstacles, numRows, numCols, history)
    end
  end

  defp is_loop(curPos, curDir, obstacles, numRows, numCols, pastSteps \\ []) do
    history = cond do
      !Enum.any?(pastSteps, fn step -> {curPos, curDir} == step end) -> [{curPos, curDir} | pastSteps]
      true -> nil
    end

    next_step_out = next_step(curPos, curDir, obstacles, numRows, numCols)
    cond do
      history == nil -> true
      next_step_out == nil -> false
      true -> is_loop(elem(next_step_out, 0), elem(next_step_out, 1), obstacles, numRows, numCols, history)
    end
  end

  defp next_step(pos, dir, obstacles, numRows, numCols) do
    cond do
      dir == :up ->
        if elem(pos, 0) == 0 do
          nil
        else
          nextPos = put_elem(pos, 0, elem(pos, 0) - 1)
          if Enum.any?(obstacles, fn obstacle -> nextPos == obstacle end) do
            {pos, :right}
          else
            {nextPos, dir}
          end
        end
      dir == :down ->
        if elem(pos, 0) == numRows - 1 do
          nil
        else
          nextPos = put_elem(pos, 0, elem(pos, 0) + 1)
          if Enum.any?(obstacles, fn obstacle -> nextPos == obstacle end) do
            {pos, :left}
          else
            {nextPos, dir}
          end
        end
      dir == :left ->
        if elem(pos, 1) == 0 do
          nil
        else
          nextPos = put_elem(pos, 1, elem(pos, 1) - 1)
          if Enum.any?(obstacles, fn obstacle -> nextPos == obstacle end) do
            {pos, :up}
          else
            {nextPos, dir}
          end
        end
      dir == :right ->
        if elem(pos, 1) == numCols - 1 do
          nil
        else
          nextPos = put_elem(pos, 1, elem(pos, 1) + 1)
          if Enum.any?(obstacles, fn obstacle -> nextPos == obstacle end) do
            {pos, :down}
          else
            {nextPos, dir}
          end
        end
    end
  end
end

IO.puts Day6.solve_part1()
IO.puts Day6.solve_part2()
