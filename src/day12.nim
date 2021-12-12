import sequtils
import std/[deques, sets]
import strutils
import sugar
import tables

func isBigCave(name: string): bool = name.items.toSeq.allIt(it.isUpperAscii)

func toMap(input: seq[string]): Table[string, HashSet[string]] =
  for line in input:
    let (x, y) = (line.split("-")[0], line.split("-")[1])
    if y != "start": result.mgetOrPut(x, initHashSet[string]()).incl(y)
    if x != "start": result.mgetOrPut(y, initHashSet[string]()).incl(x)

func process(input: seq[string], extraTest: (CountTable[string]) -> bool): int =
  let caves = input.toMap
  var deque = [("start", newSeq[string](), initCountTable[string]())].toDeque
  while deque.len > 0:
    let (current, path, seen) = deque.popFirst
    if current == "end": result.inc else:
      var nextSeen = seen
      if not current.isBigCave: nextSeen.inc(current)
      for next in caves[current].toSeq.filter(v => v.isBigCave or v notin nextSeen or nextSeen.extraTest):
        deque.addLast((next, path & current, nextSeen))

func part1*(input: seq[string]): int = input.process(nextSeen => false)

func part2*(input: seq[string]): int = input.process(nextSeen => nextSeen.values.toSeq.allIt(it == 1))
