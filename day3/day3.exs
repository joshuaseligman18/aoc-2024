defmodule Day3 do
  def solve_part1() do
    parse_input(~r/mul\(\d{1,3},\d{1,3}\)/) |>
      Enum.map(fn match -> Regex.scan(~r/\d{1,3}/, match) end)
      |> Enum.map(fn match_arr -> List.flatten(match_arr) end)
      |> Enum.map(fn [snum1 | [snum2]] -> [String.to_integer(snum1) | [String.to_integer(snum2)]] end)
      |> Enum.reduce(0, fn [num1 | [num2]], acc -> acc + num1 * num2 end)
  end

  def solve_part2() do
    parse_input(~r/(?:mul\(\d{1,3},\d{1,3}\))|(?:do\(\))|(?:don't\(\))/)
      |> Enum.reduce({0, true}, fn match, acc ->
          cond do
            Regex.match?(~r/mul\(\d{1,3},\d{1,3}\)/, match) && elem(acc, 1) -> 
              put_elem(
                acc,
                0,
                elem(acc, 0) + (
                  Regex.scan(~r/\d{1,3}/, match)
                    |> List.flatten
                    |> Enum.reduce(1, fn snum, local_acc -> local_acc * String.to_integer(snum) end)
                )
              )
            Regex.match?(~r/do\(\)/, match) -> put_elem(acc, 1, true)
            Regex.match?(~r/don't\(\)/, match) -> put_elem(acc, 1, false)
            true -> acc
          end
        end)
      |> elem(0)
  end

  defp parse_input(regex) do
    regex |> Regex.scan(File.read!("input.txt")) |> Enum.map(fn match -> hd(match) end)
  end
end

IO.puts Day3.solve_part1()
IO.puts Day3.solve_part2()
