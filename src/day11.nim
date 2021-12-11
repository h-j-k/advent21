import adventutils
import algorithm
import sequtils
import std/[deques, sets]
import sugar
import tables

func process(input: (IntGrid, int)): (IntGrid, int) =
  let grid = input[0]
  var
    flashed = initHashSet[Point]()
    newValues: Table[Point, int] = collect:
      for y in 0 ..< grid.len:
        for x in 0 ..< grid[0].len: {(x, y): grid[(x, y)] + 1}
  while newValues.pairs.toSeq.anyIt(it[1] > 9 and not (it[0] in flashed)):
    for k in newValues.keys.toSeq.filter(p => newValues[p] > 9):
      if not flashed.containsOrIncl(k):
        for p in k.adjacents(grid, true): newValues[p] = newValues[p] + 1
  for p in flashed: newValues[p] = 0
  let newGrid = toSeq(0 ..< grid.len).foldl(
    a & newValues.pairs.toSeq.filterIt(it[0].y == b).sortedByIt(it[0].x).mapIt(it[1]),
    newSeq[seq[int]]()
  )
  (newGrid, input[1] + flashed.len)

func part1*(input: IntGrid): int = toSeq(1 .. 100).foldl(a.process, (input, 0))[1]

func part2*(input: IntGrid): int =
  var
    target = 0
    current = input
  while true:
    target.inc
    current = (current, 0).process[0]
    if current.foldl(a & b).toHashSet.len == 1: return target
