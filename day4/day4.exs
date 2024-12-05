defmodule Day4 do
  def solve_part1() do
    input = parse_input()
    Enum.to_list(0..(length(input) - 1))
      |> Enum.map(fn index -> Enum.slice(input, index, 4) end)
      |> Enum.reduce(0, fn grid, acc -> 
          acc + count_horizontal(grid) + count_vertical(grid) + count_diagonal_right(grid) + count_diagonal_left(grid)
        end)
  end

  def solve_part2() do
    input = parse_input()
    Enum.to_list(0..(length(input) - 1))
      |> Enum.map(fn index -> Enum.slice(input, index, 3) end)
      |> Enum.filter(fn row -> length(row) == 3 end)
      |> Enum.reduce(0, fn grid, acc -> 
          acc + count_xmas(grid)
        end)
  end

  defp parse_input() do
    File.read!("input.txt") |> String.split("\n") |> Enum.reverse() |> tl() |> Enum.reverse()
  end

  defp count_horizontal(the_grid) do
    row = hd(the_grid)
    Enum.to_list(0..(String.length(row) - 1))
      |> Enum.map(fn index -> String.slice(row, index, 4) end)
      |> Enum.count(fn substr -> String.equivalent?(substr, "XMAS") || String.equivalent?(substr, "SAMX") end)
  end

  defp count_vertical(the_grid) do
    cond do
      length(the_grid) == 4 ->
        Enum.to_list(0..(String.length(hd(the_grid)) - 1))
          |> Enum.map(fn index ->
                Enum.map(the_grid, fn row ->
                  String.at(row, index)
                end)
                |> Enum.join()
              end)
          |> Enum.count(fn substr -> String.equivalent?(substr, "XMAS") || String.equivalent?(substr, "SAMX") end)
      true -> 0
    end
  end

  defp count_diagonal_right(the_grid) do
    cond do
      length(the_grid) == 4 ->
        Enum.to_list(0..(String.length(hd(the_grid)) - 4))
          |> Enum.map(fn index ->
              Enum.reduce(the_grid, {"", index}, fn row, acc -> 
                put_elem(acc, 0, elem(acc, 0) <> String.at(row, elem(acc, 1)))
                |> put_elem(1, elem(acc, 1) + 1)
              end)
              |> elem(0)
          end)
          |> Enum.count(fn substr -> String.equivalent?(substr, "XMAS") || String.equivalent?(substr, "SAMX") end)
      true -> 0
    end
  end

  defp count_diagonal_left(the_grid) do
    cond do
      length(the_grid) == 4 ->
        Enum.to_list(3..(String.length(hd(the_grid)) - 1))
          |> Enum.map(fn index ->
              Enum.reduce(the_grid, {"", index}, fn row, acc -> 
                put_elem(acc, 0, elem(acc, 0) <> String.at(row, elem(acc, 1)))
                |> put_elem(1, elem(acc, 1) - 1)
              end)
              |> elem(0)
          end)
          |> Enum.count(fn substr -> String.equivalent?(substr, "XMAS") || String.equivalent?(substr, "SAMX") end)
      true -> 0
    end
  end

  defp count_xmas(the_grid) do
    diag_right = Enum.to_list(0..(String.length(hd(the_grid)) - 3))
      |> Enum.map(fn index ->
          Enum.reduce(the_grid, {"", index}, fn row, acc -> 
            put_elem(acc, 0, elem(acc, 0) <> String.at(row, elem(acc, 1)))
            |> put_elem(1, elem(acc, 1) + 1)
          end)
          |> elem(0)
      end)
      |> Enum.map(fn substr -> String.equivalent?(substr, "MAS") || String.equivalent?(substr, "SAM") end)

    diag_left = Enum.to_list(0..(String.length(hd(the_grid)) - 3))
      |> Enum.map(fn index ->
          Enum.reduce(the_grid, {"", index + 2}, fn row, acc -> 
            put_elem(acc, 0, elem(acc, 0) <> String.at(row, elem(acc, 1)))
            |> put_elem(1, elem(acc, 1) - 1)
          end)
          |> elem(0)
      end)
      |> Enum.map(fn substr -> String.equivalent?(substr, "MAS") || String.equivalent?(substr, "SAM") end)

    Enum.zip(diag_left, diag_right)
      |> Enum.count(fn {left_res, right_res} -> left_res && right_res end)
  end
end

IO.puts Day4.solve_part1()
IO.puts Day4.solve_part2()
