import adventutils
import re
import sequtils
import strscans
import sugar
import tables

func levelPoints(line: (Point, Point)): seq[Point] =
  let (m, n) = line
  return if m.x == n.x: (min(m.y, n.y) .. max(m.y, n.y)).mapIt((x: m.x, y: it))
    elif m.y == n.y: (min(m.x, n.x) .. max(m.x, n.x)).mapIt((x: it, y: m.y))
    else: newSeq[Point]()

func allPoints(line: (Point, Point)): seq[Point] =
  let (m, n) = line
  return if m.x != n.x and m.y != n.y:
    let
      xDelta = func (x: int): int = (if m.x < n.x: x + 1 else: x - 1)
      yDelta = func (y: int): int = (if m.y < n.y: y + 1 else: y - 1)
      mapper = func (p: Point): Point = (x: p.x.xDelta, y: p.y.yDelta)
    (1 .. abs(m.x - n.x)).foldl(a & a[^1].mapper, @[m])
  else:
    line.levelPoints

func process(input: seq[string], mapper: ((Point, Point)) -> seq[Point]): int =
  input.mapIt(it.scanTuple("$i,$i -> $i,$i"))
    .mapIt(((x: it[1], y: it[2]), (x: it[3], y: it[4])))
    .foldl(a & b.mapper, newSeq[Point]())
    .toCountTable.pairs.toSeq.countIt(it[1] >= 2)

func part1*(input: seq[string]): int = input.process levelPoints

func part2*(input: seq[string]): int = input.process allPoints
