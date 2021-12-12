import adventutils
import algorithm
import sequtils
import sets
import sugar
import tables

func process(input: (IntGrid, int)): (IntGrid, int) =
  let grid = input[0]
  var
    flashed = 0
    newValues: Table[Point, int] = collect:
      for y in 0 ..< grid.len:
        for x in 0 ..< grid[0].len: {(x, y): grid[(x, y)] + 1}
  while newValues.pairs.toSeq.anyIt(it[1] > 9):
    for k in newValues.keys.toSeq.filter(p => newValues[p] > 9):
      flashed.inc
      newValues[k] = 0
      for p in k.adjacents(grid, true).filter(a => newValues[a] > 0): newValues[p] += 1
  (grid + newValues, input[1] + flashed)

func part1*(input: IntGrid): int = toSeq(1 .. 100).foldl(a.process, (input, 0))[1]

func part2*(input: IntGrid): int =
  var current = input
  while current.foldl(a & b, newSeq[int]()).toHashSet.len != 1:
    result.inc
    current = (current, 0).process[0]
