import algorithm
import sequtils
import std/[deques, sets]
import strutils
import sugar

type Point = tuple[x: int, y: int]

func `[]`(mapping: seq[seq[int]], p: Point): int = mapping[p.y][p.x]

func adjacents(p: Point, height: int, width: int): seq[Point] = collect:
  for d in [(x: -1, y: 0), (x: 1, y: 0), (x: 0, y: -1), (x: 0, y: 1)]:
    if d.x + p.x in 0 ..< width and d.y + p.y in 0 ..< height: (x: d.x + p.x, y: d.y + p.y)

func process(input: seq[string]): (seq[Point], seq[seq[int]]) =
  let
    height = input.len
    width = input[0].len
    mapping = input.map(line => line.items.toSeq.mapIt(parseInt($it)))
  var lowPoints = newSeq[Point]()
  for y in 0 ..< height:
    for x in 0 ..< width:
      let p = (x, y)
      if p.adjacents(height, width).all(a => mapping[a] > mapping[p]): lowPoints.add(p)
  (lowPoints, mapping)

func part1*(input: seq[string]): int =
  let (lowPoints, mapping) = input.process
  lowPoints.foldl(a + mapping[b] + 1, 0)

func expand(p: Point, mapping: seq[seq[int]]): int =
  var
    deque = [p].toDeque
    seen = initHashSet[Point]()
  while deque.len > 0:
    let p = deque.popFirst
    if not seen.containsOrIncl(p):
      for a in p.adjacents(mapping.len, mapping[0].len).filter(a => mapping[a] != 9):
        deque.addLast(a)
  seen.len

func part2*(input: seq[string]): int =
  let (lowPoints, mapping) = input.process
  lowPoints.mapIt(it.expand mapping).sorted[^3 .. ^1].foldl(a * b, 1)
