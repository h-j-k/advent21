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
      for y in 0 ..< grid.len: (for x in 0 ..< grid[0].len: {(x, y): grid[(x, y)] + 1})
  while newValues.values.toSeq.anyIt(it > 9):
    for k in newValues.keys.toSeq.filter(p => newValues[p] > 9):
      flashed.inc
      newValues[k] = 0
      for a in k.adjacents(grid, true).filter(p => newValues[p] > 0): newValues[a] += 1
  (grid + newValues, input[1] + flashed)

func part1*(input: IntGrid): int = (1 .. 100).foldl(a.process, (input, 0))[1]

func part2*(input: IntGrid): int =
  var current = input
  while current.foldl(a & b, newSeq[int]()).toHashSet.len != 1:
    result.inc
    current = (current, 0).process[0]
