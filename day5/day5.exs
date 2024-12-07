defmodule Day5 do
  def solve_part1() do
    {rules, updates} = parse_input()
    updates |> Enum.filter(fn update -> is_valid_update(update, rules) end)
    |> Enum.map(fn update -> Enum.at(update, floor(length(update) / 2)) end)
    |> Enum.reduce(0, fn midPage, acc -> acc + midPage end)
  end

  def solve_part2() do
    {rules, updates} = parse_input()
    updates |> Enum.filter(fn update -> !is_valid_update(update, rules) end)
      |> Enum.map(fn update -> update |> Enum.sort(fn num1, num2 -> 
        the_rule = rules |> Enum.filter(fn rule -> elem(rule, 0) in [num1, num2] && elem(rule, 1) in [num1, num2] end)
          |> Enum.reduce(nil, fn rule, _acc -> rule end)
        the_rule == nil or elem(the_rule, 0) == num1
      end)
    end)
    |> Enum.map(fn update -> Enum.at(update, floor(length(update) / 2)) end)
    |> Enum.reduce(0, fn midPage, acc -> acc + midPage end)
  end

  defp parse_input() do
    {rules, updates} = File.read!("input.txt")
      |> String.split("\n")
      |> Enum.filter(fn row -> String.length(row) > 0 end)
      |> Enum.split_with(fn row -> String.contains?(row, "|") end)
    parsedRules = rules |> Enum.map(fn rule ->
      String.split(rule, "|")
        |> Enum.map(fn pageStr -> String.to_integer(pageStr) end)
        |> List.to_tuple()
    end)
    parsedUpdates = updates |> Enum.map(fn update ->
      String.split(update, ",")
        |> Enum.map(fn pageStr -> String.to_integer(pageStr) end)
    end)
    {parsedRules, parsedUpdates}
  end

  defp is_valid_update(update, rules) do
    Enum.to_list(0..(length(update) - 2))
      |> Enum.all?(fn index ->
        [page | rest] = Enum.slice(update, index..(length(update) - 1))
        !Enum.any?(rest, fn restPage ->
          Enum.any?(rules, fn rule -> elem(rule, 0) == restPage && elem(rule, 1) == page end)
        end)
      end)
  end
end

IO.puts Day5.solve_part1()
IO.puts Day5.solve_part2()
