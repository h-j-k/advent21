import adventutils
import algorithm
import sequtils
import std/[deques, sets]
import strutils
import sugar

func lowPoints(grid: IntGrid): seq[Point] =
  for y in 0 ..< grid.len:
    for x in 0 ..< grid[0].len:
      let p = (x, y)
      if p.adjacents(grid, false).all(a => grid[a] > grid[p]): result.add(p)

func part1*(input: IntGrid): int = input.lowPoints.foldl(a + input[b] + 1, 0)

func mapBasin(p: Point, grid: IntGrid): HashSet[Point] =
  var deque = [p].toDeque
  while deque.len > 0:
    let p = deque.popFirst
    if not result.containsOrIncl(p):
      for a in p.adjacents(grid, false).filter(a => grid[a] != 9): deque.addLast(a)

func part2*(input: IntGrid): int =
  input.lowPoints.mapIt(it.mapBasin(input).len).sorted[^3 .. ^1].foldl(a * b, 1)
