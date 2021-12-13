import adventutils
import sequtils
import sets
import strutils

func toPoint(value: string): Point =
  let parts = value.split(',').map(parseInt)
  (x: parts[0], y: parts[1])

func fold(instruction: string, p: Point): Point =
  let
    parts = instruction.splitWhitespace[^1].split('=')
    value = parts[1].parseInt
  case parts[0]:
    of "x": return if p.x > value: (x: 2 * value - p.x, y: p.y) else: p
    of "y": return if p.y > value: (x: p.x, y: 2 * value - p.y) else: p
    else: discard

func process(input: seq[string]): seq[HashSet[Point]] =
  let parts = input.splitByEmptyLines
  result.add(parts[0].mapIt(it.toPoint).toHashSet)
  for instruction in parts[1]:
    result.add result[^1].foldl(a + [instruction.fold b].toHashSet, initHashSet[Point]())

func part1*(input: seq[string]): int = input.process[1].len

func part2*(input: seq[string]): seq[string] =
  let
    output = input.process[^1]
    max = output.foldl((x: max(a.x, b.x), y: max(a.y, b.y)), (x: 0, y: 0))
  toSeq(0 .. max.y).mapIt(toSeq(0 .. max.x).foldl(a & (if (b, it) in output: "8" else: " "), ""))
