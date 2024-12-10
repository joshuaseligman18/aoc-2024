defmodule Day9 do
  def solve_part1() do
    parse_input()
      |> convert_map_to_blocks()
      |> defragment_disk1()
      |> compute_checksum()
  end

  def solve_part2() do
    parse_input()
      |> defragment_disk2()
      |> compute_checksum()
  end

  defp parse_input() do
    File.read!("input.txt")
      |> String.split("\n")
      |> hd()
      |> String.split("")
      |> Enum.filter(fn c -> c != "" end)
      |> Enum.map(fn c -> String.to_integer(c) end)
  end

  defp convert_map_to_blocks(diskMap) do
    diskMap
      |> Enum.map_reduce({0, true}, fn mapElem, acc -> 
        cond do
          elem(acc, 1) ->
            blocks = List.duplicate(elem(acc, 0), mapElem)
            newAcc = {elem(acc, 0) + 1, false}
            {blocks, newAcc}
          !elem(acc, 1) ->
            blocks = List.duplicate(nil, mapElem)
            newAcc = {elem(acc, 0), true}
            {blocks, newAcc}
        end
      end)
      |> elem(0)
      |> List.flatten()
  end

  defp defragment_disk1(blocks) do
    blocks
      |> Enum.zip(Enum.to_list(0..(length(blocks) - 1)))
      |> Enum.map_reduce(length(blocks), fn {fileNum, index}, cutoff -> 
        cond do
          index >= cutoff -> {nil, cutoff}
          fileNum != nil -> {fileNum, cutoff}
          fileNum == nil ->
            rest = Enum.slice(blocks, (index + 1)..(cutoff - 1)) |> Enum.reverse()
            first = Enum.find_index(rest, fn elem -> elem != nil end) 
            cond do
              first == nil -> {nil, cutoff}
              first != nil ->
                newCutoff = cutoff - first - 1
                {Enum.at(blocks, newCutoff), newCutoff}
            end
        end
    end)
    |> elem(0)
  end

  defp defragment_disk2(input) do
    fileSizes = Enum.take_every(input, 2)
    gapSizes = Enum.take_every(tl(input), 2) ++ (if rem(length(input), 2) == 1 do [0] else [] end)

    Enum.zip(fileSizes, gapSizes)
      |> Enum.with_index()
      |> Enum.reduce({[], []}, fn {{fileSize, gapSize}, fileNum}, {disk, movedFiles} ->
        newDisk = cond do
          Enum.member?(movedFiles, fileNum) -> disk ++ List.duplicate(nil, fileSize)
          true -> disk ++ List.duplicate(fileNum, fileSize)
        end
        {moves, remainingSpace} = get_best_move(fileNum, fileSizes, gapSize, movedFiles) 
        filledGap = Enum.reduce(moves, [], fn movedFile, filledGap -> filledGap ++ List.duplicate(movedFile, Enum.at(fileSizes, movedFile)) end)
        filledGap = filledGap ++ List.duplicate(nil, remainingSpace)
        {newDisk ++ filledGap, movedFiles ++ moves}
      end)
      |> elem(0)
  end

  defp get_best_move(curFile, fileSizes, targetGapSize, movedFiles) do
    fileSizes
      |> Enum.with_index()
      |> Enum.reverse()
      |> Enum.reduce({[], targetGapSize}, fn {fileSize, fileNum}, {moves, remainingSpace} ->
        cond do
          fileNum > curFile && fileSize <= remainingSpace && !Enum.member?(movedFiles, fileNum) -> {moves ++ [fileNum], remainingSpace - fileSize}
          true -> {moves, remainingSpace}
        end
      end)
  end

  defp compute_checksum(blocks) do
    blocks
      |> Enum.zip(Enum.to_list(0..(length(blocks) - 1)))
      |> Enum.reduce(0, fn {fileNum, index}, acc -> 
        cond do
          fileNum == nil -> acc
          fileNum != nil -> acc + (fileNum * index)
        end
      end)
  end
end

IO.puts Day9.solve_part1()
IO.puts Day9.solve_part2()
