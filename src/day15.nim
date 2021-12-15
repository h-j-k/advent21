import adventutils
import heapqueue
import sequtils
import sugar
import tables

func `<`(a: (Point, int), b: (Point, int)): bool = a[1] < b[1]

func process(grid: IntGrid): int =
  let target = (x: grid[0].len - 1, y: grid.len - 1)
  var
    heapQueue = [((x: 0, y: 0), 0)].toHeapQueue
    seen = initCountTable[Point]()
  while heapQueue.len > 0:
    let (p, r) = heapQueue.pop
    if p == target: return r else:
      for a in p.adjacents(grid, false).filter(a => r + grid[a] < seen.getOrDefault(a, int.high)):
        seen[a] = r + grid[a]
        heapQueue.push (a, seen[a])

func part1*(input: IntGrid): int = input.process

func inc(row: seq[int]): seq[int] = row.foldl(a & (if b + 1 > 9: 1 else: b + 1), newSeq[int]())

func part2*(input: IntGrid): int =
  let row = input.mapIt((1 ..< 5).foldl(a & a[^1].inc, @[it]).concat)
  (1 ..< 5).foldl(a & a[^1].mapIt(it.inc), @[row]).concat.process
