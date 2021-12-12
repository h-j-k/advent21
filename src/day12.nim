import sequtils
import std/[deques, sets]
import strutils
import sugar
import tables

func isBigCave(name: string): bool = name.items.toSeq.foldl(a and b.isUpperAscii, true)

func toMap(input: seq[string]): Table[string, HashSet[string]] =
  for line in input:
    let (x, y) = (line.split("-")[0], line.split("-")[1])
    if y != "start": result.mgetOrPut(x, initHashSet[string]()).incl(y)
    if x != "start": result.mgetOrPut(y, initHashSet[string]()).incl(x)

func process(input: seq[string], extraTest: (CountTable[string]) -> bool): int =
  let caves = input.toMap
  var deque = [("start", initCountTable[string]())].toDeque
  while deque.len > 0:
    let (last, lastSeen) = deque.popFirst
    if last == "end": result.inc else:
      var seen = lastSeen
      if not last.isBigCave: seen.inc(last)
      for c in caves[last].toSeq.filter(v => v.isBigCave or v notin seen or seen.extraTest): deque.addLast((c, seen))

func part1*(input: seq[string]): int = input.process(seen => false)

func part2*(input: seq[string]): int = input.process(seen => seen.values.toSeq.foldl(a + b, 0) == seen.len)
