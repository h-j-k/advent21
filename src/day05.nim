import re
import sequtils
import strutils
import sugar
import tables

type Point = tuple[x: int, y: int]

type Line = tuple[a: Point, b: Point]

func parse(line: string): Line =
  var matches: array[4, string]
  if line.match(re"(\d+),(\d+) -> (\d+),(\d+)", matches):
    let values = matches.map(parseInt)
    return (a: (x: values[0], y: values[1]), b: (x: values[2], y: values[3]))

func levelPoints(line: Line): seq[Point] =
  let (m, n) = line
  return if m.x == n.x:
    toSeq(min(m.y, n.y) .. max(m.y, n.y)).map(y => (x: m.x, y: y))
  elif m.y == n.y:
    toSeq(min(m.x, n.x) .. max(m.x, n.x)).map(x => (x: x, y: m.y))
  else:
    newSeq[Point]()

func noPoints(line: Line): seq[Point] = newSeq[Point]()

func diagonalPoints(line: Line): seq[Point] =
  let (m, n) = line
  return if m.x != n.x and m.y != n.y:
    let mapper = func (p: Point): Point = (x: (if m.x < n.x: p.x + 1 else: p.x - 1), y: (if m.y < n.y: p.y + 1 else: p.y - 1))
    toSeq(1 .. abs(m.x - n.x)).foldl(a & a[^1].mapper, @[m])
  else:
    newSeq[Point]()

func process(input: seq[string], mapper: (Line) -> seq[Point]): int =
  input.map(parse).foldl(a.concat(b.levelPoints, b.mapper), newSeq[Point]())
      .toCountTable.pairs.toSeq.countIt(it[1] >= 2)

func part1*(input: seq[string]): int = input.process noPoints

func part2*(input: seq[string]): int = input.process diagonalPoints
