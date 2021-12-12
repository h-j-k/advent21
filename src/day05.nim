import adventutils
import re
import sequtils
import strutils
import sugar
import tables

type Line = tuple[m: Point, n: Point]

func parse(line: string): Line =
  var matches: array[4, string]
  if line.match(re"(\d+),(\d+) -> (\d+),(\d+)", matches):
    let values = matches.map(parseInt)
    return (m: (x: values[0], y: values[1]), n: (x: values[2], y: values[3]))

func levelPoints(line: Line): seq[Point] =
  let (m, n) = line
  return if m.x == n.x:
    toSeq(min(m.y, n.y) .. max(m.y, n.y)).map(y => (x: m.x, y: y))
  elif m.y == n.y:
    toSeq(min(m.x, n.x) .. max(m.x, n.x)).map(x => (x: x, y: m.y))
  else:
    newSeq[Point]()

func allPoints(line: Line): seq[Point] =
  let (m, n) = line
  return if m.x != n.x and m.y != n.y:
    let
      xDelta = func (x: int): int =
        if m.x < n.x: x + 1 else: x - 1
      yDelta = func (y: int): int =
        if m.y < n.y: y + 1 else: y - 1
      mapper = func (p: Point): Point = (x: p.x.xDelta, y: p.y.yDelta)
    toSeq(1 .. abs(m.x - n.x)).foldl(a & a[^1].mapper, @[m])
  else:
    line.levelPoints

func process(input: seq[string], mapper: (Line) -> seq[Point]): int =
  input.map(parse).foldl(a & b.mapper, newSeq[Point]())
      .toCountTable.pairs.toSeq.countIt(it[1] >= 2)

func part1*(input: seq[string]): int = input.process levelPoints

func part2*(input: seq[string]): int = input.process allPoints
