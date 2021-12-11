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

func chunkByEmptyLines*(input: seq[string]): seq[seq[string]] =
  let chunks = input.count("") + (if input[0] == "": 0 else: 1)
  input.distribute(chunks, false).map(c => c[1 ..< c.len])

func flip*(values: seq[string]): seq[string] = toSeq(0 ..< values[0].len).mapIt(values.foldl(a & b[it], ""))

func keyFor*[K, V](lookup: Table[K, V], value: V): K =
  for k, v in lookup:
    if v == value: return k

func withIndex*[T](values: seq[T]): seq[(int, T)] = toSeq(0 ..< values.len).zip values
