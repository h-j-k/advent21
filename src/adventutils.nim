import sequtils
import sugar
import tables

type IntGrid* = seq[seq[int]]

type Point* = tuple[x: int, y: int]

func `[]`*(grid: IntGrid, p: Point): int = grid[p.y][p.x]

func `in`(p: Point, grid: IntGrid): bool = p.x in 0 ..< grid[0].len and p.y in 0 ..< grid.len

func adjacents*(p: Point, grid: IntGrid, hasCorners: bool): seq[Point] = collect:
  for dy in -1 .. 1:
    for dx in -1 .. 1:
      let p = (x: dx + p.x, y: dy + p.y)
      if p in grid and (dx, dy) != (0, 0) and (hasCorners or (dx * dy == 0)): p

func `+`*(grid: IntGrid, newValues: Table[Point, int]): IntGrid =
  result = grid
  for k, v in newValues:
    if k in grid: result[k.y][k.x] = v

func flip*(values: seq[string]): seq[string] = (0 ..< values[0].len).mapIt(values.foldl(a & b[it], ""))

func keyFor*[K, V](lookup: Table[K, V], value: V): K =
  for k, v in lookup:
    if v == value: return k

func splitByEmptyLines*(input: seq[string]): seq[seq[string]] =
  result.add(@[])
  for line in input:
    if line == "": result.add(@[]) else: result[^1].add(line)
  result.keepItIf(it.len > 0)

func withIndex*[T](values: seq[T]): seq[(int, T)] = toSeq(0 ..< values.len).zip values
